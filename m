Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 91FCA6B005D
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 18:02:50 -0400 (EDT)
Date: Fri, 14 Sep 2012 15:02:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] KSM: numa awareness sysfs knob
Message-Id: <20120914150248.59e9757d.akpm@linux-foundation.org>
In-Reply-To: <1347657767-1912-1-git-send-email-pholasek@redhat.com>
References: <1347657767-1912-1-git-send-email-pholasek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, 14 Sep 2012 23:22:47 +0200
Petr Holasek <pholasek@redhat.com> wrote:

> Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_nodes

I wonder if merge_across_nodes would be a better name.

> which control merging pages across different numa nodes.
> When it is set to zero only pages from the same node are merged,
> otherwise pages from all nodes can be merged together (default behavior).
> 
> Typical use-case could be a lot of KVM guests on NUMA machine
> and cpus from more distant nodes would have significant increase
> of access latency to the merged ksm page. Sysfs knob was choosen
> for higher scalability.

Well...  what is the use case for merge_nodes=0?  IOW, why shouldn't we
make this change non-optional and avoid the sysfs knob?

> Every numa node has its own stable & unstable trees because
> of faster searching and inserting. Changing of merge_nodes
> value is possible only when there are not any ksm shared pages in system.
> 
> This patch also adds share_all sysfs knob which can be used for adding
> all anon vmas of all processes in system to ksmd scan queue. Knob can be
> triggered only when run knob is set to zero.

I really don't understand this share_all thing.  From reading the code,
it is a once-off self-resetting trigger thing.  Why?  How is one to use
this?  What's the benefit?  What's the effect?

> I've tested this patch on numa machines with 2, 4 and 8 nodes and
> measured speed of memory access inside of KVM guests with memory pinned
> to one of nodes with this benchmark:
> 
> http://pholasek.fedorapeople.org/alloc_pg.c
> 
> Population standard deviations of access times in percentage of average
> were following:
> 
> merge_nodes=1
> 2 nodes 1.4%
> 4 nodes 1.6%
> 8 nodes	1.7%
> 
> merge_nodes=0
> 2 nodes	1%
> 4 nodes	0.32%
> 8 nodes	0.018%
> 
>
> ...
>
> @@ -462,7 +473,13 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>  		cond_resched();
>  	}
>  
> -	rb_erase(&stable_node->node, &root_stable_tree);
> +	if (ksm_merge_nodes)
> +		nid = 0;
> +	else
> +		nid = pfn_to_nid(stable_node->kpfn);

This sequence happens three times - it might be a little tidier to
capture the above into a separate helper function.  Or not bother ;)
One benefit of the standalone function is that it provides a nice site
for a comment


