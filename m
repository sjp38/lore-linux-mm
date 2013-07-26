Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 5B2966B0036
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 08:29:30 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC] pram: persistent over-kexec memory file system
Date: Fri, 26 Jul 2013 16:29:23 +0400
Message-ID: <1374841763-11958-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com

Hi,

We want to propose a way to upgrade a kernel on a machine without
restarting all the user-space services. This is to be done with CRIU
project, but we need help from the kernel to preserve some data in
memory while doing kexec.

The key point of our implementation is leaving process memory in-place
during reboot. This should eliminate most io operations the services
would produce during initialization. To achieve this, we have
implemented a pseudo file system that preserves its content during
kexec. We propose saving CRIU dump files to this file system, kexec'ing
and then restoring the processes in the newly booted kernel.

A typical usage scenario would look like this:

 1) Boot kernel with 'pram_banned=MEMRANGE' boot option
    (MEMRANGE=MEMMIN-MEMMAX).

    This is to prevent kexec from overwriting persistent data while
    loading the new kernel. Later on kexec will be forced to load kernel
    to the range specified. MEMRANGE=0-128M should be enough.

 2) Mount pram file system and save dump files there:

    # mount -t pram none /mnt
    # criu dump -D /mnt -t $PID

 3) Run kexec passing pram location to the new kernel and forcing it to
    load the kernel image to MEMRAGE:

    # kexec --load /vmlinuz --initrd=initrd.img \
            --append="$(cat /proc/cmdline | sed -e 's/pram=[^ ]*//g') pram=$(cat /sys/kernel/pram)" \
            --mem-min=$MEMMIN --mem-max=$MEMMAX
    # reboot

 4) After reboot mount pram, restore processes, and cleanup:

    # mount -t pram none /mnt
    # criu restore -d -D /mnt
    # rm -f /mnt/*
    # umount /mnt

In this patch I introduce the pram pseudo file system that keeps its
memory in place during kexec. pram is based on ramfs, but it serializes
and leaves in memory its content on unmount, and restores it on the next
mount. To survive over kexec, pram finds the serialized content, whose
location should be specified by 'pram' boot param (exported via
/sys/kernel/pram), and reserves it at early boot. To avoid conflicts
with other parts of the kernel that make early reservation too, pram
tracks all memory regions that have ever been reserved and avoids using
them for storing its data. Plus, it adds 'pram_banned' boot param, which
can be used to explicitly disallow pram to use specified memory regions.
This may be useful for avoiding conflicts with kexec loading the new
kernel image (as it is done in the usage scenario).

This implementation serves as a proof of concept and so has a number of
limitations:

 * pram only supports regular files; directories, symlinks, etc are
   ignored

 * pram is implemented only for x86

 * pram does not support swapping out

 * pram checksums serialized content and drops it in case it is
   corrupted with no possibility of restore

What do you think about it, does it make sense to go on with this
approach or should we reconsider it as a whole?

Thanks.
---
 arch/x86/kernel/setup.c |    2 +
 fs/Kconfig              |   13 +
 fs/ramfs/Makefile       |    1 +
 fs/ramfs/inode.c        |    2 +-
 fs/ramfs/persistent.c   |  699 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/pram.h    |   18 ++
 include/linux/ramfs.h   |    1 +
 kernel/ksysfs.c         |   13 +
 mm/bootmem.c            |    5 +
 mm/memblock.c           |    7 +-
 mm/nobootmem.c          |    2 +
 mm/page_alloc.c         |    3 +
 12 files changed, 764 insertions(+), 2 deletions(-)
 create mode 100644 fs/ramfs/persistent.c
 create mode 100644 include/linux/pram.h

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index f8ec578..7d22ad0 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -50,6 +50,7 @@
 #include <linux/init_ohci1394_dma.h>
 #include <linux/kvm_para.h>
 #include <linux/dma-contiguous.h>
+#include <linux/pram.h>
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -1137,6 +1138,7 @@ void __init setup_arch(char **cmdline_p)
 	early_acpi_boot_init();
 
 	initmem_init();
