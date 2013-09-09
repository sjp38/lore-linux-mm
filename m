Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A17926B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 09:10:12 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Mon, 09 Sep 2013 15:10:10 +0200
From: "azurIt" <azurit@pobox.sk>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>, <20130803170831.GB23319@cmpxchg.org>, <20130830215852.3E5D3D66@pobox.sk>, <20130902123802.5B8E8CB1@pobox.sk>, <20130903204850.GA1412@cmpxchg.org>, <20130904101852.58E70042@pobox.sk> <20130905115430.GB856@cmpxchg.org>
In-Reply-To: <20130905115430.GB856@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20130909151010.3A3CBC6A@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>
Cc: =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

>Hi azur,
>
>On Wed, Sep 04, 2013 at 10:18:52AM +0200, azurIt wrote:
>> > CC: "Andrew Morton" <akpm@linux-foundation.org>, "Michal Hocko" <mhocko@suse.cz>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>> >Hello azur,
>> >
>> >On Mon, Sep 02, 2013 at 12:38:02PM +0200, azurIt wrote:
>> >> >>Hi azur,
>> >> >>
>> >> >>here is the x86-only rollup of the series for 3.2.
>> >> >>
>> >> >>Thanks!
>> >> >>Johannes
>> >> >>---
>> >> >
>> >> >
>> >> >Johannes,
>> >> >
>> >> >unfortunately, one problem arises: I have (again) cgroup which cannot be deleted :( it's a user who had very high memory usage and was reaching his limit very often. Do you need any info which i can gather now?
>> >
>> >Did the OOM killer go off in this group?
>> >
>> >Was there a warning in the syslog ("Fixing unhandled memcg OOM
>> >context")?
>> 
>> 
>> 
>> Ok, i see this message several times in my syslog logs, one of them is also for this unremovable cgroup (but maybe all of them cannot be removed, should i try?). Example of the log is here (don't know where exactly it starts and ends so here is the full kernel log):
>> http://watchdog.sk/lkml/oom_syslog.gz
>There is an unfinished OOM invocation here:
>
>  Aug 22 13:15:21 server01 kernel: [1251422.715112] Fixing unhandled memcg OOM context set up from:
>  Aug 22 13:15:21 server01 kernel: [1251422.715191]  [<ffffffff811105c2>] T.1154+0x622/0x8f0
>  Aug 22 13:15:21 server01 kernel: [1251422.715274]  [<ffffffff8111153e>] mem_cgroup_cache_charge+0xbe/0xe0
>  Aug 22 13:15:21 server01 kernel: [1251422.715357]  [<ffffffff810cf31c>] add_to_page_cache_locked+0x4c/0x140
>  Aug 22 13:15:21 server01 kernel: [1251422.715443]  [<ffffffff810cf432>] add_to_page_cache_lru+0x22/0x50
>  Aug 22 13:15:21 server01 kernel: [1251422.715526]  [<ffffffff810cfdd3>] find_or_create_page+0x73/0xb0
>  Aug 22 13:15:21 server01 kernel: [1251422.715608]  [<ffffffff811493ba>] __getblk+0xea/0x2c0
>  Aug 22 13:15:21 server01 kernel: [1251422.715692]  [<ffffffff8114ca73>] __bread+0x13/0xc0
>  Aug 22 13:15:21 server01 kernel: [1251422.715774]  [<ffffffff81196968>] ext3_get_branch+0x98/0x140
>  Aug 22 13:15:21 server01 kernel: [1251422.715859]  [<ffffffff81197557>] ext3_get_blocks_handle+0xd7/0xdc0
>  Aug 22 13:15:21 server01 kernel: [1251422.715942]  [<ffffffff81198304>] ext3_get_block+0xc4/0x120
>  Aug 22 13:15:21 server01 kernel: [1251422.716023]  [<ffffffff81155c3a>] do_mpage_readpage+0x38a/0x690
>  Aug 22 13:15:21 server01 kernel: [1251422.716107]  [<ffffffff81155f8f>] mpage_readpage+0x4f/0x70
>  Aug 22 13:15:21 server01 kernel: [1251422.716188]  [<ffffffff811973a8>] ext3_readpage+0x28/0x60
>  Aug 22 13:15:21 server01 kernel: [1251422.716268]  [<ffffffff810cfa48>] filemap_fault+0x308/0x560
>  Aug 22 13:15:21 server01 kernel: [1251422.716350]  [<ffffffff810ef898>] __do_fault+0x78/0x5a0
>  Aug 22 13:15:21 server01 kernel: [1251422.716433]  [<ffffffff810f2ab4>] handle_pte_fault+0x84/0x940
>
>__getblk() has this weird loop where it tries to instantiate the page,
>frees memory on failure, then retries.  If the memcg goes OOM, the OOM
>path might be entered multiple times and each time leak the memcg
>reference of the respective previous OOM invocation.
>
>There are a few more find_or_create() sites that do not propagate an
>error and it's incredibly hard to find out whether they are even taken
>during a page fault.  It's not practical to annotate them all with
>memcg OOM toggles, so let's just catch all OOM contexts at the end of
>handle_mm_fault() and clear them if !VM_FAULT_OOM instead of treating
>this like an error.
>
>azur, here is a patch on top of your modified 3.2.  Note that Michal
>might be onto something and we are looking at multiple issues here,
>but the log excert above suggests this fix is required either way.




Johannes, is this still up to date? Thank you.

azur






>---
>From: Johannes Weiner <hannes@cmpxchg.org>
>Subject: [patch] mm: memcg: handle non-error OOM situations more gracefully
>
>Many places that can trigger a memcg OOM situation return gracefully
>and don't propagate VM_FAULT_OOM up the fault stack.
>
>It's not practical to annotate all of them to disable the memcg OOM
>killer.  Instead, just clean up any set OOM state without warning in
>case the fault is not returning VM_FAULT_OOM.
>
>Also fail charges immediately when the current task already is in an
>OOM context.  Otherwise, the previous context gets overwritten and the
>memcg reference is leaked.
>
>Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>---
> include/linux/memcontrol.h | 40 ++++++----------------------------------
> include/linux/sched.h      |  3 ---
> mm/filemap.c               | 11 +----------
> mm/memcontrol.c            | 15 ++++++++-------
> mm/memory.c                |  8 ++------
> mm/oom_kill.c              |  2 +-
> 6 files changed, 18 insertions(+), 61 deletions(-)
>
>diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>index b113c0f..7c43903 100644
>--- a/include/linux/memcontrol.h
>+++ b/include/linux/memcontrol.h
>@@ -120,39 +120,16 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> 					struct task_struct *p);
> 
>-/**
>- * mem_cgroup_toggle_oom - toggle the memcg OOM killer for the current task
>- * @new: true to enable, false to disable
>- *
>- * Toggle whether a failed memcg charge should invoke the OOM killer
>- * or just return -ENOMEM.  Returns the previous toggle state.
>- *
>- * NOTE: Any path that enables the OOM killer before charging must
>- *       call mem_cgroup_oom_synchronize() afterward to finalize the
>- *       OOM handling and clean up.
>- */
>-static inline bool mem_cgroup_toggle_oom(bool new)
>-{
>-	bool old;
>-
>-	old = current->memcg_oom.may_oom;
>-	current->memcg_oom.may_oom = new;
>-
>-	return old;
>-}
>-
> static inline void mem_cgroup_enable_oom(void)
> {
>-	bool old = mem_cgroup_toggle_oom(true);
>-
>-	WARN_ON(old == true);
>+	WARN_ON(current->memcg_oom.may_oom);
>+	current->memcg_oom.may_oom = true;
> }
> 
> static inline void mem_cgroup_disable_oom(void)
> {
>-	bool old = mem_cgroup_toggle_oom(false);
>-
>-	WARN_ON(old == false);
>+	WARN_ON(!current->memcg_oom.may_oom);
>+	current->memcg_oom.may_oom = false;
> }
> 
> static inline bool task_in_memcg_oom(struct task_struct *p)
>@@ -160,7 +137,7 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
> 	return p->memcg_oom.in_memcg_oom;
> }
> 
>-bool mem_cgroup_oom_synchronize(void);
>+bool mem_cgroup_oom_synchronize(bool wait);
> 
> #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> extern int do_swap_account;
>@@ -375,11 +352,6 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> {
> }
> 
>-static inline bool mem_cgroup_toggle_oom(bool new)
>-{
>-	return false;
>-}
>-
> static inline void mem_cgroup_enable_oom(void)
> {
> }
>@@ -393,7 +365,7 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
> 	return false;
> }
> 
>-static inline bool mem_cgroup_oom_synchronize(void)
>+static inline bool mem_cgroup_oom_synchronize(bool wait)
> {
> 	return false;
> }
>diff --git a/include/linux/sched.h b/include/linux/sched.h
>index 3f2562c..70a62fd 100644
>--- a/include/linux/sched.h
>+++ b/include/linux/sched.h
>@@ -91,7 +91,6 @@ struct sched_param {
> #include <linux/latencytop.h>
> #include <linux/cred.h>
> #include <linux/llist.h>
>-#include <linux/stacktrace.h>
> 
> #include <asm/processor.h>
> 
>@@ -1573,8 +1572,6 @@ struct task_struct {
> 		unsigned int may_oom:1;
> 		unsigned int in_memcg_oom:1;
> 		unsigned int oom_locked:1;
>-		struct stack_trace trace;
>-		unsigned long trace_entries[16];
> 		int wakeups;
> 		struct mem_cgroup *wait_on_memcg;
> 	} memcg_oom;
>diff --git a/mm/filemap.c b/mm/filemap.c
>index 030774a..5f0a3c9 100644
>--- a/mm/filemap.c
>+++ b/mm/filemap.c
>@@ -1661,7 +1661,6 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> 	struct inode *inode = mapping->host;
> 	pgoff_t offset = vmf->pgoff;
> 	struct page *page;
>-	bool memcg_oom;
> 	pgoff_t size;
> 	int ret = 0;
> 
>@@ -1670,11 +1669,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> 		return VM_FAULT_SIGBUS;
> 
> 	/*
>-	 * Do we have something in the page cache already?  Either
>-	 * way, try readahead, but disable the memcg OOM killer for it
>-	 * as readahead is optional and no errors are propagated up
>-	 * the fault stack.  The OOM killer is enabled while trying to
>-	 * instantiate the faulting page individually below.
>+	 * Do we have something in the page cache already?
> 	 */
> 	page = find_get_page(mapping, offset);
> 	if (likely(page)) {
>@@ -1682,14 +1677,10 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> 		 * We found the page, so try async readahead before
> 		 * waiting for the lock.
> 		 */
>-		memcg_oom = mem_cgroup_toggle_oom(false);
> 		do_async_mmap_readahead(vma, ra, file, page, offset);
>-		mem_cgroup_toggle_oom(memcg_oom);
> 	} else {
> 		/* No page in the page cache at all */
>-		memcg_oom = mem_cgroup_toggle_oom(false);
> 		do_sync_mmap_readahead(vma, ra, file, offset);
>-		mem_cgroup_toggle_oom(memcg_oom);
> 		count_vm_event(PGMAJFAULT);
> 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> 		ret = VM_FAULT_MAJOR;
>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>index 83acd11..ebd07f3 100644
>--- a/mm/memcontrol.c
>+++ b/mm/memcontrol.c
>@@ -1874,12 +1874,6 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
> 
> 	current->memcg_oom.in_memcg_oom = 1;
> 
>-	current->memcg_oom.trace.nr_entries = 0;
>-	current->memcg_oom.trace.max_entries = 16;
>-	current->memcg_oom.trace.entries = current->memcg_oom.trace_entries;
>-	current->memcg_oom.trace.skip = 1;
>-	save_stack_trace(&current->memcg_oom.trace);
>-
> 	/*
> 	 * As with any blocking lock, a contender needs to start
> 	 * listening for wakeups before attempting the trylock,
>@@ -1935,6 +1929,7 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
> 
> /**
>  * mem_cgroup_oom_synchronize - complete memcg OOM handling
>+ * @wait: wait for OOM handler or just clear the OOM state
>  *
>  * This has to be called at the end of a page fault if the the memcg
>  * OOM handler was enabled and the fault is returning %VM_FAULT_OOM.
>@@ -1950,7 +1945,7 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
>  * Returns %true if an ongoing memcg OOM situation was detected and
>  * finalized, %false otherwise.
>  */
>-bool mem_cgroup_oom_synchronize(void)
>+bool mem_cgroup_oom_synchronize(bool wait)
> {
> 	struct oom_wait_info owait;
> 	struct mem_cgroup *memcg;
>@@ -1969,6 +1964,9 @@ bool mem_cgroup_oom_synchronize(void)
> 	if (!memcg)
> 		goto out;
> 
>+	if (!wait)
>+		goto out_memcg;
>+
> 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> 		goto out_memcg;
> 
>@@ -2369,6 +2367,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> 	struct mem_cgroup *memcg = NULL;
> 	int ret;
> 
>+	if (unlikely(current->memcg_oom.in_memcg_oom))
>+		goto nomem;
>+
> 	/*
> 	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
> 	 * in system level. So, allow to go ahead dying process in addition to
>diff --git a/mm/memory.c b/mm/memory.c
>index cdbe41b..cdad471 100644
>--- a/mm/memory.c
>+++ b/mm/memory.c
>@@ -57,7 +57,6 @@
> #include <linux/swapops.h>
> #include <linux/elf.h>
> #include <linux/gfp.h>
>-#include <linux/stacktrace.h>
> 
> #include <asm/io.h>
> #include <asm/pgalloc.h>
>@@ -3521,11 +3520,8 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> 	if (flags & FAULT_FLAG_USER)
> 		mem_cgroup_disable_oom();
> 
>-	if (WARN_ON(task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))) {
>-		printk("Fixing unhandled memcg OOM context set up from:\n");
>-		print_stack_trace(&current->memcg_oom.trace, 0);
>-		mem_cgroup_oom_synchronize();
>-	}
>+	if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
>+		mem_cgroup_oom_synchronize(false);
> 
> 	return ret;
> }
>diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>index aa60863..3bf664c 100644
>--- a/mm/oom_kill.c
>+++ b/mm/oom_kill.c
>@@ -785,7 +785,7 @@ out:
>  */
> void pagefault_out_of_memory(void)
> {
>-	if (mem_cgroup_oom_synchronize())
>+	if (mem_cgroup_oom_synchronize(true))
> 		return;
> 	if (try_set_system_oom()) {
> 		out_of_memory(NULL, 0, 0, NULL);
>-- 
>1.8.4
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
