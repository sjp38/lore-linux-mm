Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7A26B011A
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:35:12 -0400 (EDT)
From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
Date: Tue, 21 Jun 2011 00:34:28 +0800
Message-Id: <1308587683-2555-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Amerigo Wang <amwang@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

transparent_hugepage=never should mean to disable THP completely,
otherwise we don't have a way to disable THP completely.
The design is broken.

Signed-off-by: WANG Cong <amwang@redhat.com>
---
 mm/huge_memory.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 81532f2..9c63c90 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -488,19 +488,26 @@ static struct attribute_group khugepaged_attr_group = {
 };
 #endif /* CONFIG_SYSFS */
 
+#define hugepage_enabled()	khugepaged_enabled()
+
 static int __init hugepage_init(void)
 {
-	int err;
+	int err = 0;
 #ifdef CONFIG_SYSFS
 	static struct kobject *hugepage_kobj;
 #endif
 
-	err = -EINVAL;
 	if (!has_transparent_hugepage()) {
+		err = -EINVAL;
 		transparent_hugepage_flags = 0;
 		goto out;
 	}
 
+	if (!hugepage_enabled()) {
+		printk(KERN_INFO "hugepage: totally disabled\n");
+		goto out;
+	}
+
 #ifdef CONFIG_SYSFS
 	err = -ENOMEM;
 	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
