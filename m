Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id DEF736B0093
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 07:48:43 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so1550005eaj.40
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 04:48:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si9336007eeo.193.2013.12.09.04.48.42
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 04:48:42 -0800 (PST)
Date: Mon, 9 Dec 2013 13:48:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131209124840.GC3597@dhcp22.suse.cz>
References: <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
 <20131202200221.GC5524@dhcp22.suse.cz>
 <20131202212500.GN22729@cmpxchg.org>
 <20131203120454.GA12758@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
 <20131204111318.GE8410@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed 04-12-13 16:23:41, David Rientjes wrote:
> On Wed, 4 Dec 2013, Michal Hocko wrote:
> 
> > > I'll repeat: Section 10 of Documentation/cgroups/memory.txt specifies what 
> > > userspace should do when waking up; one of those options is not "check if 
> > > the memcg is still actually oom in a short period of time once a charging 
> > > task with a pending SIGKILL or in the exit path has been able to exit."
> > > Users of this interface typically also disable the memcg oom killer 
> > > through the same file, it's ludicrous to put the responsibility on 
> > > userspace to determine if the wakeup is actionable and requires it to 
> > > intervene in one of the methods listed in section 10.
> > 
> > David, you would need to show us that such a condition happens in real
> > loads often enough that such a tweak is worth it. Repeating that a race
> > exists doesn't help, because yeah it does and it will after your patch
> > as well. So show us that it happens considerably less often with this
> > check.
> >  
> 
> Google depends on getting memory.oom_control notifications only when they 
> are actionable, which is exactly how Documentation/cgroups/memory.txt 
> describes how userspace should respond to such a notification.
> 
> "Actionable" here means that the kernel has exhausted its capabilities of 
> allowing for future memory freeing, which is the entire premise of any oom 
> killer.
> 
> Giving a dying process or a process that is going to subsequently die 
> access to memory reserves is a capability the kernel users to ensure 
> progress is made in oom conditions.  It is not an exhaustion of 
> capabilities.
> 
> Yes, we all know that subsequent to the userspace notification that memory 
> may be freed and the kill no longer becomes required.  There is nothing 
> that can be done about that, and it has never been implied that a memcg is 
> guaranteed to still be oom when the process wakes up.
> 
> I'm referring to a siutation that can manifest in a number of ways: 
> coincidental process exit, coincidental process being killed, 
> VMPRESSURE_CRITICAL notification that results in a process being killed, 
> or memory threshold notification that results in a process being killed.  
> Regardless, we're talking about a situation where something is already 
> in the exit path or has been killed and is simply attempting to free its 
> memory.

You have already mentioned that. Several times in fact. And I do
understand what you are saying. You are just not backing your claims
with anything that would convince us that what you are trying to solve
is an issue in the real life. So show us it is real, please.

> Such a process simply needs access to memory reserves to make progress and 
> free its memory as part of the exit path.  The process waiting on 
> memory.oom_control does _not_ need to do any of the actions mentioned in 
> Documentation/cgroups/memory.txt: reduce usage, enlarge the limit, kill a 
> process, or move a process with charge migration.
> 
> It would be ridiculous to require anybody implementing such a process to 
> check if the oom condition still exists after a period of time before 
> taking such an action.

Why would you consider that ridiculous? If your memcg is oom already
then waiting few seconds to let racing tasks finish doesn't sound that
bad to me.

> It would be required to wait for any possible 
> dying task or process with a pending SIGKILL to exit and there's no way to 
> determine how long is long enough to wait or that it will get woken up 
> again if it relies on a second signal for the same oom condition.  At the 
> same time, the action taken by such a process would still be as racy as it 
> would with the patch: we simply can't guarantee memory is not freed 
> immediately after we issue the SIGKILL.
> 
> What we can control is that the kernel has exhausted its capabilities of 
> allowing for future memory freeing at the time of notification.  That's 
> the goal of the patch, at the same time making it consistent with the 
> documentation.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
