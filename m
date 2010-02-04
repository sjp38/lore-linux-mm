Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9726B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 17:53:42 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o14Mrcrv011748
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 22:53:39 GMT
Received: from pzk17 (pzk17.prod.google.com [10.243.19.145])
	by wpaz13.hot.corp.google.com with ESMTP id o14MrQdx027774
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 14:53:37 -0800
Received: by pzk17 with SMTP id 17so3142660pzk.6
        for <linux-mm@kvack.org>; Thu, 04 Feb 2010 14:53:37 -0800 (PST)
Date: Thu, 4 Feb 2010 14:53:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <201002042331.34086.elendil@planet.nl>
Message-ID: <alpine.DEB.2.00.1002041435200.19721@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
 <4B6A1241.60009@redhat.com> <4B6A1241.60009@redhat.com> <alpine.DEB.2.00.1002041339220.6071@chino.kir.corp.google.com> <201002042331.34086.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Rik van Riel <riel@redhat.com>, l.lunak@suse.cz, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, jkosina@suse.cz
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010, Frans Pop wrote:

> Shouldn't fork bomb detection take into account the age of children?
> After all, long running processes with a lot of long running children are 
> rather unlikely to be runaway fork _bombs_.
> 

Yeah, Lubos mentioned using cpu time as a requirement, in addition to the 
already existing child->mm != parent->mm, as a prerequisite to be added 
into the tally to check the forkbomb threshold.  I think something like 
this would be appropriate:

	struct task_cputime task_time;
	int forkcount = 0;
	int child_rss = 0;

	...

	list_for_each_entry(child, &p->children, sibling) {
		unsigned long runtime;

		task_lock(child);
		if (!child->mm || child->mm == p->mm) {
			task_unlock(child);
			continue;
		}
		thread_group_cputime(child, &task_time);
		runtime = cputime_to_jiffies(task_time.utime) +
				cputime_to_jiffies(task_time.stime);

		/*
		 * Only threads that have run for less than a second are
		 * considered toward the forkbomb, these threads rarely
		 * get to execute at all in such cases anyway.
		 */
		if (runtime < HZ) {
			task_unlock(child);
			continue;
		}
		child_rss += get_mm_rss(child->mm);
		forkcount++;
	}

	if (forkcount > sysctl_oom_forkbomb_thres) {
		/*
		 * Penalize forkbombs by considering the average rss and
		 * how many factors we are over the threshold.
		 */
		points += child_rss / sysctl_oom_forkbomb_thres;
	}

I changed the calculation from lowest child rss to average child rss, so 
this is functionally equivalent to

(average rss size of children) * (# of first-generated execve children) /
			sysctl_oom_forkbomb_thres

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
