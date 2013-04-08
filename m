Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 0467F6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 18:30:25 -0400 (EDT)
Date: Mon, 8 Apr 2013 15:30:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/1] mm: Another attempt to monitor task's memory
 changes
Message-Id: <20130408153024.4edbcb491f18c948adbe9fe8@linux-foundation.org>
In-Reply-To: <515F0484.1010703@parallels.com>
References: <515F0484.1010703@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@parallels.com>, Matthew Wilcox <willy@linux.intel.com>

On Fri, 05 Apr 2013 21:06:12 +0400 Pavel Emelyanov <xemul@parallels.com> wrote:

> Hello,
> 
> This is another attempt (previous one was [1]) to implement support for 
> memory snapshot for the the checkpoint-restore project (http://criu.org).
> Let me remind what the issue is.
> 
> << EOF
> To create a dump of an application(s) we save all the information about it
> to files, and the biggest part of such dump is the contents of tasks' memory.
> However, there are usage scenarios where it's not required to get _all_ the
> task memory while creating a dump. For example, when doing periodical dumps,
> it's only required to take full memory dump only at the first step and then
> take incremental changes of memory. Another example is live migration. We 
> copy all the memory to the destination node without stopping all tasks, then
> stop them, check for what pages has changed, dump it and the rest of the state,
> then copy it to the destination node. This decreases freeze time significantly.
> 
> That said, some help from kernel to watch how processes modify the contents
> of their memory is required. Previous attempt used ftrace to inform userspace
> about memory being written to. This one is different.
> 
> EOF

Did you consider teaching the kernel to perform a strong hash on a
page's contents so that userspace can do a before-and-after check to see
if it changed?

> The proposal is to introduce a soft dirty bit on pte (for x86 it's the same
> bit that is used by kmemcheck), that is set at the same time as the regular
> dirty bit is, but that can be cleared by hands.

How can it be used at the same time as kmemcheck?  Because one looks
only at kernel pages and the other only at user pages, perhaps?  This
question should be answered in a code comment in pgtable_types.h, please!

<looks>

erk, the whole feature is dependent on !KMEMCHECK.  That sucks quite a lot.

> It is cleared by writing "4"
> into the existing /proc/pid/clear_refs file.

clear_refs is documented in Documentation/filesystems/proc.txt ;)

> When soft dirty is cleared, the
> pte is also being write-protected to make #pf occur on next write and raise 
> the soft dirty bit again. Reading this bit is currently done via the
> /proc/pid/pagemap file. There's no bits left in there :( but there are 6
> effectively constant bits used for page-shift, so I (for RFC only) reuse the
> highest one of them, which is normally zero. Would it be OK to introduce the
> "pagemap2" file without this page-size constant?

It seems reasonable and natural to me.

> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -92,6 +92,11 @@ static inline int pte_dirty(pte_t pte)
>  	return pte_flags(pte) & _PAGE_DIRTY;
>  }
>  
> +static inline int pte_soft_dirty(pte_t pte)
> +{
> +	return pte_flags(pte) & _PAGE_SOFTDIRTY;
> +}

grumble.  Some symbols use "soft_dirty" and others use "softdirty". 
Please choose one and stick to it.

> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -688,10 +688,32 @@ const struct file_operations proc_tid_smaps_operations = {
>  	.release	= seq_release_private,
>  };
>  
> +#define CLEAR_REFS_ALL 1
> +#define CLEAR_REFS_ANON 2
> +#define CLEAR_REFS_MAPPED 3
> +#define CLEAR_REFS_SOFT_DIRTY 4

grumble.  Not your fault, but this would be better as

enum clear_refs_type {
	CLEAR_REFS_ALL,
	CLEAR_REFS_ANON,
	CLEAR_REFS_MAPPED,
	CLEAR_REFS_SOFT_DIRTY,
	CLEAR_REFS_LAST,
};
	
> +struct crefs_walk_priv {
> +	struct vm_area_struct *vma;
> +	int type;

And this has type enum clear_refs_type.

Once all this is done, we don't need to remember to edit

> -	if (type < CLEAR_REFS_ALL || type > CLEAR_REFS_MAPPED)
> +	if (type < CLEAR_REFS_ALL || type > CLEAR_REFS_SOFT_DIRTY)

each time we add a type.

> +};
> +
> +static inline void clear_soft_dirty(struct vm_area_struct *vma,
> +		unsigned long addr, pte_t *pte)
> +{
> +#ifdef CONFIG_MEM_SOFTDIRTY
> +	pte_t ptent = *pte;
> +	ptent = pte_wrprotect(ptent);
> +	ptent = pte_clear_flags(ptent, _PAGE_SOFTDIRTY);
> +	set_pte_at(vma->vm_mm, addr, pte, ptent);
> +#endif
> +}

I guess here would be as good a place as any at which to document the
whole feature.

>  static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  				unsigned long end, struct mm_walk *walk)
>  {
> -	struct vm_area_struct *vma = walk->private;
> +	struct crefs_walk_priv *cp = walk->private;
> +	struct vm_area_struct *vma = cp->vma;
>  	pte_t *pte, ptent;
>  	spinlock_t *ptl;
>  	struct page *page;
>
> ...
>
>  static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
> -					pmd_t pmd, int offset)
> +		pmd_t pmd, int offset, u64 pmd_flags)
>  {
>  	/*
>  	 * Currently pmd for thp is always present because thp can not be
> @@ -887,13 +921,13 @@ static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
>  	 */
>  	if (pmd_present(pmd))
>  		*pme = make_pme(PM_PFRAME(pmd_pfn(pmd) + offset)
> -				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT);
> +				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT | pmd_flags);
>  	else
>  		*pme = make_pme(PM_NOT_PRESENT);
>  }
>  #else
>  static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
> -						pmd_t pmd, int offset)
> +		pmd_t pmd, int offset, pagemap_entry_t pmd_flags)
>  {
>  }
>  #endif

One version of thp_pmd_to_pagemap_entry() uses "u64 pmd_flags" but the
other uses "pagemap_entry_t pmd_flags".  Can we unscrew that up?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
