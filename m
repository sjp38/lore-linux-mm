Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8P4cHAM016143
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 14:38:17 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8P4cIuH4399164
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 14:38:18 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8P4c2nX023294
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 14:38:02 +1000
Message-ID: <46F8909E.40907@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2007 10:07:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch -mm 5/5] oom: add sysctl to dump tasks memory state
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212313140.13727@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.0.9999.0709212313140.13727@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
>  /**
> + * Dumps the current memory state of all system tasks, excluding kernel threads.
> + * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
> + * score, and name.
> + *
> + * Call with tasklist_lock read-locked.
> + */
> +static void dump_tasks(void)
> +{
> +	struct task_struct *g, *p;
> +
> +	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
> +	       "name\n");
> +	do_each_thread(g, p) {
> +		/*
> +		 * total_vm and rss sizes do not exist for tasks with a
> +		 * detached mm so there's no need to report them.
> +		 */
> +		if (!p->mm)
> +			continue;
> +
> +		task_lock(p);
> +		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
> +		       p->pid, p->uid, p->tgid, p->mm->total_vm,
> +		       get_mm_rss(p->mm), (int)task_cpu(p), p->oomkilladj,
> +		       p->comm);
> +		task_unlock(p);
> +	} while_each_thread(g, p);
> +}
> +


I like this, but can we make this cgroup aware?
-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
