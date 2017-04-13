Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7896B039F
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:42:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v6so5710850wrc.21
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:42:17 -0700 (PDT)
Received: from hera.aquilenet.fr (hera.aquilenet.fr. [141.255.128.1])
        by mx.google.com with ESMTP id 89si2082493wrk.321.2017.04.13.02.42.15
        for <linux-mm@kvack.org>;
        Thu, 13 Apr 2017 02:42:15 -0700 (PDT)
Date: Thu, 13 Apr 2017 11:42:00 +0200
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: [RFC] Re: Costless huge virtual memory? /dev/same, /dev/null?
Message-ID: <20170413094200.b4lftvumqt4g36hz@var.youpi.perso.aquilenet.fr>
References: <20160229162835.GA2816@var.bordeaux.inria.fr>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="utrjiimipmbqkvfw"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160229162835.GA2816@var.bordeaux.inria.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org


--utrjiimipmbqkvfw
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hello,

More than one year passed without any activity :)

I have attached a proposed patch for discussion.

Samuel

Samuel Thibault, on lun. 29 fA(C)vr. 2016 17:28:35 +0100, wrote:
> I'm wondering whether we could introduce a /dev/same device to allow
> costless huge virtual memory.
> 
> The use case is the simulation of the execution of a big irregular HPC
> application, to provision memory usage, cpu time, etc. We know how much
> time each computation loop takes, and it's easy to replace them with a
> mere accounting. We'd however like to avoid having to revamp the rest
> of the code, which does allocation/memcpys/etc., by just replacing
> the allocation calls with virtual allocations, i.e. allocations which
> return addresses of buffers that one can read/write, but the values you
> read are not necessarily what you wrote, i.e. the data is not actually
> properly stored (since we don't do the actual computations that's not a
> problem).
> 
> The way we currently do this is by some folding: we map the same normal
> file several times contiguously to form the virtual allocation. By using
> a small 1MiB file, this limits memory consumption to 1MiB plus the page
> table (and fits the dumb data in a typical cache). This however creates
> one VMA per file mapping, we get limited by the 65535 VMA limit, and
> VMA lookup becomes slow.
> 
> The way I could see is to have a /dev/same device: when you open it, it
> allocates one page. When you mmap it, it maps the same page over the
> whole resulting single VMA.
> 
> This is a quite specific use case, but it seems to be easy to implement,
> and it seems to me that it could be integrated mainline. Actually I was
> thinking that /dev/null itself could be providing that service?
> (currently it returns ENODEV)
> 
> What do people think?  Is there perhaps another solution to achieve this
> that I didn't think about?
> 
> Samuel

--utrjiimipmbqkvfw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dev_garbage

mm: Add /dev/garbage which provides bogus data and throws data away

When testing applications, one does not necessarily care about the
content of the resulting data, only e.g. assertions, and thus to
run big instances or a lot of instances in parallel, it is useful to
optimize the memory allocation away. Modifying the application to not
touch the non-allocated areas is however very tedious, so it makes
sense to be able to allocate memory areas with as many optimizations
as possible under the assumption that we do not care about the data
content. Such optimizations typically lead to physical memory usage
reduction, cache pollution reduction, etc.

We here add a new mem-based character device /dev/garbage to that end:
it does not provide any useful data and throws data away:

- read() from it does not actually put data in the userland buffer
- write() to it throws the data away
- open() it allocates one page used for mmap
- mmap() maps this page repeatedly on the whole memory range, thus
not consuming more physical memory than the page allocated by open.
Of course, accesses to the resulting area get completely mixed.

Additionally, since data is not actually backed, we can let
populate_vma_page_range emit write faults and dirty the page.

That way

int garbage = open("/dev/garbage", O_RDWR);
char *c = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_POPULATE, garbage, 0);

gets a VMA which is really immediately writable without any page fault
(which are costly).

Signed-off-by: Samuel Thibault <samuel.thibault@labri.fr>

--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -296,6 +296,11 @@ static unsigned zero_mmap_capabilities(s
 	return NOMMU_MAP_COPY;
 }
 
