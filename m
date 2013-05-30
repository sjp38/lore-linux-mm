Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 52D8B6B0032
	for <linux-mm@kvack.org>; Thu, 30 May 2013 16:47:34 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id xa12so1011055pbc.39
        for <linux-mm@kvack.org>; Thu, 30 May 2013 13:47:33 -0700 (PDT)
Date: Thu, 30 May 2013 13:47:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130530150539.GA18155@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com> <20130530150539.GA18155@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, 30 May 2013, Michal Hocko wrote:

> > Completely disabling the oom killer for a memcg is problematic if
> > userspace is unable to address the condition itself, usually because it
> > is unresponsive. 
> 
> Isn't this a bug in the userspace oom handler? Why is it unresponsive? It
> shouldn't allocated any memory so nothing should prevent it from running (if
> other tasks are preempting it permanently then the priority of the handler
> should be increased).
> 

Unresponsiveness isn't necessarily only because of memory constraints, you 
may have your oom notifier in a parent cgroup that isn't oom.  If a 
process is stuck on mm->mmap_sem in the oom cgroup, though, the oom 
notifier may not be able to scrape /proc/pid and attain necessary 
information in making an oom kill decision.  If the oom notifier is in the 
oom cgroup, it may not be able to successfully read the memcg "tasks" 
file to even determine the set of eligible processes.  There is also no 
guarantee that the userspace oom handler will have the necessary memory to 
even re-enable the oom killer in the memcg under oom which would allow the 
kernel to make forward progress.

We've used this for a few years as a complement to oom notifiers so that a 
process would have a grace period to deal with the oom condition itself 
before allowing the kernel to terminate a process and free memory.  We've 
simply had no alternative in the presence of kernel constraints that 
prevent it from being done in any other way.  We _want_ userspace to deal 
with the issue but when it cannot collect the necessary information (and 
we're not tracing every fork() that every process in a potentially oom 
memcg does) to deal with the condition, we want the kernel to step in 
instead of relying on an admin to login or a global oom condition.

If you'd like to debate this issue, I'd be more than happy to do so and 
show why this patch is absolutely necessary for inclusion, but I'd ask 
that you'd present the code from your userspace oom handler so I can 
understand how it works without needing such backup support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
