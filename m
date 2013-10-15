Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1046B003B
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:35:58 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so9567386pab.39
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:35:58 -0700 (PDT)
Subject: [RFC][PATCH 5/8] mm: pcp: make percpu_pagelist_fraction sysctl undoable
From: Dave Hansen <dave@sr71.net>
Date: Tue, 15 Oct 2013 13:35:45 -0700
References: <20131015203536.1475C2BE@viggo.jf.intel.com>
In-Reply-To: <20131015203536.1475C2BE@viggo.jf.intel.com>
Message-Id: <20131015203545.9DAADC18@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

The kernel has two methods of setting the sizes of the percpu
pagesets:

 1. The default, according to a page_alloc.c comment is "set to
    around 1000th of the size of the zone.  But no more than 1/2
    of a meg."
 2. After boot, vm.percpu_pagelist_fraction can be set to
    override the default.

However, the trip from 1->2 is a one-way street.  There's no way
to get back.  You can get either the 'high' or 'batch' values to
match the boot-time value, but since the relationship between the
two is different in the two different modes, you can never get
back _exactly_ to where you were.  This kinda sucks if you are
trying to do performance testing to find optimal values.

Note that we remove the .extra1 argument to the sysctl structure.
The bounding behavior is now open-coded in the handler.

Since we are now able to go back to the boot-time values, we
need the boot-time function zone_batchsize() to be available
at runtime, so remove its __meminit.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/Documentation/sysctl/vm.txt |    6 +++---
 linux.git-davehans/kernel/sysctl.c             |   25 +++++++++++++++++++++----
 linux.git-davehans/mm/page_alloc.c             |    2 +-
 3 files changed, 25 insertions(+), 8 deletions(-)

diff -puN Documentation/sysctl/vm.txt~make-percpu_pagelist_fraction-sysctl-undoable Documentation/sysctl/vm.txt
--- linux.git/Documentation/sysctl/vm.txt~make-percpu_pagelist_fraction-sysctl-undoable	2013-10-15 09:57:07.004662395 -0700
+++ linux.git-davehans/Documentation/sysctl/vm.txt	2013-10-15 09:57:07.011662705 -0700
@@ -653,6 +653,9 @@ why oom happens. You can get snapshot.
 
 percpu_pagelist_fraction
 
+Set (at boot) to 0.  The kernel will size each percpu pagelist to around
+1/1000th of the size of the zone but limited to be around 0.75MB.
+
 This is the fraction of pages at most (high mark pcp->high) in each zone that
 are allocated for each per cpu page list.  The min value for this is 8.  It
 means that we don't allow more than 1/8th of pages in each zone to be
@@ -663,9 +666,6 @@ of hot per cpu pagelists.  User can spec
 The batch value of each per cpu pagelist is also updated as a result.  It is
 set to pcp->high/4.  The upper limit of batch is (PAGE_SHIFT * 8)
 
-The initial value is zero.  Kernel does not use this value at boot time to set
-the high water marks for each per cpu page list.
-
 ==============================================================
 
 stat_interval
diff -puN kernel/sysctl.c~make-percpu_pagelist_fraction-sysctl-undoable kernel/sysctl.c
--- linux.git/kernel/sysctl.c~make-percpu_pagelist_fraction-sysctl-undoable	2013-10-15 09:57:07.005662439 -0700
+++ linux.git-davehans/kernel/sysctl.c	2013-10-15 09:57:07.012662750 -0700
@@ -138,7 +138,6 @@ static unsigned long dirty_bytes_min = 2
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
 static int minolduid;
-static int min_percpu_pagelist_fract = 8;
 
 static int ngroups_max = NGROUPS_MAX;
 static const int cap_last_cap = CAP_LAST_CAP;
@@ -1289,7 +1288,6 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(percpu_pagelist_fraction),
 		.mode		= 0644,
 		.proc_handler	= percpu_pagelist_fraction_sysctl_handler,
-		.extra1		= &min_percpu_pagelist_fract,
 	},
 #ifdef CONFIG_MMU
 	{
@@ -1910,7 +1908,7 @@ static int do_proc_dointvec_conv(bool *n
 
 static const char proc_wspace_sep[] = { ' ', '\t', '\n' };
 
-static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
+int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
 		  int write, void __user *buffer,
 		  size_t *lenp, loff_t *ppos,
 		  int (*conv)(bool *negp, unsigned long *lvalp, int *valp,
@@ -2466,7 +2464,26 @@ static int proc_do_cad_pid(struct ctl_ta
 static int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	int ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+ 	int ret;
+	int tmp = percpu_pagelist_fraction;
+	int min_percpu_pagelist_fract = 8;
+
+	ret = __do_proc_dointvec(&tmp, table, write, buffer, length, ppos,
+		       NULL, NULL);
+	/*
+	 * We want values >= min_percpu_pagelist_fract, but we
+	 * also accept 0 to mean "stop using the fractions and
+	 * go back to the default behavior".
+	 */
+	if (write) {
+		if (tmp < 0)
+			return -EINVAL;
+		if ((tmp < min_percpu_pagelist_fract) &&
+		    (tmp != 0))
+			return -EINVAL;
+		percpu_pagelist_fraction = tmp;
+	}
+
 	if (!write || (ret < 0))
 		return ret;
 
diff -puN mm/page_alloc.c~make-percpu_pagelist_fraction-sysctl-undoable mm/page_alloc.c
--- linux.git/mm/page_alloc.c~make-percpu_pagelist_fraction-sysctl-undoable	2013-10-15 09:57:07.008662572 -0700
+++ linux.git-davehans/mm/page_alloc.c	2013-10-15 09:57:07.015662883 -0700
@@ -4059,7 +4059,7 @@ static void __meminit zone_init_free_lis
 	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
-static int __meminit zone_batchsize(struct zone *zone)
+static int zone_batchsize(struct zone *zone)
 {
 #ifdef CONFIG_MMU
 	int batch;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
