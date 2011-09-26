Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF2E9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:28:45 -0400 (EDT)
Date: Mon, 26 Sep 2011 10:28:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/2] oom: do not live lock on frozen tasks
Message-ID: <20110926082837.GC10156@tiehlicka.suse.cz>
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
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

[Let's add some more people to CC list]

Sorry it took so long but I was quite bussy recently.

On Fri 26-08-11 11:13:40, David Rientjes wrote:
> On Fri, 26 Aug 2011, Michal Hocko wrote:
[...]
> > I am not saying the bonus is necessary, though. It depends on what
> > the freezer is used for (e.g. freeze a process which went wild and
> > debug what went wrong wouldn't welcome that somebody killed it or other
> > (mis)use which relies on D state).
> > 
> 
> I'd love to be able to do a thaw on a PF_FROZEN task in the oom killer 
> followed by a SIGKILL if that task is selected for oom kill without an 
> heuristic change.  Not sure if that's possible, so we'll wait for Rafael 
> to chime in.

We have discussed that with Rafael and it should be safe to do that. See
the patch bellow.
The only place I am not entirely sure about is run_guest
(drivers/lguest/core.c). It seems that the code is able to cope with
signals but it also calls lguest_arch_run_guest after try_to_freeze.
---
