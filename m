Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8758D6B0099
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 20:02:11 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o29128dF018185
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Mar 2010 10:02:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E00BA45DE5D
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 10:02:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E64245DE51
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 10:02:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DCF61DB803C
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 10:02:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 37CA01DB804C
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 10:02:03 +0900 (JST)
Date: Tue, 9 Mar 2010 09:58:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] fix sync_mm_rss in nommu (Was Re: sync_mm_rss()
 issues
Message-Id: <20100309095830.7d4a744d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <30859.1268056796@redhat.com>
References: <30859.1268056796@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David-san, could you check this ?
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Fix breakage in NOMMU build

commit 34e55232e59f7b19050267a05ff1226e5cd122a5 added sync_mm_rss()
for syncing loosely accounted rss counters. It's for CONFIG_MMU but
sync_mm_rss is called even in NOMMU enviroment (kerne/exit.c, fs/exec.c).
Above commit doesn't handle it well.

This patch changes
  SPLIT_RSS_COUNTING depends on SPLIT_PTLOCKS && CONFIG_MMU

And for avoid unnecessary function calls, sync_mm_rss changed to be inlined
noop function in header file.

Reported-by: David Howells <dhowells@redhat.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm.h       |    6 ++++++
 include/linux/mm_types.h |    2 +-
 mm/memory.c              |    3 ---
 3 files changed, 7 insertions(+), 4 deletions(-)

Index: mmotm-2.6.33-Mar5/include/linux/mm.h
===================================================================
--- mmotm-2.6.33-Mar5.orig/include/linux/mm.h
+++ mmotm-2.6.33-Mar5/include/linux/mm.h
@@ -974,7 +974,13 @@ static inline void setmax_mm_hiwater_rss
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
Index: mmotm-2.6.33-Mar5/mm/memory.c
===================================================================
--- mmotm-2.6.33-Mar5.orig/mm/memory.c
+++ mmotm-2.6.33-Mar5/mm/memory.c
@@ -190,9 +190,6 @@ static void check_sync_rss_stat(struct t
 {
 }
 
-void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
-{
-}
 #endif
 
 /*
Index: mmotm-2.6.33-Mar5/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.33-Mar5.orig/include/linux/mm_types.h
+++ mmotm-2.6.33-Mar5/include/linux/mm_types.h
@@ -203,7 +203,7 @@ enum {
 	NR_MM_COUNTERS
 };
 
-#if USE_SPLIT_PTLOCKS
+#if USE_SPLIT_PTLOCKS && defined(CONFIG_MMU)
 #define SPLIT_RSS_COUNTING
 struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
