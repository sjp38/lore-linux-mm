Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C29B46B0005
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:48:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i10-v6so341380eds.19
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 04:48:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6-v6si882650edk.225.2018.06.26.04.48.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jun 2018 04:48:12 -0700 (PDT)
Date: Tue, 26 Jun 2018 13:48:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180626114810.ahxlfhcgpyyxcwof@quack2.suse.cz>
References: <0e6053b3-b78c-c8be-4fab-e8555810c732@nvidia.com>
 <20180619082949.wzoe42wpxsahuitu@quack2.suse.cz>
 <20180619090255.GA25522@bombadil.infradead.org>
 <20180619104142.lpilc6esz7w3a54i@quack2.suse.cz>
 <70001987-3938-d33e-11e0-de5b19ca3bdf@nvidia.com>
 <20180620120824.bghoklv7qu2z5wgy@quack2.suse.cz>
 <151edbf3-66ff-df0c-c1cc-5998de50111e@nvidia.com>
 <20180621163036.jvdbsv3t2lu34pdl@quack2.suse.cz>
 <20180625152150.jnf5suiubecfppcl@quack2.suse.cz>
 <550aacd3-cfea-c99a-3b60-563dd1621d5c@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <550aacd3-cfea-c99a-3b60-563dd1621d5c@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Mon 25-06-18 23:31:06, John Hubbard wrote:
> On 06/25/2018 08:21 AM, Jan Kara wrote:
> > On Thu 21-06-18 18:30:36, Jan Kara wrote:
> > So I think the Matthew's idea of removing pinned pages from LRU is
> > definitely worth trying to see how complex that would end up being. Did you
> > get to looking into it? If not, I can probably find some time to try that
> > out.
> > 
>  
> OK, so I looked into this some more.
> 
> As you implied in an earlier response, removing a page from LRU is
> probably the easy part. It's *keeping* it off the LRU that worries me. I
> looked at SetPageLRU() uses, there were only 5 call sites, and of those,
> I think only one might be difficult:
> 
>     __pagevec_lru_add()
> 
> It seems like the way to avoid __pagevec_lru_add() calls on these pages
> is to first call lru_add_drain_all, then remove the pages from LRU
> (presumably via isolate_page_lru). I think that should do it. But I'm a
> little concerned that maybe I'm overlooking something.
> 
> Here are the 5 search hits and my analysis. This may have mistakes in it,
> as I'm pretty new to this area, which is why I'm spelling it out:
> 
> 1. mm/memcontrol.c:2082: SetPageLRU(page); 
> 
>     This is in unlock_page_lru(). Caller: commit_charge(), and it's conditional on 
>     lrucare, so we can just skip it if the new page flag is set.

This is only used to move a page from one LRU list to another one -
lock_page_lru() removes page from current LRU and unlock_page_lru() places
it on the target one. And that all happens under lru_lock so we should not
see our pinned pages in this code if we protect ourselves with the lru_lock
as well. But probably worth adding VM_BUG_ON()...
 
> 2. mm/swap.c:831: SetPageLRU(page_tail);
>     This is in lru_add_page_tail(), which is only called by __split_huge_page_tail, and
>     there, we can also just skip the call for these pages.

This is of no concern as this gets called only when splitting huge page.
Extra page reference obtained by GUP prevents huge page splitting so this
code path cannot be executed for pinned pages. Maybe VM_BUG_ON() for
checking page really is not pinned.

> 3. mm/swap.c:866:  SetPageLRU(page);
>     This is in __pagevec_lru_add_fn (sole caller: __pagevec_lru_add), and is
>     discussed above.

Agreed that here we'll need to update __pagevec_lru_add_fn() to detect
pinned pages and avoid putting them to LRU.

> 4. mm/vmscan.c:1680: SetPageLRU(page);	
>     This is in putback_inactive_pages(), which I think won't get called unless
>     the page is already on an LRU.
>
> 5. mm/vmscan.c:1873: SetPageLRU(page);	//  (N/A)
>     This is in move_active_pages_to_lru(), which I also think won't get called unless 
>     the page is already on an LRU.

These two are correct. We just have to be careful about the cases where
page pinning races with reclaim handling these pages. But when we
transition the page to the 'pinned' state under lru_lock and remove it from
any list it is on, we should be safe against all the races with reclaim. We
just have to be careful to get all the accounting right when moving page to
the pinned state.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
