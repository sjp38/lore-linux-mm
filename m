Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA156B006E
	for <linux-mm@kvack.org>; Thu,  7 May 2015 10:10:07 -0400 (EDT)
Received: by pdea3 with SMTP id a3so42405788pde.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 07:10:06 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ed4si2934980pbc.132.2015.05.07.07.10.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 07:10:06 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v4 2/3] proc: add kpagecgroup file
Date: Thu, 7 May 2015 17:09:41 +0300
Message-ID: <26cc7e1dfc31afc565e72228b3602b9b5a3c1f49.1431002699.git.vdavydov@parallels.com>
In-Reply-To: <cover.1431002699.git.vdavydov@parallels.com>
References: <cover.1431002699.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

/proc/kpagecgroup contains a 64-bit inode number of the memory cgroup
each page is charged to, indexed by PFN. Having this information is
useful for estimating a cgroup working set size.

The file is present if CONFIG_PROC_PAGE_MONITOR && CONFIG_MEMCG.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 Documentation/vm/pagemap.txt |    6 ++++-
 fs/proc/Kconfig              |    5 ++--
 fs/proc/page.c               |   53 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 6bfbc172cdb9..a9b7afc8fbc6 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
 userspace programs to examine the page tables and related information by
 reading files in /proc.
 
-There are three components to pagemap:
+There are four components to pagemap:
 
  * /proc/pid/pagemap.  This file lets a userspace process find out which
    physical frame each virtual page is mapped to.  It contains one 64-bit
@@ -65,6 +65,10 @@ There are three components to pagemap:
     23. BALLOON
     24. ZERO_PAGE
 
+ * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
+   memory cgroup each page is charged to, indexed by PFN. Only available when
+   CONFIG_MEMCG is set.
+
 Short descriptions to the page flags:
 
  0. LOCKED
diff --git a/fs/proc/Kconfig b/fs/proc/Kconfig
index 2183fcf41d59..5021a2935bb9 100644
--- a/fs/proc/Kconfig
+++ b/fs/proc/Kconfig
@@ -69,5 +69,6 @@ config PROC_PAGE_MONITOR
  	help
 	  Various /proc files exist to monitor process memory utilization:
 	  /proc/pid/smaps, /proc/pid/clear_refs, /proc/pid/pagemap,
-	  /proc/kpagecount, and /proc/kpageflags. Disabling these
-          interfaces will reduce the size of the kernel by approximately 4kb.
+	  /proc/kpagecount, /proc/kpageflags, and /proc/kpagecgroup.
+	  Disabling these interfaces will reduce the size of the kernel
+	  by approximately 4kb.
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 7eee2d8b97d9..70d23245dd43 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -9,6 +9,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/hugetlb.h>
+#include <linux/memcontrol.h>
 #include <linux/kernel-page-flags.h>
 #include <asm/uaccess.h>
 #include "internal.h"
@@ -225,10 +226,62 @@ static const struct file_operations proc_kpageflags_operations = {
 	.read = kpageflags_read,
 };
 
+#ifdef CONFIG_MEMCG
+static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	u64 __user *out = (u64 __user *)buf;
+	struct page *ppage;
+	unsigned long src = *ppos;
+	unsigned long pfn;
+	ssize_t ret = 0;
+	u64 ino;
+
+	pfn = src / KPMSIZE;
+	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
+	if (src & KPMMASK || count & KPMMASK)
+		return -EINVAL;
+
+	while (count > 0) {
+		if (pfn_valid(pfn))
+			ppage = pfn_to_page(pfn);
+		else
+			ppage = NULL;
+
+		if (ppage)
+			ino = page_cgroup_ino(ppage);
+		else
+			ino = 0;
+
+		if (put_user(ino, out)) {
+			ret = -EFAULT;
+			break;
+		}
+
+		pfn++;
+		out++;
+		count -= KPMSIZE;
+	}
+
+	*ppos += (char __user *)out - buf;
+	if (!ret)
+		ret = (char __user *)out - buf;
+	return ret;
+}
+
+static const struct file_operations proc_kpagecgroup_operations = {
+	.llseek = mem_lseek,
+	.read = kpagecgroup_read,
+};
+#endif /* CONFIG_MEMCG */
+
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
 	proc_create("kpageflags", S_IRUSR, NULL, &proc_kpageflags_operations);
+#ifdef CONFIG_MEMCG
+	proc_create("kpagecgroup", S_IRUSR, NULL, &proc_kpagecgroup_operations);
+#endif
 	return 0;
 }
 fs_initcall(proc_page_init);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
