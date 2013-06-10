Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 984DE6B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 10:23:26 -0400 (EDT)
Date: Mon, 10 Jun 2013 16:23:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130610142321.GE5138@dhcp22.suse.cz>
References: <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601102058.GA19474@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031102480.7956@chino.kir.corp.google.com>
 <20130603193147.GC23659@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com>
 <20130604095514.GC31242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com>
 <20130605093937.GK15997@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed 05-06-13 17:09:17, David Rientjes wrote:
> On Wed, 5 Jun 2013, Michal Hocko wrote:
> 
> > > For the aforementioned reason that we give users the ability to manipulate 
> > > their own memcg trees and userspace is untrusted.  Their oom notifiers 
> > > cannot be run as root, not only because of security but also because it 
> > > would not properly isolate their memory usage to their memcg tree.
> > 
> > Yes, but nothing prevents an admin - I hope you trust at least this
> > entity - to do the global watchdog for the fallback mode. So users can
> > play as they like  but if they are not able to cope with the oom
> > situation for the defined timeout then the global (trusted and running
> > in the root memcg) watchdog re-enables in-kernel oom handler.
> > 
> 
> Users have the full ability to manipulate their own memcg hierarchy 
> under the root, the global entity that schedules these jobs is not aware 
> of any user subcontainers that are created beneath the user root.  These 
> user subcontainers may be oom and our desire is for the user to be able to 
> have their own userspace handling implementation at a higher level (or 
> with memcg memory reserves).  Userspace is untrusted, they can't be 
> expected to register an oom notifier for a child memcg with a global 
> resource, they may not care that they deadlock and leave behind gigabytes 
> of memory that can't be freed if they oom.  And, if that userspace global 
> resource dies or becomes unresponsive itself for whatever reason, all oom 
> memcgs deadlock.
> 
> > > I don't think you yet understand the problem, which is probably my fault.  
> > > I'm not insisting this be implemented in the kernel, I'm saying it's not 
> > > possible to do it in userspace.  
> > 
> > Because you still insist on having this fallback mode running inside
> > untrusted environment AFAIU.
> > 
> 
> -ENOPARSE. 

Either the global watchdog is running as a trusted code and you _can_
implement it without dealocks (this is what I claim and I haven't heard
strong arguments against that) or even the watchdog runs as an untrusted
code and then I would ask why.

> The failsafe is the kernel, it ensures that memcgs don't sit          
> completely deadlocked for days and weeks and take up resources that   
> can never be freed.                                                   

Yes, I _understand_ what you are proposing.

Your only objection against userspace handling so far was that admin
has no control over sub-hierarchies. But that is hardly a problem. A
periodic tree scan would solve this easily (just to make sure we are on
the same page - this is still the global watchdog living in a trusted
root cgroup which is marked as unkillable for the global oom).

> The entire purpose of userspace oom notification is so 
> that users can implement their own policy, whatever is implemented in the 
> kernel may not apply (they may want to kill the largest process, the 
> newest, the youngest, one on a priority-based scale, etc).
> 
> > > This is the result of memcg allowing users to disable the oom killer 
> > > entirely for a memcg, which is still ridiculous, because if the user 
> > > doesn't respond then you've wasted all that memory and cannot get it back 
> > > without admin intervention or a reboot.  There are no other "features" in 
> > > the kernel that put such a responsibility on a userspace process such that 
> > > if it doesn't work then the entire memcg deadlocks forever without admin 
> > > intervention.  We need a failsafe in the kernel.
> > 
> > But the memcg would deadlock within constrains assigned from somebody
> > trusted. So while the memory is basically wasted the limit assignment
> > already says that somebody (trusted) dedicated that much of memory. So I
> > think disabling oom for ever is not that ridiculous.
> > 
> 
> I don't understand what you're trying to say.  Yes, a trusted resource 
> sets the user root's limits and that is their allotted use.  To implement 
> a sane userspace oom handler, we need to give it time to respond; my 
> solution is memory.oom_delay_millisecs, your solution is disabling the oom 
> killer for that memcg. 

No! My solution is to let (trusted) userspace handle oom_delay_millisecs
as a fallback if user space is not able to handle oom in time.

> Anything else results in an instant oom kill from the kernel.  If the 
> user has their own implementation, with today's kernel it is required 
> to disable the oom killer entirely and nothing in that untrusted      
> environment is ever guaranteed to re-enable the oom killer or even    
> have the memory to do so if it wanted.                                

> Meanwhile, the trusted resource has no knowledge whatsoever of these
> user subcontainers and it can't infinitely scan the memcg tree to find
> them because that requires memory that may not be available because of
> global oom or because of slab accounting.

Global oom can be handled by oom_adj for the global watchdog and
slab accounting should be non issue as the limit cannot be set for the
root cgroup - or the watchdog can live in an unlimited group.

Besides that. How much memory are we talking about here (per
memcg)? Have you measure that? Is it possible that your untrusted
users could cause a DoS by creating too many groups? I would be really
surprised and argument about global watchdog quality then.

David, maybe I am still missing something but it seems to me that the
in-kernel timeout is not necessary because the user-space variant is not
that hard to implement and I really do not want to add new knobs for
something that can live outside.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
