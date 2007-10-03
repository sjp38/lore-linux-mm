Subject: Re: VMA lookup with RCU
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1191440429.5599.72.camel@lappy>
References: <46F01289.7040106@linux.vnet.ibm.com>
	 <20070918205419.60d24da7@lappy>  <1191436672.7103.38.camel@alexis>
	 <1191440429.5599.72.camel@lappy>
Content-Type: text/plain
Date: Wed, 03 Oct 2007 21:54:34 +0200
Message-Id: <1191441274.5574.1.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexis Bruemmer <alexisb@us.ibm.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-03 at 21:40 +0200, Peter Zijlstra wrote:
> On Wed, 2007-10-03 at 11:37 -0700, Alexis Bruemmer wrote:
> > Hi Peter,
> > 
> > Some colleagues and I have been looking at how best to implement
> > your latest suggestions for the VMA lookup with RCU patches, however we
> > have some questions:
> > 
> > <snip>
> > > My current plan for these patches is:
> > > 
> > > Fine grain lock the update side of the B+tree
> > > do a per-node vma reference, so that vma lookup and lock is:
> 
> > How did you envision the implementation here?  More specifically, what
> > is the best way to get local copies of B+trees on each node?
> 
> Don't copy the whole trees, just keep references to vma's locally. Saves
> a lot of traffic:
> 
> struct vm_area_struct {
> 
> 	...
> 
> 	struct rw_semaphore lock;
> 	atomic_t refs;
> };
> 
> struct vma_ref {
> 	struct vm_area_struct *vma;
> 	struct rw_semaphore lock;
> 	int dead;
> };
> 
> struct vma_ref *
> find_get_vma(struct mm_struct *mm, unsigned long addr)
> {
> 	struct vm_area_struct *vma;
> 	struct vma_ref *ref = NULL;
> 
> again:
> 	rcu_read_lock();
> 	vma = btree_find(&mm->btree, addr);
> 	if (!vma)
> 		goto out_unlock;
> 
> 	ref = btree_find(node_local_tree(), (unsigned long)vma);
> 	if (!ref) {
> 		BTREE_LOCK_CONTEXT(ctx, node_local_tree()); /* see fine grain locked RADIX tree */
> 
> 		down_read(&vma->lock);	
> 		if (atomic_read(&vma->refs) < 0) {
> 			/* vma got destroyed */
> 			up_read(&vma->lock);
> 			goto out_unlock;
> 		}
> 		atomic_inc(&vma->refs);
> 		rcu_read_unlock(); /* we got vma->lock, can't escape */
> 
> 		ref = kmalloc(sizeof(*ref), GFP_KERNEL);
> 		/* XXX: what to do when fails */
> 
> 		ref->vma = vma;
> 		init_rwsem(&ref->mutex);
> 		ref->dead = 0;
> 
> 		ret = btree_insert(ctx, (unsigned long)vma, ref);
> 
> 		if (ret = -EEXIST) {
> 			kfree(ref);
> 			goto again;
> 		}
> 	}
> 	
> 	down_read(&ref->lock);
> 	if (ref->dead) {
> 		up_read(&ref->lock);
> 		rcu_read_unlock();
> 		goto again;
> 	}
> 
> out_unlock:
> 	rcu_read_unlock();
> out:
> 	return ref;
> }


Hmm, biggest problem I now realize is that we can freely schedule
around, and the up_read() on ref->lock can happen from anywhere :-/

that will pretty much destroy all the good we got from the lookup
locality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
