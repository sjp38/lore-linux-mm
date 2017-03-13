Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5064B6B03AC
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:15:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u108so46668774wrb.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:15:12 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 12/13] mm/vas: Add lazy-attach support for first class virtual address spaces
Date: Mon, 13 Mar 2017 15:14:14 -0700
Message-Id: <20170313221415.9375-13-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

Until now, whenever a task attaches a first class virtual address space,
all the memory regions currently present in the task are replicated into
the first class virtual address space so that the task can continue
executing as if nothing has changed. However, this technique causes the
attach and detach operations to be very costly, since the whole memory map
of the task has to be duplicated.

Lazy-attaching on the other side uses a similar technique as it is done to
copy page tables during fork. Instead of completely duplicating the memory
map of the task together with its page tables, only a skeleton memory map
is created and then later filled with content when a page fault is
triggered when the process actually accesses the memory regions. The big
advantage is, that unnecessary memory regions are not duplicated at all,
but just those that the process actually uses while executing inside the
first class virtual address space. The only memory region which is always
duplicated during the attach-operation is the code memory section, because
this memory region is always necessary for execution and saves us one page
fault later during the process execution.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
---
 include/linux/mm_types.h |   1 +
 include/linux/vas.h      |  26 ++++++++
 mm/Kconfig               |  18 ++++++
 mm/memory.c              |   5 ++
 mm/vas.c                 | 164 ++++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 197 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 82bf78ea83ee..65e04f14225d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -362,6 +362,7 @@ struct vm_area_struct {
 #ifdef CONFIG_VAS
 	struct mm_struct *vas_reference;
 	ktime_t vas_last_update;
+	bool vas_attached;
 #endif
 };
 
diff --git a/include/linux/vas.h b/include/linux/vas.h
index 376b9fa1ee27..8682bfc86568 100644
--- a/include/linux/vas.h
+++ b/include/linux/vas.h
@@ -2,6 +2,7 @@
 #define _LINUX_VAS_H
 
 
+#include <linux/mm_types.h>
 #include <linux/sched.h>
 #include <linux/vas_types.h>
 
@@ -293,4 +294,29 @@ static inline int vas_exit(struct task_struct *tsk) { return 0; }
 
 #endif /* CONFIG_VAS */
 
+
+/***
+ * Management of the VAS lazy attaching
+ ***/
+
+#ifdef CONFIG_VAS_LAZY_ATTACH
+
+/**
+ * Lazily update the page tables of a vm_area which was not completely setup
+ * during the VAS attaching.
+ *
+ * @param[in] vma:		The vm_area for which the page tables should be
+ *				setup before continuing the page fault handling.
+ *
+ * @returns:			0 of the lazy-attach was successful or not
+ *				necessary, or 1 if something went wrong.
+ */
+extern int vas_lazy_attach_vma(struct vm_area_struct *vma);
+
+#else /* CONFIG_VAS_LAZY_ATTACH */
+
+static inline int vas_lazy_attach_vma(struct vm_area_struct *vma) { return 0; }
+
+#endif /* CONFIG_VAS_LAZY_ATTACH */
+
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 9a80877f3536..934c56bcdbf4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -720,6 +720,24 @@ config VAS
 
 	  If not sure, then say N.
 
+config VAS_LAZY_ATTACH
+	bool "Use lazy-attach for First Class Virtual Address Spaces"
+	depends on VAS
+	default y
+	help
+	  When this option is enabled, memory regions of First Class Virtual 
+	  Address Spaces will be mapped in the task's address space lazily after
+	  the switch happened. That means, the actual mapping will happen when a
+	  page fault occurs for the particular memory region. While this
+	  technique is less costly during the switching operation, it can become
+	  very costly during the page fault handling.
+
+	  Hence if the program uses a lot of different memory regions, this
+	  lazy-attaching technique can be more costly than doing the mapping
+	  eagerly during the switch.
+
+	  If not sure, then say Y.
+
 config VAS_DEBUG
 	bool "Debugging output for First Class Virtual Address Spaces"
 	depends on VAS
diff --git a/mm/memory.c b/mm/memory.c
index e4747b3fd5b9..cdefc99a50ac 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -64,6 +64,7 @@
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
+#include <linux/vas.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -4000,6 +4001,10 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	/* do counter updates before entering really critical section. */
 	check_sync_rss_stat(current);
 
