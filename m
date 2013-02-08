Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 7B86F6B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 20:40:52 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8E4293EE0C0
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 10:40:50 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A96145DE52
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 10:40:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D9A645DE4F
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 10:40:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37C4E1DB803E
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 10:40:50 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DA3721DB802F
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 10:40:49 +0900 (JST)
Message-ID: <5114577D.70608@jp.fujitsu.com>
Date: Fri, 08 Feb 2013 10:40:13 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from add_to_page_cache_locked
References: <20121224142526.020165D3@pobox.sk> <20121228162209.GA1455@dhcp22.suse.cz> <20121230020947.AA002F34@pobox.sk> <20121230110815.GA12940@dhcp22.suse.cz> <20130125160723.FAE73567@pobox.sk> <20130125163130.GF4721@dhcp22.suse.cz> <20130205134937.GA22804@dhcp22.suse.cz> <20130205154947.CD6411E2@pobox.sk> <20130205160934.GB22804@dhcp22.suse.cz> <20130206021721.1AE9E3C7@pobox.sk> <20130206140119.GD10254@dhcp22.suse.cz> <51138999.3090006@jp.fujitsu.com>
In-Reply-To: <51138999.3090006@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

(2013/02/07 20:01), Kamezawa Hiroyuki wrote:
> (2013/02/06 23:01), Michal Hocko wrote:
>> On Wed 06-02-13 02:17:21, azurIt wrote:
>>>> 5-memcg-fix-1.patch is not complete. It doesn't contain the folloup I
>>>> mentioned in a follow up email. Here is the full patch:
>>>
>>>
>>> Here is the log where OOM, again, killed MySQL server [search for "(mysqld)"]:
>>> http://www.watchdog.sk/lkml/oom_mysqld6
>>
>> [...]
>> WARNING: at mm/memcontrol.c:2409 T.1149+0x2d9/0x610()
>> Hardware name: S5000VSA
>> gfp_mask:4304 nr_pages:1 oom:0 ret:2
>> Pid: 3545, comm: apache2 Tainted: G        W    3.2.37-grsec #1
>> Call Trace:
>>   [<ffffffff8105502a>] warn_slowpath_common+0x7a/0xb0
>>   [<ffffffff81055116>] warn_slowpath_fmt+0x46/0x50
>>   [<ffffffff81108163>] ? mem_cgroup_margin+0x73/0xa0
>>   [<ffffffff8110b6f9>] T.1149+0x2d9/0x610
>>   [<ffffffff812af298>] ? blk_finish_plug+0x18/0x50
>>   [<ffffffff8110c6b4>] mem_cgroup_cache_charge+0xc4/0xf0
>>   [<ffffffff810ca6bf>] add_to_page_cache_locked+0x4f/0x140
>>   [<ffffffff810ca7d2>] add_to_page_cache_lru+0x22/0x50
>>   [<ffffffff810cad32>] filemap_fault+0x252/0x4f0
>>   [<ffffffff810eab18>] __do_fault+0x78/0x5a0
>>   [<ffffffff810edcb4>] handle_pte_fault+0x84/0x940
>>   [<ffffffff810e2460>] ? vma_prio_tree_insert+0x30/0x50
>>   [<ffffffff810f2508>] ? vma_link+0x88/0xe0
>>   [<ffffffff810ee6a8>] handle_mm_fault+0x138/0x260
>>   [<ffffffff8102709d>] do_page_fault+0x13d/0x460
>>   [<ffffffff810f46fc>] ? do_mmap_pgoff+0x3dc/0x430
>>   [<ffffffff815b61ff>] page_fault+0x1f/0x30
>> ---[ end trace 8817670349022007 ]---
>> apache2 invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0, oom_score_adj=0
>> apache2 cpuset=uid mems_allowed=0
>> Pid: 3545, comm: apache2 Tainted: G        W    3.2.37-grsec #1
>> Call Trace:
>>   [<ffffffff810ccd2e>] dump_header+0x7e/0x1e0
>>   [<ffffffff810ccc2f>] ? find_lock_task_mm+0x2f/0x70
>>   [<ffffffff810cd1f5>] oom_kill_process+0x85/0x2a0
>>   [<ffffffff810cd8a5>] out_of_memory+0xe5/0x200
>>   [<ffffffff810cda7d>] pagefault_out_of_memory+0xbd/0x110
>>   [<ffffffff81026e76>] mm_fault_error+0xb6/0x1a0
>>   [<ffffffff8102734e>] do_page_fault+0x3ee/0x460
>>   [<ffffffff810f46fc>] ? do_mmap_pgoff+0x3dc/0x430
>>   [<ffffffff815b61ff>] page_fault+0x1f/0x30
>>
>> The first trace comes from the debugging WARN and it clearly points to
>> a file fault path. __do_fault pre-charges a page in case we need to
>> do CoW (copy-on-write) for the returned page. This one falls back to
>> memcg OOM and never returns ENOMEM as I have mentioned earlier.
>> However, the fs fault handler (filemap_fault here) can fallback to
>> page_cache_read if the readahead (do_sync_mmap_readahead) fails
>> to get page to the page cache. And we can see this happening in
>> the first trace. page_cache_read then calls add_to_page_cache_lru
>> and eventually gets to add_to_page_cache_locked which calls
>> mem_cgroup_cache_charge_no_oom so we will get ENOMEM if oom should
>> happen. This ENOMEM gets to the fault handler and kaboom.
>>
>
> Hmm. do we need to increase the "limit" virtually at memcg oom until
> the oom-killed process dies ?

