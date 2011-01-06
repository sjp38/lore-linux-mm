Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1DC6B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 20:21:00 -0500 (EST)
Date: Thu, 6 Jan 2011 10:09:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
Message-Id: <20110106100923.24b1dd12.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110105115840.GD4654@cmpxchg.org>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
	<20110105115840.GD4654@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jan 2011 12:58:40 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Jan 05, 2011 at 01:00:20PM +0900, Daisuke Nishimura wrote:
> > In current implimentation, mem_cgroup_end_migration() decides whether the page
> > migration has succeeded or not by checking "oldpage->mapping".
> > 
> > But if we are tring to migrate a shmem swapcache, the page->mapping of it is
> > NULL from the begining, so the check would be invalid.
> > As a result, mem_cgroup_end_migration() assumes the migration has succeeded
> > even if it's not, so "newpage" would be freed while it's not uncharged.
> > 
> > This patch fixes it by passing mem_cgroup_end_migration() the result of the
> > page migration.
> 
> Are there other users that rely on unused->mapping being NULL after
> migration?
> 
As long as I can see, no.

> If so, aren't they prone to misinterpreting this for shmem swapcache
> as well?
> 
> If not, wouldn't it be better to remove that page->mapping = NULL from
> migrate_page_copy() altogether?  I think it's an ugly exception where
> the outcome of PageAnon() is not meaningful for an LRU page.
> 
IIUC, oldpage will be freed on success of page migration, so we hit bad_page
check at freeing the page unless we clear oldpage->mapping, 

> To your patch:
> 
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2856,7 +2856,7 @@ int mem_cgroup_prepare_migration(struct page *page,
> >  
> >  /* remove redundant charge if migration failed*/
> >  void mem_cgroup_end_migration(struct mem_cgroup *mem,
> > -	struct page *oldpage, struct page *newpage)
> > +	struct page *oldpage, struct page *newpage, int result)
> >  {
> >  	struct page *used, *unused;
> >  	struct page_cgroup *pc;
> > @@ -2865,8 +2865,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
> >  		return;
> >  	/* blocks rmdir() */
> >  	cgroup_exclude_rmdir(&mem->css);
> > -	/* at migration success, oldpage->mapping is NULL. */
> > -	if (oldpage->mapping) {
> > +	if (result) {
> 
> Since this function does not really need more than a boolean value,
> wouldn't it make the code more obvious if the parameter was `bool
> success'?
> 
> 	if (!success) {
> >  		used = oldpage;
> >  		unused = newpage;
> >  	} else {
> 
> Minor nit, though.  I agree with the patch in general.
> 
Thank you for your review.
How about this ?

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

In current implimentation, mem_cgroup_end_migration() decides whether the page
migration has succeeded or not by checking "oldpage->mapping".

But if we are tring to migrate a shmem swapcache, the page->mapping of it is
NULL from the begining, so the check would be invalid.
As a result, mem_cgroup_end_migration() assumes the migration has succeeded
even if it's not, so "newpage" would be freed while it's not uncharged.

This patch fixes it by passing mem_cgroup_end_migration() the result of the
page migration.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/memcontrol.h |    5 ++---
 mm/memcontrol.c            |    5 ++---
 mm/migrate.c               |    2 +-
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 159a076..cc5a8fd 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -93,7 +93,7 @@ extern int
 mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr);
 extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
-	struct page *oldpage, struct page *newpage);
+	struct page *oldpage, struct page *newpage, bool success);
 
 /*
  * For memory reclaim.
@@ -231,8 +231,7 @@ mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 }
 
 static inline void mem_cgroup_end_migration(struct mem_cgroup *mem,
-					struct page *oldpage,
-					struct page *newpage)
+		struct page *oldpage, struct page *newpage, bool success)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 61678be..fbecd02 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2856,7 +2856,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 
 /* remove redundant charge if migration failed*/
 void mem_cgroup_end_migration(struct mem_cgroup *mem,
-	struct page *oldpage, struct page *newpage)
+	struct page *oldpage, struct page *newpage, bool success)
 {
 	struct page *used, *unused;
 	struct page_cgroup *pc;
@@ -2865,8 +2865,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 		return;
 	/* blocks rmdir() */
 	cgroup_exclude_rmdir(&mem->css);
-	/* at migration success, oldpage->mapping is NULL. */
-	if (oldpage->mapping) {
+	if (!success) {
 		used = oldpage;
 		unused = newpage;
 	} else {
diff --git a/mm/migrate.c b/mm/migrate.c
index 6ae8a66..be66b23 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -756,7 +756,7 @@ rcu_unlock:
 		rcu_read_unlock();
 uncharge:
 	if (!charge)
-		mem_cgroup_end_migration(mem, page, newpage);
+		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
 unlock:
 	unlock_page(page);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