+	/* Check if this VMA belongs to a VAS and needs to be lazy attached. */
+	if (unlikely(vas_lazy_attach_vma(vma)))
+		return VM_FAULT_SIGSEGV;
+
 	/*
 	 * Enable the memcg OOM handling for faults triggered in user
 	 * space.  Kernel faults are handled more gracefully.
diff --git a/mm/vas.c b/mm/vas.c
index 345b023c21aa..953ba8d6e603 100644
--- a/mm/vas.c
+++ b/mm/vas.c
@@ -138,12 +138,13 @@ static void __dump_memory_map(const char *title, struct mm_struct *mm)
 		else
 			pr_cont(" OTHER ");
 
-		pr_cont("%c%c%c%c [%c]",
+		pr_cont("%c%c%c%c [%c:%c]",
 			vma->vm_flags & VM_READ ? 'r' : '-',
 			vma->vm_flags & VM_WRITE ? 'w' : '-',
 			vma->vm_flags & VM_EXEC ? 'x' : '-',
 			vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
-			vma->vas_reference ? 'v' : '-');
+			vma->vas_reference ? 'v' : '-',
+			vma->vas_attached ? 'a' : '-');
 
 		if (vma->vm_file) {
 			struct file *f = vma->vm_file;
@@ -883,6 +884,43 @@ static inline void vas_seg_put_share(int type, struct vas_seg *seg)
 }
 
 /**
+ * Identifying special regions of a memory map.
+ **/
+static inline unsigned long round_up_to_page(unsigned long addr)
+{
+	return PAGE_ALIGNED(addr) ? addr : ((addr & PAGE_MASK) + PAGE_SIZE);
+}
+
+static inline unsigned long round_down_to_page(unsigned long addr)
+{
+	return (addr & PAGE_MASK);
+}
+
+static inline bool is_code_region(struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	return ((vma->vm_start >= round_down_to_page(mm->start_code)) &&
+		(vma->vm_end <= round_up_to_page(mm->end_code)));
+}
+
+static inline bool is_data_region(struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	return ((vma->vm_start >= round_down_to_page(mm->start_data)) &&
+		(vma->vm_end <= round_up_to_page(mm->end_data)));
+}
+
+static inline bool is_heap_region(struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	return ((vma->vm_start >= round_down_to_page(mm->start_brk)) &&
+		(vma->vm_end <= round_up_to_page(mm->brk)));
+}
+
+/**
  * Management of the memory maps.
  **/
 static int init_vas_mm(struct vas *vas)
@@ -1070,7 +1108,8 @@ static inline
 struct vm_area_struct *__copy_vm_area(struct mm_struct *src_mm,
 				      struct vm_area_struct *src_vma,
 				      struct mm_struct *dst_mm,
-				      unsigned long vm_flags)
+				      unsigned long vm_flags,
+				      bool dup_pages)
 {
 	struct vm_area_struct *vma, *prev;
 	struct rb_node **rb_link, *rb_parent;
@@ -1105,11 +1144,13 @@ struct vm_area_struct *__copy_vm_area(struct mm_struct *src_mm,
 	if (vma->vm_ops && vma->vm_ops->open)
 		vma->vm_ops->open(vma);
 	vma->vas_last_update = src_vma->vas_last_update;
+	vma->vas_attached = dup_pages;
 
 	vma_link(dst_mm, vma, prev, rb_link, rb_parent);
 
 	vm_stat_account(dst_mm, vma->vm_flags, vma_pages(vma));
-	if (unlikely(dup_page_range(dst_mm, vma, src_mm, src_vma)))
+	if (dup_pages &&
+	    unlikely(dup_page_range(dst_mm, vma, src_mm, src_vma)))
 		pr_vas_debug("Failed to copy page table for VMA %p from %p\n",
 			     vma, src_vma);
 
@@ -1199,7 +1240,7 @@ struct vm_area_struct *__update_vm_area(struct mm_struct *src_mm,
 		}
 
 		dst_vma = __copy_vm_area(src_mm, src_vma, dst_mm,
-					 orig_vm_flags);
+					 orig_vm_flags, true);
 		if (!dst_vma)
 			goto out;
 
@@ -1264,7 +1305,7 @@ static int vas_merge(struct att_vas *avas, struct vas *vas, int type)
 			merged_vm_flags &= ~(VM_WRITE | VM_MAYWRITE);
 
 		new_vma = __copy_vm_area(vas_mm, vma, avas_mm,
-					 merged_vm_flags);
+					 merged_vm_flags, true);
 		if (!new_vma) {
 			pr_vas_debug("Failed to merge a VAS memory region (%#lx - %#lx)\n",
 				     vma->vm_start, vma->vm_end);
@@ -1337,7 +1378,7 @@ static int vas_unmerge(struct att_vas *avas, struct vas *vas)
 				     vma->vm_start, vma->vm_end);
 
 			new_vma = __copy_vm_area(avas_mm, vma, vas_mm,
-						 vma->vm_flags);
+						 vma->vm_flags, true);
 			if (!new_vma) {
 				pr_vas_debug("Failed to unmerge a new VAS memory region (%#lx - %#lx)\n",
 					     vma->vm_start, vma->vm_end);
@@ -1346,7 +1387,8 @@ static int vas_unmerge(struct att_vas *avas, struct vas *vas)
 			}
 
 			new_vma->vas_reference = NULL;
