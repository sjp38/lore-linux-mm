Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8296B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 13:58:12 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o13Iw431005044
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 10:58:05 -0800
Received: from pzk17 (pzk17.prod.google.com [10.243.19.145])
	by spaceape11.eur.corp.google.com with ESMTP id o13IuBWM013738
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 10:58:03 -0800
Received: by pzk17 with SMTP id 17so1686295pzk.6
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 10:58:03 -0800 (PST)
Date: Wed, 3 Feb 2010 10:58:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <20100203170127.GH19641@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <4B698CEE.5020806@redhat.com> <20100203170127.GH19641@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, Lubos Lunak <l.lunak@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Balbir Singh wrote:

> > IIRC the child accumulating code was introduced to deal with
> > malicious code (fork bombs), but it makes things worse for the
> > (much more common) situation of a system without malicious
> > code simply running out of memory due to being very busy.
> >
> 
> For fork bombs, we could do a number of children number test and have
> a threshold before we consider a process and its children for
> badness().
> 

Yes, we could look for the number of children with seperate mm's and then 
penalize those threads that have forked an egregious amount, say, 500 
tasks.  I think we should check for this threshold within the badness() 
heuristic to identify such forkbombs and not limit it only to certain 
applications.  

My rewrite for the badness() heuristic is centered on the idea that scores 
should range from 0 to 1000, 0 meaning "never kill this task" and 1000 
meaning "kill this task first."  The baseline for a thread, p, may be 
something like this:

	unsigned int badness(struct task_struct *p,
					unsigned long totalram)
	{
		struct task_struct *child;
		struct mm_struct *mm;
		int forkcount = 0;
		long points;

		task_lock(p);
		mm = p->mm;
		if (!mm) {
			task_unlock(p);
			return 0;
		}
		points = (get_mm_rss(mm) +
				get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
				totalram;
		task_unlock(p);

		list_for_each_entry(child, &p->children, sibling)
			/* No lock, child->mm won't be dereferenced */
			if (child->mm && child->mm != mm)
				forkcount++;

		/* Forkbombs get penalized 10% of available RAM */
		if (forkcount > 500)
			points += 100;

		...

		/*
		 * /proc/pid/oom_adj ranges from -1000 to +1000 to either
		 * completely disable oom killing or always prefer it.
		 */
		points += p->signal->oom_adj;

		if (points < 0)
			return 0;
		return (points <= 1000) ? points : 1000;
	}

	static struct task_struct *select_bad_process(...,
						nodemask_t *nodemask)
	{
		struct task_struct *p;
		unsigned long totalram = 0;
		int nid;

		for_each_node_mask(nid, nodemask)
			totalram += NODE_DATA(nid)->node_present_pages;

		for_each_process(p) {
			unsigned int points;

			...

			if (!nodes_intersects(p->mems_allowed, nodemasks))
				continue;

			...
			points = badness(p, totalram);
			...
		}
		...
	}

In this example, /proc/pid/oom_adj now ranges from -1000 to +1000, with 
OOM_DISABLE being -1000, to polarize tasks for oom killing or determine 
when a task is leaking memory because it is using far more memory than it 
should.  The nodemask passed from the page allocator should be intersected 
with current->mems_allowed within the oom killer; userspace is then fully 
aware of what value is an egregious amount of RAM for a task to consume, 
including information it knows about the task's cpuset or mempolicy.  For 
example, it would be very simple for a user to set an oom_adj of -500, 
which means "we discount 50% of the task's allowed memory from being 
considered in the heuristic" or +500, which means "we always allow all 
other system/cpuset/mempolicy tasks to use at least 50% more allowed 
memory than this one."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
