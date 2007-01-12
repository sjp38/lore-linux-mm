Date: Fri, 12 Jan 2007 08:01:04 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: High lock spin time for zone->lru_lock under extreme conditions
Message-ID: <20070112160104.GA5766@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>, pravin b shelar <pravin.shelar@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

Hi,
We noticed high interrupt hold off times while running some memory intensive
tests on a Sun x4600 8 socket 16 core x86_64 box.  We noticed softlockups,
lost ticks and even wall time drifting (which is probably a bug in the
x86_64 timer subsystem). 

The test was simple, we have 16 processes, each allocating 3.5G of memory
and and touching each and every page and returning.  Each of the process is
bound to a node (socket), with the local node being the preferred node for
allocation (numactl --cpubind=$node ./numa-membomb --preferred=$node).  Each
socket has 4G of physical memory and there are two cores on each socket. On
start of the test, the machine becomes unresponsive after sometime and
prints out softlockup and OOM messages.  We then found out the cause
for softlockups being the excessive spin times on zone_lru lock.  The fact
that spin_lock_irq disables interrupts while spinning made matters very bad.
We instrumented the spin_lock_irq code and found that the spin time on the
lru locks was in the order of a few seconds (tens of seconds at times) and
the hold time was comparatively lesser.

We did not use any lock debugging options and used plain old rdtsc to
measure cycles.  (We disable cpu freq scaling in the BIOS). All we did was
this:

void __lockfunc _spin_lock_irq(spinlock_t *lock)
{
        local_irq_disable();
        ------------------------> rdtsc(t1);
        preempt_disable();
        spin_acquire(&lock->dep_map, 0, 0, _RET_IP_);
        _raw_spin_lock(lock);
        ------------------------> rdtsc(t2);
        if (lock->spin_time < (t2 - t1))
                lock->spin_time = t2 - t1;
}

On some runs, we found that the zone->lru_lock spun for 33 seconds or more
while the maximal CS time was 3 seconds or so.

While the softlockups and the like went away by enabling interrupts during
spinning, as mentioned in http://lkml.org/lkml/2007/1/3/29 ,
Andi thought maybe this is exposing a problem with zone->lru_locks and 
hence warrants a discussion on lkml, hence this post.  Are there any 
plans/patches/ideas to address the spin time under such extreme conditions?

I will be happy to provide any additional information (config/dmesg/test
case if needed.

Thanks,
Kiran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
