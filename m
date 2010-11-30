Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 717716B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:45:53 -0500 (EST)
Message-ID: <4CF5384B.8000203@goop.org>
Date: Tue, 30 Nov 2010 09:45:47 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vmalloc: eagerly clear ptes on vunmap
References: <4CEF6B8B.8080206@goop.org> <20101127103656.GA6884@amd> <4CF40DCB.5010007@goop.org> <20101130124249.GB15778@amd>
In-Reply-To: <20101130124249.GB15778@amd>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: "Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Bryan Schumaker <bjschuma@netapp.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

On 11/30/2010 04:42 AM, Nick Piggin wrote:
> On Mon, Nov 29, 2010 at 12:32:11PM -0800, Jeremy Fitzhardinge wrote:
>> When unmapping a region in the vmalloc space, clear the ptes immediately.
>> There's no point in deferring this because there's no amortization
>> benefit.
>>
>> The TLBs are left dirty, and they are flushed lazily to amortize the
>> cost of the IPIs.
>>
>> This specific motivation for this patch is a regression since 2.6.36 when
>> using NFS under Xen, triggered by the NFS client's use of vm_map_ram()
>> introduced in 56e4ebf877b6043c289bda32a5a7385b80c17dee.  XFS also uses
>> vm_map_ram() and could cause similar problems.
> I do wonder whether there are cache benefits from batching page table
> updates, especially the batched per cpu maps

Perhaps.  But perhaps there are cache benefits in clearing early because
the ptes are still in cache from when they were set?
>  (and in your version they
> get double-cleared as well).

I thought I'd avoided that.  Oh, right, in both vb_free(), and again -
eventually - in free_vmap_block->free_unmap_vmap_area_noflush.

Delta patch below.

>   I think this patch is good, but I think
> perhaps making it configurable would be nice.

I'd rather not unless there's a strong reason to do so.

It occurs to me that once you remove the lazily mapped ptes, then all
that code is doing is keeping track of ranges of addresses with dirty
tlb entries.  But on x86 at least, any kernel tlb flush is a global one,
so keeping track of fine-grain address information is overkill.  I
wonder if the overall code can be simplified as a result?

On a more concrete level, vmap_page_range_noflush() and
vunmap_page_range() could be implemented with apply_to_page_range()
which removes a chunk of boilerplate code (however, it would result in a
callback per pte rather than one per pte page - but I'll fix that now).

> So... main question, does it allow Xen to use lazy flushing and avoid
> vm_unmap_aliases() calls?

Yes, it seems to.

Thanks,
    J

Subject: [PATCH] vmalloc: avoid double-unmapping percpu blocks

The area has always been unmapped by the time free_vmap_block() is
called, so there's no need to unmap it again.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9551316..ade3302 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -520,13 +520,12 @@ static void purge_vmap_area_lazy(void)
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
-	unmap_vmap_area(va);
-
 	va->flags |= VM_LAZY_FREE;
 	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
 	if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
@@ -534,6 +533,16 @@ static void free_unmap_vmap_area_noflush(struct vmap_area *va)
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
@@ -709,7 +718,7 @@ static void free_vmap_block(struct vmap_block *vb)
 	spin_unlock(&vmap_block_tree_lock);
 	BUG_ON(tmp != vb);
 
-	free_unmap_vmap_area_noflush(vb->va);
+	free_vmap_area_noflush(vb->va);
 	call_rcu(&vb->rcu_head, rcu_free_vb);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
