Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 370306B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 22:27:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id l30so22509553pgc.15
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 19:27:45 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p16si5531278pli.219.2017.08.14.19.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 19:27:44 -0700 (PDT)
Date: Mon, 14 Aug 2017 19:27:43 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170815022743.GB28715@tassilo.jf.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Aug 14, 2017 at 06:48:06PM -0700, Linus Torvalds wrote:
> On Mon, Aug 14, 2017 at 5:52 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
> > We encountered workloads that have very long wake up list on large
> > systems. A waker takes a long time to traverse the entire wake list and
> > execute all the wake functions.
> >
> > We saw page wait list that are up to 3700+ entries long in tests of large
> > 4 and 8 socket systems.  It took 0.8 sec to traverse such list during
> > wake up.  Any other CPU that contends for the list spin lock will spin
> > for a long time.  As page wait list is shared by many pages so it could
> > get very long on systems with large memory.
> 
> I really dislike this patch.
> 
> The patch seems a band-aid for really horrible kernel behavior, rather
> than fixing the underlying problem itself.
> 
> Now, it may well be that we do end up needing this band-aid in the
> end, so this isn't a NAK of the patch per se. But I'd *really* like to
> see if we can fix the underlying cause for what you see somehow..

We could try it and it may even help in this case and it may
be a good idea in any case on such a system, but:

- Even with a large hash table it might be that by chance all CPUs
will be queued up on the same page
- There are a lot of other wait queues in the kernel and they all
could run into a similar problem
- I suspect it's even possible to construct it from user space
as a kind of DoS attack

Given all that I don't see any alternative to fixing wait queues somehow.
It's just that systems are so big that now that they're starting to
stretch the tried old primitives.

Now in one case (on a smaller system) we debugged we had

- 4S system with 208 logical threads
- during the test the wait queue length was 3700 entries.
- the last CPUs queued had to wait roughly 0.8s

This gives a budget of roughly 1us per wake up. 

It could be that we could find some way to do "bulk wakeups" 
in the scheduler that are much cheaper, and switch to them if
there are a lot of entries in the wait queues. 

With that it may be possible to do a wake up in less than 1us.

But even with that it will be difficult to beat the scaling
curve. If systems get bigger again (and they will be) it
could easily break again, as the budget gets smaller and smaller.

Also disabling interrupts for that long is just nasty.

Given all that I still think a lock breaker of some form is needed.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
