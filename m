Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8654B9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 21:03:44 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p8R13VJj012428
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:03:31 -0700
Received: from gyd8 (gyd8.prod.google.com [10.243.49.200])
	by hpaq6.eem.corp.google.com with ESMTP id p8R12G58013502
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:03:30 -0700
Received: by gyd8 with SMTP id 8so7301272gyd.11
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:03:29 -0700 (PDT)
Date: Mon, 26 Sep 2011 18:03:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] oom: do not live lock on frozen tasks
In-Reply-To: <201109261751.40688.rjw@sisk.pl>
Message-ID: <alpine.DEB.2.00.1109261801150.8510@chino.kir.corp.google.com>
References: <20110825151818.GA4003@redhat.com> <alpine.DEB.2.00.1109260154510.1389@chino.kir.corp.google.com> <20110926091440.GE10156@tiehlicka.suse.cz> <201109261751.40688.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>, Michal Hocko <mhocko@suse.cz>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

On Mon, 26 Sep 2011, Rafael J. Wysocki wrote:

> > Konstantin Khlebnikov has reported (https://lkml.org/lkml/2011/8/23/45)
> > that OOM can end up in a live lock if select_bad_process picks up a frozen
> > task.
> > Unfortunately we cannot mark such processes as unkillable to ignore them
> > because we could panic the system even though there is a chance that
> > somebody could thaw the process so we can make a forward process (e.g. a
> > process from another cpuset or with a different nodemask).
> > 
> > Let's thaw an OOM selected frozen process right after we've sent fatal
> > signal from oom_kill_task.
> > Thawing is safe if the frozen task doesn't access any suspended device
> > (e.g. by ioctl) on the way out to the userspace where we handle the
> > signal and die. Note, we are not interested in the kernel threads because
> > they are not oom killable.
> > 
> > Accessing suspended devices by a userspace processes shouldn't be an
> > issue because devices are suspended only after userspace is already
> > frozen and oom is disabled at that time.
> > 
> > run_guest (drivers/lguest/core.c) calls try_to_freeze with an user
> > context but it seems it is able to cope with signals because it
> > explicitly checks for pending signals so we should be safe.
> > 
> > Other than that userspace accesses the fridge only from the
> > signal handling routines so we are able to handle SIGKILL without any
> > negative side effects.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> 
> Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
> 

Acked-by: David Rientjes <rientjes@google.com>

Although this still seems to be problematic if the chosen thread gets 
frozen before the SIGKILL can be handled.  We don't have any checks for 
fatal_signal_pending() when freezing threads and waiting for them to exit?

Michal, could you send Andrew your revised patch with all the acked-bys?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