-		} else {
+			new_vma->vas_attached = false;
+		} else if (vma->vas_attached) {
 			struct vm_area_struct *upd_vma;
 
 			/*
@@ -1365,6 +1407,9 @@ static int vas_unmerge(struct att_vas *avas, struct vas *vas)
 				ret = -EFAULT;
 				goto out_unlock;
 			}
+		} else {
+			pr_vas_debug("Skip not-attached memory region (%#lx - %#lx) during VAS unmerging\n",
+				     vma->vm_start, vma->vm_end);
 		}
 
 		/* Remove the current VMA from the attached-VAS memory map. */
@@ -1389,10 +1434,16 @@ static int vas_unmerge(struct att_vas *avas, struct vas *vas)
  *			contains all the information for this attachment.
  * @param[in] tsk:	The pointer to the task of which the memory map
  *			should be merged.
+ * @param[in] default_copy_eagerly:
+ *			How should all the memory regions except the code region
+ *			be handled. If true, their page tables will be
+ *			duplicated as well, if false they will not be
+ *			duplicated.
  *
  * @returns:		0 on success, -ERRNO otherwise.
  **/
-static int task_merge(struct att_vas *avas, struct task_struct *tsk)
+static int _task_merge(struct att_vas *avas, struct task_struct *tsk,
+		       bool default_copy_eagerly)
 {
 	struct vm_area_struct *vma, *new_vma;
 	struct mm_struct *avas_mm, *tsk_mm;
@@ -1413,10 +1464,23 @@ static int task_merge(struct att_vas *avas, struct task_struct *tsk)
 	 * map to the attached-VAS memory map.
 	 */
 	for (vma = tsk_mm->mmap; vma; vma = vma->vm_next) {
-		pr_vas_debug("Merging a task memory region (%#lx - %#lx)\n",
-			     vma->vm_start, vma->vm_end);
+		bool copy_eagerly = default_copy_eagerly;
+
+		/*
+		 * The code region of the task will *always* be copied eagerly.
+		 * We need this region in any case to continue execution. All
+		 * the other memory regions are copied according to the
+		 * 'default_copy_eagerly' variable.
+		 */
+		if (is_code_region(vma))
+			copy_eagerly = true;
 
-		new_vma = __copy_vm_area(tsk_mm, vma, avas_mm, vma->vm_flags);
+		pr_vas_debug("Merging a task memory region (%#lx - %#lx) %s\n",
+			     vma->vm_start, vma->vm_end,
+			     copy_eagerly ? "eagerly" : "lazily");
+
+		new_vma = __copy_vm_area(tsk_mm, vma, avas_mm, vma->vm_flags,
+					 copy_eagerly);
 		if (!new_vma) {
 			pr_vas_debug("Failed to merge a task memory region (%#lx - %#lx)\n",
 				     vma->vm_start, vma->vm_end);
@@ -1443,6 +1507,16 @@ static int task_merge(struct att_vas *avas, struct task_struct *tsk)
 	return ret;
 }
 
+/*
+ * Decide based on the kernel configuration setting if we copy task memory
+ * regions eagerly or lazily.
+ */
+#ifdef CONFIG_VAS_LAZY_ATTACH
+#define task_merge(avas, tsk) _task_merge(avas, tsk, false)
+#else
+#define task_merge(avas, tsk) _task_merge(avas, tsk, true)
+#endif
+
 /**
  * Unmerge task-related parts of an attached-VAS memory map back into the
  * task's memory map.
@@ -1541,7 +1615,8 @@ static int vas_seg_merge(struct vas *vas, struct vas_seg *seg, int type)
 		if (!(type & MAY_WRITE))
 			merged_vm_flags &= ~(VM_WRITE | VM_MAYWRITE);
 
-		new_vma = __copy_vm_area(seg_mm, vma, vas_mm, merged_vm_flags);
+		new_vma = __copy_vm_area(seg_mm, vma, vas_mm, merged_vm_flags,
+					 true);
 		if (!new_vma) {
 			pr_vas_debug("Failed to merge a VAS segment memory region (%#lx - %#lx)\n",
 				     vma->vm_start, vma->vm_end);
@@ -1606,7 +1681,7 @@ static int vas_seg_unmerge(struct vas *vas, struct vas_seg *seg)
 			pr_vas_debug("Skipping memory region (%#lx - %#lx) during VAS segment unmerging\n",
 				     vma->vm_start, vma->vm_end);
 			continue;
-		} else {
+		} else if (vma->vas_attached) {
 			struct vm_area_struct *upd_vma;
 
 			pr_vas_debug("Unmerging a VAS segment memory region (%#lx - %#lx)\n",
@@ -1619,6 +1694,9 @@ static int vas_seg_unmerge(struct vas *vas, struct vas_seg *seg)
 				ret = -EFAULT;
 				goto out_unlock;
 			}
+		} else {
+			pr_vas_debug("Skip not-attached memory region (%#lx - %#lx) during segment unmerging\n",
+				     vma->vm_start, vma->vm_end);
 		}
 
 		/* Remove the current VMA from the VAS memory map. */
@@ -1809,8 +1887,13 @@ static int __sync_from_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm)
 
 		ref = vas_find_reference(avas_mm, vma);
 		if (!ref) {
+#ifdef CONFIG_VAS_LAZY_ATTACH
 			ref = __copy_vm_area(tsk_mm, vma, avas_mm,
-					     vma->vm_flags);
+					     vma->vm_flags, false);
+#else
+			ref = __copy_vm_area(tsk_mm, vma, avas_mm,
+					     vma->vm_flags, true);
+#endif
 
 			if (!ref) {
 				pr_vas_debug("Failed to copy memory region (%#lx - %#lx) during task sync\n",
@@ -1824,7 +1907,7 @@ static int __sync_from_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm)
 			 * copied it from.
 			 */
 			ref->vas_reference = tsk_mm;
-		} else {
+		} else if (ref->vas_attached) {
 			ref = __update_vm_area(tsk_mm, vma, avas_mm, ref);
 			if (!ref) {
 				pr_vas_debug("Failed to update memory region (%#lx - %#lx) during task sync\n",
@@ -1832,6 +1915,9 @@ static int __sync_from_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm)
 				ret = -EFAULT;
 				break;
 			}
+		} else {
+			pr_vas_debug("Skip not-attached memory region (%#lx - %#lx) during task sync\n",
+				     vma->vm_start, vma->vm_end);
 		}
 	}
 
@@ -1848,7 +1934,7 @@ static int __sync_to_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm)
 		if (vma->vas_reference != tsk_mm) {
 			pr_vas_debug("Skip unrelated memory region (%#lx - %#lx) during task resync\n",
 				     vma->vm_start, vma->vm_end);
-		} else {
+		} else if (vma->vas_attached) {
 			struct vm_area_struct *ref;
 
 			ref = __update_vm_area(avas_mm, vma, tsk_mm, NULL);
@@ -1858,6 +1944,9 @@ static int __sync_to_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm)
 				ret = -EFAULT;
 				break;
 			}
