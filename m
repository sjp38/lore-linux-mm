Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C60068E0001
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 22:52:08 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so9429378pgt.11
        for <linux-mm@kvack.org>; Sun, 16 Dec 2018 19:52:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e63si9735870pgc.239.2018.12.16.19.52.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 16 Dec 2018 19:52:07 -0800 (PST)
Date: Sun, 16 Dec 2018 19:51:57 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
Message-ID: <20181217035157.GK10600@bombadil.infradead.org>
References: <20181204020840.49576-1-houtao1@huawei.com>
 <20181215143824.GJ10600@bombadil.infradead.org>
 <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <69457a5a-79c9-4950-37ae-eff7fa4f949a@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hou Tao <houtao1@huawei.com>
Cc: phillip@squashfs.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Sun, Dec 16, 2018 at 05:38:13PM +0800, Hou Tao wrote:
> Hi,
> 
> On 2018/12/15 22:38, Matthew Wilcox wrote:
> > On Tue, Dec 04, 2018 at 10:08:40AM +0800, Hou Tao wrote:
> >> There is no need to disable __GFP_FS in ->readpage:
> >> * It's a read-only fs, so there will be no dirty/writeback page and
> >>   there will be no deadlock against the caller's locked page
> >> * It just allocates one page, so compaction will not be invoked
> >> * It doesn't take any inode lock, so the reclamation of inode will be fine
> >>
> >> And no __GFP_FS may lead to hang in __alloc_pages_slowpath() if a
> >> squashfs page fault occurs in the context of a memory hogger, because
> >> the hogger will not be killed due to the logic in __alloc_pages_may_oom().
> > 
> > I don't understand your argument here.  There's a comment in
> > __alloc_pages_may_oom() saying that we _should_ treat GFP_NOFS
> > specially, but we currently don't.
> I am trying to say that if __GFP_FS is used in pagecache_get_page() when it tries
> to allocate a new page for squashfs, that will be no possibility of dead-lock for
> squashfs.
> 
> We do treat GFP_NOFS specially in out_of_memory():
> 
>     /*
>      * The OOM killer does not compensate for IO-less reclaim.
>      * pagefault_out_of_memory lost its gfp context so we have to
>      * make sure exclude 0 mask - all other users should have at least
>      * ___GFP_DIRECT_RECLAIM to get here.
>      */
>     if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
>         return true;
> 
> So if GFP_FS is used, no task will be killed because we will return from
> out_of_memory() prematurely. And that will lead to an infinite loop in
> __alloc_pages_slowpath() as we have observed:
> 
> * a squashfs page fault occurred in the context of a memory hogger
> * the page used for page fault allocated successfully
> * in squashfs_readpage() squashfs will try to allocate other pages
>   in the same 128KB block, and __GFP_NOFS is used (actually GFP_HIGHUSER_MOVABLE & ~__GFP_FS)
> * in __alloc_pages_slowpath() we can not get any pages through reclamation
>   (because most of memory is used by the current task) and we also can not kill
>   the current task (due to __GFP_NOFS), and it will loop forever until it's killed.

Ah, yes, that makes perfect sense.  Thank you for the explanation.

I wonder if the correct fix, however, is not to move the check for
GFP_NOFS in out_of_memory() down to below the check whether to kill
the current task.  That would solve your problem, and I don't _think_
it would cause any new ones.  Michal, you touched this code last, what
do you think?
