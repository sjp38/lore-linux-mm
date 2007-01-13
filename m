Message-ID: <45A86291.8090408@yahoo.com.au>
Date: Sat, 13 Jan 2007 15:39:45 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: High lock spin time for zone->lru_lock under extreme conditions
References: <20070112160104.GA5766@localhost.localdomain>
In-Reply-To: <20070112160104.GA5766@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>, pravin b shelar <pravin.shelar@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

Ravikiran G Thirumalai wrote:
> Hi,
> We noticed high interrupt hold off times while running some memory intensive
> tests on a Sun x4600 8 socket 16 core x86_64 box.  We noticed softlockups,

[...]

> We did not use any lock debugging options and used plain old rdtsc to
> measure cycles.  (We disable cpu freq scaling in the BIOS). All we did was
> this:
> 
> void __lockfunc _spin_lock_irq(spinlock_t *lock)
> {
>         local_irq_disable();
>         ------------------------> rdtsc(t1);
>         preempt_disable();
>         spin_acquire(&lock->dep_map, 0, 0, _RET_IP_);
>         _raw_spin_lock(lock);
>         ------------------------> rdtsc(t2);
>         if (lock->spin_time < (t2 - t1))
>                 lock->spin_time = t2 - t1;
> }
> 
> On some runs, we found that the zone->lru_lock spun for 33 seconds or more
> while the maximal CS time was 3 seconds or so.

What is the "CS time"?

It would be interesting to know how long the maximal lru_lock *hold* time is,
which could give us a better indication of whether it is a hardware problem.

For example, if the maximum hold time is 10ms, that it might indicate a
hardware fairness problem.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
