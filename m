Date: Mon, 12 Nov 2007 02:56:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] remove nopage
Message-ID: <20071112015643.GA9291@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, rth@twiddle.net, Jaya Kumar <jayakumar.lkml@gmail.com>, krh@redhat.com, stefanr@s5r6.in-berlin.de, rolandd@cisco.com, mshefty@ichips.intel.com, hal.rosenstock@gmail.com, avi@qumranet.com, mchehab@infradead.org, dgilbert@interlog.com, Greg Kroah-Hartman <greg@kroah.com>, jgarzik@pobox.com, Takashi Iwai <tiwai@suse.de>, perex@perex.cz, Karsten Wiese <annabellesgarden@yahoo.de>
List-ID: <linux-mm.kvack.org>

Hi all,

This is a patch to remove 'nopage' from the tree.

I've gone through all the drivers and converted them to use fault as best
I can. When using fault, I've also tried to use vmf->pgoff rather than the
virtual address to find the page (which is much preferred). Mostly it has
been OK, but DRM is a bit difficult, as it seems to use vma->vm_pgoff as
a 2nd dimension of addressing.

I've also done some other things while going through at the code...

Converted incorrect OOM returns to SIGBUS.  OOM should only be returned as a
result of a memory allocation failure. We will actually want the fault path OOM
handling to be unified with the normal OOM killing path in future, and that
means the box will panic if panic_on_oom is set, or it will oom-kill random
processes before retrying the fault, etc.  SIGBUS means something like
"physical address (ie. after translation) does not exist", which is appropriate
AFAIKS in all cases (but please double check).

Got rid of some bogus looking "disallow mremap" checks that just check for
address > vma->vm_end. Am I missing something here? Presumably this is supposed
to prevent an mremap expanding the mapping outside the limit of the underlying
resource, but actually mremap will update vma->vm_end, and anyway this
condition is already checked in the page fault code. Others seem to get this
right by checking the underlying resource itself. Others don't seem to even
care. Might be a fair window for corruption / security problems here. Probably
we need a flag that explicitly prevents mremap() so driver writers don't have
to think too hard.

Now all these are going to need to be split up properly, but if we can
take a look at this all together, the discussion will be more coherent ;)


---
 Documentation/fb/deferred_io.txt             |    6 -
 Documentation/feature-removal-schedule.txt   |    9 -
 Documentation/filesystems/Locking            |    3 
 arch/ia64/ia32/binfmt_elf32.c                |   34 +++----
 drivers/char/agp/alpha-agp.c                 |   17 +--
 drivers/char/drm/drm_vm.c                    |  131 ++++++++++++---------------
 drivers/ieee1394/dma.c                       |   39 +++-----
 drivers/infiniband/hw/ipath/ipath_file_ops.c |   29 ++---
 drivers/kvm/kvm_main.c                       |   38 ++-----
 drivers/media/video/videobuf-dma-sg.c        |   20 +---
 drivers/scsi/sg.c                            |   23 ++--
 drivers/uio/uio.c                            |   14 +-
 drivers/usb/mon/mon_bin.c                    |   16 +--
 drivers/video/fb_defio.c                     |   17 +--
 include/linux/mm.h                           |    8 -
 kernel/relay.c                               |   24 +---
 mm/memory.c                                  |   22 +---
 mm/mincore.c                                 |    2 
 mm/mmap.c                                    |   19 +--
 mm/rmap.c                                    |    1 
 sound/core/pcm_native.c                      |   59 +++++-------
 sound/oss/via82cxxx_audio.c                  |   26 +----
 sound/usb/usx2y/usX2Yhwdep.c                 |   21 +---
 sound/usb/usx2y/usx2yhwdeppcm.c              |   19 +--
 24 files changed, 238 insertions(+), 359 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -162,8 +162,6 @@ struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
-	struct page *(*nopage)(struct vm_area_struct *area,
-			unsigned long address, int *type);
 	unsigned long (*nopfn)(struct vm_area_struct *area,
 			unsigned long address);
 
@@ -611,12 +609,6 @@ static inline int page_mapped(struct pag
 }
 
 /*
- * Error return values for the *_nopage functions
- */
-#define NOPAGE_SIGBUS	(NULL)
-#define NOPAGE_OOM	((struct page *) (-1))
-
-/*
  * Error return values for the *_nopfn functions
  */
 #define NOPFN_SIGBUS	((unsigned long) -1)
Index: linux-2.6/kernel/relay.c
===================================================================
--- linux-2.6.orig/kernel/relay.c
+++ linux-2.6/kernel/relay.c
@@ -37,37 +37,31 @@ static void relay_file_mmap_close(struct
 }
 
 /*
- * nopage() vm_op implementation for relay file mapping.
+ * fault() vm_op implementation for relay file mapping.
  */
-static struct page *relay_buf_nopage(struct vm_area_struct *vma,
-				     unsigned long address,
-				     int *type)
+static int relay_buf_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page *page;
 	struct rchan_buf *buf = vma->vm_private_data;
-	unsigned long offset = address - vma->vm_start;
+	pgoff_t pgoff = vmf->pgoff;
 
-	if (address > vma->vm_end)
-		return NOPAGE_SIGBUS; /* Disallow mremap */
 	if (!buf)
-		return NOPAGE_OOM;
+		return VM_FAULT_OOM;
 
-	page = vmalloc_to_page(buf->start + offset);
+	page = vmalloc_to_page(buf->start + (pgoff << PAGE_SHIFT));
 	if (!page)
-		return NOPAGE_OOM;
+		return VM_FAULT_SIGBUS;
 	get_page(page);
+	vmf->page = page;
 
