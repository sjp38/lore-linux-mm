Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 0208B6B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 16:33:43 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so3534371pdj.22
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 13:33:43 -0700 (PDT)
Date: Tue, 11 Jun 2013 13:33:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130610142321.GE5138@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com>
References: <20130531112116.GC32491@dhcp22.suse.cz> <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com> <20130601102058.GA19474@dhcp22.suse.cz> <alpine.DEB.2.02.1306031102480.7956@chino.kir.corp.google.com> <20130603193147.GC23659@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com> <20130604095514.GC31242@dhcp22.suse.cz> <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com> <20130605093937.GK15997@dhcp22.suse.cz> <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com>
 <20130610142321.GE5138@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 10 Jun 2013, Michal Hocko wrote:

> > > > I don't think you yet understand the problem, which is probably my fault.  
> > > > I'm not insisting this be implemented in the kernel, I'm saying it's not 
> > > > possible to do it in userspace.  
> > > 
> > > Because you still insist on having this fallback mode running inside
> > > untrusted environment AFAIU.
> > > 
> > 
> > -ENOPARSE. 
> 
> Either the global watchdog is running as a trusted code and you _can_
> implement it without dealocks (this is what I claim and I haven't heard
> strong arguments against that) or even the watchdog runs as an untrusted
> code and then I would ask why.
> 

As I already said, no global entity could possibly know and monitor the 
entire set of memcgs when users are given the power to create their own 
child memcgs within their tree.  Not only would it be unnecessarily 
expensive to scan the entire memcg tree all the time, but it would also be 
racy and miss oom events when a child memcg is created and hits its limit 
before the global entity can scan for it.

> Your only objection against userspace handling so far was that admin
> has no control over sub-hierarchies. But that is hardly a problem. A
> periodic tree scan would solve this easily (just to make sure we are on
> the same page - this is still the global watchdog living in a trusted
> root cgroup which is marked as unkillable for the global oom).
> 

There's no way a "periodic tree scan" would solve this easily, it's 
completely racy and leaves the possibility of missing oom events when they 
happen in a new memcg before the next tree scan.

Not only that, but what happens when the entire machine is oom?  The 
global watchdog can't allocate any memory to handle the event, yet it is 
supposed to always be doing entire memcg tree scans, registering oom 
handlers, and handling wakeups when notified?

How does this "global watchdog" know when to stop the timer?  In the 
kernel that would happen if the user expands the memcg limit or there's an 
uncharge to the memcg.  The global watchdog stores the limit at the time 
of oom and compares it before killing something?  How many memcgs do we 
have to store this value for without allocating memory in a global oom 
condition?  You expect us to run with all this memory mlocked in memory 
forever?

How does the global watchdog know that there was an uncharge and then a 
charge in the memcg so it is still oom?  This would reset the timer in the 
kernel but not in userspace and may result in unnecessary killing.  If 
the timeout is 10s, the memcg is oom for 9s, uncharges, recharges, and the 
global watchdog checks at 10s that it is still oom, we don't want the kill 
because we do get uncharge events.

This idea for a global watchdog just doesn't work.

> > Meanwhile, the trusted resource has no knowledge whatsoever of these
> > user subcontainers and it can't infinitely scan the memcg tree to find
> > them because that requires memory that may not be available because of
> > global oom or because of slab accounting.
> 
> Global oom can be handled by oom_adj for the global watchdog and
> slab accounting should be non issue as the limit cannot be set for the
> root cgroup - or the watchdog can live in an unlimited group.
> 

I'm referring to a global oom condition where physical RAM is exhausted, 
not anything to do with memcg.

> Besides that. How much memory are we talking about here (per
> memcg)? Have you measure that? Is it possible that your untrusted
> users could cause a DoS by creating too many groups? I would be really
> surprised and argument about global watchdog quality then.
> 

We limit the number of css_id in children but not the top level of memcgs 
that are created by the trusted resource.

> David, maybe I am still missing something but it seems to me that the
> in-kernel timeout is not necessary because the user-space variant is not
> that hard to implement and I really do not want to add new knobs for
> something that can live outside.

It's vitally necessary and unless you answer the questions I've asked 
about your proposed "global watchdog" that exists only in your theory then 
we'll just continue to have this circular argument.  You cannot implement 
a userspace variant that works this way and insisting that you can is 
ridiculous.  These are problems that real users face and we insist on the 
problem being addressed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