+	pram_reserve();
 	memblock_find_dma_reserve();
 
 #ifdef CONFIG_KVM_GUEST
diff --git a/fs/Kconfig b/fs/Kconfig
index c229f82..8d6943f 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -168,6 +168,19 @@ config HUGETLB_PAGE
 
 source "fs/configfs/Kconfig"
 
+config PRAM
+	bool "Persistent over-kexec memory storage"
+	depends on X86
+	select CRC32
+	select LIBCRC32C
+	select CRYPTO_CRC32C
+	select CRYPTO_CRC32C_INTEL
+	default n
+	help
+	  pram is a filesystem that saves its content on unmount to be restored
+	  on the next mount after kexec. It can be used for speeding up system
+	  reboot by saving application memory images there.
+
 endmenu
 
 menuconfig MISC_FILESYSTEMS
diff --git a/fs/ramfs/Makefile b/fs/ramfs/Makefile
index c71e65d..e6953d4 100644
--- a/fs/ramfs/Makefile
+++ b/fs/ramfs/Makefile
@@ -7,3 +7,4 @@ obj-y += ramfs.o
 file-mmu-y := file-nommu.o
 file-mmu-$(CONFIG_MMU) := file-mmu.o
 ramfs-objs += inode.o $(file-mmu-y)
+ramfs-$(CONFIG_PRAM) += persistent.o
diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index c24f1e1..86f9f9a 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -250,7 +250,7 @@ static struct dentry *rootfs_mount(struct file_system_type *fs_type,
 	return mount_nodev(fs_type, flags|MS_NOUSER, data, ramfs_fill_super);
 }
 
