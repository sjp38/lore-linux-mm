Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l43IkUYL017043
	for <linux-mm@kvack.org>; Thu, 3 May 2007 11:46:31 -0700
Received: from an-out-0708.google.com (andd14.prod.google.com [10.100.30.14])
	by zps38.corp.google.com with ESMTP id l43IkIhO020082
	for <linux-mm@kvack.org>; Thu, 3 May 2007 11:46:25 -0700
Received: by an-out-0708.google.com with SMTP id d14so622942and
        for <linux-mm@kvack.org>; Thu, 03 May 2007 11:46:25 -0700 (PDT)
Message-ID: <b040c32a0705031146x7089d834k258943d4abcbb471@mail.gmail.com>
Date: Thu, 3 May 2007 11:46:24 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] per-cpuset hugetlb accounting and administration
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Existing application heavily depends on accurate free hugetlb page
pool presented in /proc/meminfo.  Enterprise applications typically
query HugePages_Free field to know how much hugetlb pages are
available for it to use and intelligently segment its memory demand
into several memory segments, one to use the full extent of hugetlb
page and have the rest to fall back to normal page segment.

The reporting data with cpuset configured breaks that information, as
it presents global stats.  This will cause hiccup in application when
run inside cpuset that application will be mislead by the kernel and
mis-configure its hugetlb segment.

The following patch attempts to fix this deficiency when hugetlb is
used with cpuset to preserve the user space visible interface.  This
is required for compatibility and to allow existing application in the
field to operate normally regardless whether it is run with or without
cpuset configured.

Signed-off-by: Ken Chen <kenchen@google.com>


--- ./mm/hugetlb.c.orig	2007-05-03 11:02:07.000000000 -0700
+++ ./mm/hugetlb.c	2007-05-03 11:12:42.000000000 -0700
@@ -213,7 +213,7 @@ static void try_to_free_low(unsigned lon
 			update_and_free_page(page);
 			free_huge_pages--;
 			free_huge_pages_node[page_to_nid(page)]--;
-			if (count >= nr_huge_pages)
+			if (count >= cpuset_mems_nr(nr_huge_pages_node))
 				return;
 		}
 	}
@@ -226,24 +226,30 @@ static inline void try_to_free_low(unsig

 static unsigned long set_max_huge_pages(unsigned long count)
 {
-	while (count > nr_huge_pages) {
+	unsigned int cpuset_nr_huge_pages = cpuset_mems_nr(nr_huge_pages_node);
+
+	while (count > cpuset_nr_huge_pages) {
 		if (!alloc_fresh_huge_page())
-			return nr_huge_pages;
+			return cpuset_nr_huge_pages;
+		cpuset_nr_huge_pages++;
 	}
-	if (count >= nr_huge_pages)
-		return nr_huge_pages;
+	if (count >= cpuset_nr_huge_pages)
+		return cpuset_nr_huge_pages;

 	spin_lock(&hugetlb_lock);
 	count = max(count, resv_huge_pages);
 	try_to_free_low(count);
-	while (count < nr_huge_pages) {
+
+	cpuset_nr_huge_pages = cpuset_mems_nr(nr_huge_pages_node);
+	while (count < cpuset_nr_huge_pages) {
 		struct page *page = dequeue_huge_page(NULL, 0);
 		if (!page)
 			break;
 		update_and_free_page(page);
+		cpuset_nr_huge_pages--;
 	}
 	spin_unlock(&hugetlb_lock);
-	return nr_huge_pages;
+	return cpuset_nr_huge_pages;
 }

 int hugetlb_sysctl_handler(struct ctl_table *table, int write,
@@ -259,12 +265,12 @@ int hugetlb_sysctl_handler(struct ctl_ta
 int hugetlb_report_meminfo(char *buf)
 {
 	return sprintf(buf,
-			"HugePages_Total: %5lu\n"
-			"HugePages_Free:  %5lu\n"
+			"HugePages_Total: %5u\n"
+			"HugePages_Free:  %5u\n"
 			"HugePages_Rsvd:  %5lu\n"
 			"Hugepagesize:    %5lu kB\n",
-			nr_huge_pages,
-			free_huge_pages,
+			cpuset_mems_nr(nr_huge_pages_node),
+			cpuset_mems_nr(free_huge_pages_node),
 			resv_huge_pages,
 			HPAGE_SIZE/1024);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
