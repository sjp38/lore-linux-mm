Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B71C56B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 14:03:40 -0400 (EDT)
Date: Wed, 11 Sep 2013 14:03:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130911180327.GL856@cmpxchg.org>
References: <20130909201238.GH856@cmpxchg.org>
 <20130910201359.D0984EFF@pobox.sk>
 <20130910183740.GI856@cmpxchg.org>
 <20130910213253.A1E666C5@pobox.sk>
 <20130910201222.GA25972@cmpxchg.org>
 <20130910230853.FEEC19B5@pobox.sk>
 <20130910211823.GJ856@cmpxchg.org>
 <20130910233247.9EDF4DBA@pobox.sk>
 <20130910220329.GK856@cmpxchg.org>
 <20130911143305.FFEAD399@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130911143305.FFEAD399@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 11, 2013 at 02:33:05PM +0200, azurIt wrote:
> >On Tue, Sep 10, 2013 at 11:32:47PM +0200, azurIt wrote:
> >> >On Tue, Sep 10, 2013 at 11:08:53PM +0200, azurIt wrote:
> >> >> >On Tue, Sep 10, 2013 at 09:32:53PM +0200, azurIt wrote:
> >> >> >> Here is full kernel log between 6:00 and 7:59:
> >> >> >> http://watchdog.sk/lkml/kern6.log
> >> >> >
> >> >> >Wow, your apaches are like the hydra.  Whenever one is OOM killed,
> >> >> >more show up!
> >> >> 
> >> >> 
> >> >> 
> >> >> Yeah, it's supposed to do this ;)
> >
> >How are you expecting the machine to recover from an OOM situation,
> >though?  I guess I don't really understand what these machines are
> >doing.  But if you are overloading them like crazy, isn't that the
> >expected outcome?
> 
> 
> 
> 
> 
> There's no global OOM, server has enough of memory. OOM is occuring only in cgroups (customers who simply don't want to pay for more memory).

Yes, sure, but when the cgroups are thrashing, they use the disk and
CPU to the point where the overall system is affected.

