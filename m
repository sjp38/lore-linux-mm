Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 860369000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:35:59 -0400 (EDT)
Date: Mon, 26 Sep 2011 10:35:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/2] oom: give bonus to frozen processes
Message-ID: <20110926083555.GD10156@tiehlicka.suse.cz>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1108261110020.13943@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri 26-08-11 11:13:40, David Rientjes wrote:
> On Fri, 26 Aug 2011, Michal Hocko wrote:
[...]
> > I am not saying the bonus is necessary, though. It depends on what
> > the freezer is used for (e.g. freeze a process which went wild and
> > debug what went wrong wouldn't welcome that somebody killed it or other
> > (mis)use which relies on D state).
[...]
> If it actually does come down to a heuristic change, then it need not 
> happen in the oom killer: the freezing code would need to use 
> test_set_oom_score_adj() to temporarily reduce the oom_score_adj for that 
> task until it comes out of the refrigerator.  We already use that in ksm 
> and swapoff to actually prefer threads, but we can use it to bias against 
> threads as well.

Let's try it with a heuristic change first. If you really do not like
it, we can move to oom_scode_adj. I like the heuristic change little bit
more because it is at the same place as the root bonus.
---
