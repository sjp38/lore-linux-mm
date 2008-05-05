Date: Mon, 5 May 2008 17:57:20 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
In-Reply-To: <20080505121240.GD5018@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805051751230.11062@blonde.site>
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 5 May 2008, Nick Piggin wrote:
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -311,6 +311,37 @@ int __pte_alloc(struct mm_struct *mm, pm
>  	if (!new)
>  		return -ENOMEM;
>  
> +	/*
> +	 * Ensure all pte setup (eg. pte page lock and page clearing) are
> +	 * visible before the pte is made visible to other CPUs by being
> +	 * put into page tables.
> +	 *
> +	 * The other side of the story is the pointer chasing in the page
> +	 * table walking code (when walking the page table without locking;
> +	 * ie. most of the time). Fortunately, these data accesses consist
> +	 * of a chain of data-dependent loads, meaning most CPUs (alpha
> +	 * being the notable exception) will already guarantee loads are
> +	 * seen in-order. x86 has a "reference" implementation of
> +	 * smp_read_barrier_depends() barriers in its page table walking
> +	 * code, even though that barrier is a simple noop on that architecture.
> +	 * Alpha obviously also has the required barriers.
> +	 *
> +	 * It is debatable whether or not the smp_read_barrier_depends()
> +	 * barriers are required for kernel page tables; it could be that
> +	 * nowhere in the kernel do we walk those pagetables without taking
> +	 * init_mm's page_table_lock.

Just delete "; it could be that ... init_mm's page_table_lock":
in general (if not everywhere) the architectures do not nowadays
take init_mm's page_table_lock to walk down those pagetables (blame
me for removing it, if anyone thinks that was wrong: I stand by it).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
