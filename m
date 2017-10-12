Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 815C46B0268
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:16:58 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o187so480421qke.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 23:16:58 -0700 (PDT)
Received: from sasl.smtp.pobox.com (pb-smtp1.pobox.com. [64.147.108.70])
        by mx.google.com with ESMTPS id y188si4768383qkd.187.2017.10.11.23.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 23:16:56 -0700 (PDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v6 3/4] cramfs: add mmap support
Date: Thu, 12 Oct 2017 02:16:12 -0400
Message-Id: <20171012061613.28705-4-nicolas.pitre@linaro.org>
In-Reply-To: <20171012061613.28705-1-nicolas.pitre@linaro.org>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

When cramfs in physical memory is used then we have the opportunity
to map files directly from ROM, directly into user space, saving on
RAM usage. This gives us Execute-In-Place (XIP) support.

For a file to be mmap()-able, the map area has to correspond to a range
of uncompressed and contiguous blocks, and in the MMU case it also has
to be page aligned. A version of mkcramfs with appropriate support is
necessary to create such a filesystem image.

In the MMU case it may happen for a vma structure to extend beyond the
actual file size. This is notably the case in binfmt_elf.c:elf_map().
Or the file's last block is shared with other files and cannot be mapped
as is. Rather than refusing to mmap it, we do a "mixed" map and let the
regular fault handler populate the unmapped area with RAM-backed pages.
In practice the unmapped area is seldom accessed so page faults might
never occur before this area is discarded.

In the non-MMU case it is the get_unmapped_area method that is responsible
for providing the address where the actual data can be found. No mapping
is necessary of course.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Tested-by: Chris Brandt <chris.brandt@renesas.com>
---
 fs/cramfs/inode.c | 209 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 209 insertions(+)

diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index d3066a8534..d967904c53 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -15,7 +15,10 @@
 
 #include <linux/module.h>
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/pagemap.h>
+#include <linux/pfn_t.h>
+#include <linux/ramfs.h>
 #include <linux/init.h>
 #include <linux/string.h>
 #include <linux/blkdev.h>
@@ -51,6 +54,7 @@ static inline struct cramfs_sb_info *CRAMFS_SB(struct super_block *sb)
 static const struct super_operations cramfs_ops;
 static const struct inode_operations cramfs_dir_inode_operations;
 static const struct file_operations cramfs_directory_operations;
+static const struct file_operations cramfs_physmem_fops;
 static const struct address_space_operations cramfs_aops;
 
 static DEFINE_MUTEX(read_mutex);
@@ -98,6 +102,10 @@ static struct inode *get_cramfs_inode(struct super_block *sb,
 	case S_IFREG:
 		inode->i_fop = &generic_ro_fops;
 		inode->i_data.a_ops = &cramfs_aops;
+		if (IS_ENABLED(CONFIG_CRAMFS_MTD) &&
+		    CRAMFS_SB(sb)->flags & CRAMFS_FLAG_EXT_BLOCK_POINTERS &&
+		    CRAMFS_SB(sb)->linear_phys_addr)
+			inode->i_fop = &cramfs_physmem_fops;
 		break;
 	case S_IFDIR:
 		inode->i_op = &cramfs_dir_inode_operations;
@@ -279,6 +287,207 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset,
 		return NULL;
 }
 
