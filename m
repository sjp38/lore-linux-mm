Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3223C8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:34:07 -0500 (EST)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p110JUoF018210
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:19:30 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p110XxLH122022
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:33:59 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p110XxBK018515
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:33:59 -0700
Subject: [RFC][PATCH 1/6] count transparent hugepage splits
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 31 Jan 2011 16:33:58 -0800
References: <20110201003357.D6F0BE0D@kernel>
In-Reply-To: <20110201003357.D6F0BE0D@kernel>
Message-Id: <20110201003358.98826457@kernel>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


The khugepaged process collapses transparent hugepages for us.  Whenever
it collapses a page into a transparent hugepage, we increment a nice
global counter exported in sysfs:

	/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed

But, transparent hugepages also get broken down in quite a few
places in the kernel.  We do not have a good idea how how many of
those collpased pages are "new" versus how many are just fixing up
spots that got split a moment before.

Note: "splits" and "collapses" are opposites in this context.

This patch adds a new sysfs file:

	/sys/kernel/mm/transparent_hugepage/pages_split

It is global, like "pages_collapsed", and is incremented whenever any
transparent hugepage on the system has been broken down in to normal
PAGE_SIZE base pages.  This way, we can get an idea how well khugepaged
is keeping up collapsing pages that have been split.

I put it under /sys/kernel/mm/transparent_hugepage/ instead of the
khugepaged/ directory since it is not strictly related to
khugepaged; it can get incremented on pages other than those
collapsed by khugepaged.

The variable storing this is a plain integer.  I needs the same
amount of locking that 'khugepaged_pages_collapsed' has, for
instance.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/Documentation/vm/transhuge.txt |    8 ++++++++
 linux-2.6.git-dave/mm/huge_memory.c               |   12 ++++++++++++
 2 files changed, 20 insertions(+)

diff -puN mm/huge_memory.c~count-thp-splits mm/huge_memory.c
--- linux-2.6.git/mm/huge_memory.c~count-thp-splits	2011-01-31 11:05:51.484526127 -0800
+++ linux-2.6.git-dave/mm/huge_memory.c	2011-01-31 11:05:51.508526113 -0800
@@ -38,6 +38,8 @@ unsigned long transparent_hugepage_flags
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG);
 
+static unsigned int huge_pages_split;
+
 /* default scan 8*512 pte (or vmas) every 30 second */
 static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
 static unsigned int khugepaged_pages_collapsed;
@@ -307,12 +309,20 @@ static struct kobj_attribute debug_cow_a
 	__ATTR(debug_cow, 0644, debug_cow_show, debug_cow_store);
 #endif /* CONFIG_DEBUG_VM */
 
+static ssize_t pages_split_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", huge_pages_split);
+}
+static struct kobj_attribute pages_split_attr = __ATTR_RO(pages_split);
+
 static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
 #endif
+	&pages_split_attr.attr,
 	NULL,
 };
 
@@ -1314,6 +1324,8 @@ static int __split_huge_page_map(struct 
 	}
 	spin_unlock(&mm->page_table_lock);
 
+	if (ret)
+		huge_pages_split++;
 	return ret;
 }
 
diff -puN fs/proc/meminfo.c~count-thp-splits fs/proc/meminfo.c
diff -puN Documentation/vm/transhuge.txt~count-thp-splits Documentation/vm/transhuge.txt
--- linux-2.6.git/Documentation/vm/transhuge.txt~count-thp-splits	2011-01-31 11:05:51.500526118 -0800
+++ linux-2.6.git-dave/Documentation/vm/transhuge.txt	2011-01-31 11:05:51.508526113 -0800
@@ -120,6 +120,14 @@ khugepaged will be automatically started
 transparent_hugepage/enabled is set to "always" or "madvise, and it'll
 be automatically shutdown if it's set to "never".
 
+Not all kernel code is aware of transparent hugepages.  Sometimes,
+it is necessary to fall back to small pages so that this kernel
+code can deal with small pages.  This might also happen if, for
+instance, munmap() was called in the middle of a transparent huge
+page.  We track these splits in:
+
+	/sys/kernel/mm/transparent_hugepage/pages_split
+
 khugepaged runs usually at low frequency so while one may not want to
 invoke defrag algorithms synchronously during the page faults, it
 should be worth invoking defrag at least in khugepaged. However it's
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
