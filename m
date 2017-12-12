Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFD826B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 00:39:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 200so14800312pge.12
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 21:39:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v11sor3765415pgc.34.2017.12.11.21.39.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 21:39:27 -0800 (PST)
Date: Tue, 12 Dec 2017 14:39:21 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171212053921.GA1392@jagdpanzerIV>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171124152857.ahnapnwmmsricunz@pathway.suse.cz>
 <20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
 <20171128014229.GA2899@X58A-UD3R>
 <20171208140022.uln4t5e5drrhnvvt@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208140022.uln4t5e5drrhnvvt@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, kernel-team@lge.com

Hello,

On (12/08/17 15:00), Petr Mladek wrote:
[..]
> > However, now that cross-release was introduces, lockdep can be applied
> > to semaphore operations. Actually, I have a plan to do that. I think it
> > would be better to make semaphore tracked with lockdep and remove all
> > these manual acquire() and release() here. What do you think about it?
> 
> IMHO, it would be great to add lockdep annotations into semaphore
> operations.

certain types of locks have no guaranteed lock-unlock ordering.
e.g. readers-writer locks, semaphores, etc.

for readers-writer lock we can easily have

CPU0		CPU1		CPU2		CPU3		CPU4
read_lock
		write_lock
		// sleep because
		// of CPU0
								read_lock
read_unlock			read_lock
				read_unlock	read_lock
						read_unlock
								read_unlock
								// wake up CPU1

so for CPU1 the lock was "locked" by CPU0 and "unlocked" by CPU4.

semaphore not necessarily has the mutual-exclusion property, because
its ->count is not required to be set to 1. in printk we use semaphore
with ->count == 1, but that's just an accident.

	-ss


p.s.
frankly, I don't see any "locking issues" in Steven's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
