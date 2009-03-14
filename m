Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EE45D6B003D
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 01:06:11 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Sat, 14 Mar 2009 16:06:03 +1100
References: <20090311170611.GA2079@elte.hu> <200903140309.39777.nickpiggin@yahoo.com.au> <200903141546.31139.nickpiggin@yahoo.com.au>
In-Reply-To: <200903141546.31139.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903141606.04450.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 14 March 2009 15:46:30 Nick Piggin wrote:

> Index: linux-2.6/arch/x86/mm/gup.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/gup.c	2009-03-14 02:48:06.000000000 +1100
> +++ linux-2.6/arch/x86/mm/gup.c	2009-03-14 02:48:12.000000000 +1100
> @@ -83,11 +83,14 @@ static noinline int gup_pte_range(pmd_t
>  		struct page *page;
>
>  		if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
> +failed:
>  			pte_unmap(ptep);
>  			return 0;
>  		}
>  		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>  		page = pte_page(pte);
> +		if (unlikely(!PageDontCOW(page)))
> +			goto failed;
>  		get_page(page);
>  		pages[*nr] = page;
>  		(*nr)++;

Ah, that's stupid, the test should be confined just to PageAnon 
&& !PageDontCOW pages, of course.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
