Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 392F4900138
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 14:13:46 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p7QIDiDh002275
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:13:44 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz33.hot.corp.google.com with ESMTP id p7QIBwcG014024
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:13:43 -0700
Received: by pzk37 with SMTP id 37so4637757pzk.1
        for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:13:42 -0700 (PDT)
Date: Fri, 26 Aug 2011 11:13:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: skip frozen tasks
In-Reply-To: <20110826095356.GB9083@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1108261110020.13943@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com> <20110824101927.GB3505@tiehlicka.suse.cz> <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com> <20110825091920.GA22564@tiehlicka.suse.cz> <20110825151818.GA4003@redhat.com>
 <20110825164758.GB22564@tiehlicka.suse.cz> <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com> <20110826070946.GA7280@tiehlicka.suse.cz> <20110826085610.GA9083@tiehlicka.suse.cz> <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
 <20110826095356.GB9083@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 26 Aug 2011, Michal Hocko wrote:

> > I do like the idea of automatically thawing the task though and if that's 
> > possible then I don't think we need to manipulate the badness heuristic at 
> > all.  I know that wouldn't be feasible when we've frozen _all_ threads and 
> 
> Why it wouldn't be feasible for all threads? If you have all tasks
> frozen (suspend going on, whole cgroup or all tasks in a cpuset/nodemask
> are frozen) then the selection is more natural because all of them are
> equal (with or without a bonus). The bonus tries to reduce thawing if
> not all of them are frozen.

Yeah, this comment wasn't in reference to your heuristic change, it was in 
reference to the fact that if all threads are frozen then there is little 
hope for us recovering from the situation without a user response.  I 
think that's why we want oom_killer_disable() so that we avoid looping 
forever and can actually fail allocations in the hope that we'll bring 
ourselves out of suspend.

> I am not saying the bonus is necessary, though. It depends on what
> the freezer is used for (e.g. freeze a process which went wild and
> debug what went wrong wouldn't welcome that somebody killed it or other
> (mis)use which relies on D state).
> 

I'd love to be able to do a thaw on a PF_FROZEN task in the oom killer 
followed by a SIGKILL if that task is selected for oom kill without an 
heuristic change.  Not sure if that's possible, so we'll wait for Rafael 
to chime in.

If it actually does come down to a heuristic change, then it need not 
happen in the oom killer: the freezing code would need to use 
test_set_oom_score_adj() to temporarily reduce the oom_score_adj for that 
task until it comes out of the refrigerator.  We already use that in ksm 
and swapoff to actually prefer threads, but we can use it to bias against 
threads as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
