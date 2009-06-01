Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 426A26B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 04:05:27 -0400 (EDT)
Subject: Re: [rfc][patch] swap: virtual swap readahead
From: Andi Kleen <andi@firstfloor.org>
References: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org>
Date: Mon, 01 Jun 2009 10:05:22 +0200
In-Reply-To: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org> (Johannes Weiner's message of "Wed, 27 May 2009 17:05:46 +0200")
Message-ID: <87zlcscrb1.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> writes:
>
> This patch makes swap-in base its readaround window on the virtual
> proximity of pages in the faulting VMA, as an indicator for pages
> needed in the near future, while still taking physical locality of
> swap slots into account.

I think it's a good idea, something that needed fixing in Linux forever.

Now if we can only start swapping out in larger cluster too.

> +		if (swp_type(swp) != swp_type(entry))
> +			continue;
> +		/*
> +		 * Dont move the disk head too far away.  This also
> +		 * throttles readahead while thrashing, where virtual
> +		 * order diverges more and more from physical order.
> +		 */
> +		if (swp_offset(swp) > pmax)
> +			continue;
> +		if (swp_offset(swp) < pmin)
> +			continue;
> +		page = read_swap_cache_async(swp, gfp_mask, vma, pos);

It would be a good idea then to fix r_s_c_a() to pass down the VMA
and use alloc_page_vma() down below, so that NUMA Policy is preserved
over swapin. 

I originally tried this when I did the NUMA policy code, but then Hugh
pointed out it was useless because the prefetched pages are not
necessarily from this VMA anyways. With your virtual readahead it would
make sense again.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
