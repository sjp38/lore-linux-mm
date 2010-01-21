Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A6A3C6B0078
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:43:38 -0500 (EST)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0LHXTKh030921
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:33:29 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0LHhajZ137352
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:43:36 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0LHhZDT010999
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:43:36 -0500
Subject: Re: [PATCH 04 of 30] clear compound mapping
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <bf7a027f8ee11d7230b5.1264054828@v2.random>
References: <patchbomb.1264054824@v2.random>
	 <bf7a027f8ee11d7230b5.1264054828@v2.random>
Content-Type: text/plain
Date: Thu, 21 Jan 2010 09:43:30 -0800
Message-Id: <1264095810.32717.34483.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-01-21 at 07:20 +0100, Andrea Arcangeli wrote:
> Clear compound mapping for anonymous compound pages like it already happens for
> regular anonymous pages.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -584,6 +584,8 @@ static void __free_pages_ok(struct page 
> 
>  	kmemcheck_free_shadow(page, order);
> 
> +	if (PageAnon(page))
> +		page->mapping = NULL;
>  	for (i = 0 ; i < (1 << order) ; ++i)
>  		bad += free_pages_check(page + i);
>  	if (bad)

This one may at least need a bit of an enhanced patch description.  I
didn't immediately remember that __free_pages_ok() is only actually
called for compound pages.

Would it make more sense to pull the page->mapping=NULL out of
free_hot_cold_page(), and just put a single one in __free_pages()?

I guess we'd also need one in free_compound_page() since it calls
__free_pages_ok() directly.  But, if this patch were putting modifying
free_compound_page() it would at least be super obvious what was going
on.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