-	if (type)
-		*type = VM_FAULT_MINOR;
-
-	return page;
+	return 0;
 }
 
 /*
  * vm_ops for relay file mappings.
  */
 static struct vm_operations_struct relay_file_mmap_ops = {
-	.nopage = relay_buf_nopage,
+	.fault = relay_buf_fault,
 	.close = relay_file_mmap_close,
 };
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1044,8 +1044,7 @@ int get_user_pages(struct task_struct *t
 		if (pages)
 			foll_flags |= FOLL_GET;
 		if (!write && !(vma->vm_flags & VM_LOCKED) &&
-		    (!vma->vm_ops || (!vma->vm_ops->nopage &&
-					!vma->vm_ops->fault)))
+		    (!vma->vm_ops || !vma->vm_ops->fault))
 			foll_flags |= FOLL_ANON;
 
 		do {
@@ -2218,20 +2217,9 @@ static int __do_fault(struct mm_struct *
 
 	BUG_ON(vma->vm_flags & VM_PFNMAP);
 
-	if (likely(vma->vm_ops->fault)) {
-		ret = vma->vm_ops->fault(vma, &vmf);
-		if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
-			return ret;
-	} else {
-		/* Legacy ->nopage path */
-		ret = 0;
-		vmf.page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
-		/* no page was available -- either SIGBUS or OOM */
-		if (unlikely(vmf.page == NOPAGE_SIGBUS))
-			return VM_FAULT_SIGBUS;
-		else if (unlikely(vmf.page == NOPAGE_OOM))
-			return VM_FAULT_OOM;
-	}
+	ret = vma->vm_ops->fault(vma, &vmf);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+		return ret;
 
 	/*
 	 * For consistency in subsequent calls, make the faulted page always
@@ -2467,7 +2455,7 @@ static inline int handle_pte_fault(struc
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
-				if (vma->vm_ops->fault || vma->vm_ops->nopage)
+				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
 						pte, pmd, write_access, entry);
 				if (unlikely(vma->vm_ops->nopfn))
Index: linux-2.6/mm/mincore.c
===================================================================
--- linux-2.6.orig/mm/mincore.c
+++ linux-2.6/mm/mincore.c
@@ -33,7 +33,7 @@ static unsigned char mincore_page(struct
 	 * When tmpfs swaps out a page from a file, any process mapping that
 	 * file will not get a swp_entry_t in its pte, but rather it is like
 	 * any other file mapping (ie. marked !present and faulted in with
-	 * tmpfs's .nopage). So swapped out tmpfs mappings are tested here.
+	 * tmpfs's .fault). So swapped out tmpfs mappings are tested here.
 	 *
 	 * However when tmpfs moves the page from pagecache and into swapcache,
 	 * it is still in core, but the find_get_page below won't find it.
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -2149,24 +2149,23 @@ int may_expand_vm(struct mm_struct *mm, 
 }
 
 
-static struct page *special_mapping_nopage(struct vm_area_struct *vma,
-					   unsigned long address, int *type)
+static int special_mapping_fault(struct vm_area_struct *vma,
+				struct vm_fault *vmf)
 {
+	pgoff_t pgoff = vmf->pgoff;
 	struct page **pages;
 
-	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-
-	address -= vma->vm_start;
-	for (pages = vma->vm_private_data; address > 0 && *pages; ++pages)
-		address -= PAGE_SIZE;
+	for (pages = vma->vm_private_data; pgoff && *pages; ++pages)
+		pgoff--;
 
 	if (*pages) {
 		struct page *page = *pages;
 		get_page(page);
-		return page;
+		vmf->page = page;
+		return 0;
 	}
 
-	return NOPAGE_SIGBUS;
+	return VM_FAULT_SIGBUS;
 }
 
 /*
@@ -2178,7 +2177,7 @@ static void special_mapping_close(struct
 
 static struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
-	.nopage	= special_mapping_nopage,
+	.fault = special_mapping_fault,
 };
 
 /*
Index: linux-2.6/arch/ia64/ia32/binfmt_elf32.c
===================================================================
--- linux-2.6.orig/arch/ia64/ia32/binfmt_elf32.c
+++ linux-2.6/arch/ia64/ia32/binfmt_elf32.c
@@ -52,33 +52,29 @@ extern struct page *ia32_shared_page[];
 extern unsigned long *ia32_gdt;
 extern struct page *ia32_gate_page;
 
-struct page *
-ia32_install_shared_page (struct vm_area_struct *vma, unsigned long address, int *type)
+int
+ia32_install_shared_page (struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct page *pg = ia32_shared_page[smp_processor_id()];
-	get_page(pg);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return pg;
-}
-
-struct page *
-ia32_install_gate_page (struct vm_area_struct *vma, unsigned long address, int *type)
-{
-	struct page *pg = ia32_gate_page;
-	get_page(pg);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return pg;
+	vmf->page = ia32_shared_page[smp_processor_id()];
+	get_page(vmf->page);
+	return 0;
+}
+
+int
+ia32_install_gate_page (struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	vmf->page = ia32_gate_page;
+	get_page(vmf->page);
+	return 0;
 }
 
 
 static struct vm_operations_struct ia32_shared_page_vm_ops = {
-	.nopage = ia32_install_shared_page
+	.fault = ia32_install_shared_page
 };
 
 static struct vm_operations_struct ia32_gate_page_vm_ops = {
-	.nopage = ia32_install_gate_page
+	.fault = ia32_install_gate_page
 };
 
 void
Index: linux-2.6/drivers/char/agp/alpha-agp.c
===================================================================
--- linux-2.6.orig/drivers/char/agp/alpha-agp.c
+++ linux-2.6/drivers/char/agp/alpha-agp.c
@@ -11,29 +11,28 @@
 
 #include "agp.h"
 
-static struct page *alpha_core_agp_vm_nopage(struct vm_area_struct *vma,
-					     unsigned long address,
-					     int *type)
+static int alpha_core_agp_vm_fault(struct vm_area_struct *vma,
+					struct vm_fault *vmf)
 {
 	alpha_agp_info *agp = agp_bridge->dev_private_data;
 	dma_addr_t dma_addr;
 	unsigned long pa;
 	struct page *page;
 
-	dma_addr = address - vma->vm_start + agp->aperture.bus_base;
+	dma_addr = (unsigned long)vmf->virtual_address - vma->vm_start
+						+ agp->aperture.bus_base;
 	pa = agp->ops->translate(agp, dma_addr);
 
 	if (pa == (unsigned long)-EINVAL)
-		return NULL;	/* no translation */
+		return VM_FAULT_SIGBUS;	/* no translation */
 
 	/*
 	 * Get the page, inc the use count, and return it
 	 */
 	page = virt_to_page(__va(pa));
 	get_page(page);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return page;
+	vmf->page = page;
+	return 0;
 }
 
 static struct aper_size_info_fixed alpha_core_agp_sizes[] =
@@ -42,7 +41,7 @@ static struct aper_size_info_fixed alpha
 };
 
 struct vm_operations_struct alpha_core_agp_vm_ops = {
-	.nopage = alpha_core_agp_vm_nopage,
+	.fault = alpha_core_agp_vm_fault,
 };
 
 
Index: linux-2.6/drivers/char/drm/drm_vm.c
===================================================================
--- linux-2.6.orig/drivers/char/drm/drm_vm.c
+++ linux-2.6/drivers/char/drm/drm_vm.c
@@ -66,7 +66,7 @@ static pgprot_t drm_io_prot(uint32_t map
 }
 
 /**
- * \c nopage method for AGP virtual memory.
+ * \c fault method for AGP virtual memory.
  *
  * \param vma virtual memory area.
  * \param address access address.
@@ -76,8 +76,8 @@ static pgprot_t drm_io_prot(uint32_t map
  * map, get the page, increment the use count and return it.
  */
 #if __OS_HAS_AGP
