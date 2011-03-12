Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 16EB78D003A
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 07:43:00 -0500 (EST)
Date: Sat, 12 Mar 2011 13:34:13 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
Message-ID: <20110312123413.GA18351@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On 03/11, David Rientjes wrote:
>
> On Wed, 9 Mar 2011, Andrew Morton wrote:
>
> > If Oleg's test program cause a hang with
> > oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch and doesn't
> > cause a hang without
> > oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch then that's a
> > big problem for
> > oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch, no?
> >
>
> It's a problem, but not because of
> oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch.

It is, afaics. oom-killer can't ussume that a single PF_EXITING && p->mm
thread is going to free the memory.

> If we don't
> have this patch, then we have a trivial panic when an oom kill occurs in a
> cpuset with no other eligible processes, the oom killed thread group
> leader exits

It is not clear what "leader exits" actually mean. OK, perhaps you mean
its ->mm == NULL.

> but its other threads do not and they trigger oom kills
> themselves.  for_each_process() does not iterate over these threads and so
> it finds no eligible threads to kill and then panics

Could you explain what do you mean? No need to kill these threads, they
are already killed, we should wait until they all exit.

> I'll look at Oleg's test case
> and see what can be done to fix that condition, but the answer isn't to
> ignore eligible threads that can be killed.

Once again, they are already killed. Or I do not understand what you meant.

Could you please explain the problem in more details?


Also. Could you please look at the patches I sent?

	[PATCH 1/1] oom_kill_task: mark every thread as TIF_MEMDIE
	[PATCH v2 1/1] select_bad_process: improve the PF_EXITING check

Note also the note about "p == current" check. it should be fixed too.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
