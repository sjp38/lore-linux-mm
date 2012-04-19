Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 417926B0044
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 02:35:07 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so12425240pbc.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 23:35:06 -0700 (PDT)
Date: Wed, 18 Apr 2012 23:34:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] memcg: fix Bad page state after replace_page_cache
Message-ID: <alpine.LSU.2.00.1204182325350.3700@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <mszeredi@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

My 9ce70c0240d0 "memcg: fix deadlock by inverting lrucare nesting" put a
nasty little bug into v3.3's version of mem_cgroup_replace_page_cache(),
sometimes used for FUSE.  Replacing __mem_cgroup_commit_charge_lrucare()
by __mem_cgroup_commit_charge(), I used the "pc" pointer set up earlier:
but it's for oldpage, and needs now to be for newpage.  Once oldpage was
freed, its PageCgroupUsed bit (cleared above but set again here) caused
"Bad page state" messages - and perhaps worse, being missed from newpage.
(I didn't find this by using FUSE, but in reusing the function for tmpfs.)

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org [v3.3 only]
---

 mm/memcontrol.c |    1 +
 1 file changed, 1 insertion(+)

--- 3.4-rc3/mm/memcontrol.c	2012-04-15 20:47:37.151777506 -0700
+++ linux/mm/memcontrol.c	2012-04-18 22:29:18.490639511 -0700
@@ -3392,6 +3392,7 @@ void mem_cgroup_replace_page_cache(struc
 	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
 	 * LRU while we overwrite pc->mem_cgroup.
 	 */
+	pc = lookup_page_cgroup(newpage);
 	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, type, true);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