Here is my naive idea...
==
 From 1a46318cf89e7df94bd4844f29105b61dacf335b Mon Sep 17 00:00:00 2001
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 8 Feb 2013 10:43:52 +0900
Subject: [PATCH] [Don't Apply][PATCH] memcg relax resource at OOM situation.

When an OOM happens, a task is killed and resources will be freed.

A problem here is that a task, which is oom-killed, may wait for
some other resource in which memory resource is required. Some thread
waits for free memory may holds some mutex and oom-killed process
wait for the mutex.

To avoid this, relaxing charged memory by giving virtual resource
can be a help. The system can get back it at uncharge().
This is a sample native implementation.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
  mm/memcontrol.c |   79 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
  1 file changed, 73 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 25ac5f4..4dea49a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -301,6 +301,9 @@ struct mem_cgroup {
  	/* set when res.limit == memsw.limit */
  	bool		memsw_is_minimum;
  
+	/* extra resource at emergency situation */
+	unsigned long	loan;
+	spinlock_t	loan_lock;
  	/* protect arrays of thresholds */
  	struct mutex thresholds_lock;
  
@@ -2034,6 +2037,61 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
  	mem_cgroup_iter_break(root_memcg, victim);
  	return total;
  }
+/*
+ * When a memcg is in OOM situation, this lack of resource may cause deadlock
+ * because of complicated lock dependency(i_mutex...). To avoid that, we
+ * need extra resource or avoid charging.
+ *
+ * A memcg can request resource in an emergency state. We call it as loan.
+ * A memcg will return a loan when it does uncharge resource. We disallow
+ * double-loan and moving task to other groups until the loan is fully
+ * returned.
+ *
+ * Note: the problem here is that we cannot know what amount resouce should
+ * be necessary to exiting an emergency state.....
+ */
+#define LOAN_MAX		(2 * 1024 * 1024)
+
+static void mem_cgroup_make_loan(struct mem_cgroup *memcg)
+{
+	u64 usage;
+	unsigned long amount;
+
+	amount = LOAN_MAX;
+
+	usage = res_counter_read_u64(&memcg->res, RES_USAGE);
+	if (amount > usage /2 )
+		amount = usage / 2;
+	spin_lock(&memcg->loan_lock);
+	if (memcg->loan) {
+		spin_unlock(&memcg->loan_lock);
+		return;
+	}
+	memcg->loan = amount;
+	res_counter_uncharge(&memcg->res, amount);
+	if (do_swap_account)
+		res_counter_uncharge(&memcg->memsw, amount);
+	spin_unlock(&memcg->loan_lock);
+}
+
+/* return amount of free resource which can be uncharged */
+static unsigned long
+mem_cgroup_may_return_loan(struct mem_cgroup *memcg, unsigned long val)
+{
+	unsigned long tmp;
+	/* we don't care small race here */
+	if (unlikely(!memcg->loan))
+		return val;
+	spin_lock(&memcg->loan_lock);
+	if (memcg->loan) {
+		tmp = min(memcg->loan, val);
+		memcg->loan -= tmp;
+		val -= tmp;
+	}
+	spin_unlock(&memcg->loan_lock);
+	return val;
+}
+
  
  /*
   * Check OOM-Killer is already running under our hierarchy.
@@ -2182,6 +2240,7 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
  	if (need_to_kill) {
  		finish_wait(&memcg_oom_waitq, &owait.wait);
  		mem_cgroup_out_of_memory(memcg, mask, order);
+		mem_cgroup_make_loan(memcg);
  	} else {
  		schedule();
  		finish_wait(&memcg_oom_waitq, &owait.wait);
@@ -2748,6 +2807,8 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
  	if (!mem_cgroup_is_root(memcg)) {
  		unsigned long bytes = nr_pages * PAGE_SIZE;
  
+		bytes = mem_cgroup_may_return_loan(memcg, bytes);
+
  		res_counter_uncharge(&memcg->res, bytes);
  		if (do_swap_account)
  			res_counter_uncharge(&memcg->memsw, bytes);
@@ -3989,6 +4050,7 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
  {
  	struct memcg_batch_info *batch = NULL;
  	bool uncharge_memsw = true;
+	unsigned long val;
  
  	/* If swapout, usage of swap doesn't decrease */
  	if (!do_swap_account || ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
@@ -4029,9 +4091,11 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
  		batch->memsw_nr_pages++;
  	return;
  direct_uncharge:
-	res_counter_uncharge(&memcg->res, nr_pages * PAGE_SIZE);
+	val = nr_pages * PAGE_SIZE;
+	val = mem_cgroup_may_return_loan(memcg, val);
+	res_counter_uncharge(&memcg->res, val);
  	if (uncharge_memsw)
-		res_counter_uncharge(&memcg->memsw, nr_pages * PAGE_SIZE);
+		res_counter_uncharge(&memcg->memsw, val);
  	if (unlikely(batch->memcg != memcg))
  		memcg_oom_recover(memcg);
  }
@@ -4182,6 +4246,7 @@ void mem_cgroup_uncharge_start(void)
  void mem_cgroup_uncharge_end(void)
  {
  	struct memcg_batch_info *batch = &current->memcg_batch;
+	unsigned long val;
  
  	if (!batch->do_batch)
  		return;
@@ -4192,16 +4257,16 @@ void mem_cgroup_uncharge_end(void)
  
  	if (!batch->memcg)
  		return;
+	val = batch->nr_pages * PAGE_SIZE;
+	val = mem_cgroup_may_return_loan(batch->memcg, val);
  	/*
  	 * This "batch->memcg" is valid without any css_get/put etc...
  	 * bacause we hide charges behind us.
  	 */
  	if (batch->nr_pages)
-		res_counter_uncharge(&batch->memcg->res,
-				     batch->nr_pages * PAGE_SIZE);
+		res_counter_uncharge(&batch->memcg->res, val);
  	if (batch->memsw_nr_pages)
-		res_counter_uncharge(&batch->memcg->memsw,
-				     batch->memsw_nr_pages * PAGE_SIZE);
+		res_counter_uncharge(&batch->memcg->memsw, val);
  	memcg_oom_recover(batch->memcg);
  	/* forget this pointer (for sanity check) */
  	batch->memcg = NULL;
@@ -6291,6 +6356,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
  	memcg->move_charge_at_immigrate = 0;
  	mutex_init(&memcg->thresholds_lock);
  	spin_lock_init(&memcg->move_lock);
+	memcg->loan = 0;
+	spin_lock_init(&memcg->loan_lock);
  
  	return &memcg->css;
  
-- 
1.7.10.2







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
