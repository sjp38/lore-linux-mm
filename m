Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 635F4828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 23:56:24 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id q63so40012135pfb.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 20:56:24 -0800 (PST)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [125.16.236.5])
        by mx.google.com with ESMTPS id ym10si741321pac.41.2016.01.10.20.56.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 20:56:23 -0800 (PST)
Received: from localhost
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Jan 2016 10:26:21 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 44680394005A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 10:26:18 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0B4uHZe50528282
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 10:26:18 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0B4uEdO031315
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 10:26:16 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH next] powerpc/mm: fix _PAGE_PTE breaking swapoff
In-Reply-To: <alpine.LSU.2.11.1601091643060.9808@eggly.anvils>
References: <alpine.LSU.2.11.1601091643060.9808@eggly.anvils>
Date: Mon, 11 Jan 2016 10:26:10 +0530
Message-ID: <87si24u32t.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> Swapoff after swapping hangs on the G5.  That's because the _PAGE_PTE
> bit, added by set_pte_at(), is not expected by swapoff: so swap ptes
> cannot be recognized.
>
> I'm not sure whether a swap pte should or should not have _PAGE_PTE set:
> this patch assumes not, and fixes set_pte_at() to set _PAGE_PTE only on
> present entries.

One of the reason we added _PAGE_PTE is to enable HUGETLB migration. So
we want migratio ptes to have _PAGE_PTE set.

>
> But if that's wrong, a reasonable alternative would be to
> #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) & ~_PAGE_PTE })
> #define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
>

We do clear _PAGE_PTE bits, when converting swp_entry_t to type and
offset. Can you share the stack trace for the hang, which will help me
understand this more ? . 

> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>
>  arch/powerpc/mm/pgtable.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> --- 4.4-next/arch/powerpc/mm/pgtable.c	2016-01-06 11:54:01.477512251 -0800
> +++ linux/arch/powerpc/mm/pgtable.c	2016-01-09 13:51:15.793485717 -0800
> @@ -180,9 +180,10 @@ void set_pte_at(struct mm_struct *mm, un
>  	VM_WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
>  		(_PAGE_PRESENT | _PAGE_USER));
>  	/*
> -	 * Add the pte bit when tryint set a pte
> +	 * Add the pte bit when setting a pte (not a swap entry)
>  	 */
> -	pte = __pte(pte_val(pte) | _PAGE_PTE);
> +	if (pte_val(pte) & _PAGE_PRESENT)
> +		pte = __pte(pte_val(pte) | _PAGE_PTE);
>
>  	/* Note: mm->context.id might not yet have been assigned as
>  	 * this context might not have been activated yet when this

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
