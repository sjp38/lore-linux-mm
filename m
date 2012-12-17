Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 465D86B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 05:33:58 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so2822611bkc.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 02:33:56 -0800 (PST)
Date: Mon, 17 Dec 2012 11:33:50 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121217103350.GA1644@gmail.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
 <20121210113945.GA7550@gmail.com>
 <20121210152405.GJ1009@suse.de>
 <20121211010201.GP1009@suse.de>
 <20121211085238.GA21673@gmail.com>
 <20121211163017.GR1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121211163017.GR1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > > [...] Holding PTL across task_numa_fault is bad, but not 
> > > the bad we're looking for.
> > 
> > No, holding the PTL across task_numa_fault() is fine, 
> > because this bit got reworked in my tree rather 
> > significantly, see:
> > 
> >  6030a23a1c66 sched: Move the NUMA placement logic to a 
> >  worklet
> > 
> > and followup patches.
> 
> I believe I see your point. After that patch is applied 
> task_numa_fault() is a relatively small function and is no 
> longer calling task_numa_placement. Sure, PTL is held longer 
> than necessary but not enough to cause real scalability 
> issues.

Yes - my motivation for that was three-fold:

1) to push rebalancing into process context and thus make it
   essentially lockless and also potentially preemptable.

2) enable the flip-tasks logic, which relies on taking a
   balancing decision and acting on it immediately. If you are
   in process context then this is doable. If you are in a
   balancing irq context then not so much.

3) to simplify the 2M-emu loop was extra dressing on the cake:
   instead of taking and dropping the PTL 512 times (possibly
   interleaving two threads on the same pmd, both of them
   taking/dropping the same set of locks?), it only takes the
   ptl once.

I'll revive this aspect, it has many positives.

> > > If the bug is indeed here, it's not obvious. I don't know 
> > > why I'm triggering it or why it only triggers for specjbb 
> > > as I cannot imagine what the JVM would be doing that is 
> > > that weird or that would not have triggered before. Maybe 
> > > we both suffer this type of problem but that numacores 
> > > rate of migration is able to trigger it.
> > 
> > Agreed.
> 
> I spent some more time on this today and the bug is *really* 
> hard to trigger or at least I have been unable to trigger it 
> today. This begs the question why it triggered three times in 
> relatively quick succession separated by a few hours when 
> testing numacore on Dec 9th. Other tests ran between the 
> failures. The first failure results were discarded. I deleted 
> them to see if the same test reproduced it a second time (it 
> did).
>
> Of the three times this bug triggered in the last week, two 
> were unclear where they crashed but one showed that the bug 
> was triggered by the JVMs garbage collector. That at least is 
> a corner case and might explain why it's hard to trigger.
> 
> I feel extremely bad about how I reported this because even 
> though we differ in how we handle faults, I really cannot see 
> any difference that would explain this and I've looked long 
> enough. Triggering this by the kernel would *have* to be 
> something like missing a cache or TLB flush after page tables 
> have been modified or during migration but in most way that 
> matters we share that logic. Where we differ, it shouldn't 
> matter.

Don't worry, I really think you reported a genuine bug, even if 
it's hard to hit.

> FWIW, numacore pulled yesterday completed the same tests 
> without any error this time but none of the commits since Dec 
> 9th would account for fixing it.

Correct. I think chances are that it's still latent. Either 
fixed in your version of the code, which will be hard to 
reconstruct - or it's an active upstream bug.

I'd not blame it on the JVM for a good while - JVMs are one of 
the most abused pieces of code on the planet, literally running 
millions of applications on thousands of kernel variants.

Could you try the patch below on latest upstream with 
CONFIG_NUMA_BALANCING=y, it increases migration bandwidth 
10-fold - does it make it easier to trigger the bug on the now 
upstream NUMA-balancing feature?

It will kill throughput on a number of your tests, but it should 
make all the NUMA-specific activities during the JVM test a lot 
more frequent.

Thanks,

	Ingo

diff --git a/mm/migrate.c b/mm/migrate.c
index 32efd80..8699e8f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1511,7 +1511,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
  */
 static unsigned int migrate_interval_millisecs __read_mostly = 100;
 static unsigned int pteupdate_interval_millisecs __read_mostly = 1000;
-static unsigned int ratelimit_pages __read_mostly = 128 << (20 - PAGE_SHIFT);
+static unsigned int ratelimit_pages __read_mostly = 1280 << (20 - PAGE_SHIFT);
 
 /* Returns true if NUMA migration is currently rate limited */
 bool migrate_ratelimited(int node)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