> >> >> >> >> What do you think? I'm now running kernel with your previous patch, not with the newest one.
> >> >> >> >
> >> >> >> >Which one exactly?  Can you attach the diff?
> >> >> >> 
> >> >> >> 
> >> >> >> 
> >> >> >> I meant, the problem above occured on kernel with your latest patch:
> >> >> >> http://watchdog.sk/lkml/7-2-memcg-fix.patch
> >> >> >
> >> >> >The above log has the following callstack:
> >> >> >
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337628]  [<ffffffff810d19fe>] dump_header+0x7e/0x1e0
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337707]  [<ffffffff810d18ff>] ? find_lock_task_mm+0x2f/0x70
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337790]  [<ffffffff810d18ff>] ? find_lock_task_mm+0x2f/0x70
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337874]  [<ffffffff81094bb0>] ? __css_put+0x50/0x90
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337952]  [<ffffffff810d1ec5>] oom_kill_process+0x85/0x2a0
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338037]  [<ffffffff810d2448>] mem_cgroup_out_of_memory+0xa8/0xf0
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338120]  [<ffffffff81110858>] T.1154+0x8b8/0x8f0
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338201]  [<ffffffff81110fa6>] mem_cgroup_charge_common+0x56/0xa0
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338283]  [<ffffffff81111035>] mem_cgroup_newpage_charge+0x45/0x50
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338364]  [<ffffffff810f3039>] handle_pte_fault+0x609/0x940
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338451]  [<ffffffff8102ab1f>] ? pte_alloc_one+0x3f/0x50
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338532]  [<ffffffff8107e455>] ? sched_clock_local+0x25/0x90
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338617]  [<ffffffff810f34d7>] handle_mm_fault+0x167/0x340
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338699]  [<ffffffff8102714b>] do_page_fault+0x13b/0x490
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338781]  [<ffffffff810f8848>] ? do_brk+0x208/0x3a0
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338865]  [<ffffffff812dba22>] ? gr_learn_resource+0x42/0x1e0
> >> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338951]  [<ffffffff815cb7bf>] page_fault+0x1f/0x30
> >> >> >
> >> >> >The charge code seems to be directly invoking the OOM killer, which is
> >> >> >not possible with 7-2-memcg-fix.  Are you sure this is the right patch
> >> >> >for this log?  This _looks_ more like what 7-1-memcg-fix was doing,
> >> >> >with a direct kill in the charge context and a fixup later on.
> >> >> 
> >> >> I, luckyly, still have the kernel source from which that kernel was build. I tried to re-apply the 7-2-memcg-fix.patch:
> >> >> 
> >> >> # patch -p1 --dry-run < 7-2-memcg-fix.patch 
> >> >> patching file arch/x86/mm/fault.c
> >> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> >> Apply anyway? [n] 
> >> >> Skipping patch.
> >> >> 4 out of 4 hunks ignored -- saving rejects to file arch/x86/mm/fault.c.rej
> >> >> patching file include/linux/memcontrol.h
> >> >> Hunk #1 succeeded at 141 with fuzz 2 (offset 21 lines).
> >> >> Hunk #2 succeeded at 391 with fuzz 1 (offset 39 lines).
> >> >
> >> >Uhm, some of it applied...  I have absolutely no idea what state that
> >> >tree is in now...
> >> 
> >> I used '--dry-run' so it should be ok :)
> >
> >Ah, right.
> >
> >> >> patching file include/linux/mm.h
> >> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> >> Apply anyway? [n] 
> >> >> Skipping patch.
> >> >> 1 out of 1 hunk ignored -- saving rejects to file include/linux/mm.h.rej
> >> >> patching file include/linux/sched.h
> >> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> >> Apply anyway? [n] 
> >> >> Skipping patch.
> >> >> 1 out of 1 hunk ignored -- saving rejects to file include/linux/sched.h.rej
> >> >> patching file mm/memcontrol.c
> >> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> >> Apply anyway? [n] 
> >> >> Skipping patch.
> >> >> 10 out of 10 hunks ignored -- saving rejects to file mm/memcontrol.c.rej
> >> >> patching file mm/memory.c
> >> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> >> Apply anyway? [n] 
> >> >> Skipping patch.
> >> >> 2 out of 2 hunks ignored -- saving rejects to file mm/memory.c.rej
> >> >> patching file mm/oom_kill.c
> >> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> >> Apply anyway? [n] 
> >> >> Skipping patch.
> >> >> 1 out of 1 hunk ignored -- saving rejects to file mm/oom_kill.c.rej
> >> >> 
> >> >> 
> >> >> Can you tell from this if the source has the right patch?
> >> >
> >> >Not reliably, I don't think.  Can you send me
> >> >
> >> >  include/linux/memcontrol.h
> >> >  mm/memcontrol.c
> >> >  mm/memory.c
> >> >  mm/oom_kill.c
> >> >
> >> >from those sources?
> >> >
> >> >It might be easier to start the application from scratch...  Keep in
> >> >mind that 7-2 was not an incremental fix, you need to remove the
> >> >previous memcg patches (as opposed to 7-1).
> >> 
> >> 
> >> 
> >> Yes, i used only 7-2 from your patches. Here are the files:
> >> http://watchdog.sk/lkml/kernel
> >> 
> >> orig - kernel source which was used to build the kernel i was talking about earlier
> >> new - newly unpacked and patched 3.2.50 with all of 'my' patches
> >
> >Ok, thanks!
> >
> >> Here is how your patch was applied:
> >> 
> >> # patch -p1 < 7-2-memcg-fix.patch 
> >> patching file arch/x86/mm/fault.c
> >> Hunk #1 succeeded at 944 (offset 102 lines).
> >> Hunk #2 succeeded at 970 (offset 102 lines).
> >> Hunk #3 succeeded at 1273 with fuzz 1 (offset 212 lines).
> >> Hunk #4 succeeded at 1382 (offset 223 lines).
> >
> >Ah, I forgot about this one.  Could you provide that file (fault.c) as
> >well please?
> 
> 
> 
> 
> I added it.

Thanks.  This one looks good, too.

> >> patching file include/linux/memcontrol.h
> >> Hunk #1 succeeded at 122 with fuzz 2 (offset 2 lines).
> >> Hunk #2 succeeded at 354 (offset 2 lines).
> >
> >Looks good, still.
> >
> >> patching file include/linux/mm.h
> >> Hunk #1 succeeded at 163 (offset 7 lines).
> >> patching file include/linux/sched.h
> >> Hunk #1 succeeded at 1644 (offset 76 lines).
> >> patching file mm/memcontrol.c
> >> Hunk #1 succeeded at 1752 (offset 9 lines).
> >> Hunk #2 succeeded at 1777 (offset 9 lines).
> >> Hunk #3 succeeded at 1828 (offset 9 lines).
> >> Hunk #4 succeeded at 1867 (offset 9 lines).
> >> Hunk #5 succeeded at 2256 (offset 9 lines).
> >> Hunk #6 succeeded at 2317 (offset 9 lines).
> >> Hunk #7 succeeded at 2348 (offset 9 lines).
> >> Hunk #8 succeeded at 2411 (offset 9 lines).
> >> Hunk #9 succeeded at 2419 (offset 9 lines).
> >> Hunk #10 succeeded at 2432 (offset 9 lines).
> >> patching file mm/memory.c
> >> Hunk #1 succeeded at 3712 (offset 273 lines).
> >> Hunk #2 succeeded at 3812 (offset 317 lines).
> >> patching file mm/oom_kill.c
> >
> >These look good as well.
> >
> >That leaves the weird impossible stack trace.  Did you double check
> >that this crash came from a kernel with those exact files?
> 
> 
> 
> Yes i'm sure.

