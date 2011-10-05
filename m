Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 642AE9400BF
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 13:22:08 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p95GvtHl028682
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 12:57:55 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p95HM42x256776
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 13:22:05 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p95HLe4G016044
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 11:21:42 -0600
Date: Wed, 5 Oct 2011 22:34:20 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 3/26]   Uprobes: register/unregister
 probes.
Message-ID: <20111005170420.GB28250@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120022.25326.35868.sendpatchset@srdronam.in.ibm.com>
 <20111003124640.GA25811@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111003124640.GA25811@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Oleg Nesterov <oleg@redhat.com> [2011-10-03 14:46:40]:

> On 09/20, Srikar Dronamraju wrote:
> >
> > +static struct vma_info *__find_next_vma_info(struct list_head *head,
> > +			loff_t offset, struct address_space *mapping,
> > +			struct vma_info *vi)
> > +{
> > +	struct prio_tree_iter iter;
> > +	struct vm_area_struct *vma;
> > +	struct vma_info *tmpvi;
> > +	loff_t vaddr;
> > +	unsigned long pgoff = offset >> PAGE_SHIFT;
> > +	int existing_vma;
> > +
> > +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
> > +		if (!vma || !valid_vma(vma))
> > +			return NULL;
> 
> !vma is not possible.
> 
> But I can't understand the !valid_vma(vma) check... We shouldn't return,
> we should ignore this vma and continue, no? Otherwise, I can't see how
> this can work if someone does, say, mmap(PROT_READ).

Agree. Infact I encountered this problem last week and had fixed it.
In mycase, I had mapped the file read and write while trying to insert
probes.
The changed code looks like this

	if (!vma) 
		return NULL;

	if (!valid_vma(vma))
		continue;

> 
> > +		existing_vma = 0;
> > +		vaddr = vma->vm_start + offset;
> > +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > +		list_for_each_entry(tmpvi, head, probe_list) {
> > +			if (tmpvi->mm == vma->vm_mm && tmpvi->vaddr == vaddr) {
> > +				existing_vma = 1;
> > +				break;
> > +			}
> > +		}
> > +		if (!existing_vma &&
> > +				atomic_inc_not_zero(&vma->vm_mm->mm_users)) {
> 
> This looks suspicious. If atomic_inc_not_zero() can fail, iow if we can
> see ->mm_users == 0, then why it is safe to touch this counter/memory?
> How we can know ->mm_count != 0 ?
> 
> I _think_ this is probably correct, ->mm_users == 0 means we are racing
> mmput(), ->i_mmap_mutex and the fact we found this vma guarantees that
> mmput() can't pass unlink_file_vma() and thus mmdrop() is not possible.
> May be needs a comment...
> 
> > +static struct vma_info *find_next_vma_info(struct list_head *head,
> > +			loff_t offset, struct address_space *mapping)
> > +{
> > +	struct vma_info *vi, *retvi;
> > +	vi = kzalloc(sizeof(struct vma_info), GFP_KERNEL);
> > +	if (!vi)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	INIT_LIST_HEAD(&vi->probe_list);
> 
> Looks unneeded.
> 
> > +	mutex_lock(&mapping->i_mmap_mutex);
> > +	retvi = __find_next_vma_info(head, offset, mapping, vi);
> > +	mutex_unlock(&mapping->i_mmap_mutex);
> 
> It is not clear why we can't race with mmap() after find_next_vma_info()
> returns NULL. I guess this is solved by the next patches.

I assume mmap_uprobe() solves this.

> 
> > +static int __register_uprobe(struct inode *inode, loff_t offset,
> > +				struct uprobe *uprobe)
> > +{
> > +	struct list_head try_list;
> > +	struct vm_area_struct *vma;
> > +	struct address_space *mapping;
> > +	struct vma_info *vi, *tmpvi;
> > +	struct mm_struct *mm;
> > +	int ret = 0;
> > +
> > +	mapping = inode->i_mapping;
> > +	INIT_LIST_HEAD(&try_list);
> > +	while ((vi = find_next_vma_info(&try_list, offset,
> > +							mapping)) != NULL) {
> > +		if (IS_ERR(vi)) {
> > +			ret = -ENOMEM;
> > +			break;
> > +		}
> > +		mm = vi->mm;
> > +		down_read(&mm->mmap_sem);
> > +		vma = find_vma(mm, (unsigned long) vi->vaddr);
> 
> But we can't trust find_vma? The original vma found by find_next_vma_info()
> could go away, at least we should verify vi->vaddr >= vm_start.

Yes, Peter has already pointed this out and I have fixed this too.
Should be fixed in the next iteration.

> 
> And worse, I do not understand how we can trust ->vaddr. Can't we race with
> sys_mremap() ?
> 
> > +static void __unregister_uprobe(struct inode *inode, loff_t offset,
> > +						struct uprobe *uprobe)
> > +{
> > +	struct list_head try_list;
> > +	struct address_space *mapping;
> > +	struct vma_info *vi, *tmpvi;
> > +	struct vm_area_struct *vma;
> > +	struct mm_struct *mm;
> > +
> > +	mapping = inode->i_mapping;
> > +	INIT_LIST_HEAD(&try_list);
> > +	while ((vi = find_next_vma_info(&try_list, offset,
> > +							mapping)) != NULL) {
> > +		if (IS_ERR(vi))
> > +			break;
> > +		mm = vi->mm;
> > +		down_read(&mm->mmap_sem);
> > +		vma = find_vma(mm, (unsigned long) vi->vaddr);
> 
> Same problems...
> 
> > +		if (!vma || !valid_vma(vma)) {
> > +			list_del(&vi->probe_list);
> > +			kfree(vi);
> > +			up_read(&mm->mmap_sem);
> > +			mmput(mm);
> > +			continue;
> > +		}
> 
> Not sure about !valid_vma() (and note that __find_next_vma_info does() this
> check too).
> 
> Suppose that register_uprobe() succeeds. After that unregister_ should work
> even if user-space does mprotect() which can make valid_vma() == F, right?
> 

Agree, If we want __find_next_vma_info() also to not worry about
valid_vma() while unregistering, then we would have to pass an
additional parameter.

> > +int register_uprobe(struct inode *inode, loff_t offset,
> > +				struct uprobe_consumer *consumer)
> > +{
> > +	struct uprobe *uprobe;
> > +	int ret = 0;
> > +
> > +	inode = igrab(inode);
> > +	if (!inode || !consumer || consumer->next)
> > +		return -EINVAL;
> > +
> > +	if (offset > inode->i_size)
> > +		return -EINVAL;
> 
> I guess this needs i_size_read().

Okay, 

> 
> And every "return" in register/unregister leaks something.

Yes, this has been pointed out by Stefan Hajnoczi earlier.
Have taken care of this.

> 
> > +
> > +	mutex_lock(&inode->i_mutex);
> > +	uprobe = alloc_uprobe(inode, offset);
> 
> Looks like, alloc_uprobe() doesn't need ->i_mutex.


Actually this was pointed out by you in the last review.
https://lkml.org/lkml/2011/7/24/91

So if we alloc_uprobe() without a lock and succeed but while we contend
on the lock , if the unregister can erase the uprobe from the rbtree.
We end up with a valid uprobe but that is no more in the rbtree. right?

> 
> OTOH,
> 
> > +void unregister_uprobe(struct inode *inode, loff_t offset,
> > +				struct uprobe_consumer *consumer)
> > +{
> > +	struct uprobe *uprobe;
> > +
> > +	inode = igrab(inode);
> > +	if (!inode || !consumer)
> > +		return;
> > +
> > +	if (offset > inode->i_size)
> > +		return;
> > +
> > +	uprobe = find_uprobe(inode, offset);
> > +	if (!uprobe)
> > +		return;
> > +
> > +	if (!del_consumer(uprobe, consumer)) {
> > +		put_uprobe(uprobe);
> > +		return;
> > +	}
> > +
> > +	mutex_lock(&inode->i_mutex);
> > +	if (!uprobe->consumers)
> > +		__unregister_uprobe(inode, offset, uprobe);
> 
> It seemes that del_consumer() should be done under ->i_mutex. If it
> removes the last consumer, we can race with register_uprobe() which
> takes ->i_mutex before us and does another __register_uprobe(), no?

We should still be okay, because we check for the consumers before we
do the actual unregister in form of __unregister_uprobe.
since the consumer is again added by the time we get the lock, we dont
do the actual unregistration and go as if del_consumer deleted one
consumer but not the last. 

or Am I missing something?

-- 
Thanks and Regards
Srikar

> 
> Oleg.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
