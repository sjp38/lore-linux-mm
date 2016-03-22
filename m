Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B2D9A6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 08:51:20 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l68so162240602wml.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 05:51:20 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id bh5si28086207wjb.83.2016.03.22.05.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 05:51:15 -0700 (PDT)
Date: Tue, 22 Mar 2016 13:51:13 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/9] sched: add schedule_timeout_idle()
Message-ID: <20160322125113.GO6344@twins.programming.kicks-ass.net>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
 <1458644426-22973-2-git-send-email-mhocko@kernel.org>
 <20160322122345.GN6344@twins.programming.kicks-ass.net>
 <20160322123314.GD10381@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160322123314.GD10381@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>

On Tue, Mar 22, 2016 at 01:33:14PM +0100, Michal Hocko wrote:
> On Tue 22-03-16 13:23:45, Peter Zijlstra wrote:
> > On Tue, Mar 22, 2016 at 12:00:18PM +0100, Michal Hocko wrote:
> > 
> > >  extern signed long schedule_timeout_interruptible(signed long timeout);
> > >  extern signed long schedule_timeout_killable(signed long timeout);
> > >  extern signed long schedule_timeout_uninterruptible(signed long timeout);
> > > +extern signed long schedule_timeout_idle(signed long timeout);
> > 
> > > +/*
> > > + * Like schedule_timeout_uninterruptible(), except this task will not contribute
> > > + * to load average.
> > > + */
> > > +signed long __sched schedule_timeout_idle(signed long timeout)
> > > +{
> > > +	__set_current_state(TASK_IDLE);
> > > +	return schedule_timeout(timeout);
> > > +}
> > > +EXPORT_SYMBOL(schedule_timeout_idle);
> > 
> > Yes we have 3 such other wrappers, but I've gotta ask: why? They seem
> > pretty pointless.
> 
> It seems it is just too easy to miss the __set_current_state (I am
> talking from my own experience).

Well, that's what you get; if you call schedule() and forget to set a
blocking state you also don't block, where the problem?

> This also seems to be a pretty common
> pattern so why not wrap it under a common call.

It just seems extremely silly to create a (out-of-line even) function
for a store and a call.

> > Why not kill the lot?
> 
> We have over 400 users, would it be much better if we open code all of
> them? It doesn't sound like a huge win to me.

Dunno, changing them around isn't much work, we've got coccinelle for
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
