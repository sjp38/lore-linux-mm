Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 19B1A6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 00:42:32 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 150DE3EE0C2
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 14:42:30 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E69C845DE54
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 14:42:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C7CD245DE51
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 14:42:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B4DDD1DB8040
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 14:42:29 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 610E51DB8037
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 14:42:29 +0900 (JST)
Date: Wed, 25 Jan 2012 14:41:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v5] memcg: remove PCG_CACHE page_cgroup flag
Message-Id: <20120125144100.4fcfcb82.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120125090025.6d24cd0f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
	<20120120122658.1b14b512.kamezawa.hiroyu@jp.fujitsu.com>
	<20120120084545.GC9655@tiehlicka.suse.cz>
	<20120124121636.115f1cf0.kamezawa.hiroyu@jp.fujitsu.com>
	<20120124111644.GE1660@cmpxchg.org>
	<20120124145411.GF1660@cmpxchg.org>
	<20120124160140.GH26289@tiehlicka.suse.cz>
	<20120124164449.GH1660@cmpxchg.org>
	<20120124172308.GI26289@tiehlicka.suse.cz>
	<20120124180842.GA18372@tiehlicka.suse.cz>
	<20120125090025.6d24cd0f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed, 25 Jan 2012 09:00:25 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 24 Jan 2012 19:09:47 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Tue 24-01-12 18:23:08, Michal Hocko wrote:
> > > On Tue 24-01-12 17:44:49, Johannes Weiner wrote:
> > > > On Tue, Jan 24, 2012 at 05:01:40PM +0100, Michal Hocko wrote:
> > > > > On Tue 24-01-12 15:54:11, Johannes Weiner wrote:
> > > > > > Hold on, I think this patch is still not complete: end_migration()
> > > > > > directly uses __mem_cgroup_uncharge_common() with the FORCE charge
> > > > > > type.  This will uncharge all migrated anon pages as cache, when it
> > > > > > should decide based on PageAnon(used), which is the page where
> > > > > > ->mapping is intact after migration.
> > > > > 
> > > > > You are right, I've missed that one as well. Anyway
> > > > > MEM_CGROUP_CHARGE_TYPE_FORCE is used only in mem_cgroup_end_migration
> > > > > these days and it got out of sync with its documentation (used by
> > > > > force_empty) quite some time ago (f817ed48). What about something like
> > > > > the following on top of the previous patch?
> > > > > --- 
> > > > > Should be foldet into the previous patch with the updated changelog:
> > > > > 
> > > > > Mapping of the unused page is not touched during migration (see
> > > > 
> > > > used one, not unused.  unused->mapping is globbered during migration.
> > > 
> > > Yes, you are right:
> > 
> > Sorry I haven't sent the most recent update. Here we go:
> > ---
> > Should be folded into the previous patch with the updated changelog:
> > 
> Thanks, I'll fold this into v5.
> -Kame
> 

v5 here
==
Subject: [PATCH v5] memcg: remove PCG_CACHE

We record 'the page is cache' by PCG_CACHE bit to page_cgroup.
Here, "CACHE" means anonymous user pages (and SwapCache). This
doesn't include shmem.

Consdering callers, at charge/uncharge, the caller should know
what  the page is and we don't need to record it by using 1bit
per page.

This patch removes PCG_CACHE bit and make callers of
mem_cgroup_charge_statistics() to specify what the page is.

About page migration:
Mapping of the used page is not touched during migration (see
page_remove_rmap) so we can rely on it and push the correct charge type
down to __mem_cgroup_uncharge_common from end_migration for unused page.
The force flag was misleading was abused for skipping the needless
page_mapped() / PageCgroupMigration() check, as we know the unused page
is no longer mapped and cleared the migration flag just a few lines
up.  But doing the checks is no biggie and it's not worth adding another
flag just to skip them.

Changelog since v4
 - fixed a bug at page migration by Michal Hokko.

Changelog since v3
 - renamed a variable 'rss' to 'anon'

Changelog since v2
 - removed 'not_rss', added 'anon'
 - changed a meaning of arguments to mem_cgroup_charge_statisitcs()
 - removed a patch to mem_cgroup_uncharge_cache
 - simplified comment.

Changelog since RFC.
 - rebased onto memcg-devel
 - rename 'file' to 'not_rss'
 - some cleanup and added comment.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    8 +-----
 mm/memcontrol.c             |   57 ++++++++++++++++++++++++-------------------
 2 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index a2d1177..1060292 100644
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
@@ -64,11 +63,6 @@ static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
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
@@ -85,7 +79,7 @@ static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
 	/*
 	 * Don't take this lock in IRQ context.
-	 * This lock is for pc->mem_cgroup, USED, CACHE, MIGRATION
+	 * This lock is for pc->mem_cgroup, USED, MIGRATION
 	 */
 	bit_spin_lock(PCG_LOCK, &pc->flags);
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1c56c5f..45dab06 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -670,15 +670,19 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
-					 bool file, int nr_pages)
+					 bool anon, int nr_pages)
 {
 	preempt_disable();
 
-	if (file)
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
+	/*
+	 * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
+	 * counted as CACHE even if it's on ANON LRU.
+	 */
+	if (anon)
+		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
 				nr_pages);
 	else
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
+		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
 				nr_pages);
 
 	/* pagein of a big page is an event. So, ignore page size */
