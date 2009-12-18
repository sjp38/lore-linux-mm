Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D88E6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:59:47 -0500 (EST)
Date: Fri, 18 Dec 2009 18:59:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 13 of 28] bail out gup_fast on freezed pmd
Message-ID: <20091218185934.GE21194@csn.ul.ie>
References: <patchbomb.1261076403@v2.random> <6cd9b035a6e0752ec74d.1261076416@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <6cd9b035a6e0752ec74d.1261076416@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 07:00:16PM -0000, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Force gup_fast to take the slow path and block if the pmd is freezed, not only
> if it's none.
> 

What does the slow path do when the same PMD is encountered? Assume it's
clear later but the set at the moment kinda requires you to understand
the entire series all at once.

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -156,7 +156,7 @@ static int gup_pmd_range(pud_t pud, unsi
>  		pmd_t pmd = *pmdp;
>  
>  		next = pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
>  			return 0;
>  		if (unlikely(pmd_large(pmd))) {
>  			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
