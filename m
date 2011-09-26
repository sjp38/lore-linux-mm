Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DD96A9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:54:20 -0400 (EDT)
Date: Mon, 26 Sep 2011 11:54:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] oom: give bonus to frozen processes
Message-ID: <20110926095416.GG10156@tiehlicka.suse.cz>
References: <20110825164758.GB22564@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
 <20110826070946.GA7280@tiehlicka.suse.cz>
 <20110826085610.GA9083@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
 <20110826095356.GB9083@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108261110020.13943@chino.kir.corp.google.com>
 <20110926083555.GD10156@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1109260157270.1389@chino.kir.corp.google.com>
 <20110926183115.277afeb1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110926183115.277afeb1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Mon 26-09-11 18:31:15, KAMEZAWA Hiroyuki wrote:
> On Mon, 26 Sep 2011 02:02:59 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Mon, 26 Sep 2011, Michal Hocko wrote:
> > 
> > > Let's try it with a heuristic change first. If you really do not like
> > > it, we can move to oom_scode_adj. I like the heuristic change little bit
> > > more because it is at the same place as the root bonus.
> > 
> > The problem with the bonus is that, as mentioned previously, it doesn't 
> > protect against ANYTHING for the case you're trying to fix.  

Yes, it just makes this less probable.


> > This won't panic the machine because all killable threads are
> > guaranteed to have a non-zero badness score, but it's a very valid
> > configuration to have either
> > 
> >  - all eligible threads (system-wide, shared cpuset, shared mempolicy 
> >    nodes) are frozen, or
> > 
> >  - all eligible frozen threads use <5% of memory whereas all other 
> >    eligible killable threads use 1% of available memory.
> > 
> > and that means the oom killer will repeatedly select those threads and the 
> > livelock still exists unless you can guarantee that they are successfully 
> > thawed, that thawing them in all situations is safe, and that once thawed 
> > they will make a timely exit.

Yes, this is what the first patch is fixing. Thawed tasks should die
almost immediately because they are on the way to userspace anyway.

> > 
> > Additionally, I don't think biasing against frozen tasks makes sense from 
> > a heusritic standpoint of the oom killer.  Why would we want give 
> > non-frozen tasks that are actually getting work done a preference over a 
> > task that is frozen and doing absolutely nothing?  

Because frozen tasks are in that state usually (not considering suspend
path which has OOM disabled) based on an user request (via freezer
cgroup e.g.). I wouldn't be surprised if somebody relied on the D state
and that the task will not get killer.

> > It seems like that's backwards and that we'd actually prefer killing
> > the task doing nothing so it can free its memory.
> > 
> 
> I agree with David.
> Why don't you set oom_score_adj as -1000 for processes which never should die ?

It is little bit unintuitive to think about OOM killer when you just
want to debug your frozen application.
On the other hand I agree that adding a new heuristic for an use case
that is not entirely clear and which is not 100% anyway is not good.

So, please scratch this patch and let's wait for somebody with a valid
use case.

> You don't freeze processes via user-land using cgroup ?

That was exactly the use case I had in mind. Somebody using freezer
cgroup to freeze a task to debug it.

> 
> Thanks,
> -Kame
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
