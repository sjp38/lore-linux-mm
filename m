Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AEEBE6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 07:01:57 -0400 (EDT)
Date: Fri, 26 Aug 2011 13:01:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: skip frozen tasks
Message-ID: <20110826110150.GD9083@tiehlicka.suse.cz>
References: <20110824101927.GB3505@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
 <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com>
 <20110825164758.GB22564@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
 <20110826070946.GA7280@tiehlicka.suse.cz>
 <20110826085610.GA9083@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
 <20110826095356.GB9083@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110826095356.GB9083@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri 26-08-11 11:53:56, Michal Hocko wrote:
> On Fri 26-08-11 02:21:42, David Rientjes wrote:
> > On Fri, 26 Aug 2011, Michal Hocko wrote:
> > 
> > > Let's give all frozen tasks a bonus (OOM_SCORE_ADJ_MAX/2) so that we do
> > > not consider them unless really necessary and if we really pick up one
> > > then thaw its threads before we try to kill it.
> > > 
> > 
> > I don't like arbitrary heuristics like this because they polluted the old 
> > oom killer before it was rewritten and made it much more unpredictable.  
> > The only heuristic it includes right now is a bonus for root tasks so that 
> > when two processes have nearly the same amount of memory usage (within 3% 
> > of available memory), the non-root task is chosen instead.
> > 
> > This bonus is actually saying that a single frozen task can use up to 50% 
> > more of the machine's capacity in a system-wide oom condition than the 
> > task that will now be killed instead.  That seems excessive.
> 
> Yes, the number is probably too high. I just wanted to start up with
> something. Maybe we can give it another root bonus. But I agree whatever
> we use it will be just a random value...
> 
> > 
> > I do like the idea of automatically thawing the task though and if that's 
> > possible then I don't think we need to manipulate the badness heuristic at 
> > all.  I know that wouldn't be feasible when we've frozen _all_ threads and 
> 
> Why it wouldn't be feasible for all threads? If you have all tasks
> frozen (suspend going on, whole cgroup or all tasks in a cpuset/nodemask
> are frozen) then the selection is more natural because all of them are
> equal (with or without a bonus). The bonus tries to reduce thawing if
> not all of them are frozen.
> I am not saying the bonus is necessary, though. It depends on what
> the freezer is used for (e.g. freeze a process which went wild and
> debug what went wrong wouldn't welcome that somebody killed it or other
> (mis)use which relies on D state).

Anyway, I do agree, the two things (bonus and thaw during oom_kill)
should be handled separately.

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
