Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AE56B6B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:24:24 -0500 (EST)
Date: Tue, 30 Nov 2010 19:23:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] vmalloc: eagerly clear ptes on vunmap
Message-Id: <20101130192306.280a9437.akpm@linux-foundation.org>
In-Reply-To: <4CF5BC77.8090400@goop.org>
References: <4CEF6B8B.8080206@goop.org>
	<20101127103656.GA6884@amd>
	<4CF40DCB.5010007@goop.org>
	<20101130162938.8a6b0df4.akpm@linux-foundation.org>
	<4CF5BC77.8090400@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <npiggin@kernel.dk>, "Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Bryan Schumaker <bjschuma@netapp.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 19:09:43 -0800 Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> On 11/30/2010 04:29 PM, Andrew Morton wrote:
> > On Mon, 29 Nov 2010 12:32:11 -0800
> > Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> >
> >> When unmapping a region in the vmalloc space, clear the ptes immediately.
> >> There's no point in deferring this because there's no amortization
> >> benefit.
> >>
> >> The TLBs are left dirty, and they are flushed lazily to amortize the
> >> cost of the IPIs.
> >>
> >> This specific motivation for this patch is a regression since 2.6.36 when
> >> using NFS under Xen, triggered by the NFS client's use of vm_map_ram()
> >> introduced in 56e4ebf877b6043c289bda32a5a7385b80c17dee.  XFS also uses
> >> vm_map_ram() and could cause similar problems.
> >>
> > Do we have any quantitative info on that regression?
> 
> It's pretty easy to reproduce - you get oopses very quickly while using
> NFS.

Bah.  I'd assumed that it was a performance regression and had vaguely
queued it for 2.6.37.

> I haven't got any lying around right now, but I could easily
> generate one if you want to decorate the changelog a bit.

You owe me that much ;)


Here's the current rollup of the three patches.  Please check.



From: Jeremy Fitzhardinge <jeremy@goop.org>

When unmapping a region in the vmalloc space, clear the ptes immediately. 
There's no point in deferring this because there's no amortization
benefit.

The TLBs are left dirty, and they are flushed lazily to amortize the cost
of the IPIs.

This specific motivation for this patch is an oops-causing regression
since 2.6.36 when using NFS under Xen, triggered by the NFS client's use
of vm_map_ram() introduced in 56e4ebf877b60 ("NFS: readdir with vmapped
pages") .  XFS also uses vm_map_ram() and could cause similar problems.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Alex Elder <aelder@sgi.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/x86/xen/mmu.c      |    2 --
 include/linux/vmalloc.h |    2 --
 mm/vmalloc.c            |   30 ++++++++++++++++++------------
 3 files changed, 18 insertions(+), 16 deletions(-)

diff -puN mm/vmalloc.c~vmalloc-eagerly-clear-ptes-on-vunmap mm/vmalloc.c
--- a/mm/vmalloc.c~vmalloc-eagerly-clear-ptes-on-vunmap
+++ a/mm/vmalloc.c
@@ -31,8 +31,6 @@
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
-bool vmap_lazy_unmap __read_mostly = true;
-
 /*** Page table manipulation functions ***/
 
 static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
@@ -503,9 +501,6 @@ static unsigned long lazy_max_pages(void
 {
 	unsigned int log;
 
-	if (!vmap_lazy_unmap)
-		return 0;
-
 	log = fls(num_online_cpus());
 
 	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
@@ -566,7 +561,6 @@ static void __purge_vmap_area_lazy(unsig
 			if (va->va_end > *end)
 				*end = va->va_end;
 			nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
-			unmap_vmap_area(va);
 			list_add_tail(&va->purge_list, &valist);
 			va->flags |= VM_LAZY_FREEING;
 			va->flags &= ~VM_LAZY_FREE;
@@ -611,10 +605,11 @@ static void purge_vmap_area_lazy(void)
 }
 
 /*
- * Free and unmap a vmap area, caller ensuring flush_cache_vunmap had been
- * called for the correct range previously.
+ * Free a vmap area, caller ensuring that the area has been unmapped
+ * and flush_cache_vunmap had been called for the correct range
+ * previously.
  */
-static void free_unmap_vmap_area_noflush(struct vmap_area *va)
+static void free_vmap_area_noflush(struct vmap_area *va)
 {
 	va->flags |= VM_LAZY_FREE;
 	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
@@ -623,6 +618,16 @@ static void free_unmap_vmap_area_noflush
 }
 
 /*
+ * Free and unmap a vmap area, caller ensuring flush_cache_vunmap had been
+ * called for the correct range previously.
+ */
+static void free_unmap_vmap_area_noflush(struct vmap_area *va)
+{
+	unmap_vmap_area(va);
+	free_vmap_area_noflush(va);
+}
+
+/*
  * Free and unmap a vmap area
  */
 static void free_unmap_vmap_area(struct vmap_area *va)
@@ -798,7 +803,7 @@ static void free_vmap_block(struct vmap_
 	spin_unlock(&vmap_block_tree_lock);
 	BUG_ON(tmp != vb);
 
-	free_unmap_vmap_area_noflush(vb->va);
+	free_vmap_area_noflush(vb->va);
 	call_rcu(&vb->rcu_head, rcu_free_vb);
 }
 
@@ -944,8 +949,10 @@ static void vb_free(const void *addr, un
 		BUG_ON(vb->free);
 		spin_unlock(&vb->lock);
 		free_vmap_block(vb);
-	} else
+	} else {
 		spin_unlock(&vb->lock);
+		vunmap_page_range((unsigned long)addr, (unsigned long)addr + size);
+	}
 }
 
 /**
@@ -988,7 +995,6 @@ void vm_unmap_aliases(void)
 
 				s = vb->va->va_start + (i << PAGE_SHIFT);
 				e = vb->va->va_start + (j << PAGE_SHIFT);
-				vunmap_page_range(s, e);
 				flush = 1;
 
 				if (s < start)
diff -puN arch/x86/xen/mmu.c~vmalloc-eagerly-clear-ptes-on-vunmap arch/x86/xen/mmu.c
--- a/arch/x86/xen/mmu.c~vmalloc-eagerly-clear-ptes-on-vunmap
+++ a/arch/x86/xen/mmu.c
@@ -2415,8 +2415,6 @@ void __init xen_init_mmu_ops(void)
 	x86_init.paging.pagetable_setup_done = xen_pagetable_setup_done;
 	pv_mmu_ops = xen_mmu_ops;
 
-	vmap_lazy_unmap = false;
-
 	memset(dummy_mapping, 0xff, PAGE_SIZE);
 }
 
diff -puN include/linux/vmalloc.h~vmalloc-eagerly-clear-ptes-on-vunmap include/linux/vmalloc.h
--- a/include/linux/vmalloc.h~vmalloc-eagerly-clear-ptes-on-vunmap
+++ a/include/linux/vmalloc.h
@@ -7,8 +7,6 @@
 
 struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 
-extern bool vmap_lazy_unmap;
-
 /* bits in flags of vmalloc's vm_struct below */
 #define VM_IOREMAP	0x00000001	/* ioremap() and friends */
 #define VM_ALLOC	0x00000002	/* vmalloc() */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