> +	rb_erase(&stable_node->node,
> +			&root_stable_tree[nid]);
>  	free_stable_node(stable_node);
>  }
>  
>
> ...
>
> +static int ksmd_should_run(void)
> +{
> +	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
> +}
> +
> +static int ksmd_should_madvise(void)
> +{
> +	return ksm_share_all;
> +}
> +
> +static int ksm_madvise_all(void)
> +{
> +	struct task_struct *p;
> +	int err;
> +
> +	for_each_process(p) {

what, what.  We can't just go waltzing across the task list without
taking any locks.  Needs rcu_read_lock(), methinks.

Also...  I've forgotten how threads/processes are arranged.  Will this
walk across all the threads in the system?  If so, that would be
terribly inefficient walking 1000 task structs which share a single mm,
manipulating that mm 1000 times.  It might be better to walk the mm's
instead - see mm_struct.mmlist.

> +		read_lock(&tasklist_lock);
> +
> +		if (!p->mm)
> +			goto out;
> +
> +		down_write(&p->mm->mmap_sem);

whoa, you can't do down_write() inside read_lock().

Please, immediately put down your mail client, read
Documentation/SubmitChecklist section 12 and go make the appropriate
changes to your kernel .config.

> +		err = ksm_madvise_mm(p->mm);
> +		up_write(&p->mm->mmap_sem);
> +out:
> +		read_unlock(&tasklist_lock);
> +		if (err)
> +			break;
> +		cond_resched();
> +	}
> +	return err;
> +}
> +
> +/**
> + * ksm_do_scan  - the ksm scanner main worker function.
> + * @scan_npages - number of pages we want to scan before we return.
> + */
> +static void ksm_do_scan(unsigned int scan_npages)
> +{
> +	struct rmap_item *rmap_item;
> +	struct page *uninitialized_var(page);

gcc is silly.  I think that got fixed in more recent versions.

> +	while (scan_npages-- && likely(!freezing(current))) {
> +		cond_resched();
> +		rmap_item = scan_get_next_rmap_item(&page);
> +		if (!rmap_item)
> +			return;
> +		if (!PageKsm(page) || !in_stable_tree(rmap_item))
> +			cmp_and_merge_page(page, rmap_item);
> +		put_page(page);
> +	}
> +}
> +
> +static int ksm_scan_thread(void *nothing)
> +{
> +	set_freezable();
> +	set_user_nice(current, 5);

The reason for the set_user_nice() is a total mystery to this and any
other reader.  Hence it needs a comment.

> +	while (!kthread_should_stop()) {
> +		mutex_lock(&ksm_thread_mutex);
> +		if (ksmd_should_madvise()) {
> +			ksm_madvise_all();
> +			ksm_share_all = 0;
> +		}
> +		if (ksmd_should_run())
> +			ksm_do_scan(ksm_thread_pages_to_scan);
> +		mutex_unlock(&ksm_thread_mutex);
> +
> +		try_to_freeze();
> +
> +		if (ksmd_should_run()) {
> +			schedule_timeout_interruptible(
> +				msecs_to_jiffies(ksm_thread_sleep_millisecs));
> +		} else {
> +			wait_event_freezable(ksm_thread_wait,
> +				ksmd_should_run() ||
> +				ksmd_should_madvise() ||
> +				kthread_should_stop());
> +		}
> +	}
> +	return 0;
> +}
> +
>  struct page *ksm_does_need_to_copy(struct page *page,
>  			struct vm_area_struct *vma, unsigned long address)
>  {
>
> ...
>
> +static ssize_t merge_nodes_store(struct kobject *kobj,
> +				   struct kobj_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long knob;
> +
> +	err = kstrtoul(buf, 10, &knob);
> +	if (err)
> +		return err;
> +	if (knob > 1)
> +		return -EINVAL;
> +
> +	mutex_lock(&ksm_thread_mutex);
> +	if (ksm_run & KSM_RUN_MERGE) {
> +		err = -EBUSY;
> +	} else {
> +		if (ksm_merge_nodes != knob) {
> +			if (ksm_pages_shared > 0)
> +				err = -EBUSY;

What's happening here?  The attempt to set merge_nodes can randomly
fail due to internal transient state within ksm?  That sounds rather
user-hostile.

What did the user do wrong and how should he correct the situation? 

What documentation should he have read to avoid this mistake?

> +			else
> +				ksm_merge_nodes = knob;
> +		}
> +	}
> +
> +	if (err)
> +		count = err;
> +	mutex_unlock(&ksm_thread_mutex);
> +
> +	return count;
> +}
> +KSM_ATTR(merge_nodes);
> +#endif
> +
> +static ssize_t share_all_show(struct kobject *kobj,
> +				 struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%u\n", ksm_share_all);
> +}
> +
> +static ssize_t share_all_store(struct kobject *kobj,
> +				 struct kobj_attribute *attr,
> +				 const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long knob;
> +
> +	err = kstrtoul(buf, 10, &knob);
> +	if (err)
> +		return err;
> +	if (knob > 1)
> +		return -EINVAL;
> +
> +	mutex_lock(&ksm_thread_mutex);
> +	if (ksm_run & KSM_RUN_MERGE) {
> +		err = -EBUSY;

OK, this one makes more sense: the user most stop KSM before altering
share_all.  Document this?

> +	} else {
> +		if (ksm_share_all != knob)
> +			ksm_share_all = knob;
> +	}
> +	if (err)
> +		count = err;
> +	mutex_unlock(&ksm_thread_mutex);
> +
> +	return count;
> +}
> +KSM_ATTR(share_all);
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
