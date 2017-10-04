Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B88B86B0253
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:47:56 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a12so12683620qka.7
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:47:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 23sor12832725qtx.67.2017.10.04.13.47.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 13:47:55 -0700 (PDT)
Date: Wed, 4 Oct 2017 16:47:52 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
In-Reply-To: <20171004072553.GA24620@infradead.org>
Message-ID: <nycvar.YSQ.7.76.1710041608460.1693@knanqh.ubzr>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org> <20170927233224.31676-5-nicolas.pitre@linaro.org> <20171001083052.GB17116@infradead.org> <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr> <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
 <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr> <20171003145732.GA8890@infradead.org> <nycvar.YSQ.7.76.1710031107290.5407@knanqh.ubzr> <20171003153659.GA31600@infradead.org> <nycvar.YSQ.7.76.1710031137580.5407@knanqh.ubzr>
 <20171004072553.GA24620@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>

On Wed, 4 Oct 2017, Christoph Hellwig wrote:

> As said in my last mail: look at the VM_MIXEDMAP flag and how it is 
> used by DAX, and you'll get out of the vma splitting business in the 
> fault path.

Alright, it appears to work.

The only downside so far is the lack of visibility from user space to 
confirm it actually works as intended. With the vma splitting approach 
you clearly see what gets directly mapped in /proc/*/maps thanks to 
remap_pfn_range() storing the actual physical address in vma->vm_pgoff. 
With VM_MIXEDMAP things are no longer visible. Any opinion for the best 
way to overcome this?

Anyway, here's a replacement for patch 4/5 below:

----- >8
Subject: cramfs: add mmap support

When cramfs_physmem is used then we have the opportunity to map files
directly from ROM, directly into user space, saving on RAM usage.
This gives us Execute-In-Place (XIP) support.

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

diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index 2fc886092b..9d5d0c1f7d 100644
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
@@ -277,6 +285,188 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset,
 		return NULL;
 }
 
+/*
+ * For a mapping to be possible, we need a range of uncompressed and
+ * contiguous blocks. Return the offset for the first block and number of
+ * valid blocks for which that is true, or zero otherwise.
+ */
+static u32 cramfs_get_block_range(struct inode *inode, u32 pgoff, u32 *pages)
+{
+	struct super_block *sb = inode->i_sb;
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+	int i;
+	u32 *blockptrs, blockaddr;
+
+	/*
+	 * We can dereference memory directly here as this code may be
+	 * reached only when there is a direct filesystem image mapping
+	 * available in memory.
+	 */
+	blockptrs = (u32 *)(sbi->linear_virt_addr + OFFSET(inode) + pgoff*4);
+	blockaddr = blockptrs[0] & ~CRAMFS_BLK_FLAGS;
+	i = 0;
+	do {
+		u32 expect = blockaddr + i * (PAGE_SIZE >> 2);
+		expect |= CRAMFS_BLK_FLAG_DIRECT_PTR|CRAMFS_BLK_FLAG_UNCOMPRESSED;
+		if (blockptrs[i] != expect) {
+			pr_debug("range: block %d/%d got %#x expects %#x\n",
+				 pgoff+i, pgoff+*pages-1, blockptrs[i], expect);
+			if (i == 0)
+				return 0;
+			break;
+		}
+	} while (++i < *pages);
+
+	*pages = i;
+
+	/* stored "direct" block ptrs are shifted down by 2 bits */
+	return blockaddr << 2;
+}
+
+static int cramfs_physmem_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct inode *inode = file_inode(file);
+	struct super_block *sb = inode->i_sb;
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+	unsigned int pages, vma_pages, max_pages, offset;
+	unsigned long address;
+	char *fail_reason;
+	int ret;
+
+	if (!IS_ENABLED(CONFIG_MMU))
+		return vma->vm_flags & (VM_SHARED | VM_MAYSHARE) ? 0 : -ENOSYS;
+
+	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE))
+		return -EINVAL;
+
+	/* Could COW work here? */
+	fail_reason = "vma is writable";
+	if (vma->vm_flags & VM_WRITE)
+		goto fail;
+
+	vma_pages = (vma->vm_end - vma->vm_start + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	max_pages = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	fail_reason = "beyond file limit";
+	if (vma->vm_pgoff >= max_pages)
+		goto fail;
+	pages = vma_pages;
+	if (pages > max_pages - vma->vm_pgoff)
+		pages = max_pages - vma->vm_pgoff;
+
+	offset = cramfs_get_block_range(inode, vma->vm_pgoff, &pages);
+	fail_reason = "unsuitable block layout";
+	if (!offset)
+		goto fail;
+	address = sbi->linear_phys_addr + offset;
+	fail_reason = "data is not page aligned";
+	if (!PAGE_ALIGNED(address))
+		goto fail;
+
+	/* Don't map the last page if it contains some other data */
+	if (unlikely(vma->vm_pgoff + pages == max_pages)) {
+		unsigned int partial = offset_in_page(inode->i_size);
+		if (partial) {
+			char *data = sbi->linear_virt_addr + offset;
+			data += (max_pages - 1) * PAGE_SIZE + partial;
+			while ((unsigned long)data & 7)
+				if (*data++ != 0)
+					goto nonzero;
+			while (offset_in_page(data)) {
+				if (*(u64 *)data != 0) {
+					nonzero:
+					pr_debug("mmap: %s: last page is shared\n",
+						 file_dentry(file)->d_name.name);
+					pages--;
+					break;
+				}
+				data += 8;
+			}
+		}
+	}
+
+	if (!pages) {
+		fail_reason = "no suitable block remaining";
+		goto fail;
+	} else if (pages != vma_pages) {
+		/*
+		 * Let's create a mixed map if we can't map it all.
+		 * The normal paging machinery will take care of the
+		 * unpopulated vma via cramfs_readpage().
+		 */
+		int i;
+		vma->vm_flags |= VM_MIXEDMAP;
+		for (i = 0; i < pages; i++) {
+			unsigned long vaddr = vma->vm_start + i*PAGE_SIZE;
+			pfn_t pfn = phys_to_pfn_t(address + i*PAGE_SIZE, PFN_DEV);
+			ret = vm_insert_mixed(vma, vaddr, pfn);
+			if (ret)
+				return ret;
+		}
+		vma->vm_ops = &generic_file_vm_ops;
+	} else {
+		ret = remap_pfn_range(vma, vma->vm_start, address >> PAGE_SHIFT,
+				      pages * PAGE_SIZE, vma->vm_page_prot);
+		if (ret)
+			return ret;
+	}
+
+	pr_debug("mapped %s at 0x%08lx (%u/%u pages) to vma 0x%08lx, "
+		 "page_prot 0x%llx\n", file_dentry(file)->d_name.name,
+		 address, pages, vma_pages, vma->vm_start,
+		 (unsigned long long)pgprot_val(vma->vm_page_prot));
+	return 0;
+
+fail:
+	pr_debug("%s: direct mmap failed: %s\n",
+		 file_dentry(file)->d_name.name, fail_reason);
+
+	/* We failed to do a direct map, but normal paging is still possible */
+	vma->vm_ops = &generic_file_vm_ops;
+	return 0;
+}
+
+#ifndef CONFIG_MMU
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
+static unsigned cramfs_physmem_mmap_capabilities(struct file *file)
+{
+	return NOMMU_MAP_COPY | NOMMU_MAP_DIRECT | NOMMU_MAP_READ | NOMMU_MAP_EXEC;
+}
+#endif
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
