Date: Wed, 30 Apr 2003 20:45:51 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] remove unnecessary PAE pgd set
Message-ID: <20030501034551.GB20911@holomorphy.com>
References: <3EB05F61.5070404@us.ibm.com> <20030501032215.GA20911@holomorphy.com> <3EB096D8.80905@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3EB096D8.80905@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> I suspect this set_pgd() should go away for non-PAE also.

On Wed, Apr 30, 2003 at 08:39:04PM -0700, Dave Hansen wrote:
> Wouldn't it be analogous to the PMD set with PAE on, and necessary?
> Since processes don't share PGDs in 4G mode, the PGD entry could be
> missing in a process's pagetables after the kernel ones have been filled
> in.  That set_pgd() will be necessary to move any new entry over.

Not really; it should just fall through to the pmd "level", which as
emulated should do all the instantiation needed for non-PAE.


On Wed, Apr 30, 2003 at 08:39:04PM -0700, Dave Hansen wrote:
> - a process does a vmalloc, which eventually calls pte_alloc_kernel()
> - pte_alloc_kernel() is always called with init_mm as its mm argument
> - pte_alloc_kernel() populates init_mm PGD entries with the new pte page
> - the process goes to use its new vmalloc'd area, and faults, because
>   its pgd doesn't have the same entries.  do_page_fault():vmalloc_fault
>   brings over the necessary entries from init, and the fault is handled

Sounds like a good plan to me.


On Wed, Apr 30, 2003 at 08:39:04PM -0700, Dave Hansen wrote:
> The other option is to hold mmlist_lock and populate the entries around
> when pte_alloc_kernel() is called.  The lazy way is better because not
> every process will go looking into the vmalloc area, _and_ and new pgds
> should be copied from the init one anyway, and inherit the PTE mapping.
>  The lazy update only needs to be done for processes when their PGDs
> were allocated in the past.

Yeah, that could get ugly. Best to keep things lazy.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
