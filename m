Message-ID: <3EB096D8.80905@us.ibm.com>
Date: Wed, 30 Apr 2003 20:39:04 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove unnecessary PAE pgd set
References: <3EB05F61.5070404@us.ibm.com> <20030501032215.GA20911@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Wed, Apr 30, 2003 at 04:42:25PM -0700, Dave Hansen wrote:
> 
>>With PAE on, there are only 4 PGD entries.  The kernel ones never
>>change, so there is no need to copy them when a vmalloc fault occurs.
>>This was this was causing problems with the split pmd patches, but it is
>>still correct for mainline.
>>Tested with and without PAE.  I ran it in a loop turning on and off 10
>>swap partitions, which is what excited the original bug.
>>http://bugme.osdl.org/show_bug.cgi?id=640
> 
> I suspect this set_pgd() should go away for non-PAE also.

Wouldn't it be analogous to the PMD set with PAE on, and necessary?
Since processes don't share PGDs in 4G mode, the PGD entry could be
missing in a process's pagetables after the kernel ones have been filled
in.  That set_pgd() will be necessary to move any new entry over.

- a process does a vmalloc, which eventually calls pte_alloc_kernel()
- pte_alloc_kernel() is always called with init_mm as its mm argument
- pte_alloc_kernel() populates init_mm PGD entries with the new pte page
- the process goes to use its new vmalloc'd area, and faults, because
  its pgd doesn't have the same entries.  do_page_fault():vmalloc_fault
  brings over the necessary entries from init, and the fault is handled

The other option is to hold mmlist_lock and populate the entries around
when pte_alloc_kernel() is called.  The lazy way is better because not
every process will go looking into the vmalloc area, _and_ and new pgds
should be copied from the init one anyway, and inherit the PTE mapping.
 The lazy update only needs to be done for processes when their PGDs
were allocated in the past.
-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
