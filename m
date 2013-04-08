Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 08A106B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:07:55 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y10so3354272pdj.26
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 12:07:54 -0700 (PDT)
Date: Mon, 8 Apr 2013 15:07:38 -0400
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH v8 3/3] mm: reinititalise user and admin reserves if memory
 is added or removed
Message-ID: <20130408190738.GC2321@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

This patch alters the admin and user reserves of the previous patches 
in this series when memory is added or removed.

If memory is added and the reserves have been eliminated or increased above
the default max, then we'll trust the admin.

If memory is removed and there isn't enough free memory, then we
need to reset the reserves.

Otherwise keep the reserve set by the admin.

The reserve reset code is the same as the reserve initialization code.

Does this sound reasonable to other people? I figured that hot removal
with too large of memory in the reserves was the most important case 
to get right.

I tested hot addition and removal by triggering it via sysfs. The reserves 
shrunk when they were set high and memory was removed. They were reset 
higher when memory was added again.

---
 mm/mmap.c | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 8fb9d99..321348b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -33,6 +33,8 @@
 #include <linux/uprobes.h>
 #include <linux/rbtree_augmented.h>
 #include <linux/sched/sysctl.h>
+#include <linux/notifier.h>
+#include <linux/memory.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -3111,3 +3113,64 @@ int __meminit init_admin_reserve(void)
 	return 0;
 }
 module_init(init_admin_reserve)
+
+/*
+ * Reinititalise user and admin reserves if memory is added or removed.
+ *
+ * If memory is added and the reserves have been eliminated or increased above
+ * the default max, then we'll trust the admin. 
+ *
+ * If memory is removed and there isn't enough free memory, then we 
+ * need to reset the reserves.
+ *
+ * Otherwise keep the reserve set by the admin.
+ */
+static int reserve_mem_notifier(struct notifier_block *nb,
+			     unsigned long action, void *data)
+{
+	unsigned long tmp, free_kbytes;
+
+	switch (action) {
+	case MEM_ONLINE:
+		tmp = sysctl_user_reserve_kbytes;
+		if (0 < tmp && tmp < (1UL << 17))
+			init_user_reserve();
+
+		tmp = sysctl_admin_reserve_kbytes;
+		if (0 < tmp && tmp < (1UL << 13))
+			init_admin_reserve();
+
+		break;
+	case MEM_OFFLINE:
+		free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+
+		if (sysctl_user_reserve_kbytes > free_kbytes) {
+			init_user_reserve();
+			pr_info("vm.user_reserve_kbytes reset to %lu\n",
+				sysctl_user_reserve_kbytes);
+		}
+
+		if (sysctl_admin_reserve_kbytes > free_kbytes) {
+			init_admin_reserve();
+			pr_info("vm.admin_reserve_kbytes reset to %lu\n",
+				sysctl_admin_reserve_kbytes);
+		}
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block reserve_mem_nb = {
+	.notifier_call = reserve_mem_notifier,
+};
+
+int __meminit init_reserve_notifier(void)
+{
+	if (register_memory_notifier(&reserve_mem_nb))
+		printk("Failed registering memory add/remove notifier for admin reserve");
+
+	return 0;
+}
+module_init(init_reserve_notifier)
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