-static __inline__ struct page *drm_do_vm_nopage(struct vm_area_struct *vma,
-						unsigned long address)
+static __inline__ int drm_do_vm_fault(struct vm_area_struct *vma,
+						struct vm_fault *vmf)
 {
 	struct drm_file *priv = vma->vm_file->private_data;
 	struct drm_device *dev = priv->head->dev;
@@ -89,19 +89,24 @@ static __inline__ struct page *drm_do_vm
 	 * Find the right map
 	 */
 	if (!drm_core_has_AGP(dev))
-		goto vm_nopage_error;
+		goto vm_fault_error;
 
 	if (!dev->agp || !dev->agp->cant_use_aperture)
-		goto vm_nopage_error;
+		goto vm_fault_error;
 
 	if (drm_ht_find_item(&dev->map_hash, vma->vm_pgoff, &hash))
-		goto vm_nopage_error;
+		goto vm_fault_error;
 
 	r_list = drm_hash_entry(hash, struct drm_map_list, hash);
 	map = r_list->map;
 
 	if (map && map->type == _DRM_AGP) {
-		unsigned long offset = address - vma->vm_start;
+		/*
+		 * Using vm_pgoff as a selector forces us to use this unusual
+		 * addressing scheme.
+		 */
+		unsigned long offset = (unsigned long)vmf->virtual_address -
+								vma->vm_start;
 		unsigned long baddr = map->offset + offset;
 		struct drm_agp_mem *agpmem;
 		struct page *page;
@@ -123,7 +128,7 @@ static __inline__ struct page *drm_do_vm
 		}
 
 		if (!agpmem)
-			goto vm_nopage_error;
+			goto vm_fault_error;
 
 		/*
 		 * Get the page, inc the use count, and return it
@@ -131,27 +136,28 @@ static __inline__ struct page *drm_do_vm
 		offset = (baddr - agpmem->bound) >> PAGE_SHIFT;
 		page = virt_to_page(__va(agpmem->memory->memory[offset]));
 		get_page(page);
+		vmf->page = page;
 
 		DRM_DEBUG
 		    ("baddr = 0x%lx page = 0x%p, offset = 0x%lx, count=%d\n",
 		     baddr, __va(agpmem->memory->memory[offset]), offset,
 		     page_count(page));
 
-		return page;
+		return 0;
 	}
-      vm_nopage_error:
-	return NOPAGE_SIGBUS;	/* Disallow mremap */
+      vm_fault_error:
+	return VM_FAULT_SIGBUS;	/* Disallow mremap */
 }
 #else				/* __OS_HAS_AGP */
-static __inline__ struct page *drm_do_vm_nopage(struct vm_area_struct *vma,
-						unsigned long address)
+static __inline__ int drm_do_vm_fault(struct vm_area_struct *vma,
+						struct vm_fault *vmf)
 {
-	return NOPAGE_SIGBUS;
+	return VM_FAULT_SIGBUS;
 }
 #endif				/* __OS_HAS_AGP */
 
 /**
- * \c nopage method for shared virtual memory.
+ * \c fault method for shared virtual memory.
  *
  * \param vma virtual memory area.
  * \param address access address.
@@ -160,28 +166,27 @@ static __inline__ struct page *drm_do_vm
  * Get the mapping, find the real physical page to map, get the page, and
  * return it.
  */
-static __inline__ struct page *drm_do_vm_shm_nopage(struct vm_area_struct *vma,
-						    unsigned long address)
+static __inline__ int drm_do_vm_shm_fault(struct vm_area_struct *vma,
+						    struct vm_fault *vmf)
 {
 	struct drm_map *map = (struct drm_map *) vma->vm_private_data;
 	unsigned long offset;
 	unsigned long i;
 	struct page *page;
 
-	if (address > vma->vm_end)
-		return NOPAGE_SIGBUS;	/* Disallow mremap */
 	if (!map)
-		return NOPAGE_SIGBUS;	/* Nothing allocated */
+		return VM_FAULT_SIGBUS;	/* Nothing allocated */
 
-	offset = address - vma->vm_start;
+	offset = (unsigned long)vmf->virtual_address - vma->vm_start;
 	i = (unsigned long)map->handle + offset;
 	page = vmalloc_to_page((void *)i);
 	if (!page)
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	get_page(page);
+	vmf->page = page;
 
-	DRM_DEBUG("shm_nopage 0x%lx\n", address);
-	return page;
+	DRM_DEBUG("shm_fault 0x%lx\n", offset);
+	return 0;
 }
 
 /**
@@ -263,7 +268,7 @@ static void drm_vm_shm_close(struct vm_a
 }
 
 /**
- * \c nopage method for DMA virtual memory.
+ * \c fault method for DMA virtual memory.
  *
  * \param vma virtual memory area.
  * \param address access address.
@@ -271,8 +276,8 @@ static void drm_vm_shm_close(struct vm_a
  *
  * Determine the page number from the page offset and get it from drm_device_dma::pagelist.
  */
-static __inline__ struct page *drm_do_vm_dma_nopage(struct vm_area_struct *vma,
-						    unsigned long address)
+static __inline__ int drm_do_vm_dma_fault(struct vm_area_struct *vma,
+						    struct vm_fault *vmf)
 {
 	struct drm_file *priv = vma->vm_file->private_data;
 	struct drm_device *dev = priv->head->dev;
@@ -282,24 +287,23 @@ static __inline__ struct page *drm_do_vm
 	struct page *page;
 
 	if (!dma)
-		return NOPAGE_SIGBUS;	/* Error */
-	if (address > vma->vm_end)
-		return NOPAGE_SIGBUS;	/* Disallow mremap */
+		return VM_FAULT_SIGBUS;	/* Error */
 	if (!dma->pagelist)
-		return NOPAGE_SIGBUS;	/* Nothing allocated */
+		return VM_FAULT_SIGBUS;	/* Nothing allocated */
 
-	offset = address - vma->vm_start;	/* vm_[pg]off[set] should be 0 */
-	page_nr = offset >> PAGE_SHIFT;
+	offset = (unsigned long)vmf->virtual_address - vma->vm_start;	/* vm_[pg]off[set] should be 0 */
+	page_nr = offset >> PAGE_SHIFT; /* page_nr could just be vmf->pgoff */
 	page = virt_to_page((dma->pagelist[page_nr] + (offset & (~PAGE_MASK))));
 
 	get_page(page);
+	vmf->page = page;
 
-	DRM_DEBUG("dma_nopage 0x%lx (page %lu)\n", address, page_nr);
-	return page;
+	DRM_DEBUG("dma_fault 0x%lx (page %lu)\n", offset, page_nr);
+	return 0;
 }
 
 /**
- * \c nopage method for scatter-gather virtual memory.
+ * \c fault method for scatter-gather virtual memory.
  *
  * \param vma virtual memory area.
  * \param address access address.
@@ -307,8 +311,8 @@ static __inline__ struct page *drm_do_vm
  *
  * Determine the map offset from the page offset and get it from drm_sg_mem::pagelist.
  */
