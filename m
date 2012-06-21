Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 1AB8D6B00AD
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 06:07:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2F4F33EE0C2
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:07:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1250E45DEB2
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:07:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E863545DEB6
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:07:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D78161DB8038
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:07:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 850EC1DB803C
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:07:32 +0900 (JST)
Message-ID: <4FE2F1DA.8030608@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 19:05:14 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com> <4FE2D73C.3060001@kernel.org> <alpine.DEB.2.00.1206210124380.6635@chino.kir.corp.google.com> <alpine.DEB.2.00.1206210158360.10975@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206210158360.10975@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/06/21 18:01), David Rientjes wrote:
> On Thu, 21 Jun 2012, David Rientjes wrote:
>
>> It's possible that subsequent pageblocks would contain memory allocated
>> from solely non-oom memcgs, but it's certainly not a guarantee and results
>> in terrible performance as exhibited above.  Is there another good
>> criteria to use when deciding when to stop isolating and attempting to
>> migrate all of these pageblocks?
>>
>> Other ideas?
>>
>
> The only other alternative that I can think of is to check
> mem_cgroup_margin() in isolate_migratepages_range() and return a NULL
> lruvec that would break that pageblock and return, and then set a bit in
> struct mem_cgroup that labels it as oom so we can check for it on
> subsequent pageblocks without incurring the locking to do
> mem_cgroup_margin() in res_counter, and then clear that bit on every
> uncharge to a memcg, but this still seems like a tremendous waste of cpu
> (especially if /sys/kernel/mm/transparent_hugepage/defrag == always) if
> most pageblocks contain pages from an oom memcg.

I guess the best way will be never calling charge/uncharge at migration.
....but it has been a battle with many race conditions..

Here is an alternative way, remove -ENOMEM in mem_cgroup_prepare_migration()
by using res_counter_charge_nofail().

Could you try this ?
==
 From 12cd8c387cc19b6f89c51a89dc89cdb0fc54074e Mon Sep 17 00:00:00 2001
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 19:18:07 +0900
Subject: [PATCH] memcg: never fail charge at page migration.

memory cgroup adds an extra charge to memcg at page migration.
In theory, this is unnecessary but codes will be much more complex
without this...because of many race conditions.

Now, if a memory cgroup is under OOM, page migration never succeed
if target page is under the memcg. This prevents page defragment
and tend to consume much cpus needlessly.

This patch uses res_counter_charge_nofail() in migration path
and avoid stopping page migration, caused by OOM-memcg.

But, even if it's temporal state, usage > limit doesn't seem
good. This patch adds a new function res_counter_usage_safe().

This does
	if (usage < limit)
		return usage;
	return limit;

So, res_counter_charge_nofail() will never break user experience.

Reported-by: David Rientjes <rientjes@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
  include/linux/res_counter.h |    2 ++
  kernel/res_counter.c        |   14 ++++++++++++++
  mm/memcontrol.c             |   22 ++++++----------------
  3 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index c6b0368..ece3d02 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -226,4 +226,6 @@ res_counter_set_soft_limit(struct res_counter *cnt,
  	return 0;
  }
  
+u64 res_counter_usage_safe(struct res_counter *cnt);
+
  #endif
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index d9ea45e..da520c7 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -176,6 +176,20 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
  }
  #endif
  
+u64 res_counter_usage_safe(struct res_counter *counter)
+{
+	u64 val;
+	unsigned long flags;
+
+	spin_lock_irqsave(&counter->lock, flags);
+	if (counter->usage < counter->limit)
+		val = counter->usage;
+	else
+		val = counter->limit;
+	spin_unlock_irqrestore(&counter->lock, flags);
+	return val;
+}
+
  int res_counter_memparse_write_strategy(const char *buf,
  					unsigned long long *res)
  {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 767440c..b468d9a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3364,6 +3364,7 @@ int mem_cgroup_prepare_migration(struct page *page,
  	struct mem_cgroup *memcg = NULL;
  	struct page_cgroup *pc;
  	enum charge_type ctype;
+	struct res_counter *dummy;
  	int ret = 0;
  
  	*memcgp = NULL;
@@ -3418,21 +3419,10 @@ int mem_cgroup_prepare_migration(struct page *page,
  		return 0;
  
  	*memcgp = memcg;
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, memcgp, false);
+	res_counter_charge_nofail(&memcg->res, PAGE_SIZE, &dummy);
+	if (do_swap_account)
+		res_counter_charge_nofail(&memcg->memsw, PAGE_SIZE, &dummy);
  	css_put(&memcg->css);/* drop extra refcnt */
-	if (ret) {
-		if (PageAnon(page)) {
-			lock_page_cgroup(pc);
-			ClearPageCgroupMigration(pc);
-			unlock_page_cgroup(pc);
-			/*
-			 * The old page may be fully unmapped while we kept it.
-			 */
-			mem_cgroup_uncharge_page(page);
-		}
-		/* we'll need to revisit this error code (we have -EINTR) */
-		return -ENOMEM;
-	}
  	/*
  	 * We charge new page before it's used/mapped. So, even if unlock_page()
  	 * is called before end_migration, we can catch all events on this new
@@ -3995,9 +3985,9 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
  
  	if (!mem_cgroup_is_root(memcg)) {
  		if (!swap)
-			return res_counter_read_u64(&memcg->res, RES_USAGE);
+			return res_counter_usage_safe(&memcg->res);
  		else
-			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
+			return res_counter_usage_safe(&memcg->memsw);
  	}
  
  	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
