Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6B8486B00FE
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 04:11:07 -0400 (EDT)
From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH v2 1/4] mm: completely disable THP by transparent_hugepage=0
Date: Tue, 21 Jun 2011 16:10:42 +0800
Message-Id: <1308643849-3325-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Amerigo Wang <amwang@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

Introduce "transparent_hugepage=0" to totally disable THP.
"transparent_hugepage=never" means setting THP to be partially
disabled, we need a new way to totally disable it.

Signed-off-by: WANG Cong <amwang@redhat.com>
---
 Documentation/vm/transhuge.txt |    3 ++-
 mm/huge_memory.c               |   12 ++++++++++++
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 0924aac..43c4d53 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -156,7 +156,8 @@ for each pass:
 You can change the sysfs boot time defaults of Transparent Hugepage
 Support by passing the parameter "transparent_hugepage=always" or
 "transparent_hugepage=madvise" or "transparent_hugepage=never"
-(without "") to the kernel command line.
+(without "") to the kernel command line. To totally disable this
+feature, pass "transparent_hugepage=0".
 
 == Need of application restart ==
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 81532f2..e4a4f2b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -488,6 +488,8 @@ static struct attribute_group khugepaged_attr_group = {
 };
 #endif /* CONFIG_SYSFS */
 
+static int no_hugepage_init;
+
 static int __init hugepage_init(void)
 {
 	int err;
@@ -501,6 +503,13 @@ static int __init hugepage_init(void)
 		goto out;
 	}
 
+	if (no_hugepage_init) {
+		err = 0;
+		transparent_hugepage_flags = 0;
+		printk(KERN_INFO "hugepage: totally disabled\n");
+		goto out;
+	}
+
 #ifdef CONFIG_SYSFS
 	err = -ENOMEM;
 	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
@@ -572,6 +581,9 @@ static int __init setup_transparent_hugepage(char *str)
 		clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
 			  &transparent_hugepage_flags);
 		ret = 1;
+	} else if (!strcmp(str, "0")) {
+		no_hugepage_init = 1;
+		ret = 1;
 	}
 out:
 	if (!ret)
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
