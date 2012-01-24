Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 214776B005A
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 11:01:44 -0500 (EST)
Date: Tue, 24 Jan 2012 17:01:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4] memcg: remove PCG_CACHE page_cgroup flag
Message-ID: <20120124160140.GH26289@tiehlicka.suse.cz>
References: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
 <20120120122658.1b14b512.kamezawa.hiroyu@jp.fujitsu.com>
 <20120120084545.GC9655@tiehlicka.suse.cz>
 <20120124121636.115f1cf0.kamezawa.hiroyu@jp.fujitsu.com>
 <20120124111644.GE1660@cmpxchg.org>
 <20120124145411.GF1660@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120124145411.GF1660@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Tue 24-01-12 15:54:11, Johannes Weiner wrote:
> On Tue, Jan 24, 2012 at 12:16:44PM +0100, Johannes Weiner wrote:
> > On Tue, Jan 24, 2012 at 12:16:36PM +0900, KAMEZAWA Hiroyuki wrote:
> > > 
> > > > Can we make this anon as well?
> > > 
> > > I'm sorry for long RTT. version 4 here.
> > > ==
> > > >From c40256561d6cdaee62be7ec34147e6079dc426f4 Mon Sep 17 00:00:00 2001
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Date: Thu, 19 Jan 2012 17:09:41 +0900
> > > Subject: [PATCH] memcg: remove PCG_CACHE
> > > 
> > > We record 'the page is cache' by PCG_CACHE bit to page_cgroup.
> > > Here, "CACHE" means anonymous user pages (and SwapCache). This
> > > doesn't include shmem.
> > 
> > !CACHE means anonymous/swapcache
> > 
> > > Consdering callers, at charge/uncharge, the caller should know
> > > what  the page is and we don't need to record it by using 1bit
> > > per page.
> > > 
> > > This patch removes PCG_CACHE bit and make callers of
> > > mem_cgroup_charge_statistics() to specify what the page is.
> > > 
> > > Changelog since v3
> > >  - renamed a variable 'rss' to 'anon'
> > > 
> > > Changelog since v2
> > >  - removed 'not_rss', added 'anon'
> > >  - changed a meaning of arguments to mem_cgroup_charge_statisitcs()
> > >  - removed a patch to mem_cgroup_uncharge_cache
> > >  - simplified comment.
> > > 
> > > Changelog since RFC.
> > >  - rebased onto memcg-devel
> > >  - rename 'file' to 'not_rss'
> > >  - some cleanup and added comment.
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Hold on, I think this patch is still not complete: end_migration()
> directly uses __mem_cgroup_uncharge_common() with the FORCE charge
> type.  This will uncharge all migrated anon pages as cache, when it
> should decide based on PageAnon(used), which is the page where
> ->mapping is intact after migration.

You are right, I've missed that one as well. Anyway
MEM_CGROUP_CHARGE_TYPE_FORCE is used only in mem_cgroup_end_migration
these days and it got out of sync with its documentation (used by
force_empty) quite some time ago (f817ed48). What about something like
the following on top of the previous patch?
--- 
Should be foldet into the previous patch with the updated changelog:

Mapping of the unused page is not touched during migration (see
page_remove_rmap) so we can rely on it and push the correct charge type
down to __mem_cgroup_uncharge_common from end_migration. The force flag
was misleading anyway.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4d655ee..c541551 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3217,7 +3217,9 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	ClearPageCgroupMigration(pc);
 	unlock_page_cgroup(pc);
 
-	__mem_cgroup_uncharge_common(unused, MEM_CGROUP_CHARGE_TYPE_FORCE);
+	__mem_cgroup_uncharge_common(unused,
+			PageAnon(unused) ? MEM_CGROUP_CHARGE_TYPE_MAPPED
+			: MEM_CGROUP_CHARGE_TYPE_CACHE);
 
 	/*
 	 * If a page is a file cache, radix-tree replacement is very atomic

And then we can get rid of the FORCE as well.
---
