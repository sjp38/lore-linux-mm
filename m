Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l94FiVAd021218
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 01:44:31 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l94FkmpA101830
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 01:46:48 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l94Fgvg6008576
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 01:42:57 +1000
Message-ID: <470509F5.4010902@linux.vnet.ibm.com>
Date: Thu, 04 Oct 2007 21:12:45 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: VMA lookup with RCU
References: <46F01289.7040106@linux.vnet.ibm.com> <20070918205419.60d24da7@lappy>  <1191436672.7103.38.camel@alexis> <1191440429.5599.72.camel@lappy>
In-Reply-To: <1191440429.5599.72.camel@lappy>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Bharata B Rao <bharata@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
>>>     lookup in node local tree
>>>     if found, take read lock on local reference
>>>     if not-found, do global lookup, lock vma, take reference, 
>>>                   insert reference into local tree,
>>>                   take read lock on it, drop vma lock
>>>
>>> write lock on the vma would:
>>>     find the vma in the global tree, lock it
>>>     enqueue work items in a waitqueue that,
>>>       find the local ref, lock it (might sleep)
>>>       release the reference, unlock and clear from local tree
>>>       signal completion
>>>     once all nodes have completed we have no outstanding refs
>>>     and since we have the lock, we're exclusive.
> 
> void invalidate_vma_refs(void *addr)
> {
> 	BTREE_LOCK_CONTEXT(ctx, node_local_tree());
> 
> 	rcu_read_lock();
> 	ref = btree_find(node_local_tree, (unsigned long)addr);
> 	if (!ref)
> 		goto out_unlock;
> 
> 	down_write(&ref->lock); /* no more local refs */
> 	ref->dead = 1;
> 	atomic_dec(&ref->vma->refs); /* release */
> 	btree_delete(ctx, (unsigned long)addr); /* unhook */
> 	rcu_call(free_vma_ref, ref); /* destroy */
> 	up_write(&ref->lock);
> 
> out_unlock:
> 	rcu_read_unlock();
> }
> 
> struct vm_area_struct *
> write_lock_vma(struct mm *mm, unsigned long addr)
> {
> 	rcu_read_lock();
> 	vma = btree_find(&mm->btree, addr);
> 	if (!vma)
> 		goto out_unlock;
> 
> 	down_write(&vma->lock); /* no new refs */
> 	rcu_read_unlock();
> 
> 	schedule_on_each_cpu(invalidate_vma_refs, vma, 0, 1);
> 
> 	return vma;
> 
> out_unlock:
> 	rcu_read_unlock();
> 	return NULL;
> }
> 
> 

Hi Peter,

Making node local copies of VMA is a good idea to reduce inter-node
traffic, but the cost of search and delete is very high.  Also, as you have
pointed out, if the atomic operations happen on remote node due to
scheduler migrating our thread, then all the cycles saved may be lost.

In find_get_vma() cross node traffic is due to btree traversal or the
actual VMA object reference?  Can we look at duplicating the btree
structure per node and have VMA structures just one copy and make all
btrees in each node point to the same vma object.  This will make write
operation and deletion of btree entries on all nodes little simple.  All
VMA lists will be unique and not duplicated.

Another related idea is to move the VMA object to node local memory.  Can
we migrate the VMA object to the node where it is referenced the most?  We
still maintain only _one_ copy of VMA object.  No data duplication, but we
can move the memory around to make it node local.

Some more thoughts:

Pagefault handler does most of the find_get_vma() to validate user address
and then create page table entries (allocate page frames)... can we make
the page fault handler run on the node where the VMAs have been allocated?
 The CPU that has page-faulted need not necessarily do all the find_vma()
calls and update the page table.  The process can sleep while another CPU
_near_ to the memory containing VMAs and pagetable can do the job with
local memory references.

I don't know if the page tables for the faulting process is allocated in
node local memory.

Per CPU last vma cache:  Currently we have the last vma referenced in a one
entry cache in mm_struct.  Can we have this cache per CPU or per node so
that a multi threaded application can have node/cpu local cache of last vma
referenced.  This may reduce btree/rbtree traversal.  Let the hardware
cache maintain the corresponding VMA object and its coherency.

Please let me know your comment and thoughts.

Thanks,
Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