-static __inline__ struct page *drm_do_vm_sg_nopage(struct vm_area_struct *vma,
-						   unsigned long address)
+static __inline__ int drm_do_vm_sg_fault(struct vm_area_struct *vma,
+						   struct vm_fault *vmf)
 {
 	struct drm_map *map = (struct drm_map *) vma->vm_private_data;
 	struct drm_file *priv = vma->vm_file->private_data;
@@ -320,77 +324,64 @@ static __inline__ struct page *drm_do_vm
 	struct page *page;
 
 	if (!entry)
-		return NOPAGE_SIGBUS;	/* Error */
-	if (address > vma->vm_end)
-		return NOPAGE_SIGBUS;	/* Disallow mremap */
+		return VM_FAULT_SIGBUS;	/* Error */
 	if (!entry->pagelist)
-		return NOPAGE_SIGBUS;	/* Nothing allocated */
+		return VM_FAULT_SIGBUS;	/* Nothing allocated */
 
-	offset = address - vma->vm_start;
+	offset = (unsigned long)vmf->virtual_address - vma->vm_start;
 	map_offset = map->offset - (unsigned long)dev->sg->virtual;
 	page_offset = (offset >> PAGE_SHIFT) + (map_offset >> PAGE_SHIFT);
 	page = entry->pagelist[page_offset];
 	get_page(page);
+	vmf->page = page;
 
-	return page;
+	return 0;
 }
 
-static struct page *drm_vm_nopage(struct vm_area_struct *vma,
-				  unsigned long address, int *type)
+static int drm_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return drm_do_vm_nopage(vma, address);
+	return drm_do_vm_fault(vma, vmf);
 }
 
-static struct page *drm_vm_shm_nopage(struct vm_area_struct *vma,
-				      unsigned long address, int *type)
+static int drm_vm_shm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return drm_do_vm_shm_nopage(vma, address);
+	return drm_do_vm_shm_fault(vma, vmf);
 }
 
-static struct page *drm_vm_dma_nopage(struct vm_area_struct *vma,
-				      unsigned long address, int *type)
+static int drm_vm_dma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return drm_do_vm_dma_nopage(vma, address);
+	return drm_do_vm_dma_fault(vma, vmf);
 }
 
-static struct page *drm_vm_sg_nopage(struct vm_area_struct *vma,
-				     unsigned long address, int *type)
+static int drm_vm_sg_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return drm_do_vm_sg_nopage(vma, address);
+	return drm_do_vm_sg_fault(vma, vmf);
 }
 
 /** AGP virtual memory operations */
 static struct vm_operations_struct drm_vm_ops = {
-	.nopage = drm_vm_nopage,
+	.fault = drm_vm_fault,
 	.open = drm_vm_open,
 	.close = drm_vm_close,
 };
 
 /** Shared virtual memory operations */
 static struct vm_operations_struct drm_vm_shm_ops = {
-	.nopage = drm_vm_shm_nopage,
+	.fault = drm_vm_shm_fault,
 	.open = drm_vm_open,
 	.close = drm_vm_shm_close,
 };
 
 /** DMA virtual memory operations */
 static struct vm_operations_struct drm_vm_dma_ops = {
-	.nopage = drm_vm_dma_nopage,
+	.fault = drm_vm_dma_fault,
 	.open = drm_vm_open,
 	.close = drm_vm_close,
 };
 
 /** Scatter-gather virtual memory operations */
 static struct vm_operations_struct drm_vm_sg_ops = {
-	.nopage = drm_vm_sg_nopage,
+	.fault = drm_vm_sg_fault,
 	.open = drm_vm_open,
 	.close = drm_vm_close,
 };
