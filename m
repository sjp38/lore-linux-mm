Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3310F8D003A
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 05:34:28 -0400 (EDT)
Date: Mon, 21 Mar 2011 10:34:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: cgroup: real meaning of memory.usage_in_bytes
Message-ID: <20110321093419.GA26047@tiehlicka.suse.cz>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110318152532.GB18450@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 18-03-11 16:25:32, Michal Hocko wrote:
[...]
> According to our documention this is a reasonable test case:
> Documentation/cgroups/memory.txt:
> memory.usage_in_bytes           # show current memory(RSS+Cache) usage.
> 
> This however doesn't work after your commit:
> cdec2e4265d (memcg: coalesce charging via percpu storage)
> 
> because since then we are charging in bulks so we can end up with
> rss+cache <= usage_in_bytes.
[...]
> I think we have several options here
> 	1) document that the value is actually >= rss+cache and it shows
> 	   the guaranteed charges for the group
> 	2) use rss+cache rather then res->count
> 	3) remove the file
> 	4) call drain_all_stock_sync before asking for the value in
> 	   mem_cgroup_read
> 	5) collect the current amount of stock charges and subtract it
> 	   from the current res->count value
> 
> 1) and 2) would suggest that the file is actually not very much useful.
> 3) is basically the interface change as well
> 4) sounds little bit invasive as we basically lose the advantage of the
> pool whenever somebody reads the file. Btw. for who is this file
> intended?
> 5) sounds like a compromise

I guess that 4) is really too invasive - for no good reason so here we
go with the 5) solution.
--- 
From: Michal Hocko <mhocko@suse.cz>
Subject: Drain memcg_stock before returning res->count value

Since cdec2e4265d (memcg: coalesce charging via percpu storage) commit we
are charging resource counter in batches. This means that the current
res->count value doesn't show the real consumed value (rss+cache as we
describe in the documentation) but rather a promissed charges for future.
We are pre-charging CHARGE_SIZE bulk at once and subsequent charges are
satisfied from the per-cpu cgroup_stock pool.

We have seen a report that one of the LTP testcases checks exactly this
condition so the test fails.

As this exported value is a part of kernel->userspace interface we should
try to preserve the original (and documented) semantic.

This patch fixes the issue by collecting the current usage of each per-cpu
stock and subtracting it from the current res counter value.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Index: linus_tree/mm/memcontrol.c
===================================================================
--- linus_tree.orig/mm/memcontrol.c	2011-03-18 16:09:11.000000000 +0100
+++ linus_tree/mm/memcontrol.c	2011-03-21 10:21:55.000000000 +0100
@@ -3579,13 +3579,30 @@ static unsigned long mem_cgroup_recursiv
 	return val;
 }
 
+static u64 mem_cgroup_current_usage(struct mem_cgroup *mem)
+{
+	u64 val = res_counter_read_u64(&mem->res, RES_USAGE);
+	u64 per_cpu_val = 0;
+	int cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
+
+		per_cpu_val += stock->nr_pages * PAGE_SIZE;
+	}
+	put_online_cpus();
+
+	return (val > per_cpu_val)? val - per_cpu_val: 0;
+}
+
 static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
 {
 	u64 val;
 
 	if (!mem_cgroup_is_root(mem)) {
 		if (!swap)
-			return res_counter_read_u64(&mem->res, RES_USAGE);
+			return mem_cgroup_current_usage(mem);
 		else
 			return res_counter_read_u64(&mem->memsw, RES_USAGE);
 	}
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
