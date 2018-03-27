Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A64176B000A
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 17:31:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p128so138879pga.19
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 14:31:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31-v6sor920701plc.126.2018.03.27.14.30.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 14:30:59 -0700 (PDT)
Date: Tue, 27 Mar 2018 14:30:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 07/24] mm: VMA sequence count
In-Reply-To: <1520963994-28477-8-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803271429230.36401@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-8-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> diff --git a/mm/mmap.c b/mm/mmap.c
> index faf85699f1a1..5898255d0aeb 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -558,6 +558,10 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
>  	else
>  		mm->highest_vm_end = vm_end_gap(vma);
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	seqcount_init(&vma->vm_sequence);
> +#endif
> +
>  	/*
>  	 * vma->vm_prev wasn't known when we followed the rbtree to find the
>  	 * correct insertion point for that vma. As a result, we could not
> @@ -692,6 +696,30 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	long adjust_next = 0;
>  	int remove_next = 0;
>  
> +	/*
> +	 * Why using vm_raw_write*() functions here to avoid lockdep's warning ?
> +	 *
> +	 * Locked is complaining about a theoretical lock dependency, involving
> +	 * 3 locks:
> +	 *   mapping->i_mmap_rwsem --> vma->vm_sequence --> fs_reclaim
> +	 *
> +	 * Here are the major path leading to this dependency :
> +	 *  1. __vma_adjust() mmap_sem  -> vm_sequence -> i_mmap_rwsem
> +	 *  2. move_vmap() mmap_sem -> vm_sequence -> fs_reclaim
> +	 *  3. __alloc_pages_nodemask() fs_reclaim -> i_mmap_rwsem
> +	 *  4. unmap_mapping_range() i_mmap_rwsem -> vm_sequence
> +	 *
> +	 * So there is no way to solve this easily, especially because in
> +	 * unmap_mapping_range() the i_mmap_rwsem is grab while the impacted
> +	 * VMAs are not yet known.
> +	 * However, the way the vm_seq is used is guarantying that we will
> +	 * never block on it since we just check for its value and never wait
> +	 * for it to move, see vma_has_changed() and handle_speculative_fault().
> +	 */
> +	vm_raw_write_begin(vma);
> +	if (next)
> +		vm_raw_write_begin(next);
> +
>  	if (next && !insert) {
>  		struct vm_area_struct *exporter = NULL, *importer = NULL;
>  

Eek, what about later on:

		/*
		 * Easily overlooked: when mprotect shifts the boundary,
		 * make sure the expanding vma has anon_vma set if the
		 * shrinking vma had, to cover any anon pages imported.
		 */
		if (exporter && exporter->anon_vma && !importer->anon_vma) {
			int error;

			importer->anon_vma = exporter->anon_vma;
			error = anon_vma_clone(importer, exporter);
			if (error)
				return error;
		}

This needs

if (error) {
	if (next && next != vma)
		vm_raw_write_end(next);
	vm_raw_write_end(vma);
	return error;
}
