Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7IKchqm027813
	for <linux-mm@kvack.org>; Thu, 18 Aug 2005 16:38:43 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7IKchH6280492
	for <linux-mm@kvack.org>; Thu, 18 Aug 2005 16:38:43 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7IKchvo011362
	for <linux-mm@kvack.org>; Thu, 18 Aug 2005 16:38:43 -0400
Subject: Re: [PATCH 0/4] Demand faunting for huge pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20050818003548.GV3996@wotan.suse.de>
References: <1124304966.3139.37.camel@localhost.localdomain>
	 <20050817210431.GR3996@wotan.suse.de>
	 <20050818003302.GE7103@localhost.localdomain>
	 <20050818003548.GV3996@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 18 Aug 2005 15:33:27 -0500
Message-Id: <1124397207.3152.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, christoph@lameter.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 2005-08-18 at 02:35 +0200, Andi Kleen wrote:
> I disagree. With Linux's primitive hugepage allocation scheme (static
> pool that is usually too small) at least simple overcommit check
> is absolutely essential.
> 
> > Strict accounting leads to nicer behaviour in some cases - you'll tend
> > to die early rather than late - but it seems an awful lot of work for
> > a fairly small improvement in behaviour.
> 
> Strict is a lot of work, but a simple "right in 99% of all cases, but racy" 
> check is quite easy.

How about something like the following?
---
Initial Post (Thu, 18 Aug 2005)

Basic overcommit checking for hugetlb_file_map() based on an implementation
used with demand faulting in SLES9.

Since demand faulting can't guarantee the availability of pages at mmap time,
this patch implements a basic sanity check to ensure that the number of huge
pages required to satisfy the mmap are currently available.  Despite the
obvious race, I think it is a good start on doing proper accounting.  I'd like
to work towards an accounting system that mimics the semantics of normal pages
(especially for the MAP_PRIVATE/COW case).  That work is underway and builds on
what this patch starts.

Huge page shared memory segments are simpler and still maintain their commit on shmget semantics.

Diffed against 2.6.13-rc6-git7

Signed-off-by: Adam Litke <agl@us.ibm.com>

---
 fs/hugetlbfs/inode.c    |   36 ++++++++++++++++++++++++++++++++++++
 include/linux/hugetlb.h |    3 +++
 2 files changed, 39 insertions(+)
diff -upN reference/fs/hugetlbfs/inode.c current/fs/hugetlbfs/inode.c
--- reference/fs/hugetlbfs/inode.c
+++ current/fs/hugetlbfs/inode.c
@@ -45,9 +45,41 @@ static struct backing_dev_info hugetlbfs
 
 int sysctl_hugetlb_shm_group;
 
+static void huge_pagevec_release(struct pagevec *pvec);
+
+unsigned long
+huge_pages_needed(struct address_space *mapping, struct vm_area_struct *vma,
+		unsigned long start, unsigned long end)
+{
+	int i;
+	struct pagevec pvec;
+	unsigned long hugepages = (end - start) >> HPAGE_SHIFT;
+	pgoff_t next = vma->vm_pgoff + ((start - vma->vm_start)>>PAGE_SHIFT);
+	pgoff_t endpg = next + ((end - start) >> PAGE_SHIFT);
+
+	pagevec_init(&pvec, 0);
+	while (next < endpg) {
+		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))
+			break;
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+			if (page->index > next)
+				next = page->index;
+			if (page->index >= endpg)
+				break;
+			next++;
+			hugepages--;
+		}
+		huge_pagevec_release(&pvec);
+	}
+	return hugepages << HPAGE_SHIFT;
+}
+
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file->f_dentry->d_inode;
+	struct address_space *mapping = inode->i_mapping;
+	unsigned long bytes;
 	loff_t len, vma_len;
 	int ret;
 
@@ -66,6 +98,10 @@ static int hugetlbfs_file_mmap(struct fi
 	if (vma->vm_end - vma->vm_start < HPAGE_SIZE)
 		return -EINVAL;
 
+	bytes = huge_pages_needed(mapping, vma, vma->vm_start, vma->vm_end);
+	if (!is_hugepage_mem_enough(bytes))
+		return -ENOMEM;
+
 	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
 
 	down(&inode->i_sem);
diff -upN reference/include/linux/hugetlb.h current/include/linux/hugetlb.h
--- reference/include/linux/hugetlb.h
+++ current/include/linux/hugetlb.h
@@ -42,6 +42,9 @@ struct page *follow_huge_pmd(struct mm_s
 				pmd_t *pmd, int write);
 int is_aligned_hugepage_range(unsigned long addr, unsigned long len);
 int pmd_huge(pmd_t pmd);
+unsigned long huge_pages_needed(struct address_space *mapping,
+			struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
 
 #ifndef ARCH_HAS_HUGEPAGE_ONLY_RANGE
 #define is_hugepage_only_range(mm, addr, len)	0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
