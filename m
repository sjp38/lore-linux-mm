Message-Id: <20080604113112.902971712@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
Date: Wed, 04 Jun 2008 21:29:54 +1000
From: npiggin@suse.de
Subject: [patch 15/21] hugetlb: override default huge page size
Content-Disposition: inline; filename=hugetlb-non-default-hstate.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Allow configurations with the default huge page size which is different to
the traditional HPAGE_SIZE size. The default huge page size is the one
represented in the legacy /proc ABIs, SHM, and which is defaulted to when
mounting hugetlbfs filesystems.

This is implemented with a new kernel option default_hugepagesz=, which
defaults to HPAGE_SIZE if not specified.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 fs/hugetlbfs/inode.c |    2 ++
 mm/hugetlb.c         |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-06-04 20:51:23.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2008-06-04 20:51:24.000000000 +1000
@@ -34,6 +34,7 @@ struct hstate hstates[HUGE_MAX_HSTATE];
 /* for command line parsing */
 static struct hstate * __initdata parsed_hstate = NULL;
 static unsigned long __initdata default_hstate_max_huge_pages = 0;
+static unsigned long __initdata default_hstate_size = HPAGE_SIZE;
 
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
@@ -1207,11 +1208,14 @@ static int __init hugetlb_init(void)
 {
 	BUILD_BUG_ON(HPAGE_SHIFT == 0);
 
-	if (!size_to_hstate(HPAGE_SIZE)) {
-		hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
-		parsed_hstate->max_huge_pages = default_hstate_max_huge_pages;
-	}
-	default_hstate_idx = size_to_hstate(HPAGE_SIZE) - hstates;
+	if (!size_to_hstate(default_hstate_size)) {
+		default_hstate_size = HPAGE_SIZE;
+		if (!size_to_hstate(default_hstate_size))
+			hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
+	}
+	default_hstate_idx = size_to_hstate(default_hstate_size) - hstates;
+	if (default_hstate_max_huge_pages)
+		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
 
 	hugetlb_init_hstates();
 
@@ -1263,7 +1267,7 @@ void __init hugetlb_add_hstate(unsigned 
 	parsed_hstate = h;
 }
 
-static int __init hugetlb_setup(char *s)
+static int __init hugetlb_nrpages_setup(char *s)
 {
 	unsigned long *mhp;
 	static unsigned long *last_mhp;
@@ -1298,7 +1302,14 @@ static int __init hugetlb_setup(char *s)
 
 	return 1;
 }
-__setup("hugepages=", hugetlb_setup);
+__setup("hugepages=", hugetlb_nrpages_setup);
+
+static int __init hugetlb_default_setup(char *s)
+{
+	default_hstate_size = memparse(s, &s);
+	return 1;
+}
+__setup("default_hugepagesz=", hugetlb_default_setup);
 
 static unsigned int cpuset_mems_nr(unsigned int *array)
 {
Index: linux-2.6/Documentation/kernel-parameters.txt
===================================================================
--- linux-2.6.orig/Documentation/kernel-parameters.txt	2008-06-04 20:51:24.000000000 +1000
+++ linux-2.6/Documentation/kernel-parameters.txt	2008-06-04 20:51:24.000000000 +1000
@@ -774,6 +774,13 @@ and is between 256 and 4096 characters. 
 			CPU supports the "pdpe1gb" cpuinfo flag)
 			Note that 1GB pages can only be allocated at boot time
 			using hugepages= and not freed afterwards.
+	default_hugepagesz=
+			[same as hugepagesz=] The size of the default
+			HugeTLB page size. This is the size represented by
+			the legacy /proc/ hugepages APIs, used for SHM, and
+			default size when mounting hugetlbfs filesystems.
+			Defaults to the default architecture's huge page size
+			if not specified.
 
 	i8042.direct	[HW] Put keyboard port into non-translated mode
 	i8042.dumbkbd	[HW] Pretend that controller can only read data from

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
