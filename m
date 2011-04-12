Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D60268D003B
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 02:31:34 -0400 (EDT)
Date: Mon, 11 Apr 2011 23:33:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: convert vma->vm_flags to 64bit
Message-Id: <20110411233358.dd400e59.akpm@linux-foundation.org>
In-Reply-To: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

On Tue, 12 Apr 2011 15:10:56 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> Benjamin, Hugh, I hope to add your S-O-B to this one because you are original author. 
> Can I do?
> 
> Paul, Russell, This patch modifies arm and sh code a bit. I don't think
> they are risky change. but I'm really glad if you see it.
> 
> 
> Note: I confirmed x86, power and nommu-arm cross compiler build and
> I've got no warning/error.
> 
> 
> 
> >From d5a0d1c265e4caccb9ff5978c615f74019b65453 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 12 Apr 2011 14:00:42 +0900
> Subject: [PATCH] mm: convert vma->vm_flags to 64bit
> 
> For years, powerpc people repeatedly request us to convert vm_flags
> to 64bit. Because now it has no room to store an addional powerpc
> specific flags.
> 
> Here is previous discussion logs.
> 
> 	http://lkml.org/lkml/2009/10/1/202
> 	http://lkml.org/lkml/2010/4/27/23
> 
> But, unforunately they didn't get merged. This is 3rd trial.
> I've merged previous two posted patches and adapted it for
> latest tree.
> 
> Of cource, this patch has no functional change.

That's a bit sad, but all 32 bits are used up, so we'll presumably need
this change pretty soon anyway.

How the heck did we end up using 32 flags??

> @@ -217,7 +217,7 @@ vivt_flush_cache_range(struct vm_area_struct *vma, unsigned long start, unsigned
>  {
>  	if (cpumask_test_cpu(smp_processor_id(), mm_cpumask(vma->vm_mm)))
>  		__cpuc_flush_user_range(start & PAGE_MASK, PAGE_ALIGN(end),
> -					vma->vm_flags);
> +					(unsigned long)vma->vm_flags);
>  }

I'm surprised this change (and similar) are needed?

Is it risky?  What happens if we add yet another vm_flags bit and
__cpuc_flush_user_range() wants to use it?  I guess when that happens,
__cpuc_flush_user_range() needs to be changed to take a ull.

> -static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
> +static inline unsigned long long arch_calc_vm_prot_bits(unsigned long prot)
>  {
> -	return (prot & PROT_SAO) ? VM_SAO : 0;
> +	return (prot & PROT_SAO) ? VM_SAO : 0ULL;
>  }

The patch does a lot of adding "ULL" like this.  But I don't think any
of it is needed - won't the compiler do the right thing, without
warning?

> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -26,8 +26,8 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
>  	unsigned long s_end = sbase + PUD_SIZE;
>  
>  	/* Allow segments to share if only one is marked locked */
> -	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
> -	unsigned long svm_flags = svma->vm_flags & ~VM_LOCKED;
> +	unsigned long long vm_flags = vma->vm_flags & ~VM_LOCKED;
> +	unsigned long long svm_flags = svma->vm_flags & ~VM_LOCKED;

hm, on second thoughts it is safer to add the ULL when we're doing ~ on
the constants.

>  static inline int private_mapping_ok(struct vm_area_struct *vma)
>  {
> -	return vma->vm_flags & VM_MAYSHARE;
> +	return !!(vma->vm_flags & VM_MAYSHARE);
>  }

Fair enough.

> @@ -67,55 +67,55 @@ extern unsigned int kobjsize(const void *objp);
>  /*
>   * vm_flags in vm_area_struct, see mm_types.h.
>   */
> -#define VM_READ		0x00000001	/* currently active flags */
> -#define VM_WRITE	0x00000002
> -#define VM_EXEC		0x00000004
> -#define VM_SHARED	0x00000008
> +#define VM_READ		0x00000001ULL	/* currently active flags */
> +#define VM_WRITE	0x00000002ULL
> +#define VM_EXEC		0x00000004ULL
> +#define VM_SHARED	0x00000008ULL
>  
>  /* mprotect() hardcodes VM_MAYREAD >> 4 == VM_READ, and so for r/w/x bits. */
> -#define VM_MAYREAD	0x00000010	/* limits for mprotect() etc */
> -#define VM_MAYWRITE	0x00000020
> -#define VM_MAYEXEC	0x00000040
> -#define VM_MAYSHARE	0x00000080
> +#define VM_MAYREAD	0x00000010ULL	/* limits for mprotect() etc */
> +#define VM_MAYWRITE	0x00000020ULL
> +#define VM_MAYEXEC	0x00000040ULL
> +#define VM_MAYSHARE	0x00000080ULL
>  
> -#define VM_GROWSDOWN	0x00000100	/* general info on the segment */
> +#define VM_GROWSDOWN	0x00000100ULL	/* general info on the segment */
>  #if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
> -#define VM_GROWSUP	0x00000200
> +#define VM_GROWSUP	0x00000200ULL
>  #else
> -#define VM_GROWSUP	0x00000000
> -#define VM_NOHUGEPAGE	0x00000200	/* MADV_NOHUGEPAGE marked this vma */
> +#define VM_GROWSUP	0x00000000ULL
> +#define VM_NOHUGEPAGE	0x00000200ULL	/* MADV_NOHUGEPAGE marked this vma */
>  #endif
> -#define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
> -#define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
> +#define VM_PFNMAP	0x00000400ULL	/* Page-ranges managed without "struct page", just pure PFN */
> +#define VM_DENYWRITE	0x00000800ULL	/* ETXTBSY on write attempts.. */
>  
> -#define VM_EXECUTABLE	0x00001000
> -#define VM_LOCKED	0x00002000
> -#define VM_IO           0x00004000	/* Memory mapped I/O or similar */
> +#define VM_EXECUTABLE	0x00001000ULL
> +#define VM_LOCKED	0x00002000ULL
> +#define VM_IO           0x00004000ULL	/* Memory mapped I/O or similar */

A problem with this patch is that there might be unconverted code,
either in-tree or out-of-tree or soon-to-be-in-tree.  If that code
isn't 64-bit aware then we'll be adding subtle bugs which take a long
time to discover.

One way to detect those bugs nice and quickly might be to change some
of all of these existing constants so they use the upper 32-bits.  But that
will make __cpuc_flush_user_range() fail ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
