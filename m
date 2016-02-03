Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7B41B6B0253
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 06:03:32 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id r129so159237339wmr.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 03:03:32 -0800 (PST)
Received: from mail-wm0-x24a.google.com (mail-wm0-x24a.google.com. [2a00:1450:400c:c09::24a])
        by mx.google.com with ESMTPS id k4si9248901wje.12.2016.02.03.03.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 03:03:31 -0800 (PST)
Received: by mail-wm0-x24a.google.com with SMTP id r129so3980147wmr.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 03:03:30 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 3 Feb 2016 11:06:20 +0100
Message-ID: <001a114b360c7fdb9b052adb91d6@google.com>
Subject: [PATCH] mm: vmpressure: make vmpressure_window a tunable.
From: Martijn Coenen <maco@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Anton Vorontsov <anton@enomsg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>

The window size used for calculating vm pressure
events was previously fixed at 512 pages. The
window size has a big impact on the rate of notifications
sent off to userspace, in particular when using the
"low" level. On machines with a lot of memory, the
current value may be excessive.

On the other hand, making the window size depend on
machine size does not allow userspace to change the
notification rate based on the current state of the
system. For example, when a lot of memory is still
available, userspace may want to increase the window
since it's not interested in receiving notifications
for every 2MB scanned.

This patch makes vmpressure_window a sysctl tunable.

Signed-off-by: Martijn Coenen <maco@google.com>
---
  Documentation/sysctl/vm.txt | 15 +++++++++++++++
  include/linux/vmpressure.h  |  1 +
  kernel/sysctl.c             | 11 +++++++++++
  mm/vmpressure.c             |  5 ++---
  4 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 89a887c..0fa4846 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -60,6 +60,7 @@ Currently, these files are in /proc/sys/vm:
  - swappiness
  - user_reserve_kbytes
  - vfs_cache_pressure
+- vmpressure_window
  - zone_reclaim_mode

  ==============================================================
@@ -805,6 +806,20 @@ ten times more freeable objects than there are.

  ==============================================================

+vmpressure_window
+
+The vmpressure algorithm calculates vm pressure by looking
+at the number of pages reclaimed vs the number of pages scanned.
+The vmpressure_window tunable specifies the minimum amount
+of pages that needs to be scanned before sending any vmpressure
+event. Setting a small window size can cause a lot of false
+positives; setting a large window size may delay notifications
+for too long.
+
+The default value is 512 pages.
+
+==============================================================
+
  zone_reclaim_mode:

  Zone_reclaim_mode allows someone to set more or less aggressive approaches  
to
diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 3347cc3..b5341d0 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -29,6 +29,7 @@ struct vmpressure {
  struct mem_cgroup;

  #ifdef CONFIG_MEMCG
+extern unsigned long vmpressure_win;
  extern void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
  		       unsigned long scanned, unsigned long reclaimed);
  extern void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 97715fd..64938ad 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -51,6 +51,7 @@
  #include <linux/dnotify.h>
  #include <linux/syscalls.h>
  #include <linux/vmstat.h>
+#include <linux/vmpressure.h>
  #include <linux/nfs_fs.h>
  #include <linux/acpi.h>
  #include <linux/reboot.h>
@@ -1590,6 +1591,16 @@ static struct ctl_table vm_table[] = {
  		.extra2		= (void *)&mmap_rnd_compat_bits_max,
  	},
  #endif
+#ifdef CONFIG_MEMCG
+	{
+		.procname	= "vmpressure_window",
+		.data		= &vmpressure_win,
+		.maxlen		= sizeof(vmpressure_win),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1		= &one,
+	},
+#endif
  	{ }
  };

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 9a6c070..bda6af9 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -35,10 +35,9 @@
   * As the vmscan reclaimer logic works with chunks which are multiple of
   * SWAP_CLUSTER_MAX, it makes sense to use it for the window size as well.
   *
- * TODO: Make the window size depend on machine size, as we do for vmstat
- * thresholds. Currently we set it to 512 pages (2MB for 4KB pages).
+ * The window size is a tunable sysctl.
   */
-static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
+unsigned long __read_mostly vmpressure_win = SWAP_CLUSTER_MAX * 16;

  /*
   * These thresholds are used when we account memory pressure through
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