+static unsigned garbage_mmap_capabilities(struct file *file)
+{
+	return NOMMU_MAP_COPY | NOMMU_MAP_DIRECT;
+}
+
 /* can't do an in-place private mapping if there's no MMU */
 static inline int private_mapping_ok(struct vm_area_struct *vma)
 {
@@ -738,10 +743,74 @@ static int open_port(struct inode *inode
 	return capable(CAP_SYS_RAWIO) ? 0 : -EPERM;
 }
 
+static ssize_t read_iter_garbage(struct kiocb *iocb, struct iov_iter *iter)
+{
+	size_t written = 0;
+
+	while (iov_iter_count(iter)) {
+		written += iov_iter_count(iter);
+	}
+	return written;
+}
+
+static int garbage_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct page *page = vma->vm_file->private_data;
+	vmf->page = page;
+	return 0;
+}
+
+const struct vm_operations_struct mmap_garbage_ops = {
+	.fault	 	= garbage_fault,
+	.map_pages	= filemap_map_pages,
+};
+
+static int mmap_garbage(struct file *file, struct vm_area_struct *vma)
+{
+#ifndef CONFIG_MMU
+	return -ENOSYS;
+#endif
+	if (vma->vm_file)
+		fput(vma->vm_file);
+	vma->vm_file = get_file(file);
+	vma->vm_ops = &mmap_garbage_ops;
+	return 0;
+}
+
+static unsigned long get_unmapped_area_garbage(struct file *file,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags)
+{
+#ifdef CONFIG_MMU
+	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+#else
+	return -ENOSYS;
+#endif
+}
+
+static int open_garbage(struct inode *inode, struct file *file)
+{
+	struct page *page = alloc_page(__GFP_ZERO);
+	if (!page)
+		return -ENOMEM;
+	file->private_data = page;
+	return 0;
+}
+
+static int release_garbage(struct inode *inode, struct file *file)
+{
+	struct page *page = file->private_data;
+	__free_page(page);
+	return 0;
+}
+
 #define zero_lseek	null_lseek
 #define full_lseek      null_lseek
+#define garbage_lseek   null_lseek
 #define write_zero	write_null
+#define write_garbage	write_null
 #define write_iter_zero	write_iter_null
+#define write_iter_garbage	write_iter_null
 #define open_mem	open_port
 #define open_kmem	open_mem
 
@@ -803,6 +872,20 @@ static const struct file_operations full
 	.write		= write_full,
 };
 
+static const struct file_operations garbage_fops = {
+	.llseek		= garbage_lseek,
+	.write		= write_garbage,
+	.read_iter	= read_iter_garbage,
+	.write_iter	= write_iter_garbage,
+	.mmap		= mmap_garbage,
+	.open		= open_garbage,
+	.release	= release_garbage,
+	.get_unmapped_area = get_unmapped_area_garbage,
+#ifndef CONFIG_MMU
+	.mmap_capabilities = garbage_mmap_capabilities,
+#endif
+};
+
 static const struct memdev {
 	const char *name;
 	umode_t mode;
@@ -826,6 +909,8 @@ static const struct memdev {
 #ifdef CONFIG_PRINTK
 	[11] = { "kmsg", 0644, &kmsg_fops, 0 },
 #endif
+	/* [12] = { "oldmem", ... } */
+	[13] = { "garbage", 0666, &garbage_fops, 0 },
 };
 
 static int memory_open(struct inode *inode, struct file *filp)
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1028,7 +1028,11 @@ long populate_vma_page_range(struct vm_a
 	 * to break COW, except for shared mappings because these don't COW
 	 * and we would not want to dirty them for nothing.
 	 */
-	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
+	vm_flags_t check_shared = VM_SHARED;
+	if (vma->vm_ops == &mmap_garbage_ops)
+		/* This will go to the bin anyway */
+		check_shared = 0;
+	if ((vma->vm_flags & (VM_WRITE | check_shared)) == VM_WRITE)
 		gup_flags |= FOLL_WRITE;
 
 	/*
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2440,5 +2440,7 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern const struct vm_operations_struct mmap_garbage_ops;
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
--- a/Documentation/admin-guide/devices.txt
+++ b/Documentation/admin-guide/devices.txt
@@ -16,6 +16,7 @@
 		 11 = /dev/kmsg		Writes to this come out as printk's, reads
 					export the buffered printk records.
 		 12 = /dev/oldmem	OBSOLETE - replaced by /proc/vmcore
+		 13 = /dev/garbage	Garbage byte source
 
    1 block	RAM disk
 		  0 = /dev/ram0		First RAM disk

--utrjiimipmbqkvfw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
