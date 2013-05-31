Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7556A6B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 07:21:19 -0400 (EDT)
Date: Fri, 31 May 2013 13:21:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130531112116.GC32491@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri 31-05-13 03:22:59, David Rientjes wrote:
> On Fri, 31 May 2013, Michal Hocko wrote:
> 
> > I have always discouraged people from running oom handler in the same
> > memcg (or even in the same hierarchy).
> > 
> 
> We allow users to control their own memcgs by chowning them, so they must 
> be run in the same hierarchy if they want to run their own userspace oom 
> handler.  There's nothing in the kernel that prevents that and the user 
> has no other option but to run in a parent cgroup.

If the access to the oom_control file is controlled by the file
permissions then the oom handler can live inside root cgroup. Why do you
need "must be in the same hierarchy" requirement?

> > Yes, mmap_sem is tricky. Nothing in the proc code should take it for
> > writing and charges are done with mmap_sem held for reading but that
> > doesn't prevent from non-oom thread to try to get it for writing which
> > would block also all future readers. We have also seen i_mutex being
> > held during charge so you have to be careful about that one as well but
> > I am not aware of other locks that could be a problem.
> > 
> > The question is, do you really need to open any /proc/<pid>/ files which
> > depend on mmap_sem (e.g. maps, smaps). /proc/<pid>/status should tell you
> > about used memory. Or put it another way around. What kind of data you
> > need for your OOM handler?
> > 
> 
> It's too easy to simply do even a "ps ax" in an oom memcg and make that 
> thread completely unresponsive because it allocates memory.

Yes, but we are talking about oom handler and that one has to be really
careful about what it does. So doing something that simply allocates is
dangerous.

> > I might be thinking about different use cases but user space OOM
> > handlers I have seen so far had quite a good idea what is going on
> > in the group and who to kill.
> 
> Then perhaps I'm raising constraints that you've never worked with, I 
> don't know.  We choose to have a priority-based approach that is inherited 
> by children; this priority is kept in userspace and and the oom handler 
> would naturally need to know the set of tasks in the oom memcg at the time 
> of oom and their parent-child relationship.  These priorities are 
> completely independent of memory usage.

OK, but both reading tasks file and readdir should be doable without
userspace (aka charged) allocations. Moreover if you run those oom
handlers under the root cgroup then it should be even easier.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
