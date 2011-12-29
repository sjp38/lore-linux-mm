Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 2364B6B0062
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 19:26:11 -0500 (EST)
Received: by iacb35 with SMTP id b35so27284938iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 16:26:10 -0800 (PST)
Date: Wed, 28 Dec 2011 16:26:02 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/4] memcg: fix mem_cgroup_print_bad_page
In-Reply-To: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112281623400.8257@eggly.anvils>
References: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

If DEBUG_VM, mem_cgroup_print_bad_page() is called whenever bad_page()
shows a "Bad page state" message, removes page from circulation, adds a
taint and continues.  This is at a very low level, often when a spinlock
is held (sometimes when page table lock is held, for example).

We want to recover from this badness, not make it worse: we must not
kmalloc memory here, we must not do a cgroup path lookup via dubious
pointers.  No doubt that code was useful to debug a particular case
at one time, and may be again, but take it out of the mainline kernel.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
This goes back to 2.6.39; but it is under DEBUG_VM, so probably
doesn't need Cc stable.

 mm/memcontrol.c |   17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

--- mmotm.orig/mm/memcontrol.c	2011-12-28 14:41:19.803018025 -0800
+++ mmotm/mm/memcontrol.c	2011-12-28 15:07:26.887055270 -0800
@@ -3369,23 +3369,8 @@ void mem_cgroup_print_bad_page(struct pa
 
 	pc = lookup_page_cgroup_used(page);
 	if (pc) {
-		int ret = -1;
-		char *path;
-
-		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p",
+		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p\n",
 		       pc, pc->flags, pc->mem_cgroup);
-
-		path = kmalloc(PATH_MAX, GFP_KERNEL);
-		if (path) {
-			rcu_read_lock();
-			ret = cgroup_path(pc->mem_cgroup->css.cgroup,
-							path, PATH_MAX);
-			rcu_read_unlock();
-		}
-
-		printk(KERN_CONT "(%s)\n",
-				(ret < 0) ? "cannot get the path" : path);
-		kfree(path);
 	}
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
