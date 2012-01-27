Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 6252E6B005C
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 18:01:55 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/6] pagemap: export KPF_THP
Date: Fri, 27 Jan 2012 18:02:50 -0500
Message-Id: <1327705373-29395-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This flag shows that a given pages is a subpage of transparent hugepage.
It helps us debug and test kernel by showing physical address of thp.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Changes since v2:
  - replace if with else-if not to set KPF_THP for hugetlbfs page

Changes since v1:
  - remove unnecessary ifdefs
  - fix confusing patch description
---
 fs/proc/page.c                    |    2 ++
 include/linux/kernel-page-flags.h |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git 3.3-rc1.orig/fs/proc/page.c 3.3-rc1/fs/proc/page.c
index 6d8e6a9..7fcd0d6 100644
--- 3.3-rc1.orig/fs/proc/page.c
+++ 3.3-rc1/fs/proc/page.c
@@ -115,6 +115,8 @@ u64 stable_page_flags(struct page *page)
 		u |= 1 << KPF_COMPOUND_TAIL;
 	if (PageHuge(page))
 		u |= 1 << KPF_HUGE;
+	else if (PageTransCompound(page))
+		u |= 1 << KPF_THP;
 
 	/*
 	 * Caveats on high order pages: page->_count will only be set
diff --git 3.3-rc1.orig/include/linux/kernel-page-flags.h 3.3-rc1/include/linux/kernel-page-flags.h
index bd92a89..26a6571 100644
--- 3.3-rc1.orig/include/linux/kernel-page-flags.h
+++ 3.3-rc1/include/linux/kernel-page-flags.h
@@ -30,6 +30,7 @@
 #define KPF_NOPAGE		20
 
 #define KPF_KSM			21
+#define KPF_THP			22
 
 /* kernel hacking assistances
  * WARNING: subject to change, never rely on them!
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