@@ -2405,6 +2409,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 				       struct page_cgroup *pc,
 				       enum charge_type ctype)
 {
+	bool anon;
+
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
@@ -2424,21 +2430,14 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	 * See mem_cgroup_add_lru_list(), etc.
  	 */
 	smp_wmb();
-	switch (ctype) {
-	case MEM_CGROUP_CHARGE_TYPE_CACHE:
-	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
-		SetPageCgroupCache(pc);
-		SetPageCgroupUsed(pc);
-		break;
-	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
-		ClearPageCgroupCache(pc);
-		SetPageCgroupUsed(pc);
-		break;
-	default:
-		break;
-	}
 
-	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
+	SetPageCgroupUsed(pc);
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
+		anon = true;
+	else
+		anon = false;
+
+	mem_cgroup_charge_statistics(memcg, anon, nr_pages);
 	unlock_page_cgroup(pc);
 	WARN_ON_ONCE(PageLRU(page));
 	/*
@@ -2503,6 +2502,7 @@ static int mem_cgroup_move_account(struct page *page,
 {
 	unsigned long flags;
 	int ret;
+	bool anon = PageAnon(page);
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(page));
@@ -2531,14 +2531,14 @@ static int mem_cgroup_move_account(struct page *page,
 		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		preempt_enable();
 	}
-	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
+	mem_cgroup_charge_statistics(from, anon, -nr_pages);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
 		__mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
-	mem_cgroup_charge_statistics(to, PageCgroupCache(pc), nr_pages);
+	mem_cgroup_charge_statistics(to, anon, nr_pages);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
 	 * can be under rmdir(). But in current implementation, caller of
@@ -2884,6 +2884,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
+	bool anon;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2915,6 +2916,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		/* See mem_cgroup_prepare_migration() */
 		if (page_mapped(page) || PageCgroupMigration(pc))
 			goto unlock_out;
+		anon = true;
 		break;
 	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
 		if (!PageAnon(page)) {	/* Shared memory */
@@ -2922,12 +2924,14 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 				goto unlock_out;
 		} else if (page_mapped(page)) /* Anon */
 				goto unlock_out;
+		anon = true;
 		break;
 	default:
+		anon = false;
 		break;
 	}
 
-	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), -nr_pages);
+	mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
 
 	ClearPageCgroupUsed(pc);
 	/*
@@ -3251,6 +3255,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 {
 	struct page *used, *unused;
 	struct page_cgroup *pc;
+	bool anon;
 
 	if (!memcg)
 		return;
@@ -3272,8 +3277,10 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	lock_page_cgroup(pc);
 	ClearPageCgroupMigration(pc);
 	unlock_page_cgroup(pc);
-
-	__mem_cgroup_uncharge_common(unused, MEM_CGROUP_CHARGE_TYPE_FORCE);
+	anon = PageAnon(used);
+	__mem_cgroup_uncharge_common(unused,
+		anon ? MEM_CGROUP_CHARGE_TYPE_MAPPED
+                     : MEM_CGROUP_CHARGE_TYPE_CACHE);
 
 	/*
 	 * If a page is a file cache, radix-tree replacement is very atomic
@@ -3283,7 +3290,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	 * and USED bit check in mem_cgroup_uncharge_page() will do enough
 	 * check. (see prepare_charge() also)
 	 */
-	if (PageAnon(used))
+	if (anon)
 		mem_cgroup_uncharge_page(used);
 	/*
 	 * At migration, we may charge account against cgroup which has no
@@ -3313,7 +3320,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	/* fix accounting on old pages */
 	lock_page_cgroup(pc);
 	memcg = pc->mem_cgroup;
-	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), -1);
+	mem_cgroup_charge_statistics(memcg, false, -1);
 	ClearPageCgroupUsed(pc);
 	unlock_page_cgroup(pc);
 
-- 
1.7.4.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