+		} else {
+			pr_vas_debug("Skip not-attached memory region (%#lx - %#lx) during task resync\n",
+				     vma->vm_start, vma->vm_end);
 		}
 	}
 
@@ -3100,6 +3189,47 @@ void vas_exit(struct task_struct *tsk)
 	}
 }
 
+#ifdef CONFIG_VAS_LAZY_ATTACH
+
+int vas_lazy_attach_vma(struct vm_area_struct *vma)
+{
+	struct mm_struct *ref_mm, *mm;
+	struct vm_area_struct *ref_vma;
+
+	if (likely(!vma->vas_reference))
+		return 0;
+	if (vma->vas_attached)
+		return 0;
+
+	ref_mm = vma->vas_reference;
+	mm = vma->vm_mm;
+
+	down_read_nested(&ref_mm->mmap_sem, SINGLE_DEPTH_NESTING);
+	ref_vma = vas_find_reference(ref_mm, vma);
+	up_read(&ref_mm->mmap_sem);
+	if (!ref_vma) {
+		pr_vas_debug("Couldn't find VAS reference\n");
+		return 1;
+	}
+
+	pr_vas_debug("Lazy-attach memory region (%#lx - %#lx)\n",
+		     ref_vma->vm_start, ref_vma->vm_end);
+
+	if (unlikely(dup_page_range(mm, vma, ref_mm, ref_vma))) {
+		pr_vas_debug("Failed to copy page tables for VMA %p from %p\n",
+			     vma, ref_vma);
+		return 1;
+	}
+
+	vma->vas_last_update = ref_vma->vas_last_update;
+	vma->vas_attached = true;
+
+	return 0;
+}
+
+#endif /* CONFIG_VAS_LAZY_ATTACH */
+
+
 /***
  * System Calls
  ***/
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