+/*
+ * For a mapping to be possible, we need a range of uncompressed and
+ * contiguous blocks. Return the offset for the first block and number of
+ * valid blocks for which that is true, or zero otherwise.
+ */
+static u32 cramfs_get_block_range(struct inode *inode, u32 pgoff, u32 *pages)
+{
+	struct cramfs_sb_info *sbi = CRAMFS_SB(inode->i_sb);
+	int i;
+	u32 *blockptrs, first_block_addr;
+
+	/*
+	 * We can dereference memory directly here as this code may be
+	 * reached only when there is a direct filesystem image mapping
+	 * available in memory.
+	 */
+	blockptrs = (u32 *)(sbi->linear_virt_addr + OFFSET(inode) + pgoff * 4);
+	first_block_addr = blockptrs[0] & ~CRAMFS_BLK_FLAGS;
+	i = 0;
+	do {
+		u32 block_off = i * (PAGE_SIZE >> CRAMFS_BLK_DIRECT_PTR_SHIFT);
+		u32 expect = (first_block_addr + block_off) |
+			     CRAMFS_BLK_FLAG_DIRECT_PTR |
+			     CRAMFS_BLK_FLAG_UNCOMPRESSED;
+		if (blockptrs[i] != expect) {
+			pr_debug("range: block %d/%d got %#x expects %#x\n",
+				 pgoff+i, pgoff + *pages - 1,
+				 blockptrs[i], expect);
+			if (i == 0)
+				return 0;
+			break;
+		}
+	} while (++i < *pages);
+
+	*pages = i;
+	return first_block_addr << CRAMFS_BLK_DIRECT_PTR_SHIFT;
+}
+
+#ifdef CONFIG_MMU
+
+/*
+ * Return true if the last page of a file in the filesystem image contains
+ * some other data that doesn't belong to that file. It is assumed that the
+ * last block is CRAMFS_BLK_FLAG_DIRECT_PTR | CRAMFS_BLK_FLAG_UNCOMPRESSED
+ * (verified by cramfs_get_block_range() and directly accessible in memory.
+ */
+static bool cramfs_last_page_is_shared(struct inode *inode)
+{
+	struct cramfs_sb_info *sbi = CRAMFS_SB(inode->i_sb);
+	u32 partial, last_page, blockaddr, *blockptrs;
+	char *tail_data;
+
+	partial = offset_in_page(inode->i_size);
+	if (!partial)
+		return false;
+	last_page = inode->i_size >> PAGE_SHIFT;
+	blockptrs = (u32 *)(sbi->linear_virt_addr + OFFSET(inode));
+	blockaddr = blockptrs[last_page] & ~CRAMFS_BLK_FLAGS;
+	blockaddr <<= CRAMFS_BLK_DIRECT_PTR_SHIFT;
+	tail_data = sbi->linear_virt_addr + blockaddr + partial;
+	return memchr_inv(tail_data, 0, PAGE_SIZE - partial) ? true : false;
+}
+
+static int cramfs_physmem_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct inode *inode = file_inode(file);
+	struct cramfs_sb_info *sbi = CRAMFS_SB(inode->i_sb);
+	unsigned int pages, max_pages, offset;
+	unsigned long address, pgoff = vma->vm_pgoff;
+	char *bailout_reason;
+	int ret;
+
+	ret = generic_file_readonly_mmap(file, vma);
+	if (ret)
+		return ret;
+
+	/*
+	 * Now try to pre-populate ptes for this vma with a direct
+	 * mapping avoiding memory allocation when possible.
+	 */
+
+	/* Could COW work here? */
+	bailout_reason = "vma is writable";
+	if (vma->vm_flags & VM_WRITE)
+		goto bailout;
+
+	max_pages = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	bailout_reason = "beyond file limit";
+	if (pgoff >= max_pages)
+		goto bailout;
+	pages = min(vma_pages(vma), max_pages - pgoff);
+
+	offset = cramfs_get_block_range(inode, pgoff, &pages);
+	bailout_reason = "unsuitable block layout";
+	if (!offset)
+		goto bailout;
+	address = sbi->linear_phys_addr + offset;
+	bailout_reason = "data is not page aligned";
+	if (!PAGE_ALIGNED(address))
+		goto bailout;
+
+	/* Don't map the last page if it contains some other data */
+	if (pgoff + pages == max_pages && cramfs_last_page_is_shared(inode)) {
+		pr_debug("mmap: %s: last page is shared\n",
+			 file_dentry(file)->d_name.name);
+		pages--;
+	}
+
+	if (!pages) {
+		bailout_reason = "no suitable block remaining";
+		goto bailout;
+	}
+
+	if (pages == vma_pages(vma)) {
+		/*
+		 * The entire vma is mappable. remap_pfn_range() will
+		 * make it distinguishable from a non-direct mapping
+		 * in /proc/<pid>/maps by substituting the file offset
+		 * with the actual physical address.
+		 */
+		ret = remap_pfn_range(vma, vma->vm_start, address >> PAGE_SHIFT,
+				      pages * PAGE_SIZE, vma->vm_page_prot);
+	} else {
+		/*
+		 * Let's create a mixed map if we can't map it all.
+		 * The normal paging machinery will take care of the
+		 * unpopulated ptes via cramfs_readpage().
+		 */
+		int i;
+		vma->vm_flags |= VM_MIXEDMAP;
+		for (i = 0; i < pages && !ret; i++) {
+			unsigned long off = i * PAGE_SIZE;
+			pfn_t pfn = phys_to_pfn_t(address + off, PFN_DEV);
+			ret = vm_insert_mixed(vma, vma->vm_start + off, pfn);
+		}
+	}
+
+	if (!ret)
+		pr_debug("mapped %s[%lu] at 0x%08lx (%u/%lu pages) "
+			 "to vma 0x%08lx, page_prot 0x%llx\n",
+			 file_dentry(file)->d_name.name, pgoff,
+			 address, pages, vma_pages(vma), vma->vm_start,
+			 (unsigned long long)pgprot_val(vma->vm_page_prot));
+	return ret;
+
+bailout:
+	pr_debug("%s[%lu]: direct mmap impossible: %s\n",
+		 file_dentry(file)->d_name.name, pgoff, bailout_reason);
+	/* Didn't manage any direct map, but normal paging is still possible */
+	return 0;
+}
+
+#else /* CONFIG_MMU */
+
+static int cramfs_physmem_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return vma->vm_flags & (VM_SHARED | VM_MAYSHARE) ? 0 : -ENOSYS;
+}
+
+static unsigned long cramfs_physmem_get_unmapped_area(struct file *file,
+			unsigned long addr, unsigned long len,
+			unsigned long pgoff, unsigned long flags)
+{
+	struct inode *inode = file_inode(file);
+	struct super_block *sb = inode->i_sb;
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+	unsigned int pages, block_pages, max_pages, offset;
+
+	pages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	max_pages = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (pgoff >= max_pages || pages > max_pages - pgoff)
+		return -EINVAL;
+	block_pages = pages;
+	offset = cramfs_get_block_range(inode, pgoff, &block_pages);
+	if (!offset || block_pages != pages)
+		return -ENOSYS;
+	addr = sbi->linear_phys_addr + offset;
+	pr_debug("get_unmapped for %s ofs %#lx siz %lu at 0x%08lx\n",
+		 file_dentry(file)->d_name.name, pgoff*PAGE_SIZE, len, addr);
+	return addr;
+}
+
+static unsigned int cramfs_physmem_mmap_capabilities(struct file *file)
+{
+	return NOMMU_MAP_COPY | NOMMU_MAP_DIRECT |
+	       NOMMU_MAP_READ | NOMMU_MAP_EXEC;
+}
+
+#endif /* CONFIG_MMU */
+
+static const struct file_operations cramfs_physmem_fops = {
+	.llseek			= generic_file_llseek,
+	.read_iter		= generic_file_read_iter,
+	.splice_read		= generic_file_splice_read,
+	.mmap			= cramfs_physmem_mmap,
+#ifndef CONFIG_MMU
+	.get_unmapped_area	= cramfs_physmem_get_unmapped_area,
+	.mmap_capabilities	= cramfs_physmem_mmap_capabilities,
+#endif
+};
+
 static void cramfs_kill_sb(struct super_block *sb)
 {
 	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
