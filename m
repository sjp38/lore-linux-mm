Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA10002
	for <linux-mm@kvack.org>; Sun, 2 Feb 2003 02:57:13 -0800 (PST)
Date: Sun, 2 Feb 2003 02:57:20 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030202025720.25bbf46d.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

12/4

Fix hugetlb_vmtruncate_list()


This function is quite wrong - has an "=" where it should have an "-" and
confuses PAGE_SIZE and HPAGE_SIZE in its address and file offset arithmetic.




 hugetlbfs/inode.c |   46 ++++++++++++++++++++++++++++++++--------------
 1 files changed, 32 insertions(+), 14 deletions(-)

diff -puN fs/hugetlbfs/inode.c~hugetlb_vmtruncate-fixes fs/hugetlbfs/inode.c
--- 25/fs/hugetlbfs/inode.c~hugetlb_vmtruncate-fixes	2003-02-02 01:17:12.000000000 -0800
+++ 25-akpm/fs/hugetlbfs/inode.c	2003-02-02 02:53:49.000000000 -0800
@@ -240,29 +240,47 @@ static void hugetlbfs_drop_inode(struct 
 		hugetlbfs_forget_inode(inode);
 }
 
-static void hugetlb_vmtruncate_list(struct list_head *list, unsigned long pgoff)
+/*
+ * h_pgoff is in HPAGE_SIZE units.
+ * vma->vm_pgoff is in PAGE_SIZE units.
+ */
+static void
+hugetlb_vmtruncate_list(struct list_head *list, unsigned long h_pgoff)
 {
-	unsigned long start, end, length, delta;
 	struct vm_area_struct *vma;
 
 	list_for_each_entry(vma, list, shared) {
-		start = vma->vm_start;
-		end = vma->vm_end;
-		length = end - start;
-
-		if (vma->vm_pgoff >= pgoff) {
-			zap_hugepage_range(vma, start, length);
+		unsigned long h_vm_pgoff;
+		unsigned long v_length;
+		unsigned long h_length;
+		unsigned long v_offset;
+
+		h_vm_pgoff = vma->vm_pgoff << (HPAGE_SHIFT - PAGE_SHIFT);
+		v_length = vma->vm_end - vma->vm_start;
+		h_length = v_length >> HPAGE_SHIFT;
+		v_offset = (h_pgoff - h_vm_pgoff) << HPAGE_SHIFT;
+
+		/*
+		 * Is this VMA fully outside the truncation point?
+		 */
+		if (h_vm_pgoff >= h_pgoff) {
+			zap_hugepage_range(vma, vma->vm_start, v_length);
 			continue;
 		}
 
-		length >>= PAGE_SHIFT;
-		delta = pgoff = vma->vm_pgoff;
-		if (delta >= length)
+		/*
+		 * Is this VMA fully inside the truncaton point?
+		 */
+		if (h_vm_pgoff + (v_length >> HPAGE_SHIFT) <= h_pgoff)
 			continue;
 
-		start += delta << PAGE_SHIFT;
-		length = (length - delta) << PAGE_SHIFT;
-		zap_hugepage_range(vma, start, length);
+		/*
+		 * The VMA straddles the truncation point.  v_offset is the
+		 * offset (in bytes) into the VMA where the point lies.
+		 */
+		zap_hugepage_range(vma,
+				vma->vm_start + v_offset,
+				v_length - v_offset);
 	}
 }
 

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
