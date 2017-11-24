Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D387A6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:07:23 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id d10so2942152lfj.17
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 02:07:23 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id 26si8375266ljo.222.2017.11.24.02.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 02:07:22 -0800 (PST)
From: Peter Enderborg <peter.enderborg@sony.com>
Subject: [PATCH] mm:Add watermark slope for high mark
Date: Fri, 24 Nov 2017 11:07:07 +0100
Message-ID: <20171124100707.24190-1-peter.enderborg@sony.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, David Rientjes <rientjes@google.com>, Peter Enderborg <peter.enderborg@sony.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Nikolay Borisov <nborisov@suse.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>

When tuning the watermark_scale_factor to reduce stalls and compactions
the high mark is also changed, it changed a bit too much. So this
patch introduces a slope that can reduce this overhead a bit, or
increase it if needed.

Signed-off-by: Peter Enderborg <peter.enderborg@sony.com>
---
 Documentation/sysctl/vm.txt | 15 +++++++++++++++
 include/linux/mm.h          |  1 +
 include/linux/mmzone.h      |  2 ++
 kernel/sysctl.c             |  9 +++++++++
 mm/page_alloc.c             |  6 +++++-
 5 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index eda628c..aecff6c 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -62,6 +62,7 @@ Currently, these files are in /proc/sys/vm:
 - user_reserve_kbytes
 - vfs_cache_pressure
 - watermark_scale_factor
+- watermark_high_factor_slope
 - zone_reclaim_mode
 
 ==============================================================
@@ -857,6 +858,20 @@ that the number of free pages kswapd maintains for latency reasons is
 too small for the allocation bursts occurring in the system. This knob
 can then be used to tune kswapd aggressiveness accordingly.
 
+=============================================================
+
+watermark_high_factor_slope:
+
+This factor is high mark for watermark_scale_factor.
+The unit is in percent.
+Max value is 1000 and min value is 100. (High watermark is the same as
+low water mark) Low watermark is min_wmark_pages + watermark_scale_factor.
+and high watermark is
+min_wmark_pages+(watermark_scale_factor * watermark_high_factor_slope).
+
+The default value is 200.
+
+
 ==============================================================
 
 zone_reclaim_mode:
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7661156..c89536b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2094,6 +2094,7 @@ extern void zone_pcp_reset(struct zone *zone);
 /* page_alloc.c */
 extern int min_free_kbytes;
 extern int watermark_scale_factor;
+extern int watermark_high_factor_slope;
 
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 67f2e3c..91bf842 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -886,6 +886,8 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+//int watermark_high_factor_tilt_sysctl_handler(struct ctl_table *, int,
+//					void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 2fb4e27..83c48c9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1444,6 +1444,15 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one_thousand,
 	},
 	{
+		.procname	= "watermark_high_factor_slope",
+		.data		= &watermark_high_factor_slope,
+		.maxlen		= sizeof(watermark_high_factor_slope),
+		.mode		= 0644,
+		.proc_handler	= watermark_scale_factor_sysctl_handler,
+		.extra1		= &one_hundred,
+		.extra2		= &one_thousand,
+	},
+	{
 		.procname	= "percpu_pagelist_fraction",
 		.data		= &percpu_pagelist_fraction,
 		.maxlen		= sizeof(percpu_pagelist_fraction),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48b5b01..3dc50ff 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -263,6 +263,7 @@ compound_page_dtor * const compound_page_dtors[] = {
 int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 int watermark_scale_factor = 10;
+int watermark_high_factor_slope = 200;
 
 static unsigned long __meminitdata nr_kernel_pages;
 static unsigned long __meminitdata nr_all_pages;
@@ -6989,6 +6990,7 @@ static void __setup_per_zone_wmarks(void)
 
 	for_each_zone(zone) {
 		u64 tmp;
+		u64 tmp_high;
 
 		spin_lock_irqsave(&zone->lock, flags);
 		tmp = (u64)pages_min * zone->managed_pages;
@@ -7026,7 +7028,9 @@ static void __setup_per_zone_wmarks(void)
 				      watermark_scale_factor, 10000));
 
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
-		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
+		tmp_high = mult_frac(tmp, watermark_high_factor_slope, 100);
+		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp_high;
+
 
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
