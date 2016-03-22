Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 07BDE6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 17:24:05 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id x3so326760846pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 14:24:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 76si4693014pfb.3.2016.03.22.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 14:24:04 -0700 (PDT)
Date: Tue, 22 Mar 2016 22:23:52 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/9] sched: add schedule_timeout_idle()
Message-ID: <20160322212352.GF6356@twins.programming.kicks-ass.net>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
 <1458644426-22973-2-git-send-email-mhocko@kernel.org>
 <20160322122345.GN6344@twins.programming.kicks-ass.net>
 <20160322123314.GD10381@dhcp22.suse.cz>
 <20160322125113.GO6344@twins.programming.kicks-ass.net>
 <20160322130822.GF10381@dhcp22.suse.cz>
 <20160322132249.GP6344@twins.programming.kicks-ass.net>
 <20160322175626.GA13302@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160322175626.GA13302@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 22, 2016 at 01:56:26PM -0400, Johannes Weiner wrote:
> On Tue, Mar 22, 2016 at 02:22:49PM +0100, Peter Zijlstra wrote:
> > On Tue, Mar 22, 2016 at 02:08:23PM +0100, Michal Hocko wrote:
> > > On Tue 22-03-16 13:51:13, Peter Zijlstra wrote:
> > > If that sounds like a more appropriate plan I won't object. I can simply
> > > change my patch to do __set_current_state and schedule_timeout.
> > 
> > I dunno, I just think these wrappers are silly.
> 
> Adding out-of-line, exported wrappers for every single task state is
> kind of silly. But it's still a common operation to wait in a certain
> state, so having a single function for that makes sense. Kind of like
> spin_lock_irqsave and friends.
> 
> Maybe this would be better?:
> 
> static inline long schedule_timeout_state(long timeout, long state)
> {
> 	__set_current_state(state);
> 	return schedule_timeout(timeout);
> }

Probably. However, with such semantics the schedule*() name is wrong
too, you cannot use these functions to build actual wait loops etc.

So maybe:

static inline long sleep_in_state(long timeout, long state)
{
	__set_current_state(state);
	return schedule_timeout(timeout);
}

might be an even better name; but at that point we look very like the
msleep*() class of function, so maybe we should do:

long sleep_in_state(long state, long timeout)
{
	while (timeout && !signal_pending_state(state, current)) {
		__set_current_state(state);
		timeout = schedule_timeout(timeout);
	}
	return timeout;
}

Hmm ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
