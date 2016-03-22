Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C1B646B025E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 09:08:25 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id p65so191833590wmp.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 06:08:25 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id kd3si37275308wjb.84.2016.03.22.06.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 06:08:24 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r129so17679513wmr.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 06:08:24 -0700 (PDT)
Date: Tue, 22 Mar 2016 14:08:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/9] sched: add schedule_timeout_idle()
Message-ID: <20160322130822.GF10381@dhcp22.suse.cz>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
 <1458644426-22973-2-git-send-email-mhocko@kernel.org>
 <20160322122345.GN6344@twins.programming.kicks-ass.net>
 <20160322123314.GD10381@dhcp22.suse.cz>
 <20160322125113.GO6344@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160322125113.GO6344@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>

On Tue 22-03-16 13:51:13, Peter Zijlstra wrote:
> On Tue, Mar 22, 2016 at 01:33:14PM +0100, Michal Hocko wrote:
> > On Tue 22-03-16 13:23:45, Peter Zijlstra wrote:
> > > On Tue, Mar 22, 2016 at 12:00:18PM +0100, Michal Hocko wrote:
> > > 
> > > >  extern signed long schedule_timeout_interruptible(signed long timeout);
> > > >  extern signed long schedule_timeout_killable(signed long timeout);
> > > >  extern signed long schedule_timeout_uninterruptible(signed long timeout);
> > > > +extern signed long schedule_timeout_idle(signed long timeout);
> > > 
> > > > +/*
> > > > + * Like schedule_timeout_uninterruptible(), except this task will not contribute
> > > > + * to load average.
> > > > + */
> > > > +signed long __sched schedule_timeout_idle(signed long timeout)
> > > > +{
> > > > +	__set_current_state(TASK_IDLE);
> > > > +	return schedule_timeout(timeout);
> > > > +}
> > > > +EXPORT_SYMBOL(schedule_timeout_idle);
> > > 
> > > Yes we have 3 such other wrappers, but I've gotta ask: why? They seem
> > > pretty pointless.
> > 
> > It seems it is just too easy to miss the __set_current_state (I am
> > talking from my own experience).
> 
> Well, that's what you get; if you call schedule() and forget to set a
> blocking state you also don't block, where the problem?

The error prone nature of schedule_timeout usage was the reason to
introduce them in the first place IIRC which makes me think this is
something that is not so uncommon.
 
[...]

> > > Why not kill the lot?
> > 
> > We have over 400 users, would it be much better if we open code all of
> > them? It doesn't sound like a huge win to me.
> 
> Dunno, changing them around isn't much work, we've got coccinelle for
> that.

If that sounds like a more appropriate plan I won't object. I can simply
change my patch to do __set_current_state and schedule_timeout.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
