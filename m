Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA09871
	for <linux-mm@kvack.org>; Sun, 2 Feb 2003 02:55:18 -0800 (PST)
Date: Sun, 2 Feb 2003 02:55:25 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030202025525.09827d5f.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

5/4

get_unmapped_area for hugetlbfs

Having to specify the mapping address is a pain.  Give hugetlbfs files a
file_operations.get_unmapped_area().

The implementation is in hugetlbfs rather than in arch code because it's
probably common to several architectures.  If the architecture has special
needs it can define HAVE_ARCH_HUGETLB_UNMAPPED_AREA and go it alone.  Just
like HAVE_ARCH_UNMAPPED_AREA.



Having to specify the mapping address is a pain.  Give hugetlbfs files a
file_operations.get_unmapped_area().

The implementation is in hugetlbfs rather than in arch code because it's
probably common to several architectures.  If the architecture has special
needs it can define HAVE_ARCH_HUGETLB_UNMAPPED_AREA and go it alone.  Just
like HAVE_ARCH_UNMAPPED_AREA.



 hugetlbfs/inode.c |   46 ++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 44 insertions(+), 2 deletions(-)

diff -puN fs/hugetlbfs/inode.c~hugetlbfs-get_unmapped_area fs/hugetlbfs/inode.c
--- 25/fs/hugetlbfs/inode.c~hugetlbfs-get_unmapped_area	2003-02-01 01:13:03.000000000 -0800
+++ 25-akpm/fs/hugetlbfs/inode.c	2003-02-02 01:17:01.000000000 -0800
@@ -74,6 +74,47 @@ static int hugetlbfs_file_mmap(struct fi
 }
 
 /*
+ * Called under down_write(mmap_sem), page_table_lock is not held
+ */
+
+#ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
+unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags);
+#else
+static unsigned long
+hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+
+	if (len & ~HPAGE_MASK)
+		return -EINVAL;
+	if (len > TASK_SIZE)
+		return -ENOMEM;
+
+	if (addr) {
+		addr = ALIGN(addr, HPAGE_SIZE);
+		vma = find_vma(mm, addr);
+		if (TASK_SIZE - len >= addr &&
+		    (!vma || addr + len <= vma->vm_start))
+			return addr;
+	}
+
+	addr = ALIGN(mm->free_area_cache, HPAGE_SIZE);
+
+	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+		/* At this point:  (!vma || addr < vma->vm_end). */
+		if (TASK_SIZE - len < addr)
+			return -ENOMEM;
+		if (!vma || addr + len <= vma->vm_start)
+			return addr;
+		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
+	}
+}
+#endif
+
+/*
  * Read a page. Again trivial. If it didn't already exist
  * in the page cache, it is zero-filled.
  */
@@ -466,8 +507,9 @@ static struct address_space_operations h
 };
 
 struct file_operations hugetlbfs_file_operations = {
-	.mmap		= hugetlbfs_file_mmap,
-	.fsync		= simple_sync_file,
+	.mmap			= hugetlbfs_file_mmap,
+	.fsync			= simple_sync_file,
+	.get_unmapped_area	= hugetlb_get_unmapped_area,
 };
 
 static struct inode_operations hugetlbfs_dir_inode_operations = {

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
