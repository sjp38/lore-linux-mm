Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id C137F6B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 14:47:27 -0400 (EDT)
Received: by mail-oi0-f54.google.com with SMTP id n80so11040441oig.1
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 11:47:27 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id w3si5683916obo.96.2016.03.25.11.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 11:47:26 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id h6so50094571oia.2
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 11:47:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	<1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
Date: Fri, 25 Mar 2016 11:47:26 -0700
Message-ID: <CAPcyv4iKK=1Nhz4QqEkhc4gum+UvUS4a=+Sza2zSa1Kyrth41w@mail.gmail.com>
Subject: Re: [PATCH 4/5] dax: use sb_issue_zerout instead of calling dax_clear_sectors
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, XFS Developers <xfs@oss.sgi.com>, linux-ext4 <linux-ext4@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Mar 24, 2016 at 4:17 PM, Vishal Verma <vishal.l.verma@intel.com> wrote:
> From: Matthew Wilcox <matthew.r.wilcox@intel.com>
>
> dax_clear_sectors() cannot handle poisoned blocks.  These must be
> zeroed using the BIO interface instead.  Convert ext2 and XFS to use
> only sb_issue_zerout().
>
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> [vishal: Also remove the dax_clear_sectors function entirely]
> Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
> ---
>  fs/dax.c               | 32 --------------------------------
>  fs/ext2/inode.c        |  7 +++----
>  fs/xfs/xfs_bmap_util.c |  9 ---------
>  include/linux/dax.h    |  1 -
>  4 files changed, 3 insertions(+), 46 deletions(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index bb7e9f8..a30481e 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -78,38 +78,6 @@ struct page *read_dax_sector(struct block_device *bdev, sector_t n)
>         return page;
>  }
>
> -/*
> - * dax_clear_sectors() is called from within transaction context from XFS,
> - * and hence this means the stack from this point must follow GFP_NOFS
> - * semantics for all operations.
> - */
> -int dax_clear_sectors(struct block_device *bdev, sector_t _sector, long _size)
> -{
> -       struct blk_dax_ctl dax = {
> -               .sector = _sector,
> -               .size = _size,
> -       };
> -
> -       might_sleep();
> -       do {
> -               long count, sz;
> -
> -               count = dax_map_atomic(bdev, &dax);
> -               if (count < 0)
> -                       return count;
> -               sz = min_t(long, count, SZ_128K);
> -               clear_pmem(dax.addr, sz);
> -               dax.size -= sz;
> -               dax.sector += sz / 512;
> -               dax_unmap_atomic(bdev, &dax);
> -               cond_resched();
> -       } while (dax.size);
> -
> -       wmb_pmem();
> -       return 0;
> -}
> -EXPORT_SYMBOL_GPL(dax_clear_sectors);

What about the other unwritten extent conversions in the dax path?
Shouldn't those be converted to block-layer zero-outs as well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
