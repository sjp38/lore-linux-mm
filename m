Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 46B716B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 13:41:45 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n82so7550227oig.22
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 10:41:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y7sor1549799qkd.150.2017.10.06.10.41.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Oct 2017 10:41:43 -0700 (PDT)
Date: Fri, 6 Oct 2017 13:41:41 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v5 4/5] cramfs: add mmap support
In-Reply-To: <20171006070038.GA29142@infradead.org>
Message-ID: <nycvar.YSQ.7.76.1710061231390.6291@knanqh.ubzr>
References: <20171006024531.8885-1-nicolas.pitre@linaro.org> <20171006024531.8885-5-nicolas.pitre@linaro.org> <20171006070038.GA29142@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

On Fri, 6 Oct 2017, Christoph Hellwig wrote:

> > +	/* Don't map the last page if it contains some other data */
> > +	if (unlikely(pgoff + pages == max_pages)) {
> > +		unsigned int partial = offset_in_page(inode->i_size);
> > +		if (partial) {
> > +			char *data = sbi->linear_virt_addr + offset;
> > +			data += (max_pages - 1) * PAGE_SIZE + partial;
> > +			if (memchr_inv(data, 0, PAGE_SIZE - partial) != NULL) {
> > +				pr_debug("mmap: %s: last page is shared\n",
> > +					 file_dentry(file)->d_name.name);
> > +				pages--;
> > +			}
> > +		}
> > +	}
> 
> Why is pgoff + pages == max_pages marked unlikely?  Mapping the whole
> file seems like a perfectly normal and likely case to me..

In practice it is not. This is typically used for executables where a 
mmap() call covers the executable and read-only segments located at the 
beginning of a file. The end of the file is covered by a r/w mapping 
where .data is normally located and we can't direct-mmap that.

Whatever. I have no strong opinion here as this is hardly 
performance critical so it is removed.

> Also if this was my code I'd really prefer to move this into a helper:
> 
> static bool cramfs_mmap_last_page_is_shared(struct inode *inode, int offset)
> {
> 	unsigned int partial = offset_in_page(inode->i_size);
> 	char *data = CRAMFS_SB(inode->i_sb)->linear_virt_addr + offset +
> 			(inode->i_size & PAGE_MASK);
> 
> 	return memchr_inv(data + partial, 0, PAGE_SIZE - partial);
> }
> 
> 	if (pgoff + pages == max_pages && offset_in_page(inode->i_size)	&&
> 	    cramfs_mmap_last_page_is_shared(inode, offset))
> 		pages--;
> 
> as that's much more readable and the function name provides a good
> documentation of what is going on.

OK.  The above got some details wrong but the idea is clear. Please see 
the new patch bleow.

> > +	if (pages != vma_pages(vma)) {
> 
> here is how I would turn this around:
> 
> 	if (!pages)
> 		goto done;
> 
> 	if (pages == vma_pages(vma)) {
> 		remap_pfn_range();
> 		goto done;
> 	}
> 
> 	...
> 	for (i = 0; i < pages; i++) {
> 		...
> 		vm_insert_mixed();
> 		nr_mapped++;
> 	}
> 
> 
> done:
> 	pr_debug("mapped %d out ouf %d\n", ..);
> 	if (pages != vma_pages(vma))
> 		vma->vm_ops = &generic_file_vm_ops;
> 	return 0;
> }
> 
> In fact we probably could just set the vm_ops unconditionally, they
> just wouldn't be called, but that might be more confusing then helpful.

Well... For one thing generic_file_vm_ops is not exported to modules so 
now I simply call generic_file_readonly_mmap() at the beginning and let 
it validate the vma flags. That allowed for some simplifications at the 
end.

Personally I think the if-else form is clearer over an additional goto 
label, but I moved the more common case first as you did above. At this 
point I hope you'll indulge me.

Here's the latest version of patch 4/5:

diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index 6aa1d94ed8..e1b9192f23 100644
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
@@ -49,6 +52,7 @@ static inline struct cramfs_sb_info *CRAMFS_SB(struct super_block *sb)
 static const struct super_operations cramfs_ops;
 static const struct inode_operations cramfs_dir_inode_operations;
 static const struct file_operations cramfs_directory_operations;
+static const struct file_operations cramfs_physmem_fops;
 static const struct address_space_operations cramfs_aops;
 
 static DEFINE_MUTEX(read_mutex);
@@ -96,6 +100,10 @@ static struct inode *get_cramfs_inode(struct super_block *sb,
 	case S_IFREG:
 		inode->i_fop = &generic_ro_fops;
 		inode->i_data.a_ops = &cramfs_aops;
+		if (IS_ENABLED(CONFIG_CRAMFS_PHYSMEM) &&
+		    CRAMFS_SB(sb)->flags & CRAMFS_FLAG_EXT_BLOCK_POINTERS &&
+		    CRAMFS_SB(sb)->linear_phys_addr)
+			inode->i_fop = &cramfs_physmem_fops;
 		break;
 	case S_IFDIR:
 		inode->i_op = &cramfs_dir_inode_operations;
@@ -277,6 +285,207 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset,
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
 static void cramfs_blkdev_kill_sb(struct super_block *sb)
 {
 	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
