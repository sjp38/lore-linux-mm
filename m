Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 709CF6B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 05:19:25 -0400 (EDT)
Date: Thu, 25 Aug 2011 11:19:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: skip frozen tasks
Message-ID: <20110825091920.GA22564@tiehlicka.suse.cz>
References: <20110823073101.6426.77745.stgit@zurg>
 <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com>
 <20110824101927.GB3505@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed 24-08-11 12:31:26, David Rientjes wrote:
> On Wed, 24 Aug 2011, Michal Hocko wrote:
> 
> > When we are in the global OOM condition then you are right, we have a
> > higher chance to panic. I still find the patch an improvement because
> > encountering a frozen task and looping over it without any progress
> > (even though there are other tasks that could be killed) is more
> > probable than having no killable task at all.
> > On non-NUMA machines there is even not a big chance that somebody would
> > be able to thaw a task as the system is already on knees.
> > 
> 
> That's obviously false since we call oom_killer_disable() in 
> freeze_processes() to disable the oom killer from ever being called in the 
> first place, so this is something you need to resolve with Rafael before 
> you cause more machines to panic.

I didn't mean suspend/resume path (that is protected by oom_killer_disabled)
so the patch doesn't make any change.

Other than that you may end up with all tasks frozen by freezer cgroup
(assuming that others, that are killable, would be already killed by
OOM). But in that case who can thaw those processes when we are already
in OOM? If there is no chance to move forward then panic is more
suitable than a livelock IMO.
OK, we might be in OOM on a nodemask (cpuset or mempol) on NUMA and an
allocation on a different nodemask might still succeed and so we can
thaw those processes. This should be addressed.
What if we panicked only if constraint == CONSTRAINT_NONE?

Or am I missing something?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
