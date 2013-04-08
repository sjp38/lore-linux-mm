Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 321926B0044
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 16:37:39 -0400 (EDT)
Received: by mail-ie0-f201.google.com with SMTP id a11so1572469iee.2
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 13:37:36 -0700 (PDT)
Subject: + mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed.patch added to -mm tree
From: akpm@linux-foundation.org
Date: Mon, 08 Apr 2013 13:37:34 -0700
Message-Id: <20130408203734.E502131C2DC@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org
Cc: agshew@gmail.com, linux-mm@kvack.org


The patch titled
     Subject: mm: reinititalise user and admin reserves if memory is added or removed
has been added to the -mm tree.  Its filename is
     mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed.patch

Before you just go and hit "reply", please:
   a) Consider who else should be cc'ed
   b) Prefer to cc a suitable mailing list as well
   c) Ideally: find the original patch on the mailing list and do a
      reply-to-all to that, adding suitable additional cc's

*** Remember to use Documentation/SubmitChecklist when testing your code ***

The -mm tree is included into linux-next and is updated
there every 3-4 working days

------------------------------------------------------
From: Andrew Shewmaker <agshew@gmail.com>
Subject: mm: reinititalise user and admin reserves if memory is added or removed

Alter the admin and user reserves of the previous patches in this series
when memory is added or removed.

If memory is added and the reserves have been eliminated or increased
above the default max, then we'll trust the admin.

If memory is removed and there isn't enough free memory, then we need to
reset the reserves.

Otherwise keep the reserve set by the admin.

The reserve reset code is the same as the reserve initialization code.

I tested hot addition and removal by triggering it via sysfs.  The
reserves shrunk when they were set high and memory was removed.  They were
reset higher when memory was added again.

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mmap.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff -puN mm/mmap.c~mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed mm/mmap.c
--- a/mm/mmap.c~mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed
+++ a/mm/mmap.c
@@ -33,6 +33,8 @@
 #include <linux/uprobes.h>
 #include <linux/rbtree_augmented.h>
 #include <linux/sched/sysctl.h>
+#include <linux/notifier.h>
+#include <linux/memory.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -3141,3 +3143,64 @@ int __meminit init_admin_reserve(void)
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
_

Patches currently in -mm which might be from agshew@gmail.com are

include-linux-memoryh-implement-register_hotmemory_notifier.patch
mm-limit-growth-of-3%-hardcoded-other-user-reserve.patch
mm-replace-hardcoded-3%-with-admin_reserve_pages-knob.patch
mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed.patch
mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
