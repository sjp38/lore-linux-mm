Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2229B8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:06:56 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id p5-v6so11652487pfh.11
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 14:06:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z89-v6sor3282338pfi.24.2018.09.10.14.06.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 14:06:54 -0700 (PDT)
Date: Tue, 11 Sep 2018 07:06:45 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: How to handle PTE tables with non contiguous entries ?
Message-ID: <20180911070645.239aef8a@roar.ozlabs.ibm.com>
In-Reply-To: <ddc3bb56-4da0-c093-256f-185d4a612b5c@c-s.fr>
References: <ddc3bb56-4da0-c093-256f-185d4a612b5c@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 10 Sep 2018 14:34:37 +0000
Christophe Leroy <christophe.leroy@c-s.fr> wrote:

> Hi,
> 
> I'm having a hard time figuring out the best way to handle the following 
> situation:
> 
> On the powerpc8xx, handling 16k size pages requires to have page tables 
> with 4 identical entries.
> 
> Initially I was thinking about handling this by simply modifying 
> pte_index() which changing pte_t type in order to have one entry every 
> 16 bytes, then replicate the PTE value at *ptep, *ptep+1,*ptep+2 and 
> *ptep+3 both in set_pte_at() and pte_update().
> 
> However, this doesn't work because many many places in the mm core part 
> of the kernel use loops on ptep with single ptep++ increment.
> 
> Therefore did it with the following hack:
> 
>   /* PTE level */
> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
> +typedef struct { pte_basic_t pte, pte1, pte2, pte3; } pte_t;
> +#else
>   typedef struct { pte_basic_t pte; } pte_t;
> +#endif
> 
> @@ -181,7 +192,13 @@ static inline unsigned long pte_update(pte_t *p,
>          : "cc" );
>   #else /* PTE_ATOMIC_UPDATES */
>          unsigned long old = pte_val(*p);
> -       *p = __pte((old & ~clr) | set);
> +       unsigned long new = (old & ~clr) | set;
> +
> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
> +       p->pte = p->pte1 = p->pte2 = p->pte3 = new;
> +#else
> +       *p = __pte(new);
> +#endif
>   #endif /* !PTE_ATOMIC_UPDATES */
> 
>   #ifdef CONFIG_44x
> 
> 
> @@ -161,7 +161,11 @@ static inline void __set_pte_at(struct mm_struct 
> *mm, unsigned long addr,
>          /* Anything else just stores the PTE normally. That covers all 
> 64-bit
>           * cases, and 32-bit non-hash with 32-bit PTEs.
>           */
> +#if defined(CONFIG_PPC_8xx) && defined(CONFIG_PPC_16K_PAGES)
> +       ptep->pte = ptep->pte1 = ptep->pte2 = ptep->pte3 = pte_val(pte);
> +#else
>          *ptep = pte;
> +#endif
> 
> 
> 
> But I'm not too happy with it as it means pte_t is not a single type 
> anymore so passing it from one function to the other is quite heavy.
> 
> 
> Would someone have an idea of an elegent way to handle that ?

I can't think of anything better. Do we pass pte by value to a lot of
non inlined functions? Possible to inline the important ones?

Other option, try to get an iterator like pte = pte_next(pte) into core
code.

Thanks,
Nick
