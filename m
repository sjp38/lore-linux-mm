Subject: Re: VMA lookup with RCU
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1191436672.7103.38.camel@alexis>
References: <46F01289.7040106@linux.vnet.ibm.com>
	 <20070918205419.60d24da7@lappy>  <1191436672.7103.38.camel@alexis>
Content-Type: text/plain
Date: Wed, 03 Oct 2007 21:40:29 +0200
Message-Id: <1191440429.5599.72.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexis Bruemmer <alexisb@us.ibm.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-03 at 11:37 -0700, Alexis Bruemmer wrote:
> Hi Peter,
> 
> Some colleagues and I have been looking at how best to implement
> your latest suggestions for the VMA lookup with RCU patches, however we
> have some questions:
> 
> <snip>
> > My current plan for these patches is:
> > 
> > Fine grain lock the update side of the B+tree
> > do a per-node vma reference, so that vma lookup and lock is:

> How did you envision the implementation here?  More specifically, what
> is the best way to get local copies of B+trees on each node?

Don't copy the whole trees, just keep references to vma's locally. Saves
a lot of traffic:

struct vm_area_struct {

	...

	struct rw_semaphore lock;
	atomic_t refs;
};

struct vma_ref {
	struct vm_area_struct *vma;
	struct rw_semaphore lock;
	int dead;
};

struct vma_ref *
find_get_vma(struct mm_struct *mm, unsigned long addr)
{
	struct vm_area_struct *vma;
	struct vma_ref *ref = NULL;

again:
	rcu_read_lock();
	vma = btree_find(&mm->btree, addr);
	if (!vma)
		goto out_unlock;

	ref = btree_find(node_local_tree(), (unsigned long)vma);
	if (!ref) {
		BTREE_LOCK_CONTEXT(ctx, node_local_tree()); /* see fine grain locked RADIX tree */

		down_read(&vma->lock);	
		if (atomic_read(&vma->refs) < 0) {
			/* vma got destroyed */
			up_read(&vma->lock);
			goto out_unlock;
		}
		atomic_inc(&vma->refs);
		rcu_read_unlock(); /* we got vma->lock, can't escape */

		ref = kmalloc(sizeof(*ref), GFP_KERNEL);
		/* XXX: what to do when fails */

		ref->vma = vma;
		init_rwsem(&ref->mutex);
		ref->dead = 0;

		ret = btree_insert(ctx, (unsigned long)vma, ref);

		if (ret = -EEXIST) {
			kfree(ref);
			goto again;
		}
	}
	
	down_read(&ref->lock);
	if (ref->dead) {
		up_read(&ref->lock);
		rcu_read_unlock();
		goto again;
	}

out_unlock:
	rcu_read_unlock();
out:
	return ref;
}

Something like that, it got big holes in it, but should illustrate the
idea. We index the local reference by the vma address.

> >     lookup in node local tree
> >     if found, take read lock on local reference
> >     if not-found, do global lookup, lock vma, take reference, 
> >                   insert reference into local tree,
> >                   take read lock on it, drop vma lock
> >
> > write lock on the vma would:
> >     find the vma in the global tree, lock it
> >     enqueue work items in a waitqueue that,
> >       find the local ref, lock it (might sleep)
> >       release the reference, unlock and clear from local tree
> >       signal completion
> >     once all nodes have completed we have no outstanding refs
> >     and since we have the lock, we're exclusive.

void invalidate_vma_refs(void *addr)
{
	BTREE_LOCK_CONTEXT(ctx, node_local_tree());

	rcu_read_lock();
	ref = btree_find(node_local_tree, (unsigned long)addr);
	if (!ref)
		goto out_unlock;

	down_write(&ref->lock); /* no more local refs */
	ref->dead = 1;
	atomic_dec(&ref->vma->refs); /* release */
	btree_delete(ctx, (unsigned long)addr); /* unhook */
	rcu_call(free_vma_ref, ref); /* destroy */
	up_write(&ref->lock);

out_unlock:
	rcu_read_unlock();
}

struct vm_area_struct *
write_lock_vma(struct mm *mm, unsigned long addr)
{
	rcu_read_lock();
	vma = btree_find(&mm->btree, addr);
	if (!vma)
		goto out_unlock;

	down_write(&vma->lock); /* no new refs */
	rcu_read_unlock();

	schedule_on_each_cpu(invalidate_vma_refs, vma, 0, 1);

	return vma;

out_unlock:
	rcu_read_unlock();
	return NULL;
}


> Some general questions:
> How does a process and vma know what node it's on?

numa_node_id() ?

just return the ref object, and unlock against that.

> Also, as we discussed before the initial test results on the first set
> of these patches showed really no improvement in performance over the
> vanilla kernel.  What kind of performance gains to you predict with this
> new fine grain lock approach?

Really no idea, the write side is rather heavy, it would need to
invalidate (unsigned long)vma on all cpu's (perhaps track a cpumask of
cpu's that did take a reference). The advantage is that its per vma, not
per mm.

> Finally many local kernel hackers that I have spoke with about this idea
> have expressed great interest in your patch set.  Do you have any
> objections to opening this discussion up to linux-mm? 

done :-)

> Thank you again for your time and help,

no problem at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
