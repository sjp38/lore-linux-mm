Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3631E6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 17:01:34 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: mem_cgroup_get_limit() return type, was [patch] memcg: fix unit mismatch in memcg oom limit calculation
References: <20101109110521.GS23393@cmpxchg.org>
	<xr93iq068dyd.fsf@ninji.mtv.corp.google.com>
	<alpine.DEB.2.00.1011091327420.7730@chino.kir.corp.google.com>
Date: Tue, 09 Nov 2010 14:01:07 -0800
Message-ID: <xr9362w66tss.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Rientjes <rientjes@google.com> writes:

> On Tue, 9 Nov 2010, Greg Thelen wrote:
>
>> Johannes Weiner <hannes@cmpxchg.org> writes:
>> 
>> > Adding the number of swap pages to the byte limit of a memory control
>> > group makes no sense.  Convert the pages to bytes before adding them.
>> >
>> > The only user of this code is the OOM killer, and the way it is used
>> > means that the error results in a higher OOM badness value.  Since the
>> > cgroup limit is the same for all tasks in the cgroup, the error should
>> > have no practical impact at the moment.
>> >
>> > But let's not wait for future or changing users to trip over it.
>> 
>> Thanks for the fix.
>> 
>
> Nice catch, but it's done in the opposite way: the oom killer doesn't use 
> byte limits but page limits.  So this needs to be
>
> 	(res_counter_read_u64(&memcg->res, RES_LIMIT) >> PAGE_SHIFT) +
> 			total_swap_pages;

In -mm, the oom killer queries memcg for a byte limit using
mem_cgroup_get_limit(). The following is from
mem_cgroup_out_of_memory():

	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;

So I think the "[patch] memcg: fix unit mismatch in memcg oom limit
calculation" is correct.  Although a simpler interface, would involve
changing mem_cgroup_get_limit() to return a page count instead of a byte
count and thus save the oom killer from having to do the conversion:

commit d12e5eded4505a673a7d77d8adab7fce30c7a680
Author: Greg Thelen <gthelen@google.com>
Date:   Tue Nov 9 13:46:38 2010 -0800

    memcg: change mem_cgroup_get_limit() return type
    
    The mem_cgroup_get_limit() interface routine returns a
    byte count.  The only consumer of this data is the oom
    killer, which really wants a page count.
    
    This change converts mem_cgroup_get_limit() to return a
    page count rather than a byte count.  This makes the
    memcg interface more consistent with the rest of the mm.
    This even makes the memcg interface more consistent.  Most other
    memcg interface routines operate on page counts, not byte counts.
    
    Signed-off-by: Greg Thelen <gthelen@google.com>

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3433784..0a8720e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -163,7 +163,7 @@ unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
-u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
+unsigned long mem_cgroup_get_limit(struct mem_cgroup *mem);
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
@@ -368,7 +368,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 }
 
 static inline
-u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
+unsigned long mem_cgroup_get_limit(struct mem_cgroup *mem)
 {
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7b9ecdc..90efb5d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1569,22 +1569,23 @@ static int mem_cgroup_count_children(struct mem_cgroup *mem)
 }
 
 /*
- * Return the memory (and swap, if configured) limit for a memcg.
+ * Return the memory (and swap, if configured) limit for a memcg expressed as
+ * a page count.
  */
-u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
+unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	u64 limit;
 	u64 memsw;
 
-	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-	limit += total_swap_pages << PAGE_SHIFT;
+	limit = res_counter_read_u64(&memcg->res, RES_LIMIT) >> PAGE_SHIFT;
+	limit += total_swap_pages;
 
-	memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+	memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> PAGE_SHIFT;
 	/*
 	 * If memsw is finite and limits the amount of swap space available
 	 * to this memcg, return that limit.
 	 */
-	return min(limit, memsw);
+	return min(min(limit, memsw), ULONG_MAX);
 }
 
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7dcca55..9ccc59f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -538,7 +538,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	struct task_struct *p;
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
-	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
+	limit = mem_cgroup_get_limit(mem);
 	read_lock(&tasklist_lock);
 retry:
 	p = select_bad_process(&points, limit, mem, NULL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
