Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AA2B76B0189
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 19:26:57 -0400 (EDT)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH -mmotm 3/5] page_cgroup: introduce file cache flags
Date: Mon, 15 Mar 2010 00:26:40 +0100
Message-Id: <1268609202-15581-4-git-send-email-arighi@develer.com>
In-Reply-To: <1268609202-15581-1-git-send-email-arighi@develer.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Righi <arighi@develer.com>
List-ID: <linux-mm.kvack.org>

Introduce page_cgroup flags to keep track of file cache pages.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
---
 include/linux/page_cgroup.h |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index bf9a913..65247e4 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -40,7 +40,11 @@ enum {
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
 	/* for cache-status accounting */
-	PCG_FILE_MAPPED,
+	PCG_FILE_MAPPED, /* page is accounted as file rss*/
+	PCG_FILE_DIRTY, /* page is dirty */
+	PCG_FILE_WRITEBACK, /* page is being written back to disk */
+	PCG_FILE_WRITEBACK_TEMP, /* page is used as temporary buffer for FUSE */
+	PCG_FILE_UNSTABLE_NFS, /* NFS page not yet committed to the server */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -83,6 +87,22 @@ TESTPCGFLAG(FileMapped, FILE_MAPPED)
 SETPCGFLAG(FileMapped, FILE_MAPPED)
 CLEARPCGFLAG(FileMapped, FILE_MAPPED)
 
+TESTPCGFLAG(FileDirty, FILE_DIRTY)
+SETPCGFLAG(FileDirty, FILE_DIRTY)
+CLEARPCGFLAG(FileDirty, FILE_DIRTY)
+
+TESTPCGFLAG(FileWriteback, FILE_WRITEBACK)
+SETPCGFLAG(FileWriteback, FILE_WRITEBACK)
+CLEARPCGFLAG(FileWriteback, FILE_WRITEBACK)
+
+TESTPCGFLAG(FileWritebackTemp, FILE_WRITEBACK_TEMP)
+SETPCGFLAG(FileWritebackTemp, FILE_WRITEBACK_TEMP)
+CLEARPCGFLAG(FileWritebackTemp, FILE_WRITEBACK_TEMP)
+
+TESTPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
+SETPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
+CLEARPCGFLAG(FileUnstableNFS, FILE_UNSTABLE_NFS)
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
