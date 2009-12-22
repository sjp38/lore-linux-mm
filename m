Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8E3D9620002
	for <linux-mm@kvack.org>; Tue, 22 Dec 2009 18:50:26 -0500 (EST)
Date: Wed, 23 Dec 2009 00:50:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH 00 of 28] Transparent Hugepage
 support #2]
Message-ID: <20091222235020.GH6429@random.random>
References: <20091218163058.GT29790@random.random>
 <20091218114236.e883671a.akpm@linux-foundation.org>
 <20091219160300.GB29790@random.random>
 <20091222153504.5ad9a16d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091222153504.5ad9a16d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Tue, Dec 22, 2009 at 03:35:04PM -0800, Andrew Morton wrote:
> : static void clear_huge_page(struct page *page,
> : 			unsigned long addr, unsigned long sz)
> : {
> : 	int i;
> : 
> : 	if (unlikely(sz > MAX_ORDER_NR_PAGES)) {
> : 		clear_gigantic_page(page, addr, sz);
> : 		return;
> : 	}
> : 
> : 	might_sleep();
> : 	for (i = 0; i < sz/PAGE_SIZE; i++) {
> : 		cond_resched();
> : 		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
> : 	}
> : }
> 
> umph.  So we've basically never executed the clear_user_highpage() loop.
> 
> Is there any point in retaining it?  Why not just call
> clear_gigantic_page() all the time, as we've been doing?  All it does
> it to avoid a call to mem_map_next() per clear_page().

My understanding is that not calling gigantic_page is faster by not
having to lookup zone changes, because compound pages created by the
buddy allocator are guaranteed to stay in the same zone or the buddy
couldn't return them. So we can just do page + i, if the compound
order is <= MAX_ORDER_NR_PAGES. It's probably lost in the noise by the
CPU waste of a 2M copy. I guess it's worth to retain given somebody
already bothered to optimize for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
