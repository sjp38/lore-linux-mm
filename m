Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13CE88E0002
	for <linux-mm@kvack.org>; Tue, 25 Dec 2018 10:39:35 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id z5-v6so4726547ljb.13
        for <linux-mm@kvack.org>; Tue, 25 Dec 2018 07:39:35 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id v4-v6si26778858ljk.83.2018.12.25.07.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Dec 2018 07:39:33 -0800 (PST)
From: Konstantin Khorenko <khorenko@virtuozzo.com>
Subject: [PATCH 1/1] mm/page_alloc: add a warning about high order allocations
Date: Tue, 25 Dec 2018 18:39:27 +0300
Message-Id: <20181225153927.2873-2-khorenko@virtuozzo.com>
In-Reply-To: <20181225153927.2873-1-khorenko@virtuozzo.com>
References: <20181225153927.2873-1-khorenko@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khorenko <khorenko@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@suse.com>

Adds sysctl "vm.warn_high_order". If set it will warn about
allocations with order >= vm.warn_high_order.
Prints only 32 warnings at most and skips all __GFP_NOWARN allocations.

The code is under config option, disabled by default.
If enabled, default vm.warn_high_order is 3 (PAGE_ALLOC_COSTLY_ORDER).

Sysctl max value is set to 100 which should be enough to exceed maximum
order (normally MAX_ORDER == 11).

Signed-off-by: Konstantin Khorenko <khorenko@virtuozzo.com>
---
 kernel/sysctl.c | 15 +++++++++++++++
 mm/Kconfig      | 18 ++++++++++++++++++
 mm/page_alloc.c | 25 +++++++++++++++++++++++++
 3 files changed, 58 insertions(+)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5fc724e4e454..28a8ebfa7a1d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -176,6 +176,10 @@ extern int unaligned_dump_stack;
 extern int no_unaligned_warning;
 #endif
 
+#ifdef CONFIG_WARN_HIGH_ORDER
+extern int warn_order;
+#endif
+
 #ifdef CONFIG_PROC_SYSCTL
 
 /**
@@ -1675,6 +1679,17 @@ static struct ctl_table vm_table[] = {
 		.extra1		= (void *)&mmap_rnd_compat_bits_min,
 		.extra2		= (void *)&mmap_rnd_compat_bits_max,
 	},
+#endif
+#ifdef CONFIG_WARN_HIGH_ORDER
+	{
+		.procname	= "warn_high_order",
+		.data		= &warn_order,
+		.maxlen		= sizeof(warn_order),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 #endif
 	{ }
 };
diff --git a/mm/Kconfig b/mm/Kconfig
index d85e39da47ae..4e2d613d52f1 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -336,6 +336,24 @@ config MEMORY_FAILURE
 	  even when some of its memory has uncorrected errors. This requires
 	  special hardware support and typically ECC memory.
 
+config WARN_HIGH_ORDER
+	bool "Enable complains about high order memory allocations"
+	depends on !LOCKDEP
+	default n
+	help
+	  Enables warnings on high order memory allocations. This allows to
+	  determine users of large memory chunks and rework them to decrease
+	  allocation latency. Note, some debug options make kernel structures
+	  fat.
+
+config WARN_HIGH_ORDER_LEVEL
+	int "Define page order level considered as too high"
+	depends on WARN_HIGH_ORDER
+	default 3
+	help
+	  Defines page order starting which the system to complain about.
+	  Default is current PAGE_ALLOC_COSTLY_ORDER.
+
 config HWPOISON_INJECT
 	tristate "HWPoison pages injector"
 	depends on MEMORY_FAILURE && DEBUG_KERNEL && PROC_FS
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e95b5b7c9c3d..258892adb861 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4341,6 +4341,30 @@ static inline void finalise_ac(gfp_t gfp_mask, struct alloc_context *ac)
 					ac->high_zoneidx, ac->nodemask);
 }
 
+#ifdef CONFIG_WARN_HIGH_ORDER
+int warn_order = CONFIG_WARN_HIGH_ORDER_LEVEL;
+
+/*
+ * Complain if we allocate a high order page unless there is a __GFP_NOWARN
+ * flag provided.
+ *
+ * Shuts up after 32 complains.
+ */
+static __always_inline void warn_high_order(int order, gfp_t gfp_mask)
+{
+	static atomic_t warn_count = ATOMIC_INIT(32);
+
+	if (order >= warn_order && !(gfp_mask & __GFP_NOWARN))
+		WARN(atomic_dec_if_positive(&warn_count) >= 0,
+		     "order %d >= %d, gfp 0x%x\n",
+		     order, warn_order, gfp_mask);
+}
+#else
+static __always_inline void warn_high_order(int order, gfp_t gfp_mask)
+{
+}
+#endif
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -4361,6 +4385,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
 		return NULL;
 	}
+	warn_high_order(order, gfp_mask);
 
 	gfp_mask &= gfp_allowed_mask;
 	alloc_mask = gfp_mask;
-- 
2.15.1
