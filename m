Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3AB0F6B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 11:55:19 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Fix breakage in NOMMU build
Date: Tue, 09 Mar 2010 16:55:09 +0000
Message-ID: <20100309165508.8522.63314.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@osdl.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mike Frysinger <vapier@gentoo.org>, Michal Simek <monstr@monstr.eu>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Commit 34e55232e59f7b19050267a05ff1226e5cd122a5 added sync_mm_rss() for
syncing loosely accounted rss counters.  It's for CONFIG_MMU but sync_mm_rss
is called even in NOMMU enviroment (kerne/exit.c, fs/exec.c).  Above commit
doesn't handle it well.

This patch changes
  SPLIT_RSS_COUNTING depends on SPLIT_PTLOCKS && CONFIG_MMU

And for avoid unnecessary function calls, sync_mm_rss changed to be inlined
noop function in header file.

Reported-by: David Howells <dhowells@redhat.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Michal Simek <monstr@monstr.eu>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/mm.h       |    6 ++++++
 include/linux/mm_types.h |    2 +-
 mm/memory.c              |    3 ---
 3 files changed, 7 insertions(+), 4 deletions(-)


diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3899395..7f693b2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -971,7 +971,13 @@ static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
 		*maxrss = hiwater_rss;
 }
 
+#if defined(SPLIT_RSS_COUNTING)
 void sync_mm_rss(struct task_struct *task, struct mm_struct *mm);
+#else
+static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
+{
+}
+#endif
 
 /*
  * A callback you can register to apply pressure to ageable caches.
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 048b462..b8bb9a6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -203,7 +203,7 @@ enum {
 	NR_MM_COUNTERS
 };
 
-#if USE_SPLIT_PTLOCKS
+#if USE_SPLIT_PTLOCKS && defined(CONFIG_MMU)
 #define SPLIT_RSS_COUNTING
 struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
diff --git a/mm/memory.c b/mm/memory.c
index d1153e3..3d9130b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -190,9 +190,6 @@ static void check_sync_rss_stat(struct task_struct *task)
 {
 }
 
-void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
-{
-}
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
