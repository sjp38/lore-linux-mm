Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 13E336B00B1
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 07:05:24 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4B2BE3EE0B6
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 21:05:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 31AA645DE66
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 21:05:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18DB545DF00
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 21:05:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0945B1DB8032
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 21:05:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AE1FF1DB8047
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 21:05:21 +0900 (JST)
Date: Thu, 15 Dec 2011 21:04:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/5] memcg: remove PCG_CACHE bit
Message-Id: <20111215210406.093c9a4e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111215193631.782a3e8b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
	<20111215150822.7b609f89.kamezawa.hiroyu@jp.fujitsu.com>
	<20111215102442.GI3047@cmpxchg.org>
	<20111215193631.782a3e8b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, 15 Dec 2011 19:36:31 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 15 Dec 2011 11:24:42 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:

> > What I think is required is to break up the charging and committing
> > like we do for swap cache already:
> > 
> > 	if (!mem_cgroup_try_charge())
> > 		goto error;
> > 	page_add_new_anon_rmap()
> > 	mem_cgroup_commit()
> > 
> > This will also allow us to even get rid of passing around the charge
> > type everywhere...
> > 
> 
> Thank you. I'll look into.
> 
> To be honest, I want to remove 'rss' and 'cache' counter ;(
> This doesn't have much meanings after lru was splitted.
> 

I'll use this version for test. This patch is under far deep stacks of
unmerged patches, anyway.

==
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index e4cb1bf..86967ed 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -4,7 +4,6 @@
 enum {
 	/* flags for mem_cgroup */
 	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
-	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_MIGRATION, /* under page migration */
 	/* flags for mem_cgroup and file and I/O status */
@@ -63,11 +62,6 @@ static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
 
-/* Cache flag is set only once (at allocation) */
-TESTPCGFLAG(Cache, CACHE)
-CLEARPCGFLAG(Cache, CACHE)
-SETPCGFLAG(Cache, CACHE)
-
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 SETPCGFLAG(Used, USED)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fdcf454..89c76f1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2368,6 +2368,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 				       struct page_cgroup *pc,
 				       enum charge_type ctype)
 {
+	bool file = false;
+
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
@@ -2390,18 +2392,17 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_CACHE:
 	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
-		SetPageCgroupCache(pc);
+		file = true;
 		SetPageCgroupUsed(pc);
 		break;
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
-		ClearPageCgroupCache(pc);
 		SetPageCgroupUsed(pc);
 		break;
 	default:
 		break;
 	}
 
-	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
+	mem_cgroup_charge_statistics(memcg, file, nr_pages);
 	unlock_page_cgroup(pc);
 	WARN_ON_ONCE(PageLRU(page));
 	/*
@@ -2474,6 +2475,7 @@ static int mem_cgroup_move_account(struct page *page,
 				   bool uncharge)
 {
 	unsigned long flags;
+	bool file = false;
 	int ret;
 
 	VM_BUG_ON(from == to);
@@ -2503,14 +2505,17 @@ static int mem_cgroup_move_account(struct page *page,
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		preempt_enable();
 	}
-	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
+	/* Once PageAnon is set, it will not be cleared until freed. */
+	if (!PageAnon(page))
+		file = true;
+	mem_cgroup_charge_statistics(from, file, -nr_pages);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
 		__mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
-	mem_cgroup_charge_statistics(to, PageCgroupCache(pc), nr_pages);
+	mem_cgroup_charge_statistics(to, file, nr_pages);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
 	 * can be under rmdir(). But in current implementation, caller of
@@ -2854,6 +2859,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
+	bool file = false;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2880,6 +2886,10 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		goto unlock_out;
 
 	switch (ctype) {
+	case MEM_CGROUP_CHARGE_TYPE_CACHE:
+	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
+		file = true;
+		break;
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
 	case MEM_CGROUP_CHARGE_TYPE_DROP:
 		/* See mem_cgroup_prepare_migration() */
@@ -2897,7 +2907,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		break;
 	}
 
-	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), -nr_pages);
+	mem_cgroup_charge_statistics(memcg, file, -nr_pages);
 
 	ClearPageCgroupUsed(pc);
 	/*
@@ -2938,9 +2948,13 @@ void mem_cgroup_uncharge_page(struct page *page)
 
 void mem_cgroup_uncharge_cache_page(struct page *page)
 {
+	int ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	VM_BUG_ON(page_mapped(page));
 	VM_BUG_ON(page->mapping);
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
+
+	if (page_is_file_cache(page))
+		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
+	__mem_cgroup_uncharge_common(page, ctype);
 }
 
 /*
@@ -3276,7 +3290,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	/* fix accounting on old pages */
 	lock_page_cgroup(pc);
 	memcg = pc->mem_cgroup;
-	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), -1);
+	mem_cgroup_charge_statistics(memcg, true, -1);
 	ClearPageCgroupUsed(pc);
 	unlock_page_cgroup(pc);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
