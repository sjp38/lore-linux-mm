Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E6C306B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 04:56:17 -0400 (EDT)
Date: Fri, 26 Aug 2011 10:56:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: skip frozen tasks
Message-ID: <20110826085610.GA9083@tiehlicka.suse.cz>
References: <20110823073101.6426.77745.stgit@zurg>
 <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com>
 <20110824101927.GB3505@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
 <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com>
 <20110825164758.GB22564@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
 <20110826070946.GA7280@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110826070946.GA7280@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri 26-08-11 09:09:46, Michal Hocko wrote:
> On Thu 25-08-11 14:14:20, David Rientjes wrote:
> > On Thu, 25 Aug 2011, Michal Hocko wrote:
> > 
> > > > > > That's obviously false since we call oom_killer_disable() in 
> > > > > > freeze_processes() to disable the oom killer from ever being called in the 
> > > > > > first place, so this is something you need to resolve with Rafael before 
> > > > > > you cause more machines to panic.
> > > > >
> > > > > I didn't mean suspend/resume path (that is protected by oom_killer_disabled)
> > > > > so the patch doesn't make any change.
> > > > 
> > > > Confused... freeze_processes() does try_to_freeze_tasks() before
> > > > oom_killer_disable() ?
> > > 
> > > Yes you are right, I must have been blind. 
> > > 
> > > Now I see the point. We do not want to panic while we are suspending and
> > > the memory is really low just because all the userspace is already in
> > > the the fridge.
> > > Sorry for confusion.
> > > 
> > > I still do not follow the oom_killer_disable note from David, though.
> > > 
> > 
> > oom_killer_disable() was added to that path for a reason when all threads 
> > are frozen: memory allocations still occur in the suspend path in an oom 
> > condition and adding the oom_killer_disable() will cause those 
> > allocations to fail rather than sending pointless SIGKILLs to frozen 
> > threads.
> > 
> > Now consider if the only _eligible_ threads for oom kill (because of 
> > cpusets or mempolicies) are those that are frozen.  We certainly do not 
> > want to panic because other cpusets are still getting work done.  We'd 
> > either want to add a mem to the cpuset or thaw the processes because the 
> > cpuset is oom.
> 
> Sure.
> 
> > 
> > You can't just selectively skip certain threads when their state can be 
> > temporary without risking a panic.  That's why this patch is a 
> > non-starter.
> > 
> > A much better solution would be to lower the badness score that the oom 
> > killer uses for PF_FROZEN threads so that they aren't considered a 
> > priority for kill unless there's nothing else left to kill.
> 
> Yes, sounds better.

.. but still not sufficient. We also have to thaw the process
as well. Just a quick hacked up patch (not tested, just for an
illustration).
Would something like this work?
--- 