@@ -603,7 +594,7 @@ static int drm_mmap_locked(struct file *
 			/*
 			 * On some platforms we can't talk to bus dma address from the CPU, so for
 			 * memory of type DRM_AGP, we'll deal with sorting out the real physical
-			 * pages and mappings in nopage()
+			 * pages and mappings in fault()
 			 */
 #if defined(__powerpc__)
 			pgprot_val(vma->vm_page_prot) |= _PAGE_NO_CACHE;
@@ -633,7 +624,7 @@ static int drm_mmap_locked(struct file *
 		break;
 	case _DRM_CONSISTENT:
 		/* Consistent memory is really like shared memory. But
-		 * it's allocated in a different way, so avoid nopage */
+		 * it's allocated in a different way, so avoid fault */
 		if (remap_pfn_range(vma, vma->vm_start,
 		    page_to_pfn(virt_to_page(map->handle)),
 		    vma->vm_end - vma->vm_start, vma->vm_page_prot))
Index: linux-2.6/drivers/ieee1394/dma.c
===================================================================
--- linux-2.6.orig/drivers/ieee1394/dma.c
+++ linux-2.6/drivers/ieee1394/dma.c
@@ -231,37 +231,32 @@ void dma_region_sync_for_device(struct d
 
 #ifdef CONFIG_MMU
 
-/* nopage() handler for mmap access */
+/* fault() handler for mmap access */
 
-static struct page *dma_region_pagefault(struct vm_area_struct *area,
-					 unsigned long address, int *type)
+static int dma_region_pagefault(struct vm_area_struct *vma,
+					struct vm_fault *vmf)
 {
-	unsigned long offset;
 	unsigned long kernel_virt_addr;
-	struct page *ret = NOPAGE_SIGBUS;
 
-	struct dma_region *dma = (struct dma_region *)area->vm_private_data;
+	struct dma_region *dma = (struct dma_region *)vma->vm_private_data;
 
 	if (!dma->kvirt)
-		goto out;
+		goto error;
 
-	if ((address < (unsigned long)area->vm_start) ||
-	    (address >
-	     (unsigned long)area->vm_start + (dma->n_pages << PAGE_SHIFT)))
-		goto out;
-
-	if (type)
-		*type = VM_FAULT_MINOR;
-	offset = address - area->vm_start;
-	kernel_virt_addr = (unsigned long)dma->kvirt + offset;
-	ret = vmalloc_to_page((void *)kernel_virt_addr);
-	get_page(ret);
-      out:
-	return ret;
+	if (vmf->pgoff >= dma->n_pages)
+		goto error;
+
+	kernel_virt_addr = (unsigned long)dma->kvirt + (vmf->pgoff << PAGE_SHIFT);
+	vmf->page = vmalloc_to_page((void *)kernel_virt_addr);
+	get_page(vmf->page);
+	return 0;
+
+      error:
+	return VM_FAULT_SIGBUS;
 }
 
 static struct vm_operations_struct dma_region_vm_ops = {
-	.nopage = dma_region_pagefault,
+	.fault = dma_region_pagefault,
 };
 
 /**
@@ -275,7 +270,7 @@ int dma_region_mmap(struct dma_region *d
 	if (!dma->kvirt)
 		return -EINVAL;
 
-	/* must be page-aligned */
+	/* must be page-aligned (XXX: comment is wrong, we could allow pgoff) */
 	if (vma->vm_pgoff != 0)
 		return -EINVAL;
 
Index: linux-2.6/drivers/infiniband/hw/ipath/ipath_file_ops.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ linux-2.6/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -1120,33 +1120,24 @@ bail:
 }
 
 /*
- * ipath_file_vma_nopage - handle a VMA page fault.
+ * ipath_file_vma_fault - handle a VMA page fault.
  */
-static struct page *ipath_file_vma_nopage(struct vm_area_struct *vma,
-					  unsigned long address, int *type)
+static int ipath_file_vma_fault(struct vm_area_struct *vma,
+					struct vm_fault *vmf)
 {
-	unsigned long offset = address - vma->vm_start;
-	struct page *page = NOPAGE_SIGBUS;
-	void *pageptr;
+	struct page *page;
 
-	/*
-	 * Convert the vmalloc address into a struct page.
-	 */
-	pageptr = (void *)(offset + (vma->vm_pgoff << PAGE_SHIFT));
-	page = vmalloc_to_page(pageptr);
+	page = vmalloc_to_page((void *)vmf->pgoff);
 	if (!page)
-		goto out;
-
-	/* Increment the reference count. */
+		return VM_FAULT_SIGBUS;
 	get_page(page);
-	if (type)
-		*type = VM_FAULT_MINOR;
-out:
-	return page;
+	vmf->page = page;
+
+	return 0;
 }
 
 static struct vm_operations_struct ipath_file_vm_ops = {
-	.nopage = ipath_file_vma_nopage,
+	.fault = ipath_file_vma_fault,
 };
 
 static int mmap_kvaddr(struct vm_area_struct *vma, u64 pgaddr,
Index: linux-2.6/drivers/kvm/kvm_main.c
===================================================================
--- linux-2.6.orig/drivers/kvm/kvm_main.c
+++ linux-2.6/drivers/kvm/kvm_main.c
@@ -2534,30 +2534,24 @@ static int kvm_vcpu_ioctl_debug_guest(st
 	return r;
 }
 
-static struct page *kvm_vcpu_nopage(struct vm_area_struct *vma,
-				    unsigned long address,
-				    int *type)
+static int kvm_vcpu_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct kvm_vcpu *vcpu = vma->vm_file->private_data;
-	unsigned long pgoff;
 	struct page *page;
 
-	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	if (pgoff == 0)
+	if (vmf->pgoff == 0)
 		page = virt_to_page(vcpu->run);
-	else if (pgoff == KVM_PIO_PAGE_OFFSET)
+	else if (vmf->pgoff == KVM_PIO_PAGE_OFFSET)
 		page = virt_to_page(vcpu->pio_data);
 	else
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	get_page(page);
-	if (type != NULL)
-		*type = VM_FAULT_MINOR;
-
-	return page;
+	vmf->page = page;
+	return 0;
 }
 
 static struct vm_operations_struct kvm_vcpu_vm_ops = {
-	.nopage = kvm_vcpu_nopage,
+	.fault = kvm_vcpu_fault,
 };
 
 static int kvm_vcpu_mmap(struct file *file, struct vm_area_struct *vma)
@@ -3112,27 +3106,21 @@ out:
 	return r;
 }
 
-static struct page *kvm_vm_nopage(struct vm_area_struct *vma,
-				  unsigned long address,
-				  int *type)
+static int kvm_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct kvm *kvm = vma->vm_file->private_data;
-	unsigned long pgoff;
 	struct page *page;
 
-	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	page = gfn_to_page(kvm, pgoff);
+	page = gfn_to_page(kvm, vmf->pgoff);
 	if (!page)
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	get_page(page);
-	if (type != NULL)
-		*type = VM_FAULT_MINOR;
-
-	return page;
+	vmf->page = page;
+	return 0;
 }
 
 static struct vm_operations_struct kvm_vm_vm_ops = {
-	.nopage = kvm_vm_nopage,
+	.fault = kvm_vm_fault,
 };
 
 static int kvm_vm_mmap(struct file *file, struct vm_area_struct *vma)
Index: linux-2.6/drivers/media/video/videobuf-dma-sg.c
===================================================================
--- linux-2.6.orig/drivers/media/video/videobuf-dma-sg.c
+++ linux-2.6/drivers/media/video/videobuf-dma-sg.c
@@ -385,30 +385,26 @@ videobuf_vm_close(struct vm_area_struct 
  * now ...).  Bounce buffers don't work very well for the data rates
  * video capture has.
  */
-static struct page*
-videobuf_vm_nopage(struct vm_area_struct *vma, unsigned long vaddr,
-		   int *type)
+static int
+videobuf_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page *page;
 
-	dprintk(3,"nopage: fault @ %08lx [vma %08lx-%08lx]\n",
-		vaddr,vma->vm_start,vma->vm_end);
-	if (vaddr > vma->vm_end)
-		return NOPAGE_SIGBUS;
+	dprintk(3,"fault: fault @ %08lx [vma %08lx-%08lx]\n",
+		(unsigned long)vmf->virtual_address,vma->vm_start,vma->vm_end);
 	page = alloc_page(GFP_USER | __GFP_DMA32);
 	if (!page)
-		return NOPAGE_OOM;
+		return VM_FAULT_OOM;
 	clear_user_page(page_address(page), vaddr, page);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return page;
