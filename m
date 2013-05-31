Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6ACE36B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 15:29:20 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id xb12so2734431pbc.28
        for <linux-mm@kvack.org>; Fri, 31 May 2013 12:29:19 -0700 (PDT)
Date: Fri, 31 May 2013 12:29:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130531112116.GC32491@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com> <20130530150539.GA18155@dhcp22.suse.cz> <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com> <20130531081052.GA32491@dhcp22.suse.cz> <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 31 May 2013, Michal Hocko wrote:

> > We allow users to control their own memcgs by chowning them, so they must 
> > be run in the same hierarchy if they want to run their own userspace oom 
> > handler.  There's nothing in the kernel that prevents that and the user 
> > has no other option but to run in a parent cgroup.
> 
> If the access to the oom_control file is controlled by the file
> permissions then the oom handler can live inside root cgroup. Why do you
> need "must be in the same hierarchy" requirement?
> 

Users obviously don't have the ability to attach processes to the root 
memcg.  They are constrained to their own subtree of memcgs.

> > It's too easy to simply do even a "ps ax" in an oom memcg and make that 
> > thread completely unresponsive because it allocates memory.
> 
> Yes, but we are talking about oom handler and that one has to be really
> careful about what it does. So doing something that simply allocates is
> dangerous.
> 

Show me a userspace oom handler that doesn't get notified of every fork() 
in a memcg, causing a performance degradation of its own for a complete 
and utter slowpath, that will know the entire process tree of its own 
memcg or a child memcg.

This discussion is all fine and good from a theoretical point of view 
until you actually have to implement one of these yourself.  Multiple 
users are going to be running their own oom notifiers and without some 
sort of failsafe, such as memory.oom_delay_millisecs, a memcg can too 
easily deadlock looking for memory.  If that user is constrained to his or 
her own subtree, as previously stated, there's also no way to login and 
rectify the situation at that point and requires admin intervention or a 
reboot.

> > Then perhaps I'm raising constraints that you've never worked with, I 
> > don't know.  We choose to have a priority-based approach that is inherited 
> > by children; this priority is kept in userspace and and the oom handler 
> > would naturally need to know the set of tasks in the oom memcg at the time 
> > of oom and their parent-child relationship.  These priorities are 
> > completely independent of memory usage.
> 
> OK, but both reading tasks file and readdir should be doable without
> userspace (aka charged) allocations. Moreover if you run those oom
> handlers under the root cgroup then it should be even easier.

Then why does "cat tasks" stall when my memcg is totally depleted of all 
memory?

This isn't even the argument because memory.oom_delay_millisecs isn't 
going to help that situation.  I'm talking about a failsafe that ensures a 
memcg can't deadlock.  The global oom killer will always have to exist in 
the kernel, at least in the most simplistic of forms, solely for this 
reason; you can't move all of the logic to userspace and expect it to 
react 100% of the time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