-static void ramfs_kill_sb(struct super_block *sb)
+void ramfs_kill_sb(struct super_block *sb)
 {
 	kfree(sb->s_fs_info);
 	kill_litter_super(sb);
diff --git a/fs/ramfs/persistent.c b/fs/ramfs/persistent.c
new file mode 100644
index 0000000..a2fe629
--- /dev/null
+++ b/fs/ramfs/persistent.c
@@ -0,0 +1,699 @@
+#include <linux/bootmem.h>
+#include <linux/crc32.h>
+#include <linux/crc32c.h>
+#include <linux/err.h>
+#include <linux/fs.h>
+#include <linux/gfp.h>
+#include <linux/highmem.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/kobject.h>
+#include <linux/list.h>
+#include <linux/memblock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/namei.h>
+#include <linux/pagemap.h>
+#include <linux/pagevec.h>
+#include <linux/pfn.h>
+#include <linux/pram.h>
+#include <linux/ramfs.h>
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/sysfs.h>
+#include <linux/types.h>
+
+#define PRAM_MAGIC			0x7072616D
+
+#define PRAM_PAGE_META			1
+#define PRAM_PAGE_DATA			2
+#define PRAM_PAGE_TYPE_MASK		0x00ff
+
+#define PRAM_PAGE_LRU			0x0100
+
+struct pram_entry {
+	__u32	flags;			/* PRAM_PAGE_* */
+	__u32	csum;
+	__u64	pfn;
+	__u64	index;
+};
+
+struct pram_link {
+	__u32	magic;
+	__u32	csum;
+	__u32	len;
+	__u64	link_pfn;
+	struct pram_entry entry[0];
+};
+
+#define PRAM_LINK_LEN_MAX \
+	((PAGE_SIZE-sizeof(struct pram_link))/sizeof(struct pram_entry))
+
+struct pram_chain {
+	struct page *head;
+	struct page *curr;
+	void *kmap;
+	unsigned int offset;
+	struct list_head banned;	/* list of allocated banned pages,
+					   linked via page::lru */
+};
+
+struct pram_file_image {
+	__u64	size;
+	__u32	mode;
+	__u32	name_len;
+	__u8	name[NAME_MAX];
+};
+
+struct banned_region {
+	unsigned long start, end;	/* pfn, inclusive */
+};
+
+#define MAX_NR_BANNED		(32 + MAX_NUMNODES * 2)
+
+/* arranged in ascending order, do not overlap */
+static struct banned_region banned[MAX_NR_BANNED];
+static unsigned int nr_banned;
+
+unsigned long __initdata pram_reserved_pages;
+static bool __meminitdata pram_reservation_in_progress;
+
+unsigned long pram_pfn;
+
+static int __init parse_pram_pfn(char *arg)
+{
+	return kstrtoul(arg, 16, &pram_pfn);
+}
+early_param("pram", parse_pram_pfn);
+
+static u32 pram_data_csum(struct page *page)
+{
+	u32 ret;
+	void *addr;
+
+	addr = kmap_atomic(page);
+	ret = crc32c(0, addr, PAGE_SIZE);
+	kunmap_atomic(addr);
+	return ret;
+}
+
+/* SSE-4.2 crc32c faster than crc32, but not available at early boot */
+static inline u32 pram_meta_csum(void *addr)
+{
+	/* skip magic and csum fields */
+	return crc32(0, addr + 8, PAGE_SIZE - 8);
+}
+
+static int __init pram_reserve_page(unsigned long pfn)
+{
+	int err = 0;
+	phys_addr_t base, size;
+
+	if (pfn >= max_pfn)
+		return -EINVAL;
+
+	base = PFN_PHYS(pfn);
+	size = PAGE_SIZE;
+
+#ifdef CONFIG_NO_BOOTMEM
+	if (memblock_is_region_reserved(base, size) ||
+	    memblock_reserve(base, size) < 0)
+		err = -EBUSY;
+#else
+	err = reserve_bootmem(base, size, BOOTMEM_EXCLUSIVE);
+#endif
+	if (err)
+		pr_err("PRAM: pfn:%lx busy\n", pfn);
+	else
+		pram_reserved_pages++;
+	return err;
+}
+
+static void __init pram_unreserve_page(unsigned long pfn)
+{
+	free_bootmem(PFN_PHYS(pfn), PAGE_SIZE);
+	pram_reserved_pages--;
+}
+
+static int __init pram_reserve_link(unsigned long pfn)
+{
+	int i, err = 0;
+	struct pram_link *link = pfn_to_kaddr(pfn);
+
+	err = pram_reserve_page(pfn);
+	if (err)
+		return err;
+	for (i = 0; i < link->len; i++) {
+		struct pram_entry *p = &link->entry[i];
+
+		err = pram_reserve_page(p->pfn);
+		if (err)
+			break;
+		p->flags &= ~PRAM_PAGE_LRU;
+	}
+	if (err) {
+		while (--i >= 0)
+			pram_unreserve_page(link->entry[i].pfn);
+		pram_unreserve_page(pfn);
+	}
+	return err;
+}
+
+static void __init pram_unreserve_link(unsigned long pfn)
+{
+	int i;
+	struct pram_link *link = pfn_to_kaddr(pfn);
+
+	for (i = 0; i < link->len; i++)
+		pram_unreserve_page(link->entry[i].pfn);
+	pram_unreserve_page(pfn);
+}
+
+void __init pram_reserve(void)
+{
+	unsigned long pfn = pram_pfn;
+	struct pram_link *link;
+	int err;
+
+	if (!pfn)
+		return;
+
+	pr_info("PRAM: Examining persistent memory...\n");
+	pram_reservation_in_progress = true;
+
+	do {
+		err = -EINVAL;
+		if (pfn >= max_low_pfn) {
+			pr_err("PRAM: pfn:%lx invalid\n", pfn);
+			break;
+		}
+		link = pfn_to_kaddr(pfn);
+		if (link->magic != PRAM_MAGIC ||
+		    link->csum != pram_meta_csum(link)) {
+			pr_err("PRAM: pfn:%lx corrupted\n", pfn);
+			break;
+		}
+		err = pram_reserve_link(pfn);
+		if (err)
+			break;
+		pfn = link->link_pfn;
+	} while (pfn != 0);
+
+	pram_reservation_in_progress = false;
+	if (err) {
+		unsigned long bad_pfn = pfn;
+
+		pfn = pram_pfn;
+		while (pfn != bad_pfn) {
+			link = pfn_to_kaddr(pfn);
+			pram_unreserve_link(pfn);
+			pfn = link->link_pfn;
+		}
+		pr_err("PRAM: Reservation failed: %d\n", err);
+		pram_pfn = 0;
+	} else
+		pr_info("PRAM: %lu pages reserved\n", pram_reserved_pages);
+}
+
+/* comma separated list of extra banned regions */
+static int __init parse_pram_banned(char *arg)
+{
+	char *cur = arg, *tmp;
+	unsigned long long start, end;
+
+	do {
+		start = memparse(cur, &tmp);
+		if (cur == tmp) {
+			pr_warning("pram_banned: Memory value expected\n");
+			return -EINVAL;
+		}
+		cur = tmp;
+		if (*cur != '-') {
+			pr_warning("pram_banned: '-' expected\n");
+			return -EINVAL;
+		}
+		cur++;
+		end = memparse(cur, &tmp);
+		if (cur == tmp) {
+			pr_warning("pram_banned: Memory value expected\n");
+			return -EINVAL;
+		}
+		if (end <= start) {
+			pr_warning("pram_banned: end <= start\n");
+			return -EINVAL;
+		}
+		pram_ban_region(PFN_DOWN(start), PFN_UP(end) - 1);
+	} while (*cur++ == ',');
+
+	return 0;
+}
+early_param("pram_banned", parse_pram_banned);
+
+void __meminit pram_ban_region(unsigned long start, unsigned long end)
+{
+	int i, merged = -1;
+
+	if (pram_reservation_in_progress)
+		return;
+
+	/* first try to merge the region with an existing one */
+	for (i = nr_banned - 1; i >= 0 && start <= banned[i].end + 1; i--) {
+		if (end + 1 >= banned[i].start) {
+			start = min(banned[i].start, start);
+			end = max(banned[i].end, end);
+			if (merged < 0)
+				merged = i;
+		} else
+			/* regions are arranged in ascending order and do not
+			 * intersect so the merged region cannot jump over its
+			 * predecessors */
+			BUG_ON(merged >= 0);
+	}
+
+	i++;
+	if (merged >= 0) {
+		banned[i].start = start;
+		banned[i].end = end;
+		/* shift if merged with more than one region */
+		memmove(banned + i + 1, banned + merged + 1,
+			sizeof(*banned) * (nr_banned - merged - 1));
+		nr_banned -= merged - i;
+		return;
+	}
+
+	/* the region does not intersect with anyone existing,
+	 * try to create a new one */
+	if (nr_banned == MAX_NR_BANNED) {
+		pr_err("PRAM: Failed to ban %lu-%lu: "
+		       "Too many banned regions\n", start, end);
+		return;
+	}
+
+	memmove(banned + i + 1, banned + i,
+		sizeof(*banned) * (nr_banned - i));
+	banned[i].start = start;
+	banned[i].end = end;
+	nr_banned++;
+}
+
+void __init pram_show_banned(void)
+{
+	int i;
+	unsigned long n, total = 0;
+
+	pr_info("PRAM: banned regions:\n");
+	for (i = 0; i < nr_banned; i++) {
+		n = banned[i].end - banned[i].start + 1;
+		pr_info("%4d: [%08lx - %08lx] %ld pages\n",
+			i, banned[i].start, banned[i].end, n);
+		total += n;
+	}
+	pr_info("Total banned: %lu pages in %u regions\n",
+		total, nr_banned);
+}
+
+static bool pram_page_banned(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	int l = 0, r = nr_banned - 1, m;
+
+	/* do binary search */
+	while (l <= r) {
+		m = (l + r) / 2;
+		if (pfn < banned[m].start)
+			r = m - 1;
+		else if (pfn > banned[m].end)
+			l = m + 1;
+		else
+			return true;
+	}
+	return false;
+}
+
+static struct page *pram_alloc_page(struct pram_chain *chain, gfp_t gfp_mask)
+{
+	struct page *page;
+
+	page = alloc_page(gfp_mask);
+	gfp_mask |= __GFP_COLD;
+	while (page && pram_page_banned(page)) {
+		list_add(&page->lru, &chain->banned);
+		page = alloc_page(gfp_mask);
+	}
+	return page;
+}
+
+static void pram_chain_init(struct pram_chain *chain, unsigned long pfn)
+{
+	memset(chain, 0, sizeof(*chain));
+	INIT_LIST_HEAD(&chain->banned);
+	if (pfn) {
+		chain->curr = chain->head = pfn_to_page(pfn);
+		chain->kmap = kmap(chain->curr);
+	}
+}
+
+static void pram_chain_free(struct pram_chain *chain)
+{
+	struct page *page;
+
+	while (!list_empty(&chain->banned)) {
+		page = list_first_entry(&chain->banned, struct page, lru);
+		list_del_init(&page->lru);
+		__free_page(page);
+	}
+}
+
+static void pram_finish_link(struct pram_chain *chain, struct page *next)
+{
+	struct pram_link *link = chain->kmap;
+
+	if (chain->curr) {
+		link->link_pfn = next ? page_to_pfn(next) : 0;
+		link->magic = PRAM_MAGIC;
+		link->csum = pram_meta_csum(link);
+		kunmap(chain->curr);
+	} else
+		chain->head = next;
+	chain->curr = next;
+	chain->kmap = next ? kmap(next) : NULL;
+	chain->offset = 0;
+}
+
+static int pram_write(struct pram_chain *chain,
+		      struct page *page, unsigned int flags, pgoff_t index)
+{
+	struct pram_link *link;
+	struct pram_entry *entry;
+	struct page *new = NULL;
+	int err = 0;
+
+	if (pram_page_banned(page)) {
+		new = pram_alloc_page(chain, GFP_HIGHUSER_MOVABLE);
+		if (!new)
+			return -ENOMEM;
+		copy_highpage(new, page);
+		page = new;
+		flags &= ~PRAM_PAGE_LRU;
+	}
+
+	if (!chain->curr || chain->offset >= PRAM_LINK_LEN_MAX) {
+		struct page *next;
+
+		next = pram_alloc_page(chain, GFP_KERNEL | __GFP_ZERO);
+		if (!next) {
+			err = -ENOMEM;
+			goto out;
+		}
+		pram_finish_link(chain, next);
+	}
+
+	get_page(page);
+	link = chain->kmap;
+	entry = &link->entry[chain->offset++];
+	entry->flags = flags;
+	entry->csum = pram_data_csum(page);
+	entry->pfn = page_to_pfn(page);
+	entry->index = index;
+	link->len++;
+out:
+	if (new)
+		put_page(new);
+	return err;
+}
+
+static void pram_advance_link(struct pram_chain *chain)
+{
+	struct pram_link *link = chain->kmap;
+	struct page *prev = chain->curr;
+
+	if (link->link_pfn) {
+		chain->curr = pfn_to_page(link->link_pfn);
+		chain->kmap = kmap(chain->curr);
+	} else {
+		chain->curr = NULL;
+		chain->kmap = NULL;
+	}
+	chain->offset = 0;
+	kunmap(prev);
+	ClearPageReserved(prev);
+	__free_page(prev);
+}
+
+static struct page *pram_read(struct pram_chain *chain,
+			      unsigned int *flags, pgoff_t *index)
+{
+	struct pram_link *link;
+	struct pram_entry *entry;
+	struct page *page;
+
+	if (!chain->curr)
+		return NULL;
+
+	link = chain->kmap;
+	entry = &link->entry[chain->offset];
+	page = pfn_to_page(entry->pfn);
+	if (entry->csum != pram_data_csum(page)) {
+		pr_err("PRAM: pfn:%lx corrupted\n", (unsigned long)entry->pfn);
+		return ERR_PTR(-EINVAL);
+	}
+	ClearPageReserved(page);
+	*flags = entry->flags;
+	*index = entry->index;
+
+	if (++chain->offset >= link->len)
+		pram_advance_link(chain);
+	return page;
+}
+
+static void pram_truncate(struct pram_chain *chain)
+{
+	struct pram_link *link;
+	struct page *page;
+
+	do {
+		link = chain->kmap;
+		for ( ; chain->offset < link->len; chain->offset++) {
+			page = pfn_to_page(link->entry[chain->offset].pfn);
+			ClearPageReserved(page);
+			put_page(page);
+		}
+		pram_advance_link(chain);
+	} while (chain->curr);
+}
+
+static int pram_save_file(struct pram_chain *chain, struct dentry *dentry)
+{
+	struct inode *inode = dentry->d_inode;
+	struct address_space *mapping = inode->i_mapping;
+	struct pram_file_image *img;
+	struct page *page;
+	struct pagevec pvec;
+	pgoff_t index, next = 0;
+	int i, err;
+
+	if (!S_ISREG(inode->i_mode)) {
+		pr_warn("PRAM: skipping non-regular file /%s\n",
+			dentry->d_name.name);
+		return 0;
+	}
+
+	page = pram_alloc_page(chain, GFP_HIGHUSER_MOVABLE);
+	if (!page)
+		return -ENOMEM;
+	img = kmap(page);
+	img->mode = inode->i_mode;
+	img->size = i_size_read(inode);
+	img->name_len = dentry->d_name.len;
+	memcpy(img->name, dentry->d_name.name, img->name_len);
+	kunmap(page);
+
+	err = pram_write(chain, page, PRAM_PAGE_META, 0);
+	put_page(page);
+	if (err)
+		return err;
+
+	pagevec_init(&pvec, 0);
+	while (pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			page = pvec.pages[i];
+			lock_page(page);
+			if (unlikely(page->mapping != mapping)) {
+				unlock_page(page);
+				continue;
+			}
+			index = page->index;
+			if (index > next)
+				next = index;
+			next++;
+			err = pram_write(chain, page,
+					 PRAM_PAGE_DATA|PRAM_PAGE_LRU, index);
+			if (err) {
+				unlock_page(page);
+				return err;
+			}
+			delete_from_page_cache(page);
+			unlock_page(page);
+		}
+		pagevec_release(&pvec);
+		cond_resched();
+	}
+	return 0;
+}
+
+static void pram_save_tree(struct dentry *root)
+{
+	struct pram_chain chain;
+	struct dentry *dentry;
+	int err = 0;
+
+	pram_chain_init(&chain, 0);
+
+	mutex_lock(&root->d_inode->i_mutex);
+	spin_lock(&root->d_lock);
+	list_for_each_entry(dentry, &root->d_subdirs, d_u.d_child) {
+		if (d_unhashed(dentry) || !dentry->d_inode)
+			continue;
+		dget(dentry);
+		spin_unlock(&root->d_lock);
+		err = pram_save_file(&chain, dentry);
+		spin_lock(&root->d_lock);
+		dput(dentry);
+		if (err)
+			break;
+	}
+	spin_unlock(&root->d_lock);
+	mutex_unlock(&root->d_inode->i_mutex);
+
+	if (err) {
+		if (chain.head) {
+			chain.curr = chain.head;
+			chain.kmap = kmap(chain.curr);
+			chain.offset = 0;
+			pram_truncate(&chain);
+		}
+		pr_err("PRAM: Failed to save FS tree: %d\n", err);
+	} else {
+		if (chain.head) {
+			pram_finish_link(&chain, NULL);
+			pram_pfn = page_to_pfn(chain.head);
+		}
+	}
+	pram_chain_free(&chain);
+}
+
+static struct dentry *pram_mkfile(struct dentry *parent,
+				  struct pram_file_image *img)
+{
+	struct dentry *dentry;
+	int err;
+
+	if (!S_ISREG(img->mode) || img->name_len > NAME_MAX)
+		return ERR_PTR(-EINVAL);
+
+	mutex_lock_nested(&parent->d_inode->i_mutex, I_MUTEX_PARENT);
+	dentry = lookup_one_len(img->name, parent, img->name_len);
+	if (IS_ERR(dentry))
+		return dentry;
+	err = vfs_create(parent->d_inode, dentry, img->mode, NULL);
+	if (err) {
+		dput(dentry);
+		dentry = ERR_PTR(err);
+		goto out_unlock;
+	}
+	i_size_write(dentry->d_inode, img->size);
+out_unlock:
+	mutex_unlock(&parent->d_inode->i_mutex);
+	return dentry;
+}
+
+static void pram_load_tree(struct dentry *root)
+{
+	struct pram_chain chain;
+	struct pram_file_image *img;
+	struct dentry *dentry = NULL;
+	struct page *page;
+	unsigned int flags;
+	pgoff_t index;
+	int err;
+
+	if (!pram_pfn)
+		return;
+
+	pram_chain_init(&chain, pram_pfn);
+next:
+	page = pram_read(&chain, &flags, &index);
+	if (IS_ERR_OR_NULL(page)) {
+		dput(dentry);
+		err = PTR_ERR(page);
+		goto out;
+	}
+
+	if ((flags & PRAM_PAGE_TYPE_MASK) == PRAM_PAGE_META) {
+		img = kmap(page);
+		dput(dentry);
+		dentry = pram_mkfile(root, img);
+		if (IS_ERR(dentry))
+			err = PTR_ERR(dentry);
+		kunmap(page);
+	} else if ((flags & PRAM_PAGE_TYPE_MASK) == PRAM_PAGE_DATA && dentry) {
+		struct address_space *mapping = dentry->d_inode->i_mapping;
+
+		if (flags & PRAM_PAGE_LRU) {
+			lock_page(page);
+			err = add_to_page_cache(page, mapping,
+						index, GFP_KERNEL);
+			if (err)
+				unlock_page(page);
+		} else
+			err = add_to_page_cache_lru(page, mapping,
+						    index, GFP_KERNEL);
+		if (!err) {
+			SetPageUptodate(page);
+			set_page_dirty(page);
+			unlock_page(page);
+		}
+	} else
+		err = -EINVAL;
+	put_page(page);
+	if (!err)
+		goto next;
+out:
+	if (chain.curr)
+		pram_truncate(&chain);
+	pram_chain_free(&chain);
+	pram_pfn = 0;
+	if (err)
+		pr_err("PRAM: Failed to load FS tree: %d\n", err);
+}
+
+static struct dentry *pram_mount(struct file_system_type *fs_type,
+				 int flags, const char *dev_name, void *data)
+{
+	struct dentry *root;
+
+	root = mount_single(fs_type, flags, data, ramfs_fill_super);
+	if (!IS_ERR(root))
+		pram_load_tree(root);
+	return root;
+}
+
+static void pram_kill_sb(struct super_block *sb)
+{
+	pram_save_tree(sb->s_root);
+	ramfs_kill_sb(sb);
+}
+
+static struct file_system_type pram_fs_type = {
+	.name		= "pram",
+	.mount		= pram_mount,
+	.kill_sb	= pram_kill_sb,
+};
+
+static int __init pram_init(void)
+{
+	return register_filesystem(&pram_fs_type);
+}
+module_init(pram_init);
diff --git a/include/linux/pram.h b/include/linux/pram.h
new file mode 100644
index 0000000..ba37782
--- /dev/null
+++ b/include/linux/pram.h
@@ -0,0 +1,18 @@
+#ifndef _LINUX_PRAM_H
+#define _LINUX_PRAM_H
+
+extern unsigned long pram_pfn;
+
+#ifdef CONFIG_PRAM
+extern unsigned long pram_reserved_pages;
+extern void pram_reserve(void);
+extern void pram_ban_region(unsigned long start, unsigned long end);
+extern void pram_show_banned(void);
+#else
+#define pram_reserved_pages 0UL
+static inline void pram_reserve(void) { }
+static inline void pram_ban_region(unsigned long start, unsigned long end) { }
+static inline void pram_show_banned(void) { }
+#endif
+
+#endif
diff --git a/include/linux/ramfs.h b/include/linux/ramfs.h
index 69e37c2..4fd5d7b 100644
--- a/include/linux/ramfs.h
+++ b/include/linux/ramfs.h
@@ -5,6 +5,7 @@ struct inode *ramfs_get_inode(struct super_block *sb, const struct inode *dir,
 	 umode_t mode, dev_t dev);
 extern struct dentry *ramfs_mount(struct file_system_type *fs_type,
 	 int flags, const char *dev_name, void *data);
