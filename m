From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 04 Apr 2007 14:01:31 +1000
Subject: [PATCH 10/14] get_unmapped_area handles MAP_FIXED in hugetlbfs
In-Reply-To: <1175659285.929428.835270667964.qpush@grosgo>
Message-Id: <20070404040142.7A0FFDDE9F@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---

 fs/hugetlbfs/inode.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-cell/fs/hugetlbfs/inode.c
===================================================================
--- linux-cell.orig/fs/hugetlbfs/inode.c	2007-03-22 16:12:56.000000000 +1100
+++ linux-cell/fs/hugetlbfs/inode.c	2007-03-22 16:16:02.000000000 +1100
@@ -115,6 +115,12 @@ hugetlb_get_unmapped_area(struct file *f
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
+	if (flags & MAP_FIXED) {
+		if (prepare_hugepage_range(addr, len, pgoff))
+			return -EINVAL;
+		return addr;
+	}
+
 	if (addr) {
 		addr = ALIGN(addr, HPAGE_SIZE);
 		vma = find_vma(mm, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
