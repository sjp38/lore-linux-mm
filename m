Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 76BF96B0036
	for <linux-mm@kvack.org>; Sat,  1 Jun 2013 06:21:03 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id d17so439966eek.8
        for <linux-mm@kvack.org>; Sat, 01 Jun 2013 03:21:01 -0700 (PDT)
Date: Sat, 1 Jun 2013 12:20:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130601102058.GA19474@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri 31-05-13 12:29:17, David Rientjes wrote:
> On Fri, 31 May 2013, Michal Hocko wrote:
> 
> > > We allow users to control their own memcgs by chowning them, so they must 
> > > be run in the same hierarchy if they want to run their own userspace oom 
> > > handler.  There's nothing in the kernel that prevents that and the user 
> > > has no other option but to run in a parent cgroup.
> > 
> > If the access to the oom_control file is controlled by the file
> > permissions then the oom handler can live inside root cgroup. Why do you
> > need "must be in the same hierarchy" requirement?
> > 
> 
> Users obviously don't have the ability to attach processes to the root 
> memcg.  They are constrained to their own subtree of memcgs.

OK, I assume those groups are generally untrusted, right? So you cannot
let them register their oom handler even via an admin interface. This
makes it a bit complicated because it makes much harder demands on the
handler itself as it has to run under restricted environment.

> > > It's too easy to simply do even a "ps ax" in an oom memcg and make that 
> > > thread completely unresponsive because it allocates memory.
> > 
> > Yes, but we are talking about oom handler and that one has to be really
> > careful about what it does. So doing something that simply allocates is
> > dangerous.
> > 
> 
> Show me a userspace oom handler that doesn't get notified of every fork() 
> in a memcg, causing a performance degradation of its own for a complete 
> and utter slowpath, that will know the entire process tree of its own 
> memcg or a child memcg.

I still do not see why you cannot simply read tasks file into a
preallocated buffer. This would be few pages even for thousands of pids.
You do not have to track processes as they come and go.

> This discussion is all fine and good from a theoretical point of view 
> until you actually have to implement one of these yourself.  Multiple 
> users are going to be running their own oom notifiers and without some 
> sort of failsafe, such as memory.oom_delay_millisecs, a memcg can too 
> easily deadlock looking for memory.

As I said before. oom_delay_millisecs is actually really easy to be done
from userspace. If you really need a safety break then you can register
such a handler as a fallback. I am not familiar with eventfd internals
much but I guess that multiple handlers are possible. The fallback might
be enforeced by the admin (when a new group is created) or by the
container itself. Would something like this work for your use case?

> If that user is constrained to his or her own subtree, as previously
> stated, there's also no way to login and rectify the situation at that
> point and requires admin intervention or a reboot.

Yes, insisting on the same subtree makes the life much harder for oom
handlers. I totally agree with you on that. I just feel that introducing
a new knob to workaround user "inability" to write a proper handler
(what ever that means) is not justified.
 
> > > Then perhaps I'm raising constraints that you've never worked with, I 
> > > don't know.  We choose to have a priority-based approach that is inherited 
> > > by children; this priority is kept in userspace and and the oom handler 
> > > would naturally need to know the set of tasks in the oom memcg at the time 
> > > of oom and their parent-child relationship.  These priorities are 
> > > completely independent of memory usage.
> > 
> > OK, but both reading tasks file and readdir should be doable without
> > userspace (aka charged) allocations. Moreover if you run those oom
> > handlers under the root cgroup then it should be even easier.
> 
> Then why does "cat tasks" stall when my memcg is totally depleted of all 
> memory?

if you run it like this then cat obviously needs some charged
allocations. If you had a proper handler which mlocks its buffer for the
read syscall then you shouldn't require any allocation at the oom time.
This shouldn't be that hard to do without too much memory overhead. As I
said we are talking about few (dozens) of pages per handler.

> This isn't even the argument because memory.oom_delay_millisecs isn't 
> going to help that situation.  I'm talking about a failsafe that ensures a 
> memcg can't deadlock.  The global oom killer will always have to exist in 
> the kernel, at least in the most simplistic of forms, solely for this 
> reason; you can't move all of the logic to userspace and expect it to 
> react 100% of the time.

The global case is even more complicated because every allocation
matters - not just those that are charged as for memcg case. Btw. at
last LSF there was a discussion about enabling oom_control for the root
cgroup but this is off-topic here and should be discussed separately
when somebody actually tries to implement this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