+extern void ramfs_kill_sb(struct super_block *sb);
 
 #ifdef CONFIG_MMU
 static inline int
diff --git a/kernel/ksysfs.c b/kernel/ksysfs.c
index 6ada93c..1042120 100644
--- a/kernel/ksysfs.c
+++ b/kernel/ksysfs.c
@@ -18,6 +18,7 @@
 #include <linux/stat.h>
 #include <linux/sched.h>
 #include <linux/capability.h>
+#include <linux/pram.h>
 
 #define KERNEL_ATTR_RO(_name) \
 static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
@@ -132,6 +133,15 @@ KERNEL_ATTR_RO(vmcoreinfo);
 
 #endif /* CONFIG_KEXEC */
 
+#ifdef CONFIG_KEXEC
+static ssize_t pram_show(struct kobject *kobj,
+			 struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lx\n", pram_pfn);
+}
+KERNEL_ATTR_RO(pram);
+#endif
+
 /* whether file capabilities are enabled */
 static ssize_t fscaps_show(struct kobject *kobj,
 				  struct kobj_attribute *attr, char *buf)
@@ -196,6 +206,9 @@ static struct attribute * kernel_attrs[] = {
 	&kexec_crash_size_attr.attr,
 	&vmcoreinfo_attr.attr,
 #endif
+#ifdef CONFIG_PRAM
+	&pram_attr.attr,
+#endif
 	&rcu_expedited_attr.attr,
 	NULL
 };
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 6ab7744..af02cd6 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -16,6 +16,7 @@
 #include <linux/kmemleak.h>
 #include <linux/range.h>
 #include <linux/memblock.h>
