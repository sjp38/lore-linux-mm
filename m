Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 402EC5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 15:49:22 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3KJkhOu025334
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 15:46:43 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3KJo3vr176180
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 15:50:03 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3KJo2Mo029777
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 15:50:03 -0400
Subject: Re: [PATCH V3] Fix Committed_AS underflow
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1240244120.32604.278.camel@nimitz>
References: <1240218590-16714-1-git-send-email-ebmunson@us.ibm.com>
	 <1240244120.32604.278.camel@nimitz>
Content-Type: text/plain
Date: Mon, 20 Apr 2009 12:49:59 -0700
Message-Id: <1240256999.32604.330.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@linux.vnet.ibm.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-04-20 at 09:15 -0700, Dave Hansen wrote:
> On Mon, 2009-04-20 at 10:09 +0100, Eric B Munson wrote:
> > 1. Change NR_CPUS to min(64, NR_CPUS)
> >    This will limit the amount of possible skew on kernels compiled for very
> >    large SMP machines.  64 is an arbitrary number selected to limit the worst
> >    of the skew without using more cache lines.  min(64, NR_CPUS) is used
> >    instead of nr_online_cpus() because nr_online_cpus() requires a shared
> >    cache line and a call to hweight to make the calculation.  Its runtime
> >    overhead and keeping this counter accurate showed up in profiles and it's
> >    possible that nr_online_cpus() would also show.

Wow, that empty reply was really informative, wasn't it? :)

My worry with this min(64, NR_CPUS) approach is that you effectively
ensure that you're going to be doing a lot more cacheline bouncing, but
it isn't quite as explicit.

Now, every time there's a mapping (or set of them) created or destroyed
that nets greater than 64 pages, you've got to go get a r/w cacheline to
a possibly highly contended atomic.  With a number this low, you're
almost guaranteed to hit it at fork() and exec().  Could you
double-check that this doesn't hurt any of the fork() AIM tests?

Another thought is that, instead of trying to fix this up in meminfo, we
could do this in a way that is guaranteed to never skew the global
counter negative: we always keep the *percpu* skew negative.  This
should be the same as what's in the kernel now:

void vm_acct_memory(long pages)
{
        long *local;
	long local_min = -ACCT_THRESHOLD;
	long local_max = ACCT_THRESHOLD;
	long local_goal = 0;

        preempt_disable();
        local = &__get_cpu_var(committed_space);
        *local += pages;
        if (*local > local_max || *local < local_min) {
                atomic_long_add(*local - local_goal, &vm_committed_space);
                *local = local_goal;
        }
        preempt_enable();
}

But now consider if we changed the local_* variables a bit:

	long local_min = -(ACCT_THRESHOLD*2);
	long local_max = 0
	long local_goal = -ACCT_THRESHOLD;

We'll get some possibly *large* numbers in meminfo, but it will at least
never underflow.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
