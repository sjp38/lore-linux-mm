Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F08506B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:09:47 -0500 (EST)
Message-ID: <4CF5BC77.8090400@goop.org>
Date: Tue, 30 Nov 2010 19:09:43 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vmalloc: eagerly clear ptes on vunmap
References: <4CEF6B8B.8080206@goop.org>	<20101127103656.GA6884@amd>	<4CF40DCB.5010007@goop.org> <20101130162938.8a6b0df4.akpm@linux-foundation.org>
In-Reply-To: <20101130162938.8a6b0df4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>, "Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Bryan Schumaker <bjschuma@netapp.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

On 11/30/2010 04:29 PM, Andrew Morton wrote:
> On Mon, 29 Nov 2010 12:32:11 -0800
> Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>
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
>>
> Do we have any quantitative info on that regression?

It's pretty easy to reproduce - you get oopses very quickly while using
NFS.  I haven't got any lying around right now, but I could easily
generate one if you want to decorate the changelog a bit.

>   The patch fixed
> it, I assume?

Yes, the patch fixes it, and I think it is just luck that xfs doesn't
also trigger the same problem.  Here's a followup patch to disable the
previous hack.

    J

Subject: [PATCH] vmalloc: remove vmap_lazy_unmap flag

Now that vmunmap no longer leaves stray ptes lying around, we don't need
the vmap_lazy_unmap flag any more.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 21ed8d7..0e4ecac 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -2358,8 +2358,6 @@ void __init xen_init_mmu_ops(void)
 	x86_init.paging.pagetable_setup_done = xen_pagetable_setup_done;
 	pv_mmu_ops = xen_mmu_ops;
 
-	vmap_lazy_unmap = false;
-
 	memset(dummy_mapping, 0xff, PAGE_SIZE);
 }
 
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index a03dcf6..44b54f6 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -7,8 +7,6 @@
 
 struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 
-extern bool vmap_lazy_unmap;
-
 /* bits in flags of vmalloc's vm_struct below */
 #define VM_IOREMAP	0x00000001	/* ioremap() and friends */
 #define VM_ALLOC	0x00000002	/* vmalloc() */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ffefe70..828d95e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -31,8 +31,6 @@
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
-bool vmap_lazy_unmap __read_mostly = true;
-
 /*** Page table manipulation functions ***/
 
 static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
@@ -503,9 +501,6 @@ static unsigned long lazy_max_pages(void)
 {
 	unsigned int log;
 
-	if (!vmap_lazy_unmap)
-		return 0;
-
 	log = fls(num_online_cpus());
 
 	return log * (32UL * 1024 * 1024 / PAGE_SIZE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
