Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 2B7B56B005C
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 13:38:15 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH 2/3] pagemap: export KPF_THP
Date: Mon, 19 Dec 2011 13:38:38 -0500
Message-Id: <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This flag shows that a given pages is a subpage of transparent hugepage.
It does not care about whether it is a head page or a tail page, because
it's clear from pfn of the target page which you should know when you read
/proc/kpageflags.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/page.c                    |    5 +++++
 include/linux/kernel-page-flags.h |    4 ++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git 3.2-rc5.orig/fs/proc/page.c 3.2-rc5/fs/proc/page.c
index 6d8e6a9..d436fc6 100644
--- 3.2-rc5.orig/fs/proc/page.c
+++ 3.2-rc5/fs/proc/page.c
@@ -116,6 +116,11 @@ u64 stable_page_flags(struct page *page)
 	if (PageHuge(page))
 		u |= 1 << KPF_HUGE;
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (PageTransCompound(page))
+		u |= 1 << KPF_THP;
+#endif
+
 	/*
 	 * Caveats on high order pages: page->_count will only be set
 	 * -1 on the head page; SLUB/SLQB do the same for PG_slab;
diff --git 3.2-rc5.orig/include/linux/kernel-page-flags.h 3.2-rc5/include/linux/kernel-page-flags.h
index bd92a89..7b83ee7 100644
--- 3.2-rc5.orig/include/linux/kernel-page-flags.h
+++ 3.2-rc5/include/linux/kernel-page-flags.h
@@ -31,6 +31,10 @@
 
 #define KPF_KSM			21
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define KPF_THP			22
+#endif
+
 /* kernel hacking assistances
  * WARNING: subject to change, never rely on them!
  */
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
