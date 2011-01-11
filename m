Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C92E06B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 18:00:20 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p0BN0GZc031439
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 15:00:16 -0800
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by hpaq2.eem.corp.google.com with ESMTP id p0BMxxP2021168
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 15:00:15 -0800
Received: by pwj9 with SMTP id 9so11472pwj.35
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 14:59:58 -0800 (PST)
Date: Tue, 11 Jan 2011 14:59:43 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm] thp: transparent hugepage core fixlet
In-Reply-To: <20110111163120.GR9506@random.random>
Message-ID: <alpine.LSU.2.00.1101111318190.26539@sister.anvils>
References: <alpine.LSU.2.00.1101101652200.11559@sister.anvils> <20110111015742.GL9506@random.random> <AANLkTin=gzZuDBMdGmR5ZY_9f6kggvt0KJA3XK33-z+2@mail.gmail.com> <20110111140421.GM9506@random.random> <20110111163120.GR9506@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Jeremy Fitzhardinge <jeremy@goop.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011, Andrea Arcangeli wrote:
> On Tue, Jan 11, 2011 at 03:04:21PM +0100, Andrea Arcangeli wrote:
> > architectural bug to me. Why can't pud_huge simply return 0 for
> > x86_32? Any other place dealing with hugepages and calling pud_huge on
> > x86 noPAE would be at risk, otherwise, no?
> 
> Isn't this better solution?

[Better solution than my patch to follow_page() in mmotm, to fix crash
with Transparent Huge Pages by duplicating Andrea's pmd_huge VM_HUGETLB
check to the pud_huge line too.]

The truth is, I'm sure one of the solutions is better than the other,
but I'm too confused by p?d folding to know which is which ;)

Certainly I don't oppose your patch as a replacement for mine,
if you're sure yours is better.

There are only two places which are using pud_huge() anyway:
follow_page() and apply_to_pmd_range().  Is the latter's
BUG_ON(pud_huge) safe?  Safe in the THP world?

And I never quite understood why we have both pmd_huge and pmd_large,
pud_huge and pud_large.

There are answers to these questions, but it would take me hours and
hours of easily-confused research (across several arches) to decide.

I'm hoping someone else has a surer grasp: Andi introduced pud_huge(),
and Jeremy is the most active in the pagetable layers nowadays -
perhaps they can tell us more quickly.

Hugh

> 
> ======
> Subject: avoid confusing hugetlbfs code when pmd_trans_huge is set
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> If pmd is set huge by THP, pud_huge shouldn't return 1 when pud doesn't exist
> and it's just a 1:1 bypass over the pmd (like it happens on 32bit x86 because
> there are at most 2 or 3 level of pagetables). Only pmd_huge can return 1.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -227,7 +227,15 @@ int pmd_huge(pmd_t pmd)
>  
>  int pud_huge(pud_t pud)
>  {
> +#ifdef CONFIG_X86_64
>  	return !!(pud_val(pud) & _PAGE_PSE);
> +#else
> +	/*
> +	 * pud is a bypass with 2 or 3 level pagetables, only pmd_huge
> +	 * can return 1.
> +	 */
> +	return 0;
> +#endif
>  }
>  
>  struct page *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
