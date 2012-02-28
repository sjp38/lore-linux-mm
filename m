Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 596E56B004D
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:56:22 -0500 (EST)
Message-Id: <20120228144746.900395448@intel.com>
Date: Tue, 28 Feb 2012 22:00:23 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 1/9] memcg: add page_cgroup flags for dirty page tracking
References: <20120228140022.614718843@intel.com>
Content-Disposition: inline; filename=memcg-add-page_cgroup-flags-for-dirty-page-tracking.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Minchan Kim <minchan.kim@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

From: Greg Thelen <gthelen@google.com>

Add additional flags to page_cgroup to track dirty pages
within a mem_cgroup.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Andrea Righi <andrea@betterlinux.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/page_cgroup.h |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

--- linux.orig/include/linux/page_cgroup.h	2012-02-19 10:53:14.000000000 +0800
+++ linux/include/linux/page_cgroup.h	2012-02-19 10:53:16.000000000 +0800
@@ -10,6 +10,9 @@ enum {
 	/* flags for mem_cgroup and file and I/O status */
 	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
 	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
+	PCG_FILE_DIRTY, /* page is dirty */
+	PCG_FILE_WRITEBACK, /* page is under writeback */
+	PCG_FILE_UNSTABLE_NFS, /* page is NFS unstable */
 	__NR_PCG_FLAGS,
 };
 
@@ -64,6 +67,10 @@ static inline void ClearPageCgroup##unam
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
 
+#define TESTSETPCGFLAG(uname, lname)			\
+static inline int TestSetPageCgroup##uname(struct page_cgroup *pc)	\
+	{ return test_and_set_bit(PCG_##lname, &pc->flags); }
+
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
 CLEARPCGFLAG(Cache, CACHE)
@@ -77,6 +84,22 @@ SETPCGFLAG(FileMapped, FILE_MAPPED)
 CLEARPCGFLAG(FileMapped, FILE_MAPPED)
 TESTPCGFLAG(FileMapped, FILE_MAPPED)
 
+SETPCGFLAG(FileDirty, FILE_DIRTY)
+CLEARPCGFLAG(FileDirty, FILE_DIRTY)
+TESTPCGFLAG(FileDirty, FILE_DIRTY)
+TESTCLEARPCGFLAG(FileDirty, FILE_DIRTY)
+TESTSETPCGFLAG(FileDirty, FILE_DIRTY)
+
+SETPCGFLAG(FileWriteback, FILE_WRITEBACK)
+CLEARPCGFLAG(FileWriteback, FILE_WRITEBACK)
+TESTPCGFLAG(FileWriteback, FILE_WRITEBACK)
+
+SETPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
+CLEARPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
+TESTPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
+TESTCLEARPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
+TESTSETPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
+
 SETPCGFLAG(Migration, MIGRATION)
 CLEARPCGFLAG(Migration, MIGRATION)
 TESTPCGFLAG(Migration, MIGRATION)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
