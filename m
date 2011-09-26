Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAB99000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:03:08 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p8Q934AG031602
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 02:03:05 -0700
Received: from gwj17 (gwj17.prod.google.com [10.200.10.17])
	by wpaz29.hot.corp.google.com with ESMTP id p8Q92g0I015264
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 02:03:03 -0700
Received: by gwj17 with SMTP id 17so2906066gwj.24
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 02:03:03 -0700 (PDT)
Date: Mon, 26 Sep 2011 02:02:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] oom: give bonus to frozen processes
In-Reply-To: <20110926083555.GD10156@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1109260157270.1389@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com> <20110825091920.GA22564@tiehlicka.suse.cz> <20110825151818.GA4003@redhat.com> <20110825164758.GB22564@tiehlicka.suse.cz> <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
 <20110826070946.GA7280@tiehlicka.suse.cz> <20110826085610.GA9083@tiehlicka.suse.cz> <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com> <20110826095356.GB9083@tiehlicka.suse.cz> <alpine.DEB.2.00.1108261110020.13943@chino.kir.corp.google.com>
 <20110926083555.GD10156@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Mon, 26 Sep 2011, Michal Hocko wrote:

> Let's try it with a heuristic change first. If you really do not like
> it, we can move to oom_scode_adj. I like the heuristic change little bit
> more because it is at the same place as the root bonus.

The problem with the bonus is that, as mentioned previously, it doesn't 
protect against ANYTHING for the case you're trying to fix.  This won't 
panic the machine because all killable threads are guaranteed to have a 
non-zero badness score, but it's a very valid configuration to have either

 - all eligible threads (system-wide, shared cpuset, shared mempolicy 
   nodes) are frozen, or

 - all eligible frozen threads use <5% of memory whereas all other 
   eligible killable threads use 1% of available memory.

and that means the oom killer will repeatedly select those threads and the 
livelock still exists unless you can guarantee that they are successfully 
thawed, that thawing them in all situations is safe, and that once thawed 
they will make a timely exit.

Additionally, I don't think biasing against frozen tasks makes sense from 
a heusritic standpoint of the oom killer.  Why would we want give 
non-frozen tasks that are actually getting work done a preference over a 
task that is frozen and doing absolutely nothing?  It seems like that's 
backwards and that we'd actually prefer killing the task doing nothing so 
it can free its memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