+	vmf->page = page;
+	return 0;
 }
 
 static struct vm_operations_struct videobuf_vm_ops =
 {
 	.open     = videobuf_vm_open,
 	.close    = videobuf_vm_close,
-	.nopage   = videobuf_vm_nopage,
+	.fault    = videobuf_vm_fault,
 };
 
 /* ---------------------------------------------------------------------
Index: linux-2.6/drivers/scsi/sg.c
===================================================================
--- linux-2.6.orig/drivers/scsi/sg.c
+++ linux-2.6/drivers/scsi/sg.c
@@ -1144,23 +1144,22 @@ sg_fasync(int fd, struct file *filp, int
 	return (retval < 0) ? retval : 0;
 }
 
-static struct page *
-sg_vma_nopage(struct vm_area_struct *vma, unsigned long addr, int *type)
+static int
+sg_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	Sg_fd *sfp;
-	struct page *page = NOPAGE_SIGBUS;
 	unsigned long offset, len, sa;
 	Sg_scatter_hold *rsv_schp;
 	struct scatterlist *sg;
 	int k;
 
 	if ((NULL == vma) || (!(sfp = (Sg_fd *) vma->vm_private_data)))
-		return page;
+		return VM_FAULT_SIGBUS;
 	rsv_schp = &sfp->reserve;
-	offset = addr - vma->vm_start;
+	offset = vmf->pgoff << PAGE_SHIFT;
 	if (offset >= rsv_schp->bufflen)
-		return page;
-	SCSI_LOG_TIMEOUT(3, printk("sg_vma_nopage: offset=%lu, scatg=%d\n",
+		return VM_FAULT_SIGBUS;
+	SCSI_LOG_TIMEOUT(3, printk("sg_vma_fault: offset=%lu, scatg=%d\n",
 				   offset, rsv_schp->k_use_sg));
 	sg = rsv_schp->buffer;
 	sa = vma->vm_start;
@@ -1169,21 +1168,21 @@ sg_vma_nopage(struct vm_area_struct *vma
 		len = vma->vm_end - sa;
 		len = (len < sg->length) ? len : sg->length;
 		if (offset < len) {
+			struct page *page;
 			page = virt_to_page(page_address(sg_page(sg)) + offset);
 			get_page(page);	/* increment page count */
-			break;
+			vmf->page = page;
+			return 0; /* success */
 		}
 		sa += len;
 		offset -= len;
 	}
 
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return page;
+	return VM_FAULT_SIGBUS;
 }
 
 static struct vm_operations_struct sg_mmap_vm_ops = {
-	.nopage = sg_vma_nopage,
+	.fault = sg_vma_fault,
 };
 
 static int
