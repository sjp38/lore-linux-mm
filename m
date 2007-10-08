Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l98HC5JM025462
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 03:12:05 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l98HFcvb099270
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 03:15:38 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l98HBl3N008788
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 03:11:47 +1000
Message-ID: <470A64C8.1030801@linux.vnet.ibm.com>
Date: Mon, 08 Oct 2007 22:41:36 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: VMA lookup with RCU
References: <46F01289.7040106@linux.vnet.ibm.com> <20070918205419.60d24da7@lappy>  <1191436672.7103.38.camel@alexis> <1191440429.5599.72.camel@lappy>  <470509F5.4010902@linux.vnet.ibm.com> <1191518486.5574.24.camel@lappy>
In-Reply-To: <1191518486.5574.24.camel@lappy>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Bharata B Rao <bharata@in.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Thu, 2007-10-04 at 21:12 +0530, Vaidyanathan Srinivasan wrote:
>> Peter Zijlstra wrote:
>> Hi Peter,
>>
>> Making node local copies of VMA is a good idea to reduce inter-node
>> traffic, but the cost of search and delete is very high.  Also, as you have
>> pointed out, if the atomic operations happen on remote node due to
>> scheduler migrating our thread, then all the cycles saved may be lost.
>>
>> In find_get_vma() cross node traffic is due to btree traversal or the
>> actual VMA object reference? 
> 
> Not sure, I'm not sure how to profile cacheline transfers.

I asked around and found that oprofile can give cache misses.  But
associating it with find_get_vma() is the problem.

> The outlined approach would try to keep all accesses read-only, so that
> the cacheline can be shared. But yeah, once it get evicted it needs to
> be re-transfered.

>>  Can we look at duplicating the btree
>> structure per node and have VMA structures just one copy and make all
>> btrees in each node point to the same vma object.  This will make write
>> operation and deletion of btree entries on all nodes little simple.  All
>> VMA lists will be unique and not duplicated.
> 
> But that would end up with a 2d tree, (mm, vma) in which you can try to
> find an exact match for a given (mm, address) key.
> 
> Trouble with multi-dimensional trees is the balancing thing, afaik its
> an np-hard problem.

Not a good idea then :)

>> Another related idea is to move the VMA object to node local memory.  Can
>> we migrate the VMA object to the node where it is referenced the most?  We
>> still maintain only _one_ copy of VMA object.  No data duplication, but we
>> can move the memory around to make it node local.
> 
> I guess we can do that, is you take the vma lock in exclusive mode, you
> can make a copy of the object, replace the tree pointer, mark the old
> one dead (so that rcu lookups with re-try) and rcu_free the old one.

So worth a try. I will pick this up.

>> Some more thoughts:
>>
>> Pagefault handler does most of the find_get_vma() to validate user address
>> and then create page table entries (allocate page frames)... can we make
>> the page fault handler run on the node where the VMAs have been allocated?
> 
> explicit migration - like migrate_disable() - make load balancing a very
> hard problem.

>>  The CPU that has page-faulted need not necessarily do all the find_vma()
>> calls and update the page table.  The process can sleep while another CPU
>> _near_ to the memory containing VMAs and pagetable can do the job with
>> local memory references.
> 
> would we not end up with remote page tables?

Remote pagetable update is less costly than remote vma lookup.  We will
have to balance between the two.

>> I don't know if the page tables for the faulting process is allocated in
>> node local memory.
>>
>> Per CPU last vma cache:  Currently we have the last vma referenced in a one
>> entry cache in mm_struct.  Can we have this cache per CPU or per node so
>> that a multi threaded application can have node/cpu local cache of last vma
>> referenced.  This may reduce btree/rbtree traversal.  Let the hardware
>> cache maintain the corresponding VMA object and its coherency.
>>
>> Please let me know your comment and thoughts.
> 
> Nick Piggin (and I think Eric Dumazet) had nice patches for this. I
> think they were posted in the private futex thread.

Good.  I would like to try them out.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
