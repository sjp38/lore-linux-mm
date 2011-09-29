Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 91CCF9000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 09:02:09 -0400 (EDT)
Date: Thu, 29 Sep 2011 15:02:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] oom: thaw threads if oom killed thread is frozen before
 deferring
Message-ID: <20110929130204.GG21113@tiehlicka.suse.cz>
References: <cover.1317110948.git.mhocko@suse.cz>
 <65d9dff7ff78fad1f146e71d32f9f92741281b46.1317110948.git.mhocko@suse.cz>
 <alpine.DEB.2.00.1109271133590.17876@chino.kir.corp.google.com>
 <20110928104445.GB15062@tiehlicka.suse.cz>
 <20110929115105.GE21113@tiehlicka.suse.cz>
 <20110929120517.GA10587@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110929120517.GA10587@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 29-09-11 14:05:17, Oleg Nesterov wrote:
> On 09/29, Michal Hocko wrote:
> >
> > --- a/kernel/freezer.c
> > +++ b/kernel/freezer.c
> > @@ -48,6 +48,10 @@ void refrigerator(void)
> >  	current->flags |= PF_FREEZING;
> >  
> >  	for (;;) {
> > +		if (fatal_signal_pending(current)) {
> > +			current->flags &= ~PF_FROZEN;
> 
> We can't do this.
> 
> If PF_FROZEN was set, we must not modify current->flags, this can
> race with, say, thaw_process().

OK, I see.

> 
> OK, we can take task_lock(), but this doesn't close other races.
> Say, a SIGKILL'ed task can do try_to_freeze(). Perhaps we should
> simply call thaw_process() unconditionally, this also clears
> TIF_FREEZE. 
> Or check freezing() || frozen(). Afacis this solves
> the race you described.

Sounds reasonable.

> 
> But of course this can't help if freeze_task() is called later.
> May be freezable() should check TIF_MEMDIE...

Wouldn't it be easier to ignore try_to_freeze when fatal signals are
pending in get_signal_to_deliver? This would mean that we wouldn't get
back to refrigerator just to get out of it.
What about the patch bellow?

> 
> Oleg.

Thanks!

---