Index: linux-2.6/drivers/usb/mon/mon_bin.c
===================================================================
--- linux-2.6.orig/drivers/usb/mon/mon_bin.c
+++ linux-2.6/drivers/usb/mon/mon_bin.c
@@ -1045,33 +1045,31 @@ static void mon_bin_vma_close(struct vm_
 /*
  * Map ring pages to user space.
  */
-struct page *mon_bin_vma_nopage(struct vm_area_struct *vma,
-                                unsigned long address, int *type)
+static int mon_bin_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct mon_reader_bin *rp = vma->vm_private_data;
 	unsigned long offset, chunk_idx;
 	struct page *pageptr;
 
-	offset = (address - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
+	offset = vmf->pgoff << PAGE_SHIFT;
 	if (offset >= rp->b_size)
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	chunk_idx = offset / CHUNK_SIZE;
 	pageptr = rp->b_vec[chunk_idx].pg;
 	get_page(pageptr);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return pageptr;
+	vmf->page = pageptr;
+	return 0;
 }
 
 struct vm_operations_struct mon_bin_vm_ops = {
 	.open =     mon_bin_vma_open,
 	.close =    mon_bin_vma_close,
-	.nopage =   mon_bin_vma_nopage,
+	.fault =    mon_bin_vma_fault,
 };
 
 int mon_bin_mmap(struct file *filp, struct vm_area_struct *vma)
 {
-	/* don't do anything here: "nopage" will set up page table entries */
+	/* don't do anything here: "fault" will set up page table entries */
 	vma->vm_ops = &mon_bin_vm_ops;
 	vma->vm_flags |= VM_RESERVED;
 	vma->vm_private_data = filp->private_data;
Index: linux-2.6/drivers/video/fb_defio.c
===================================================================
--- linux-2.6.orig/drivers/video/fb_defio.c
+++ linux-2.6/drivers/video/fb_defio.c
@@ -25,8 +25,8 @@
 #include <linux/pagemap.h>
 
 /* this is to find and return the vmalloc-ed fb pages */
-static struct page* fb_deferred_io_nopage(struct vm_area_struct *vma,
-					unsigned long vaddr, int *type)
+static int fb_deferred_io_fault(struct vm_area_struct *vma,
+				struct vm_fault *vmf)
 {
 	unsigned long offset;
 	struct page *page;
@@ -34,18 +34,17 @@ static struct page* fb_deferred_io_nopag
 	/* info->screen_base is in System RAM */
 	void *screen_base = (void __force *) info->screen_base;
 
-	offset = (vaddr - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
+	offset = vmf->pgoff << PAGE_SHIFT;
 	if (offset >= info->fix.smem_len)
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 
 	page = vmalloc_to_page(screen_base + offset);
 	if (!page)
-		return NOPAGE_OOM;
+		return VM_FAULT_SIGBUS;
 
 	get_page(page);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return page;
+	vmf->page = page;
+	return 0;
 }
 
 int fb_deferred_io_fsync(struct file *file, struct dentry *dentry, int datasync)
@@ -84,7 +83,7 @@ static int fb_deferred_io_mkwrite(struct
 }
 
 static struct vm_operations_struct fb_deferred_io_vm_ops = {
-	.nopage   	= fb_deferred_io_nopage,
+	.fault		= fb_deferred_io_fault,
 	.page_mkwrite	= fb_deferred_io_mkwrite,
 };
 
Index: linux-2.6/sound/core/pcm_native.c
===================================================================
--- linux-2.6.orig/sound/core/pcm_native.c
+++ linux-2.6/sound/core/pcm_native.c
@@ -3018,26 +3018,23 @@ static unsigned int snd_pcm_capture_poll
 /*
  * mmap status record
  */
-static struct page * snd_pcm_mmap_status_nopage(struct vm_area_struct *area,
-						unsigned long address, int *type)
+static int snd_pcm_mmap_status_fault(struct vm_area_struct *area,
+						struct vm_fault *vmf)
 {
 	struct snd_pcm_substream *substream = area->vm_private_data;
 	struct snd_pcm_runtime *runtime;
-	struct page * page;
 	
 	if (substream == NULL)
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	runtime = substream->runtime;
-	page = virt_to_page(runtime->status);
-	get_page(page);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return page;
+	vmf->page = virt_to_page(runtime->status);
+	get_page(vmf->page);
+	return 0;
 }
 
 static struct vm_operations_struct snd_pcm_vm_ops_status =
 {
-	.nopage =	snd_pcm_mmap_status_nopage,
+	.fault =	snd_pcm_mmap_status_fault,
 };
 
 static int snd_pcm_mmap_status(struct snd_pcm_substream *substream, struct file *file,
@@ -3061,26 +3058,23 @@ static int snd_pcm_mmap_status(struct sn
 /*
  * mmap control record
  */
-static struct page * snd_pcm_mmap_control_nopage(struct vm_area_struct *area,
-						 unsigned long address, int *type)
+static int snd_pcm_mmap_control_fault(struct vm_area_struct *area,
+						struct vm_fault *vmf)
 {
 	struct snd_pcm_substream *substream = area->vm_private_data;
 	struct snd_pcm_runtime *runtime;
-	struct page * page;
 	
 	if (substream == NULL)
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	runtime = substream->runtime;
-	page = virt_to_page(runtime->control);
-	get_page(page);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return page;
+	vmf->page = virt_to_page(runtime->control);
+	get_page(vmf->page);
+	return 0;
 }
 
 static struct vm_operations_struct snd_pcm_vm_ops_control =
 {
-	.nopage =	snd_pcm_mmap_control_nopage,
+	.fault =	snd_pcm_mmap_control_fault,
 };
 
 static int snd_pcm_mmap_control(struct snd_pcm_substream *substream, struct file *file,
@@ -3117,10 +3111,10 @@ static int snd_pcm_mmap_control(struct s
 #endif /* coherent mmap */
 
 /*
- * nopage callback for mmapping a RAM page
+ * fault callback for mmapping a RAM page
  */
-static struct page *snd_pcm_mmap_data_nopage(struct vm_area_struct *area,
-					     unsigned long address, int *type)
+static int snd_pcm_mmap_data_fault(struct vm_area_struct *area,
+						struct vm_fault *vmf)
 {
 	struct snd_pcm_substream *substream = area->vm_private_data;
 	struct snd_pcm_runtime *runtime;
@@ -3130,33 +3124,30 @@ static struct page *snd_pcm_mmap_data_no
 	size_t dma_bytes;
 	
 	if (substream == NULL)
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	runtime = substream->runtime;
-	offset = area->vm_pgoff << PAGE_SHIFT;
-	offset += address - area->vm_start;
-	snd_assert((offset % PAGE_SIZE) == 0, return NOPAGE_SIGBUS);
+	offset = vmf->pgoff << PAGE_SHIFT;
 	dma_bytes = PAGE_ALIGN(runtime->dma_bytes);
 	if (offset > dma_bytes - PAGE_SIZE)
-		return NOPAGE_SIGBUS;
+		return VM_FAULT_SIGBUS;
 	if (substream->ops->page) {
 		page = substream->ops->page(substream, offset);
-		if (! page)
-			return NOPAGE_OOM; /* XXX: is this really due to OOM? */
+		if (!page)
+			return VM_FAULT_SIGBUS;
 	} else {
 		vaddr = runtime->dma_area + offset;
 		page = virt_to_page(vaddr);
 	}
 	get_page(page);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return page;
+	vmf->page = page;
+	return 0;
 }
 
 static struct vm_operations_struct snd_pcm_vm_ops_data =
 {
 	.open =		snd_pcm_mmap_data_open,
 	.close =	snd_pcm_mmap_data_close,
-	.nopage =	snd_pcm_mmap_data_nopage,
+	.fault =	snd_pcm_mmap_data_fault,
 };
 
 /*
Index: linux-2.6/sound/oss/via82cxxx_audio.c
===================================================================
--- linux-2.6.orig/sound/oss/via82cxxx_audio.c
+++ linux-2.6/sound/oss/via82cxxx_audio.c
@@ -2099,8 +2099,7 @@ static void via_dsp_cleanup (struct via_
 }
 
 
-static struct page * via_mm_nopage (struct vm_area_struct * vma,
-				    unsigned long address, int *type)
+static int via_mm_fault (struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct via_info *card = vma->vm_private_data;
 	struct via_channel *chan = &card->ch_out;
@@ -2108,22 +2107,14 @@ static struct page * via_mm_nopage (stru
 	unsigned long pgoff;
 	int rd, wr;
 
-	DPRINTK ("ENTER, start %lXh, ofs %lXh, pgoff %ld, addr %lXh\n",
-		 vma->vm_start,
-		 address - vma->vm_start,
-		 (address - vma->vm_start) >> PAGE_SHIFT,
-		 address);
-
-        if (address > vma->vm_end) {
-		DPRINTK ("EXIT, returning NOPAGE_SIGBUS\n");
-		return NOPAGE_SIGBUS; /* Disallow mremap */
-	}
+	DPRINTK ("ENTER, pgoff %ld\n", vmf->pgoff);
+
         if (!card) {
-		DPRINTK ("EXIT, returning NOPAGE_SIGBUS\n");
-		return NOPAGE_SIGBUS;	/* Nothing allocated */
+		DPRINTK ("EXIT, returning VM_FAULT_SIGBUS\n");
+		return VM_FAULT_SIGBUS;	/* Nothing allocated */
 	}
 
-	pgoff = vma->vm_pgoff + ((address - vma->vm_start) >> PAGE_SHIFT);
+	pgoff = vmf->pgoff;
 	rd = card->ch_in.is_mapped;
 	wr = card->ch_out.is_mapped;
 
@@ -2150,9 +2141,8 @@ static struct page * via_mm_nopage (stru
 	DPRINTK ("EXIT, returning page %p for cpuaddr %lXh\n",
 		 dmapage, (unsigned long) chan->pgtbl[pgoff].cpuaddr);
 	get_page (dmapage);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return dmapage;
+	vmf->page = dmapage;
+	return 0;
 }
 
 
Index: linux-2.6/sound/usb/usx2y/usX2Yhwdep.c
===================================================================
--- linux-2.6.orig/sound/usb/usx2y/usX2Yhwdep.c
+++ linux-2.6/sound/usb/usx2y/usX2Yhwdep.c
@@ -34,34 +34,29 @@
 int usX2Y_hwdep_pcm_new(struct snd_card *card);
 
 
-static struct page * snd_us428ctls_vm_nopage(struct vm_area_struct *area, unsigned long address, int *type)
+static int snd_us428ctls_vm_fault(struct vm_area_struct *area, struct vm_fault *vmf)
 {
 	unsigned long offset;
 	struct page * page;
 	void *vaddr;
 
-	snd_printdd("ENTER, start %lXh, ofs %lXh, pgoff %ld, addr %lXh\n",
+	snd_printdd("ENTER, start %lXh, pgoff %ld\n",
 		   area->vm_start,
-		   address - area->vm_start,
-		   (address - area->vm_start) >> PAGE_SHIFT,
-		   address);
+		   vmf->pgoff);
 	
-	offset = area->vm_pgoff << PAGE_SHIFT;
-	offset += address - area->vm_start;
-	snd_assert((offset % PAGE_SIZE) == 0, return NOPAGE_SIGBUS);
+	offset = vmf->pgoff << PAGE_SHIFT;
 	vaddr = (char*)((struct usX2Ydev *)area->vm_private_data)->us428ctls_sharedmem + offset;
 	page = virt_to_page(vaddr);
 	get_page(page);
-	snd_printdd( "vaddr=%p made us428ctls_vm_nopage() return %p; offset=%lX\n", vaddr, page, offset);
+	vmf->page = page;
 
-	if (type)
-		*type = VM_FAULT_MINOR;
+	snd_printdd( "vaddr=%p made us428ctls_vm_fault() page %p\n", vaddr, page);
 
-	return page;
+	return 0;
 }
 
 static struct vm_operations_struct us428ctls_vm_ops = {
-	.nopage = snd_us428ctls_vm_nopage,
+	.fault = snd_us428ctls_vm_fault,
 };
 
 static int snd_us428ctls_mmap(struct snd_hwdep * hw, struct file *filp, struct vm_area_struct *area)
Index: linux-2.6/sound/usb/usx2y/usx2yhwdeppcm.c
===================================================================
--- linux-2.6.orig/sound/usb/usx2y/usx2yhwdeppcm.c
+++ linux-2.6/sound/usb/usx2y/usx2yhwdeppcm.c
@@ -683,30 +683,23 @@ static void snd_usX2Y_hwdep_pcm_vm_close
 }
 
 
-static struct page * snd_usX2Y_hwdep_pcm_vm_nopage(struct vm_area_struct *area, unsigned long address, int *type)
+static int snd_usX2Y_hwdep_pcm_vm_fault(struct vm_area_struct *area, struct vm_fault *vmf)
 {
 	unsigned long offset;
-	struct page *page;
 	void *vaddr;
 
-	offset = area->vm_pgoff << PAGE_SHIFT;
-	offset += address - area->vm_start;
-	snd_assert((offset % PAGE_SIZE) == 0, return NOPAGE_OOM);
+	offset = vmf->pgoff << PAGE_SHIFT;
 	vaddr = (char*)((struct usX2Ydev *)area->vm_private_data)->hwdep_pcm_shm + offset;
-	page = virt_to_page(vaddr);
-	get_page(page);
-
-	if (type)
-		*type = VM_FAULT_MINOR;
-
-	return page;
+	vmf->page = virt_to_page(vaddr);
+	get_page(vmf->page);
+	return 0;
 }
 
 
 static struct vm_operations_struct snd_usX2Y_hwdep_pcm_vm_ops = {
 	.open = snd_usX2Y_hwdep_pcm_vm_open,
 	.close = snd_usX2Y_hwdep_pcm_vm_close,
-	.nopage = snd_usX2Y_hwdep_pcm_vm_nopage,
+	.fault = snd_usX2Y_hwdep_pcm_vm_fault,
 };
 
 
Index: linux-2.6/Documentation/fb/deferred_io.txt
===================================================================
--- linux-2.6.orig/Documentation/fb/deferred_io.txt
+++ linux-2.6/Documentation/fb/deferred_io.txt
@@ -7,10 +7,10 @@ IO. The following example may be a usefu
 works:
 
 - userspace app like Xfbdev mmaps framebuffer
-- deferred IO and driver sets up nopage and page_mkwrite handlers
+- deferred IO and driver sets up fault and page_mkwrite handlers
 - userspace app tries to write to mmaped vaddress
-- we get pagefault and reach nopage handler
-- nopage handler finds and returns physical page
+- we get pagefault and reach fault handler
+- fault handler finds and returns physical page
 - we get page_mkwrite where we add this page to a list
 - schedule a workqueue task to be run after a delay
 - app continues writing to that page with no additional cost. this is
Index: linux-2.6/Documentation/feature-removal-schedule.txt
===================================================================
--- linux-2.6.orig/Documentation/feature-removal-schedule.txt
+++ linux-2.6/Documentation/feature-removal-schedule.txt
@@ -172,15 +172,6 @@ Who:	Greg Kroah-Hartman <gregkh@suse.de>
 
 ---------------------------
 
-What:	vm_ops.nopage
-When:	Soon, provided in-kernel callers have been converted
-Why:	This interface is replaced by vm_ops.fault, but it has been around
-	forever, is used by a lot of drivers, and doesn't cost much to
-	maintain.
-Who:	Nick Piggin <npiggin@suse.de>
-
----------------------------
-
 What:	Interrupt only SA_* flags
 When:	September 2007
 Why:	The interrupt related SA_* flags are replaced by IRQF_* to move them
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -514,7 +514,6 @@ prototypes:
 	void (*open)(struct vm_area_struct*);
 	void (*close)(struct vm_area_struct*);
 	int (*fault)(struct vm_area_struct*, struct vm_fault *);
-	struct page *(*nopage)(struct vm_area_struct*, unsigned long, int *);
 	int (*page_mkwrite)(struct vm_area_struct *, struct page *);
 
 locking rules:
@@ -522,7 +521,6 @@ locking rules:
 open:		no	yes
 close:		no	yes
 fault:		no	yes
-nopage:		no	yes
 page_mkwrite:	no	yes		no
 
 	->page_mkwrite() is called when a previously read-only page is
@@ -540,4 +538,3 @@ NULL.
 
 ipc/shm.c::shm_delete() - may need BKL.
 ->read() and ->write() in many drivers are (probably) missing BKL.
-drivers/sgi/char/graphics.c::sgi_graphics_nopage() - may need BKL.
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -621,7 +621,6 @@ void page_remove_rmap(struct page *page,
 			printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
 			print_symbol (KERN_EMERG "  vma->vm_ops = %s\n", (unsigned long)vma->vm_ops);
 			if (vma->vm_ops) {
-				print_symbol (KERN_EMERG "  vma->vm_ops->nopage = %s\n", (unsigned long)vma->vm_ops->nopage);
 				print_symbol (KERN_EMERG "  vma->vm_ops->fault = %s\n", (unsigned long)vma->vm_ops->fault);
 			}
 			if (vma->vm_file && vma->vm_file->f_op)
Index: linux-2.6/drivers/uio/uio.c
===================================================================
--- linux-2.6.orig/drivers/uio/uio.c
+++ linux-2.6/drivers/uio/uio.c
@@ -412,30 +412,28 @@ static void uio_vma_close(struct vm_area
 	idev->vma_count--;
 }
 
-static struct page *uio_vma_nopage(struct vm_area_struct *vma,
-				   unsigned long address, int *type)
+static int uio_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct uio_device *idev = vma->vm_private_data;
-	struct page* page = NOPAGE_SIGBUS;
+	struct page *page;
 
 	int mi = uio_find_mem_index(vma);
 	if (mi < 0)
-		return page;
+		return VM_FAULT_SIGBUS;
 
 	if (idev->info->mem[mi].memtype == UIO_MEM_LOGICAL)
 		page = virt_to_page(idev->info->mem[mi].addr);
 	else
 		page = vmalloc_to_page((void*)idev->info->mem[mi].addr);
 	get_page(page);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return page;
+	vmf->page = page;
+	return 0;
 }
 
 static struct vm_operations_struct uio_vm_ops = {
 	.open = uio_vma_open,
 	.close = uio_vma_close,
-	.nopage = uio_vma_nopage,
+	.fault = uio_vma_fault,
 };
 
 static int uio_mmap_physical(struct vm_area_struct *vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
