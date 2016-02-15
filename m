Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 274196B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:02:27 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id y8so67674394igp.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:02:27 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h19si40325933ioe.48.2016.02.14.21.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 21:02:26 -0800 (PST)
Date: Mon, 15 Feb 2016 16:01:33 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V2 09/29] powerpc/mm: Hugetlbfs is book3s_64 and
 fsl_book3e (32 or 64)
Message-ID: <20160215050133.GD3797@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1454923241-6681-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454923241-6681-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Feb 08, 2016 at 02:50:21PM +0530, Aneesh Kumar K.V wrote:
> We move large part of fsl related code to hugetlbpage-book3e.c.
> Only code movement. This also avoid #ifdef in the code.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

I am wondering why you are adding #ifdef CONFIG_PPC_FSL_BOOK3E
instances to hugetlbpage-book3e.c.  As far as I can tell from the
Kconfig* files, we only support hugetlbfs on book3s_64 and
fsl_book3e.  Yet it seems like we have provision for 64-bit processors
that are neither book3s_64 nor fsl_book3e.

So it seems that in this existing code:

> -static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
> -			   unsigned long address, unsigned pdshift, unsigned pshift)
> -{
> -	struct kmem_cache *cachep;
> -	pte_t *new;
> -
> -#ifdef CONFIG_PPC_FSL_BOOK3E
> -	int i;
> -	int num_hugepd = 1 << (pshift - pdshift);
> -	cachep = hugepte_cache;
> -#else
> -	cachep = PGT_CACHE(pdshift - pshift);
> -#endif
> -
> -	new = kmem_cache_zalloc(cachep, GFP_KERNEL|__GFP_REPEAT);
> -
> -	BUG_ON(pshift > HUGEPD_SHIFT_MASK);
> -	BUG_ON((unsigned long)new & HUGEPD_SHIFT_MASK);
> -
> -	if (! new)
> -		return -ENOMEM;
> -
> -	spin_lock(&mm->page_table_lock);
> -#ifdef CONFIG_PPC_FSL_BOOK3E
> -	/*
> -	 * We have multiple higher-level entries that point to the same
> -	 * actual pte location.  Fill in each as we go and backtrack on error.
> -	 * We need all of these so the DTLB pgtable walk code can find the
> -	 * right higher-level entry without knowing if it's a hugepage or not.
> -	 */
> -	for (i = 0; i < num_hugepd; i++, hpdp++) {
> -		if (unlikely(!hugepd_none(*hpdp)))
> -			break;
> -		else
> -			/* We use the old format for PPC_FSL_BOOK3E */
> -			hpdp->pd = ((unsigned long)new & ~PD_HUGE) | pshift;
> -	}
> -	/* If we bailed from the for loop early, an error occurred, clean up */
> -	if (i < num_hugepd) {
> -		for (i = i - 1 ; i >= 0; i--, hpdp--)
> -			hpdp->pd = 0;
> -		kmem_cache_free(cachep, new);
> -	}
> -#else
> -	if (!hugepd_none(*hpdp))
> -		kmem_cache_free(cachep, new);
> -	else {
> -#ifdef CONFIG_PPC_BOOK3S_64
> -		hpdp->pd = (unsigned long)new |
> -			    (shift_to_mmu_psize(pshift) << 2);
> -#else
> -		hpdp->pd = ((unsigned long)new & ~PD_HUGE) | pshift;

this last line here hasn't ended up anywhere and has effectively been
deleted.  Was that deliberate?

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
