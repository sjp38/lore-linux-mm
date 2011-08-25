Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CFFDA6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 17:14:27 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p7PLENU0024797
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:14:23 -0700
Received: from qyk4 (qyk4.prod.google.com [10.241.83.132])
	by hpaq6.eem.corp.google.com with ESMTP id p7PLE8kj030234
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:14:22 -0700
Received: by qyk4 with SMTP id 4so4447757qyk.13
        for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:14:22 -0700 (PDT)
Date: Thu, 25 Aug 2011 14:14:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: skip frozen tasks
In-Reply-To: <20110825164758.GB22564@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
References: <20110823073101.6426.77745.stgit@zurg> <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com> <20110824101927.GB3505@tiehlicka.suse.cz> <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com> <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com> <20110825164758.GB22564@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, 25 Aug 2011, Michal Hocko wrote:

> > > > That's obviously false since we call oom_killer_disable() in 
> > > > freeze_processes() to disable the oom killer from ever being called in the 
> > > > first place, so this is something you need to resolve with Rafael before 
> > > > you cause more machines to panic.
> > >
> > > I didn't mean suspend/resume path (that is protected by oom_killer_disabled)
> > > so the patch doesn't make any change.
> > 
> > Confused... freeze_processes() does try_to_freeze_tasks() before
> > oom_killer_disable() ?
> 
> Yes you are right, I must have been blind. 
> 
> Now I see the point. We do not want to panic while we are suspending and
> the memory is really low just because all the userspace is already in
> the the fridge.
> Sorry for confusion.
> 
> I still do not follow the oom_killer_disable note from David, though.
> 

oom_killer_disable() was added to that path for a reason when all threads 
are frozen: memory allocations still occur in the suspend path in an oom 
condition and adding the oom_killer_disable() will cause those 
allocations to fail rather than sending pointless SIGKILLs to frozen 
threads.

Now consider if the only _eligible_ threads for oom kill (because of 
cpusets or mempolicies) are those that are frozen.  We certainly do not 
want to panic because other cpusets are still getting work done.  We'd 
either want to add a mem to the cpuset or thaw the processes because the 
cpuset is oom.

You can't just selectively skip certain threads when their state can be 
temporary without risking a panic.  That's why this patch is a 
non-starter.

A much better solution would be to lower the badness score that the oom 
killer uses for PF_FROZEN threads so that they aren't considered a 
priority for kill unless there's nothing else left to kill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