+#include <linux/pram.h>
 
 #include <asm/bug.h>
 #include <asm/io.h>
@@ -279,6 +280,7 @@ unsigned long __init free_all_bootmem(void)
 		total_pages += free_all_bootmem_core(bdata);
 
 	totalram_pages += total_pages;
+	totalram_pages += pram_reserved_pages;
 
 	return total_pages;
 }
@@ -321,6 +323,9 @@ static int __init __reserve(bootmem_data_t *bdata, unsigned long sidx,
 			bdebug("silent double reserve of PFN %lx\n",
 				idx + bdata->node_min_pfn);
 		}
+
+	pram_ban_region(sidx + bdata->node_min_pfn,
+			eidx + bdata->node_min_pfn - 1);
 	return 0;
 }
 
diff --git a/mm/memblock.c b/mm/memblock.c
index a847bfe..673fa17 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -19,6 +19,7 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
+#include <linux/pram.h>
 
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
@@ -554,13 +555,17 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
 	struct memblock_type *_rgn = &memblock.reserved;
+	int err;
 
 	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size,
 		     (void *)_RET_IP_);
 
-	return memblock_add_region(_rgn, base, size, MAX_NUMNODES);
+	err = memblock_add_region(_rgn, base, size, MAX_NUMNODES);
+	if (!err)
+		pram_ban_region(PFN_DOWN(base), PFN_UP(base + size) - 1);
+	return err;
 }
 
 /**
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 61107cf..9b99681 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -16,6 +16,7 @@
 #include <linux/kmemleak.h>
 #include <linux/range.h>
 #include <linux/memblock.h>
+#include <linux/pram.h>
 
 #include <asm/bug.h>
 #include <asm/io.h>
@@ -176,6 +177,7 @@ unsigned long __init free_all_bootmem(void)
 	 */
 	pages = free_low_memory_core_early();
 	totalram_pages += pages;
+	totalram_pages += pram_reserved_pages;
 
 	return pages;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..c3b07be 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -60,6 +60,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
+#include <linux/pram.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -5313,6 +5314,8 @@ void __init mem_init_print_info(const char *str)
 	       totalhigh_pages << (PAGE_SHIFT-10),
 #endif
 	       str ? ", " : "", str ? str : "");
+
+	pram_show_banned();
 }
 
 /**
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
