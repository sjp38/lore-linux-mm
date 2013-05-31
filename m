Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 5F7646B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 04:10:55 -0400 (EDT)
Date: Fri, 31 May 2013 10:10:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130531081052.GA32491@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu 30-05-13 13:47:30, David Rientjes wrote:
> On Thu, 30 May 2013, Michal Hocko wrote:
> 
> > > Completely disabling the oom killer for a memcg is problematic if
> > > userspace is unable to address the condition itself, usually because it
> > > is unresponsive. 
> > 
> > Isn't this a bug in the userspace oom handler? Why is it unresponsive? It
> > shouldn't allocated any memory so nothing should prevent it from running (if
> > other tasks are preempting it permanently then the priority of the handler
> > should be increased).
> > 
> 
> Unresponsiveness isn't necessarily only because of memory constraints, you 
> may have your oom notifier in a parent cgroup that isn't oom. 

I have always discouraged people from running oom handler in the same
memcg (or even in the same hierarchy).

> If a process is stuck on mm->mmap_sem in the oom cgroup, though, the
> oom notifier may not be able to scrape /proc/pid and attain necessary
> information in making an oom kill decision.

Yes, mmap_sem is tricky. Nothing in the proc code should take it for
writing and charges are done with mmap_sem held for reading but that
doesn't prevent from non-oom thread to try to get it for writing which
would block also all future readers. We have also seen i_mutex being
held during charge so you have to be careful about that one as well but
I am not aware of other locks that could be a problem.

The question is, do you really need to open any /proc/<pid>/ files which
depend on mmap_sem (e.g. maps, smaps). /proc/<pid>/status should tell you
about used memory. Or put it another way around. What kind of data you
need for your OOM handler?

I might be thinking about different use cases but user space OOM
handlers I have seen so far had quite a good idea what is going on
in the group and who to kill. So it was more a decision based on the
workload and its semantic rather than based on the used memory (which
is done quite sensibly with the in kernel handler already) or something
that would trip over mmap_sem when trying to get information.

> If the oom notifier is in the oom cgroup, it may not be able to       
> successfully read the memcg "tasks" file to even determine the set of 
> eligible processes.

It would have to use preallocated buffer and have mlocked all the memory
that will be used during oom event.

> There is also no guarantee that the userspace oom handler will have
> the necessary memory to even re-enable the oom killer in the memcg
> under oom which would allow the kernel to make forward progress.

Why it wouldn't have enough memory to write to the file? Assuming that
the oom handler has the file handle (for limit_in_bytes) open, it has
mlocked all the necessary memory (code + buffers) then I do not see what
would prevent it from writing it to limit_in_bytes.

> We've used this for a few years as a complement to oom notifiers so that a 
> process would have a grace period to deal with the oom condition itself 
> before allowing the kernel to terminate a process and free memory.  We've 
> simply had no alternative in the presence of kernel constraints that 
> prevent it from being done in any other way.  We _want_ userspace to deal 
> with the issue but when it cannot collect the necessary information (and 
> we're not tracing every fork() that every process in a potentially oom 
> memcg does) to deal with the condition, we want the kernel to step in 
> instead of relying on an admin to login or a global oom condition.
> 
> If you'd like to debate this issue, I'd be more than happy to do so and 
> show why this patch is absolutely necessary for inclusion, but I'd ask 
> that you'd present the code from your userspace oom handler so I can 
> understand how it works without needing such backup support.

I usually do not write those things myself as I am supporting others so
I do not have any code handy right now. But I can come up with a simple
handler which implements your timeout based killer for peak workloads
you have mentioned earlier. That one should be quite easy to do.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
