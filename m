Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3EA16B0003
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 15:53:06 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id p41-v6so9116473oth.5
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 12:53:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n204-v6sor5137936oib.270.2018.06.17.12.53.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Jun 2018 12:53:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180617012510.20139-3-jhubbard@nvidia.com>
References: <20180617012510.20139-1-jhubbard@nvidia.com> <20180617012510.20139-3-jhubbard@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 17 Jun 2018 12:53:04 -0700
Message-ID: <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>

On Sat, Jun 16, 2018 at 6:25 PM,  <john.hubbard@gmail.com> wrote:
> From: John Hubbard <jhubbard@nvidia.com>
>
> This fixes a few problems that come up when using devices (NICs, GPUs,
> for example) that want to have direct access to a chunk of system (CPU)
> memory, so that they can DMA to/from that memory. Problems [1] come up
> if that memory is backed by persistence storage; for example, an ext4
> file system. I've been working on several customer bugs that are hitting
> this, and this patchset fixes those bugs.
>
> The bugs happen via:
>
> 1) get_user_pages() on some ext4-backed pages
> 2) device does DMA for a while to/from those pages
>
>     a) Somewhere in here, some of the pages get disconnected from the
>        file system, via try_to_unmap() and eventually drop_buffers()
>
> 3) device is all done, device driver calls set_page_dirty_lock(), then
>    put_page()
>
> And then at some point, we see a this BUG():
>
>     kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
>     backtrace:
>         ext4_writepage
>         __writepage
>         write_cache_pages
>         ext4_writepages
>         do_writepages
>         __writeback_single_inode
>         writeback_sb_inodes
>         __writeback_inodes_wb
>         wb_writeback
>         wb_workfn
>         process_one_work
>         worker_thread
>         kthread
>         ret_from_fork
>
> ...which is due to the file system asserting that there are still buffer
> heads attached:
>
>         ({                                                                  \
>                 BUG_ON(!PagePrivate(page));                     \
>                 ((struct buffer_head *)page_private(page));     \
>         })
>
> How to fix this:
> ----------------
> Introduce a new page flag: PG_dma_pinned, and set this flag on
> all pages that are returned by the get_user_pages*() family of
> functions. Leave it set nearly forever: until the page is freed.
>
> Then, check this flag before attempting to unmap pages. This will
> cause a very early return from try_to_unmap_one(), and will avoid
> doing things such as, notably, removing page buffers via drop_buffers().
>
> This uses a new struct page flag, but only on 64-bit systems.
>
> Obviously, this is heavy-handed, but given the long, broken history of
> get_user_pages in combination with file-backed memory, and given the
> problems with alternative designs, it's a reasonable fix for now: small,
> simple, and easy to revert if and when a more comprehensive design solution
> is chosen.
>
> Some alternatives, and why they were not taken:
>
> 1. It would be better, if possible, to clear PG_dma_pinned, once all
> get_user_pages callers returned the page (via something more specific than
> put_page), but that would significantly change the usage for get_user_pages
> callers. That's too intrusive for such a widely used and old API, so let's
> leave it alone.
>
> Also, such a design would require a new counter that would be associated
> with each page. There's no room in struct page, so it would require
> separate tracking, which is not acceptable for general page management.
>
> 2. There are other more complicated approaches[2], but these depend on
> trying to solve very specific call paths that, in the end, are just
> downstream effects of the root cause. And so these did not actually fix the
> customer bugs that I was working on.
>
> References:
>
> [1] https://lwn.net/Articles/753027/ : "The trouble with get_user_pages()"
>
> [2] https://marc.info/?l=linux-mm&m=<20180521143830.GA25109@bombadil.infradead.org>
>    (Matthew Wilcox listed two ideas here)
>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
[..]
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 6db729dc4c50..37576f0a4645 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1360,6 +1360,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>                                 flags & TTU_SPLIT_FREEZE, page);
>         }
>
> +       if (PageDmaPinned(page))
> +               return false;
>         /*
>          * We have to assume the worse case ie pmd for invalidation. Note that
>          * the page can not be free in this function as call of try_to_unmap()

We have a similiar problem with DAX and the conclusion we came to is
that it is not acceptable for userspace to arbitrarily block kernel
actions. The conclusion there was: 'wait' if the DMA is transient, and
'revoke' if the DMA is long lived, or otherwise 'block' long-lived DMA
if a revocation mechanism is not available.
