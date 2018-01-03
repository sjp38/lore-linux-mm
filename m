Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A14856B02D3
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 19:11:21 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id g33so44276plb.13
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 16:11:21 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id o12si5528871pgq.755.2018.01.02.16.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jan 2018 16:11:20 -0800 (PST)
Message-ID: <1514938277.4018.18.camel@HansenPartnership.com>
Subject: Re: [PATCH] mm for mmotm: Revert skip swap cache feture for
 synchronous device
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 02 Jan 2018 16:11:17 -0800
In-Reply-To: <20180102235606.GA19438@bbox>
References: <1514508907-10039-1-git-send-email-minchan@kernel.org>
	 <20180102132214.289b725cf00ac07d91e8f60b@linux-foundation.org>
	 <1514932941.4018.12.camel@HansenPartnership.com>
	 <20180102235606.GA19438@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>, Jens Axboe <axboe@kernel.dk>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Huang Ying <ying.huang@intel.com>

On Wed, 2018-01-03 at 08:56 +0900, Minchan Kim wrote:
> On Tue, Jan 02, 2018 at 02:42:21PM -0800, James Bottomley wrote:
> > 
> > On Tue, 2018-01-02 at 13:22 -0800, Andrew Morton wrote:
> > > 
> > > On Fri, 29 Dec 2017 09:55:07 +0900 Minchan Kim <minchan@kernel.or
> > > g>
> > > wrote:
> > > 
> > > > 
> > > > 
> > > > James reported a bug of swap paging-in for his testing and
> > > > found it
> > > > at rc5, soon to be -rc5.
> > > > 
> > > > Although we can fix the specific problem at the moment, it may
> > > > have other lurkig bugs so want to have one more cycle in -next
> > > > before merging.
> > > > 
> > > > This patchset reverts 23c47d2ada9f, 08fa93021d80, 8e31f339295f
> > > > completely
> > > > but 79b5f08fa34e partially because the swp_swap_info function
> > > > that
> > > > 79b5f08fa34e introduced is used by [1].
> > > 
> > > Gets a significant reject in do_swap_page().A A Could you please
> > > take a
> > > look, redo against current mainline?
> > > 
> > > Or not.A A We had a bug and James fixed it.A A That's what -rc is
> > > for.A A Why not fix the thing and proceed?
> > 
> > My main worry was lack of testing at -rc5, since the bug could
> > essentially be excited by pushing pages out to swap and then trying
> > to
> > access them again ... plus since one serious bug was discovered it
> > wouldn't be unusual for there to be others. A However, because of
> > the
> > IPT stuff, I think Linus is going to take 4.15 over a couple of
> > extra
> > -rc releases, so this is less of a problem.
> 
> Then, Here is right fix patch against current mainline.
> 
> 
> From 012bdb0774744455ab7aa8abd74c8b9ca1cdc009 Mon Sep 17 00:00:00
> 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Wed, 3 Jan 2018 08:25:15 +0900
> Subject: [PATCH] mm: release locked page in do_swap_page
> 
> James reported a bug of swap paging-in for his testing. It is that
> do_swap_page doesn't release locked page so system hang-up happens
> by deadlock of PG_locked.
> 
> It was introduced by [1] because I missed swap cache hit places to
> update swapcache variable to work well with other logics against
> swapcache in do_swap_page.
> 
> This patch fixes it.
> 
> [1] 0bcac06f27d7, mm, swap: skip swapcache for swapin of synchronous
> device
> 
> Link: http://lkml.kernel.org/r/<1514407817.4169.4.camel@HansenPartner
> ship.com>;
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Debugged-by: James Bottomley <James.Bottomley@hansenpartnership.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> A mm/memory.c | 10 ++++++++--
> A 1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index ca5674cbaff2..793004608332 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2857,8 +2857,11 @@ int do_swap_page(struct vm_fault *vmf)
> A 	int ret = 0;
> A 	bool vma_readahead = swap_use_vma_readahead();
> A 
> -	if (vma_readahead)
> +	if (vma_readahead) {
> A 		page = swap_readahead_detect(vmf, &swap_ra);
> +		swapcache = page;
> +	}
> +
> A 	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf-
> >orig_pte)) {
> A 		if (page)
> A 			put_page(page);
> @@ -2889,9 +2892,12 @@ int do_swap_page(struct vm_fault *vmf)
> A 
> A 
> A 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> -	if (!page)
> +	if (!page) {
> A 		page = lookup_swap_cache(entry, vma_readahead ? vma
> : NULL,
> A 					A vmf->address);
> +		swapcache = page;
> +	}
> +

I've got to say I prefer my version. A The problem with the above is
that if something else gets added to this path and forgets to set
swapcache = page you'll get the locked pages problem back.

Instead of setting swapcache to NULL at the top, don't set it until it
matters, which is just before the second if (!page). A It doesn't matter
before this because you're using it as a signal for the synchronous I/O
path, so why have a whole section of code where you invite people to
get it wrong for no benefit.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
