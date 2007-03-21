Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2LJhoJP000725
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 15:43:50 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2LJho4U070112
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 13:43:50 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2LJhnFu006934
	for <linux-mm@kvack.org>; Wed, 21 Mar 2007 13:43:50 -0600
Subject: pagetable_ops: Hugetlb character device example
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20070319200502.17168.17175.stgit@localhost.localdomain>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 21 Mar 2007 14:43:48 -0500
Message-Id: <1174506228.21684.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The main reason I am advocating a set of pagetable_operations is to
enable the development of a new hugetlb interface.  During the hugetlb
BOFS at OLS last year, we talked about a character device that would
behave like /dev/zero.  Many of the people were talking about how they
just wanted to create MAP_PRIVATE hugetlb mappings without all the fuss
about the hugetlbfs filesystem.  /dev/zero is a familiar interface for
getting anonymous memory so bringing that model to huge pages would make
programming for anonymous huge pages easier.

The pagetable_operations API opens up possibilities to do some
additional (and completely sane) things.  For example, I have a patch
that alters the character device code below to make use of a hugetlb
ZERO_PAGE.  This eliminates almost all the up-front fault time, allowing
pages to be COW'ed only when first written to.  We cannot do things like
this with hugetlbfs anymore because we have a set of complex semantics
to preserve.

The following patch is an example of what a simple pagetable_operations
consumer could look like.  It does depend on some other cleanups I am
working on (removal of is_file_hugepages(), ...hugetlbfs/inode.c vs.
mm/hugetlb.c separation, etc).  So it is unlikely to apply to any trees
you may have.  I do think it makes a useful illustration of what
legitimate things can be done with a pagetable_operations interface.

commit be72df1c616fb662693a8d4410ce3058f20c71f3
Author: Adam Litke <agl@us.ibm.com>
Date:   Tue Feb 13 14:18:21 2007 -0800

diff --git a/drivers/char/Makefile b/drivers/char/Makefile
index fc11063..c5e755b 100644
--- a/drivers/char/Makefile
+++ b/drivers/char/Makefile
@@ -100,6 +100,7 @@ obj-$(CONFIG_IPMI_HANDLER)	+= ipmi/
 
 obj-$(CONFIG_HANGCHECK_TIMER)	+= hangcheck-timer.o
 obj-$(CONFIG_TCG_TPM)		+= tpm/
+obj-$(CONFIG_HUGETLB_PAGE)	+= page.o
 
 # Files generated that shall be removed upon make clean
 clean-files := consolemap_deftbl.c defkeymap.c
diff --git a/drivers/char/page.c b/drivers/char/page.c
new file mode 100644
index 0000000..e903028
--- /dev/null
+++ b/drivers/char/page.c
@@ -0,0 +1,133 @@
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/init.h>
+#include <linux/device.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+#include <linux/hugetlb.h>
+
+static const struct {
+	unsigned int    minor;
+	char            *name;
+	umode_t         mode;
+} devlist[] = {
+	{1, "page-huge", S_IRUGO | S_IWUGO},
+};
+
+static struct page *page_nopage(struct vm_area_struct *vma,
+			unsigned long address, int *unused)
+{
+	BUG();
+	return NULL;
+}
+
+static struct vm_operations_struct page_vm_ops = {
+	.nopage	= page_nopage,
+};
+
+static int page_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, int write_access)
+{
+	pte_t *ptep;
+	pte_t entry, new_entry;
+	int ret;
+	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
+
+	ptep = huge_pte_alloc(mm, address);
+	if (!ptep)
+		return VM_FAULT_OOM;
+
+	mutex_lock(&hugetlb_instantiation_mutex);
+	entry = *ptep;
+	if (pte_none(entry)) {
+		struct page *page;
+
+		page = alloc_huge_page(vma, address);
+		if (!page)
+			return VM_FAULT_OOM;
+		clear_huge_page(page, address);
+
+		ret = VM_FAULT_MINOR;
+		spin_lock(&mm->page_table_lock);
+		if (!pte_none(*ptep))
+			goto out;
+		add_mm_counter(mm, file_rss, HPAGE_SIZE / PAGE_SIZE);
+		new_entry = make_huge_pte(vma, page, 0);
+		set_huge_pte_at(mm, address, ptep, new_entry);
+		goto out;
+	}
+
+	spin_lock(&mm->page_table_lock);
+	/* Check for a racing update before calling hugetlb_cow */
+	if (likely(pte_same(entry, *ptep)))
+		if (write_access && !pte_write(entry))
+			ret = hugetlb_cow(mm, vma, address, ptep, entry);
+
+out:
+	spin_unlock(&mm->page_table_lock);
+	mutex_unlock(&hugetlb_instantiation_mutex);
+	return ret;
+}
+
+
+static struct pagetable_operations_struct page_pagetable_ops = {
+	.copy_vma		= copy_hugetlb_page_range,
+	.pin_pages		= follow_hugetlb_page,
+	.unmap_page_range	= unmap_hugepage_range,
+	.change_protection	= hugetlb_change_protection,
+	.free_pgtable_range	= hugetlb_free_pgd_range,
+	.fault			= page_fault,
+};
+
+static int page_mmap(struct file * file, struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHARED)
+		return -EINVAL;
+
+	if (vma->vm_pgoff)
+		return -EINVAL;
+
+	if (vma->vm_start & ~HPAGE_MASK)
+		return -EINVAL;
+
+	if (vma->vm_end & ~HPAGE_MASK)
+		return -EINVAL;
+
+	if (vma->vm_end - vma->vm_start < HPAGE_SIZE)
+		return -EINVAL;
+
+	vma->vm_flags |= (VM_HUGETLB | VM_RESERVED);
+	vma->vm_ops = &page_vm_ops;
+	vma->pagetable_ops = &page_pagetable_ops;
+
+	return 0;
+}
+
+const struct file_operations page_file_operations = {
+	.mmap			= page_mmap,
+	.get_unmapped_area	= hugetlb_get_unmapped_area,
+	.prepare_unmapped_area	= prepare_hugepage_range,
+};
+
+static struct class *page_class;
+
+static int __init chr_dev_init(void)
+{
+	int major, i;
+
+	printk("Initializing page devices...");
+	major = register_chrdev(0, "page", &page_file_operations);
+	if (major <= 0)
+		printk("failed\n");
+	else
+		printk("(%i:0)\n", major);
+
+	page_class = class_create(THIS_MODULE, "page");
+	for (i = 0; i < ARRAY_SIZE(devlist); i++)
+		class_device_create(page_class, NULL,
+			MKDEV(major, devlist[i].minor),
+			NULL, devlist[i].name);
+
+	return 0;
+}
+fs_initcall(chr_dev_init);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4fc0bca..edd4944 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -590,6 +590,7 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	BUG_ON(!has_pt_op(vma, fault));
 
+	BUG_ON(!has_pt_op(vma,fault));
 	spin_lock(&mm->page_table_lock);
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
