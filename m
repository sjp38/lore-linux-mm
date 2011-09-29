Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0C29000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:00:29 -0400 (EDT)
Date: Thu, 29 Sep 2011 20:00:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] oom: thaw threads if oom killed thread is frozen before
 deferring
Message-ID: <20110929180021.GA27999@tiehlicka.suse.cz>
References: <cover.1317110948.git.mhocko@suse.cz>
 <65d9dff7ff78fad1f146e71d32f9f92741281b46.1317110948.git.mhocko@suse.cz>
 <alpine.DEB.2.00.1109271133590.17876@chino.kir.corp.google.com>
 <20110928104445.GB15062@tiehlicka.suse.cz>
 <20110929115105.GE21113@tiehlicka.suse.cz>
 <20110929120517.GA10587@redhat.com>
 <20110929130204.GG21113@tiehlicka.suse.cz>
 <20110929163724.GA23773@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110929163724.GA23773@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 29-09-11 18:37:24, Oleg Nesterov wrote:
> On 09/29, Michal Hocko wrote:
> >
> > On Thu 29-09-11 14:05:17, Oleg Nesterov wrote:
> >
> > > But of course this can't help if freeze_task() is called later.
> > > May be freezable() should check TIF_MEMDIE...
> >
> > Wouldn't it be easier to ignore try_to_freeze when fatal signals are
> > pending in get_signal_to_deliver?
> 
> Oh, I don't think so. For what? This doesn't close other races, and
> in fact the fatal_signal_pending() this patch adds is itself racy,
> SIGKILL can come in between.

OK, I think I see your point. You mean that oom will send KILL after
both fatal_signal_pending in refrigerator and signal_pending check in
schedule, right?

> 
> > --- a/kernel/freezer.c
> > +++ b/kernel/freezer.c
> > @@ -48,6 +48,11 @@ void refrigerator(void)
> >  	current->flags |= PF_FREEZING;
> >
> >  	for (;;) {
> > +		if (fatal_signal_pending(current)) {
> > +			if (freezing(current) || frozen(current))
> > +				thaw_process(current);
> 
> Ah, I didn't mean refrigerator() should check freezing/frozen.
> 
> I meant, oom_kill can do this before thaw thaw_process(), afaics
> this should fix the particular race you described (but not others).

This is what the follow up fix from David is doing. Check frozen in
select_bad_process if the task is TIF_MEMDIE and thaw the process.

And it seems that the David's follow up fix is sufficient so let's leave
refrigerator alone.
Or am I still missing something?

> 
> And. It is simply wrong to return from refrigerator() after we set
> PF_FROZEN, this can fool try_to_freeze_tasks(). Sure, thaw_process()
> from oom_kill is not nice too, but at least this is the special case,
> we already have the problem.
> 
> Oleg.
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
