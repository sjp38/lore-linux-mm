Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA09956
	for <linux-mm@kvack.org>; Sun, 2 Feb 2003 02:56:18 -0800 (PST)
Date: Sun, 2 Feb 2003 02:56:25 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030202025625.732d2b54.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

9/4

Give all architectures a hugetlb_nopage().


If someone maps a hugetlbfs file, then truncates it, then references the part
of the mapping outside the truncation point, they take a pagefault and we end
up hitting hugetlb_nopage().

We want to prevent this from ever happening.  This patch just makes sure that
all architectures have a goes-BUG hugetlb_nopage() to trap it.



 i386/mm/hugetlbpage.c    |   10 ++++++++--
 ia64/mm/hugetlbpage.c    |   11 +++++++++--
 sparc64/mm/hugetlbpage.c |    8 ++++++++
 x86_64/mm/hugetlbpage.c  |    4 ++--
 4 files changed, 27 insertions(+), 6 deletions(-)

diff -puN arch/i386/mm/hugetlbpage.c~hugetlbfs-nopage-cleanup arch/i386/mm/hugetlbpage.c
--- 25/arch/i386/mm/hugetlbpage.c~hugetlbfs-nopage-cleanup	2003-02-01 22:35:51.000000000 -0800
+++ 25-akpm/arch/i386/mm/hugetlbpage.c	2003-02-01 22:37:04.000000000 -0800
@@ -26,7 +26,6 @@ static long    htlbpagemem;
 int     htlbpage_max;
 static long    htlbzone_pages;
 
-struct vm_operations_struct hugetlb_vm_ops;
 static LIST_HEAD(htlbpage_freelist);
 static spinlock_t htlbpage_lock = SPIN_LOCK_UNLOCKED;
 
@@ -472,7 +471,14 @@ int is_hugepage_mem_enough(size_t size)
 	return 1;
 }
 
-static struct page *hugetlb_nopage(struct vm_area_struct * area, unsigned long address, int unused)
+/*
+ * We cannot handle pagefaults against hugetlb pages at all.  They cause
+ * handle_mm_fault() to try to instantiate regular-sized pages in the
+ * hugegpage VMA.  do_page_fault() is supposed to trap this, so BUG is we get
+ * this far.
+ */
+static struct page *
+hugetlb_nopage(struct vm_area_struct *vma, unsigned long address, int unused)
 {
 	BUG();
 	return NULL;
diff -puN arch/ia64/mm/hugetlbpage.c~hugetlbfs-nopage-cleanup arch/ia64/mm/hugetlbpage.c
--- 25/arch/ia64/mm/hugetlbpage.c~hugetlbfs-nopage-cleanup	2003-02-01 22:35:51.000000000 -0800
+++ 25-akpm/arch/ia64/mm/hugetlbpage.c	2003-02-01 22:37:08.000000000 -0800
@@ -18,7 +18,6 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
-static struct vm_operations_struct hugetlb_vm_ops;
 struct list_head htlbpage_freelist;
 spinlock_t htlbpage_lock = SPIN_LOCK_UNLOCKED;
 extern long htlbpagemem;
@@ -333,6 +332,14 @@ set_hugetlb_mem_size (int count)
 	return (int) htlbzone_pages;
 }
 
+static struct page *
+hugetlb_nopage(struct vm_area_struct *vma, unsigned long address, int unused)
+{
+	BUG();
+	return NULL;
+}
+
 static struct vm_operations_struct hugetlb_vm_ops = {
-	.close =	zap_hugetlb_resources
+	.nopage =	hugetlb_nopage,
+	.close =	zap_hugetlb_resources,
 };
diff -puN arch/sparc64/mm/hugetlbpage.c~hugetlbfs-nopage-cleanup arch/sparc64/mm/hugetlbpage.c
--- 25/arch/sparc64/mm/hugetlbpage.c~hugetlbfs-nopage-cleanup	2003-02-01 22:35:51.000000000 -0800
+++ 25-akpm/arch/sparc64/mm/hugetlbpage.c	2003-02-01 22:37:13.000000000 -0800
@@ -619,6 +619,14 @@ int set_hugetlb_mem_size(int count)
 	return (int) htlbzone_pages;
 }
 
+static struct page *
+hugetlb_nopage(struct vm_area_struct *vma, unsigned long address, int unused)
+{
+	BUG();
+	return NULL;
+}
+
 static struct vm_operations_struct hugetlb_vm_ops = {
+	.nopage = hugetlb_nopage,
 	.close	= zap_hugetlb_resources,
 };
diff -puN arch/x86_64/mm/hugetlbpage.c~hugetlbfs-nopage-cleanup arch/x86_64/mm/hugetlbpage.c
--- 25/arch/x86_64/mm/hugetlbpage.c~hugetlbfs-nopage-cleanup	2003-02-01 22:35:51.000000000 -0800
+++ 25-akpm/arch/x86_64/mm/hugetlbpage.c	2003-02-01 22:37:19.000000000 -0800
@@ -25,7 +25,6 @@ static long    htlbpagemem;
 int     htlbpage_max;
 static long    htlbzone_pages;
 
-struct vm_operations_struct hugetlb_vm_ops;
 static LIST_HEAD(htlbpage_freelist);
 static spinlock_t htlbpage_lock = SPIN_LOCK_UNLOCKED;
 
@@ -349,7 +348,8 @@ int hugetlb_report_meminfo(char *buf)
 			HPAGE_SIZE/1024);
 }
 
-static struct page * hugetlb_nopage(struct vm_area_struct * area, unsigned long address, int unused)
+static struct page *
+hugetlb_nopage(struct vm_area_struct *vma, unsigned long address, int unused)
 {
 	BUG();
 	return NULL;

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
