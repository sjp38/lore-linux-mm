Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k52FI7ts011095
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 2 Jun 2006 11:18:07 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k52FI656139458
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 2 Jun 2006 09:18:06 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k52FI5GA018739
	for <linux-mm@kvack.org>; Fri, 2 Jun 2006 09:18:05 -0600
Subject: Re: [PATCH] hugetlb: powerpc: Actively close unused htlb regions
	on vma close
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1149257287.9693.6.camel@localhost.localdomain>
References: <1149257287.9693.6.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 02 Jun 2006 08:17:32 -0700
Message-Id: <1149261452.16665.86.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-06-02 at 09:08 -0500, Adam Litke wrote:
>  #define HAVE_ARCH_UNMAPPED_AREA
>  #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
> +#define ARCH_HAS_HUGETLB_CLOSE_VMA
>  
>  #endif
>  
> diff -upN reference/include/linux/hugetlb.h
> current/include/linux/hugetlb.h
> --- reference/include/linux/hugetlb.h
> +++ current/include/linux/hugetlb.h
> @@ -85,6 +85,12 @@ pte_t huge_ptep_get_and_clear(struct mm_
>  void hugetlb_prefault_arch_hook(struct mm_struct *mm);
>  #endif
>  
> +#ifndef ARCH_HAS_HUGETLB_CLOSE_VMA
> +#define arch_hugetlb_close_vma(x)      0
> +#else
> +void arch_hugetlb_close_vma(struct vm_area_struct *vma);
> +#endif

Please don't do this ARCH_HAS stuff.  Use Kconfig at the very least.
You could also have an arch-specific htlb vma init function that could
be used for other things in the future. 

> @@ -297,7 +297,6 @@ void hugetlb_free_pgd_range(struct mmu_g
>         start = addr;
>         pgd = pgd_offset((*tlb)->mm, addr);
>         do {
> -               BUG_ON(! in_hugepage_area((*tlb)->mm->context, addr));
>                 next = pgd_addr_end(addr, end);
>                 if (pgd_none_or_clear_bad(pgd))
>                         continue;

Why does this BUG() go away?

> +/*
> + * Called when tearing down a hugetlb vma.  See if we can free up any
> + * htlb areas so normal pages can be mapped there again.
> + */
> +void arch_hugetlb_close_vma(struct vm_area_struct *vma)
> +{
> +       struct mm_struct *mm = vma->vm_mm;
> +       unsigned long i;
> +       struct slb_flush_info fi;
> +       u16 inuse, hiflush, loflush;
> +
> +       if (!mm)
> +               return;

Why is this check necessary?  Do kernel threads use vmas? ;)

> +       inuse = mm->context.low_htlb_areas;
> +       for (i = 0; i < NUM_LOW_AREAS; i++)
> +               if (prepare_low_area_for_htlb(mm, i) == 0)
> +                       inuse &= ~(1 << i);

Why check _all_ the areas?  Shouldn't the check just be for the current
VMA's area?  Also, prepare_low_area_for_htlb() is a pretty silly
function name, especially for its use here.  Especially because you are
tearing down a htlb area.  low_area_contains_vma() is a bit more apt.  

My first thought about what this function is that it should probably be
asking the question, "is the VMA that I'm closing right now that last
one in this segment?"

> +       loflush = inuse ^ mm->context.low_htlb_areas;
> +       mm->context.low_htlb_areas = inuse;

This bit fiddling should really be done in some helper functions.  It
isn't immediately and completely obvious what this is doing.  

> +       inuse = mm->context.high_htlb_areas;

Are you re-using "inuse"?  How about a different variable name for a
different use?

> +       for (i = 0; i < NUM_HIGH_AREAS; i++)
> +               if (prepare_high_area_for_htlb(mm, i) == 0)
> +                       inuse &= ~(1 << i);
> +       hiflush = inuse ^ mm->context.high_htlb_areas;
> +       mm->context.high_htlb_areas = inuse;

This, combined with the other loop, completely rebuild the mm->context's
view into htlb state, right?  Isn't that a bit excessive?

> +       /* the context changes must make it to memory before the flush,
> +        * so that further SLB misses do the right thing. */
> +       mb();
> +       fi.mm = mm;
> +       if ((fi.newareas = loflush))
> +               on_each_cpu(flush_low_segments, &fi, 0, 1);
> +       if ((fi.newareas = hiflush))
> +               on_each_cpu(flush_high_segments, &fi, 0, 1);
> +}

Yikes!  Think about a pathological program here.  It mmap()s 1 htlb
area, then unmaps it quickly, over and over.  What will that perform
like here?  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
