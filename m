Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9266B0036
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:35:47 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so9476005pad.7
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:35:47 -0700 (PDT)
Subject: [RFC][PATCH 4/8] mm: pcp: move pageset sysctl code to sysctl.c
From: Dave Hansen <dave@sr71.net>
Date: Tue, 15 Oct 2013 13:35:44 -0700
References: <20131015203536.1475C2BE@viggo.jf.intel.com>
In-Reply-To: <20131015203536.1475C2BE@viggo.jf.intel.com>
Message-Id: <20131015203544.7BD0F572@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

The percpu_pagelist_fraction_sysctl_handler() code is currently
in page_alloc.c, probably because it uses some functions static
to that file.  Now that it is smaller and its interactions with
the rest of the allocator code are confined to
update_all_zone_pageset_limits(), it is much less bound to that
file.

We will replace proc_dointvec_minmax() with a function private
to sysctl.c in the next patch.  We are stuck either exporting
that (ugly) function in the sysctl header, or exporting
update_all_zone_pageset_limits() from the mm headers.  I chose
to export from the mm headers since the function is simpler and
much less likely to get used in bad ways.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/gfp.h    |    1 +
 linux.git-davehans/include/linux/mmzone.h |    2 --
 linux.git-davehans/kernel/sysctl.c        |   20 ++++++++++++++++++++
 linux.git-davehans/mm/page_alloc.c        |   17 -----------------
 4 files changed, 21 insertions(+), 19 deletions(-)

diff -puN include/linux/gfp.h~move-pageset-sysctl-code include/linux/gfp.h
--- linux.git/include/linux/gfp.h~move-pageset-sysctl-code	2013-10-15 09:57:06.691648515 -0700
+++ linux.git-davehans/include/linux/gfp.h	2013-10-15 09:57:06.700648914 -0700
@@ -374,6 +374,7 @@ extern void free_memcg_kmem_pages(unsign
 #define free_page(addr) free_pages((addr), 0)
 
 void page_alloc_init(void);
+void update_all_zone_pageset_limits(void);
 void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 void drain_all_pages(void);
 void drain_local_pages(void *dummy);
diff -puN include/linux/mmzone.h~move-pageset-sysctl-code include/linux/mmzone.h
--- linux.git/include/linux/mmzone.h~move-pageset-sysctl-code	2013-10-15 09:57:06.693648603 -0700
+++ linux.git-davehans/include/linux/mmzone.h	2013-10-15 09:57:06.701648958 -0700
@@ -894,8 +894,6 @@ int min_free_kbytes_sysctl_handler(struc
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
diff -puN kernel/sysctl.c~move-pageset-sysctl-code kernel/sysctl.c
--- linux.git/kernel/sysctl.c~move-pageset-sysctl-code	2013-10-15 09:57:06.694648648 -0700
+++ linux.git-davehans/kernel/sysctl.c	2013-10-15 09:57:06.702649002 -0700
@@ -176,6 +176,9 @@ static int proc_taint(struct ctl_table *
 			       void __user *buffer, size_t *lenp, loff_t *ppos);
 #endif
 
+static int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
+			void __user *buffer, size_t *length, loff_t *ppos);
+
 #ifdef CONFIG_PRINTK
 static int proc_dointvec_minmax_sysadmin(struct ctl_table *table, int write,
 				void __user *buffer, size_t *lenp, loff_t *ppos);
@@ -2455,6 +2458,23 @@ static int proc_do_cad_pid(struct ctl_ta
 	return 0;
 }
 
+/*
+ * percpu_pagelist_fraction - changes the pcp->high for each zone on each
+ * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
+ * can have before it gets flushed back to buddy allocator.
+ */
+static int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (!write || (ret < 0))
+		return ret;
+
+	update_all_zone_pageset_limits();
+
+	return 0;
+}
+
 /**
  * proc_do_large_bitmap - read/write from/to a large bitmap
  * @table: the sysctl table
diff -puN mm/page_alloc.c~move-pageset-sysctl-code mm/page_alloc.c
--- linux.git/mm/page_alloc.c~move-pageset-sysctl-code	2013-10-15 09:57:06.697648781 -0700
+++ linux.git-davehans/mm/page_alloc.c	2013-10-15 09:57:06.704649091 -0700
@@ -5781,23 +5781,6 @@ void update_all_zone_pageset_limits(void
 	mutex_unlock(&pcp_batch_high_lock);
 }
 
-/*
- * percpu_pagelist_fraction - changes the pcp->high for each zone on each
- * cpu.  It is the fraction of total pages in each zone that a hot per cpu
- * pagelist can have before it gets flushed back to buddy allocator.
- */
-int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
-{
-	int ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (!write || (ret < 0))
-		return ret;
-
-	update_all_zone_pageset_limits();
-
-	return 0;
-}
-
 int hashdist = HASHDIST_DEFAULT;
 
 #ifdef CONFIG_NUMA
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
