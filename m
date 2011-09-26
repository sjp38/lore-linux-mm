Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 678A29000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:32:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 76A7B3EE0C0
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:32:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5091A45DE89
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:32:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BF9345DE7E
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:32:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A076E08003
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:32:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF2521DB8041
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:32:00 +0900 (JST)
Date: Mon, 26 Sep 2011 18:31:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] oom: give bonus to frozen processes
Message-Id: <20110926183115.277afeb1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1109260157270.1389@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
	<20110825091920.GA22564@tiehlicka.suse.cz>
	<20110825151818.GA4003@redhat.com>
	<20110825164758.GB22564@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
	<20110826070946.GA7280@tiehlicka.suse.cz>
	<20110826085610.GA9083@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
	<20110826095356.GB9083@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1108261110020.13943@chino.kir.corp.google.com>
	<20110926083555.GD10156@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1109260157270.1389@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Mon, 26 Sep 2011 02:02:59 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 26 Sep 2011, Michal Hocko wrote:
> 
> > Let's try it with a heuristic change first. If you really do not like
> > it, we can move to oom_scode_adj. I like the heuristic change little bit
> > more because it is at the same place as the root bonus.
> 
> The problem with the bonus is that, as mentioned previously, it doesn't 
> protect against ANYTHING for the case you're trying to fix.  This won't 
> panic the machine because all killable threads are guaranteed to have a 
> non-zero badness score, but it's a very valid configuration to have either
> 
>  - all eligible threads (system-wide, shared cpuset, shared mempolicy 
>    nodes) are frozen, or
> 
>  - all eligible frozen threads use <5% of memory whereas all other 
>    eligible killable threads use 1% of available memory.
> 
> and that means the oom killer will repeatedly select those threads and the 
> livelock still exists unless you can guarantee that they are successfully 
> thawed, that thawing them in all situations is safe, and that once thawed 
> they will make a timely exit.
> 
> Additionally, I don't think biasing against frozen tasks makes sense from 
> a heusritic standpoint of the oom killer.  Why would we want give 
> non-frozen tasks that are actually getting work done a preference over a 
> task that is frozen and doing absolutely nothing?  It seems like that's 
> backwards and that we'd actually prefer killing the task doing nothing so 
> it can free its memory.
> 

I agree with David.
Why don't you set oom_score_adj as -1000 for processes which never should die ?
You don't freeze processes via user-land using cgroup ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
