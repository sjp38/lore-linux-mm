Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4T6gjZw032098
	for <linux-mm@kvack.org>; Thu, 29 May 2008 02:42:45 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4T6gjUX067384
	for <linux-mm@kvack.org>; Thu, 29 May 2008 00:42:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4T6gibU000342
	for <linux-mm@kvack.org>; Thu, 29 May 2008 00:42:45 -0600
Date: Wed, 28 May 2008 23:42:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 2/2] hugetlb: remove multi-valued proc files.
Message-ID: <20080529064242.GD11357@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net> <20080529063915.GC11357@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080529063915.GC11357@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Now that we present the same information in a cleaner way in sysfs, we
can remove the duplicate information and interfaces from procfs (and
consider them to be the legacy interface). The proc interface only
controls the default hugepage size, which is either

a) the first one specified via hugepagesz= on the kernel command-line, if any
b) the legacy huge page size, otherwise

All other hugepage size pool manipulations can occur through sysfs.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
Note, this does end up making the manipulation and validation of
multiple hstates impossible without sysfs enabled and mounted. As such,
I'm not sure if this is the right approach and perhaps we should be
leaving the multi-valued proc files in place (but not as the preferred
interface). Or we could present the values in procfs only if SYSFS is
not enabled in the kernel? I imagine (but am not 100% sure) that the
only current architecture where this might be important is SUPERH?

Nick, this includes the fix to make hugepages_treat_as_movable
single-valued again, which presumably will get thrown up as a merge
conflict if it's fixed at the right place in the stack.

Realistically, this patch shouldn't need to exist in the upstream
patchset, if we decide to not extend the proc files, as we can add the
sysfs files as a new patch 5 and drop the current patches 5 and 7. I can
work out how the patch should look if that is what we decide to do (or
`git-rebase -i` can :).

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 3fe461d..fb7ef81 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -228,8 +228,8 @@ static inline struct hstate *page_hstate(struct page *page)
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
 }
 
-extern unsigned long max_huge_pages[HUGE_MAX_HSTATE];
-extern unsigned long sysctl_overcommit_huge_pages[HUGE_MAX_HSTATE];
+extern unsigned long max_huge_pages;
+extern unsigned long sysctl_overcommit_huge_pages;
 
 #else
 struct hstate {};
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index da7a4aa..15b25f0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -23,8 +23,8 @@
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
-unsigned long max_huge_pages[HUGE_MAX_HSTATE];
-unsigned long sysctl_overcommit_huge_pages[HUGE_MAX_HSTATE];
+unsigned long max_huge_pages;
+unsigned long sysctl_overcommit_huge_pages;
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
@@ -719,7 +719,8 @@ static ssize_t nr_hugepages_store(struct kobject *kobj,
 		return 0;
 
 	h->max_huge_pages = set_max_huge_pages(h, input, &tmp);
-	max_huge_pages[h - hstates] = h->max_huge_pages;
+	if (h == hstates)
+		max_huge_pages = h->max_huge_pages;
 
 	return count;
 }
@@ -744,7 +745,8 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 
 	spin_lock(&hugetlb_lock);
 	h->nr_overcommit_huge_pages = input;
-	sysctl_overcommit_huge_pages[h - hstates] = h->nr_overcommit_huge_pages;
+	if (h == hstates)
+		sysctl_overcommit_huge_pages = h->nr_overcommit_huge_pages;
 	spin_unlock(&hugetlb_lock);
 
 	return count;
