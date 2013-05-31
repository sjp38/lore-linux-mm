Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 01A1A6B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 06:23:02 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id xa12so1962058pbc.25
        for <linux-mm@kvack.org>; Fri, 31 May 2013 03:23:02 -0700 (PDT)
Date: Fri, 31 May 2013 03:22:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130531081052.GA32491@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com> <20130530150539.GA18155@dhcp22.suse.cz> <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com> <20130531081052.GA32491@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 31 May 2013, Michal Hocko wrote:

> I have always discouraged people from running oom handler in the same
> memcg (or even in the same hierarchy).
> 

We allow users to control their own memcgs by chowning them, so they must 
be run in the same hierarchy if they want to run their own userspace oom 
handler.  There's nothing in the kernel that prevents that and the user 
has no other option but to run in a parent cgroup.

> Yes, mmap_sem is tricky. Nothing in the proc code should take it for
> writing and charges are done with mmap_sem held for reading but that
> doesn't prevent from non-oom thread to try to get it for writing which
> would block also all future readers. We have also seen i_mutex being
> held during charge so you have to be careful about that one as well but
> I am not aware of other locks that could be a problem.
> 
> The question is, do you really need to open any /proc/<pid>/ files which
> depend on mmap_sem (e.g. maps, smaps). /proc/<pid>/status should tell you
> about used memory. Or put it another way around. What kind of data you
> need for your OOM handler?
> 

It's too easy to simply do even a "ps ax" in an oom memcg and make that 
thread completely unresponsive because it allocates memory.

> I might be thinking about different use cases but user space OOM
> handlers I have seen so far had quite a good idea what is going on
> in the group and who to kill.

Then perhaps I'm raising constraints that you've never worked with, I 
don't know.  We choose to have a priority-based approach that is inherited 
by children; this priority is kept in userspace and and the oom handler 
would naturally need to know the set of tasks in the oom memcg at the time 
of oom and their parent-child relationship.  These priorities are 
completely independent of memory usage.

> > If the oom notifier is in the oom cgroup, it may not be able to       
> > successfully read the memcg "tasks" file to even determine the set of 
> > eligible processes.
> 
> It would have to use preallocated buffer and have mlocked all the memory
> that will be used during oom event.
> 

Wrong, the kernel itself allocates memory when reading this information 
and that would fail in an oom memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