Okay, my suspicion is that the previous patches invoked the OOM killer
right away, whereas in this latest version it's invoked only when the
fault is finished.  Maybe the task that locked the group gets held up
somewhere else and then it takes too long until something is actually
killed.  Meanwhile, every other allocator drops into 5 reclaim cycles
before giving up, which could explain the thrashing.  And on the memcg
level we don't have BDI congestion sleeps like on the global level, so
everybody is backing off from the disk.

Here is an incremental fix to the latest version, i.e. the one that
livelocked under heavy IO, not the one you are using right now.

First, it reduces the reclaim retries from 5 to 2, which resembles the
global kswapd + ttfp somewhat.  Next, NOFS/NORETRY allocators are not
allowed to kick off the OOM killer, like in the global case, so that
we don't kill things and give up just because light reclaim can't free
anything.  Last, the memcg is marked under OOM when one task enters
OOM so that not everybody is livelocking in reclaim in a hopeless
situation.

---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 56643fe..f565857 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1878,6 +1878,7 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
 	 */
 	css_get(&memcg->css);
 	current->memcg_oom.memcg = memcg;
+	mem_cgroup_mark_under_oom(memcg);
 	current->memcg_oom.gfp_mask = mask;
 }
 
@@ -1929,7 +1930,6 @@ bool mem_cgroup_oom_synchronize(bool handle)
 	 * under OOM is always welcomed, use TASK_KILLABLE here.
 	 */
 	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
-	mem_cgroup_mark_under_oom(memcg);
 
 	locked = mem_cgroup_oom_trylock(memcg);
 
@@ -1937,12 +1937,10 @@ bool mem_cgroup_oom_synchronize(bool handle)
 		mem_cgroup_oom_notify(memcg);
 
 	if (locked && !memcg->oom_kill_disable) {
-		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask);
 	} else {
 		schedule();
-		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
 
@@ -1956,6 +1954,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
 		memcg_oom_recover(memcg);
 	}
 cleanup:
+	mem_cgroup_unmark_under_oom(memcg);
 	current->memcg_oom.memcg = NULL;
 	css_put(&memcg->css);
 	return true;
@@ -2250,7 +2249,7 @@ enum {
 };
 
 static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
-				unsigned int nr_pages, bool invoke_oom)
+				unsigned int nr_pages, bool enter_oom)
 {
 	unsigned long csize = nr_pages * PAGE_SIZE;
 	struct mem_cgroup *mem_over_limit;
@@ -2285,6 +2284,11 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (!(gfp_mask & __GFP_WAIT))
 		return CHARGE_WOULDBLOCK;
 
+	if (enter_oom) {
+		mem_cgroup_oom(mem_over_limit, gfp_mask);
+		return CHARGE_NOMEM;
+	}
+
 	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
 					      gfp_mask, flags, NULL);
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
@@ -2308,9 +2312,6 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		return CHARGE_RETRY;
 
-	if (invoke_oom)
-		mem_cgroup_oom(mem_over_limit, gfp_mask);
-
 	return CHARGE_NOMEM;
 }
 
@@ -2325,8 +2326,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				   bool oom)
 {
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
-	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *memcg = NULL;
+	int nr_reclaim_retries = 2;
 	int ret;
 
 	/*
@@ -2352,6 +2353,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	 */
 	if (!*ptr && !mm)
 		goto bypass;
+
+	if (!(gfp_mask & __GFP_FS) || (gfp_mask & __GFP_NORETRY))
+		oom = false;
 again:
 	if (*ptr) { /* css should be a valid one */
 		memcg = *ptr;
@@ -2402,7 +2406,7 @@ again:
 	}
 
 	do {
-		bool invoke_oom = oom && !nr_oom_retries;
+		bool enter_oom = false;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2410,7 +2414,13 @@ again:
 			goto bypass;
 		}
 
-		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, invoke_oom);
+		if (oom && !nr_reclaim_retries)
+			enter_oom = true;
+
+		if (atomic_read(&memcg->under_oom))
+			enter_oom = true;
+
+		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, enter_oom);
 		switch (ret) {
 		case CHARGE_OK:
 			break;
@@ -2422,12 +2432,12 @@ again:
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
 			css_put(&memcg->css);
 			goto nomem;
-		case CHARGE_NOMEM: /* OOM routine works */
-			if (!oom || invoke_oom) {
+		case CHARGE_NOMEM:
+			if (!nr_reclaim_retries || enter_oom) {
 				css_put(&memcg->css);
 				goto nomem;
 			}
-			nr_oom_retries--;
+			nr_reclaim_retries--;
 			break;
 		}
 	} while (ret != CHARGE_OK);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