@@ -909,22 +911,18 @@ int hugetlb_sysctl_handler(struct ctl_table *table, int write,
 {
 	int err;
 
-	table->maxlen = max_hstate * sizeof(unsigned long);
 	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 	if (err)
 		return err;
 
 	if (write) {
-		struct hstate *h;
-		for_each_hstate (h) {
-			int tmp;
-
-			h->max_huge_pages = set_max_huge_pages(h,
-					max_huge_pages[h - hstates], &tmp);
-			max_huge_pages[h - hstates] = h->max_huge_pages;
-			if (tmp && !err)
-				err = tmp;
-		}
+		struct hstate *h = hstates;
+		int tmp;
+
+		h->max_huge_pages = set_max_huge_pages(h, max_huge_pages, &tmp);
+		max_huge_pages = h->max_huge_pages;
+		if (tmp && !err)
+			err = tmp;
 	}
 	return err;
 }
@@ -933,7 +931,6 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
 			struct file *file, void __user *buffer,
 			size_t *length, loff_t *ppos)
 {
- 	table->maxlen = max_hstate * sizeof(int);
 	proc_dointvec(table, write, file, buffer, length, ppos);
 	if (hugepages_treat_as_movable)
 		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
@@ -948,19 +945,15 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 {
 	int err;
 
-	table->maxlen = max_hstate * sizeof(unsigned long);
 	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 	if (err)
 		return err;
 
 	if (write) {
-		struct hstate *h;
+		struct hstate *h = hstates;
 
 		spin_lock(&hugetlb_lock);
-		for_each_hstate (h) {
-			h->nr_overcommit_huge_pages =
-				sysctl_overcommit_huge_pages[h - hstates];
-		}
+		h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages;
 		spin_unlock(&hugetlb_lock);
 	}
 
@@ -969,48 +962,32 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 #endif /* CONFIG_SYSCTL */
 
-static int dump_field(char *buf, unsigned field)
-{
-	int n = 0;
-	struct hstate *h;
-	for_each_hstate (h)
-		n += sprintf(buf + n, " %5lu", *(unsigned long *)((char *)h + field));
-	buf[n++] = '\n';
-	return n;
-}
-
 int hugetlb_report_meminfo(char *buf)
 {
-	struct hstate *h;
-	int n = 0;
-	n += sprintf(buf + 0, "HugePages_Total:");
-	n += dump_field(buf + n, offsetof(struct hstate, nr_huge_pages));
-	n += sprintf(buf + n, "HugePages_Free: ");
-	n += dump_field(buf + n, offsetof(struct hstate, free_huge_pages));
-	n += sprintf(buf + n, "HugePages_Rsvd: ");
-	n += dump_field(buf + n, offsetof(struct hstate, resv_huge_pages));
-	n += sprintf(buf + n, "HugePages_Surp: ");
-	n += dump_field(buf + n, offsetof(struct hstate, surplus_huge_pages));
-	n += sprintf(buf + n, "Hugepagesize:   ");
-	for_each_hstate (h)
-		n += sprintf(buf + n, " %5lu", huge_page_size(h) / 1024);
-	n += sprintf(buf + n, " kB\n");
-	return n;
+	struct hstate *h = hstates;
+	return sprintf(buf,
+			"HugePages_Total: %5lu\n"
+			"HugePages_Free:  %5lu\n"
+			"HugePages_Rsvd:  %5lu\n"
+			"HugePages_Surp:  %5lu\n"
+			"Hugepagesize:    %5lu kB\n",
+			h->nr_huge_pages,
+			h->free_huge_pages,
+			h->resv_huge_pages,
+			h->surplus_huge_pages,
+			huge_page_size(h) / 1024);
 }
 
 int hugetlb_report_node_meminfo(int nid, char *buf)
 {
-	int n = 0;
-	n += sprintf(buf, "Node %d HugePages_Total: ", nid);
-	n += dump_field(buf + n, offsetof(struct hstate,
-						nr_huge_pages_node[nid]));
-	n += sprintf(buf + n, "Node %d HugePages_Free: ", nid);
-	n += dump_field(buf + n, offsetof(struct hstate,
-						free_huge_pages_node[nid]));
-	n += sprintf(buf + n, "Node %d HugePages_Surp: ", nid);
-	n += dump_field(buf + n, offsetof(struct hstate,
-						surplus_huge_pages_node[nid]));
-	return n;
+	struct hstate *h = hstates;
+	return sprintf(buf,
+			"HugePages_Total: %5u\n"
+			"HugePages_Free:  %5u\n"
+			"HugePages_Surp:  %5u\n",
+			h->nr_huge_pages_node[nid],
+			h->free_huge_pages_node[nid],
+			h->surplus_huge_pages_node[nid]);
 }
 
 /* Return the number pages of memory we physically have, in PAGE_SIZE units. */

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
