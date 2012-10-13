Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E405B6B002B
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 14:05:04 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Sat, 13 Oct 2012 14:05:03 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 306076E803C
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 14:05:00 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9DI4xAE293080
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 14:05:00 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9DI4wEA011765
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 12:04:59 -0600
Date: Sat, 13 Oct 2012 23:36:18 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 19/33] autonuma: memory follows CPU algorithm and
 task/mm_autonuma stats collection
Message-ID: <20121013180618.GC31442@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-20-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1349308275-2174-20-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

> +
> +bool numa_hinting_fault(struct page *page, int numpages)
> +{
> +	bool migrated = false;
> +
> +	/*
> +	 * "current->mm" could be different from the "mm" where the
> +	 * NUMA hinting page fault happened, if get_user_pages()
> +	 * triggered the fault on some other process "mm". That is ok,
> +	 * all we care about is to count the "page_nid" access on the
> +	 * current->task_autonuma, even if the page belongs to a
> +	 * different "mm".
> +	 */
> +	WARN_ON_ONCE(!current->mm);

Given the above comment, Do we really need this warn_on?
I think I have seen this warning when using autonuma.

> +	if (likely(current->mm && !current->mempolicy && autonuma_enabled())) {
> +		struct task_struct *p = current;
> +		int this_nid, page_nid, access_nid;
> +		bool new_pass;
> +
> +		/*
> +		 * new_pass is only true the first time the thread
> +		 * faults on this pass of knuma_scand.
> +		 */
> +		new_pass = p->task_autonuma->task_numa_fault_pass !=
> +			p->mm->mm_autonuma->mm_numa_fault_pass;
> +		page_nid = page_to_nid(page);
> +		this_nid = numa_node_id();
> +		VM_BUG_ON(this_nid < 0);
> +		VM_BUG_ON(this_nid >= MAX_NUMNODES);
> +		access_nid = numa_hinting_fault_memory_follow_cpu(page,
> +								  this_nid,
> +								  page_nid,
> +								  new_pass,
> +								  &migrated);
> +		/* "page" has been already freed if "migrated" is true */
> +		numa_hinting_fault_cpu_follow_memory(p, access_nid,
> +						     numpages, new_pass);
> +		if (unlikely(new_pass))
> +			/*
> +			 * Set the task's fault_pass equal to the new
> +			 * mm's fault_pass, so new_pass will be false
> +			 * on the next fault by this thread in this
> +			 * same pass.
> +			 */
> +			p->task_autonuma->task_numa_fault_pass =
> +				p->mm->mm_autonuma->mm_numa_fault_pass;
> +	}
> +
> +	return migrated;
> +}
> +

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
