Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 72C536B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 06:43:47 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id p65so18010398wmp.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 03:43:47 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id v71si26031896wmd.18.2016.03.23.03.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 03:43:46 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id u125so3183786wmg.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 03:43:45 -0700 (PDT)
Date: Wed, 23 Mar 2016 11:43:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/9] sched: add schedule_timeout_idle()
Message-ID: <20160323104344.GC7059@dhcp22.suse.cz>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
 <1458644426-22973-2-git-send-email-mhocko@kernel.org>
 <20160322122345.GN6344@twins.programming.kicks-ass.net>
 <20160322123314.GD10381@dhcp22.suse.cz>
 <20160322125113.GO6344@twins.programming.kicks-ass.net>
 <20160322130822.GF10381@dhcp22.suse.cz>
 <20160322132249.GP6344@twins.programming.kicks-ass.net>
 <20160322175626.GA13302@cmpxchg.org>
 <20160322212352.GF6356@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160322212352.GF6356@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>

On Tue 22-03-16 22:23:52, Peter Zijlstra wrote:
[...]
> Probably. However, with such semantics the schedule*() name is wrong
> too, you cannot use these functions to build actual wait loops etc.
> 
> So maybe:
> 
> static inline long sleep_in_state(long timeout, long state)
> {
> 	__set_current_state(state);
> 	return schedule_timeout(timeout);
> }
> 
> might be an even better name; but at that point we look very like the
> msleep*() class of function, so maybe we should do:
> 
> long sleep_in_state(long state, long timeout)
> {
> 	while (timeout && !signal_pending_state(state, current)) {
> 		__set_current_state(state);
> 		timeout = schedule_timeout(timeout);
> 	}
> 	return timeout;
> }
> 
> Hmm ?

I am not sure how many callers do care about premature wake-ups (e.g
I could find a use for it) but this indeed has a better and cleaner
semantic.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
