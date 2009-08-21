Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 18E606B005D
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 15:19:56 -0400 (EDT)
Received: by ewy22 with SMTP id 22so894732ewy.4
        for <linux-mm@kvack.org>; Fri, 21 Aug 2009 12:19:27 -0700 (PDT)
Date: Fri, 21 Aug 2009 23:19:25 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] oom: move oom_killer_enable()/oom_killer_disable to where
	they belong
Message-ID: <20090821191925.GA5367@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/gfp.h    |   12 ------------
 include/linux/oom.h    |   11 +++++++++++
 kernel/power/process.c |    1 +
 3 files changed, 12 insertions(+), 12 deletions(-)

--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -336,18 +336,6 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 void drain_all_pages(void);
 void drain_local_pages(void *dummy);
 
-extern bool oom_killer_disabled;
-
-static inline void oom_killer_disable(void)
-{
-	oom_killer_disabled = true;
-}
-
-static inline void oom_killer_enable(void)
-{
-	oom_killer_disabled = false;
-}
-
 extern gfp_t gfp_allowed_mask;
 
 static inline void set_gfp_allowed_mask(gfp_t mask)
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -30,5 +30,16 @@ extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
+extern bool oom_killer_disabled;
+
+static inline void oom_killer_disable(void)
+{
+	oom_killer_disabled = true;
+}
+
+static inline void oom_killer_enable(void)
+{
+	oom_killer_disabled = false;
+}
 #endif /* __KERNEL__*/
 #endif /* _INCLUDE_LINUX_OOM_H */
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -9,6 +9,7 @@
 #undef DEBUG
 
 #include <linux/interrupt.h>
+#include <linux/oom.h>
 #include <linux/suspend.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
