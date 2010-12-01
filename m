Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 907046B0085
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 03:16:44 -0500 (EST)
Message-ID: <4CF60469.60806@goop.org>
Date: Wed, 01 Dec 2010 00:16:41 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vmalloc: eagerly clear ptes on vunmap
References: <4CEF6B8B.8080206@goop.org>	<20101127103656.GA6884@amd>	<4CF40DCB.5010007@goop.org>	<20101130162938.8a6b0df4.akpm@linux-foundation.org>	<4CF5BC77.8090400@goop.org> <20101130192306.280a9437.akpm@linux-foundation.org>
In-Reply-To: <20101130192306.280a9437.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>, "Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Bryan Schumaker <bjschuma@netapp.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

On 11/30/2010 07:23 PM, Andrew Morton wrote:
> On Tue, 30 Nov 2010 19:09:43 -0800 Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>
>> On 11/30/2010 04:29 PM, Andrew Morton wrote:
>>> On Mon, 29 Nov 2010 12:32:11 -0800
>>> Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>>>
>>>> When unmapping a region in the vmalloc space, clear the ptes immediately.
>>>> There's no point in deferring this because there's no amortization
>>>> benefit.
>>>>
>>>> The TLBs are left dirty, and they are flushed lazily to amortize the
>>>> cost of the IPIs.
>>>>
>>>> This specific motivation for this patch is a regression since 2.6.36 when
>>>> using NFS under Xen, triggered by the NFS client's use of vm_map_ram()
>>>> introduced in 56e4ebf877b6043c289bda32a5a7385b80c17dee.  XFS also uses
>>>> vm_map_ram() and could cause similar problems.
>>>>
>>> Do we have any quantitative info on that regression?
>> It's pretty easy to reproduce - you get oopses very quickly while using
>> NFS.
> Bah.  I'd assumed that it was a performance regression and had vaguely
> queued it for 2.6.37.

I have a bunch of other cleanups for mm/vmalloc.c which I'll propose for
.37.

>> I haven't got any lying around right now, but I could easily
>> generate one if you want to decorate the changelog a bit.
> You owe me that much ;)

On stock 2.6.37-rc4, running:

# mount lilith:/export /mnt/lilith
# find  /mnt/lilith/ -type f -print0 | xargs -0 file

crashes the machine fairly quickly under Xen.  Often it results in oops
messages, but the couple of times I tried just now, it just hung quietly
and made Xen print some rude messages:

    (XEN) mm.c:2389:d80 Bad type (saw 7400000000000001 != exp
    3000000000000000) for mfn 1d7058 (pfn 18fa7)
    (XEN) mm.c:964:d80 Attempt to create linear p.t. with write perms
    (XEN) mm.c:2389:d80 Bad type (saw 7400000000000010 != exp
    1000000000000000) for mfn 1d2e04 (pfn 1d1fb)
    (XEN) mm.c:2965:d80 Error while pinning mfn 1d2e04

Which means the domain tried to map a pagetable page RW, which would
allow it to map arbitrary memory, so Xen stopped it.  This is because
vm_unmap_ram() left some pages mapped in the vmalloc area after NFS had
finished with them, and those pages got recycled as pagetable pages
while still having these RW aliases.

Removing those mappings immediately removes the Xen-visible aliases, and
so it has no problem with those pages being reused as pagetable pages. 
Deferring the TLB flush doesn't upset Xen because it can flush the TLB
itself as needed to maintain its invariants.

> Here's the current rollup of the three patches.  Please check.

It looks like "vmalloc: avoid double-unmapping percpu blocks" wasn't
complete.  Fix below.

Thanks,
    J


From: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
Date: Tue, 30 Nov 2010 23:53:28 -0800
Subject: [PATCH] vmalloc: always unmap in vb_free()

free_vmap_block() doesn't unmap anything, so just unconditionally unmap
the region.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ffefe70..a582491 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -946,6 +946,8 @@ static void vb_free(const void *addr, unsigned long size)
 	rcu_read_unlock();
 	BUG_ON(!vb);
 
+	vunmap_page_range((unsigned long)addr, (unsigned long)addr + size);
+
 	spin_lock(&vb->lock);
 	BUG_ON(bitmap_allocate_region(vb->dirty_map, offset >> PAGE_SHIFT, order));
 
@@ -954,10 +956,8 @@ static void vb_free(const void *addr, unsigned long size)
 		BUG_ON(vb->free);
 		spin_unlock(&vb->lock);
 		free_vmap_block(vb);
-	} else {
+	} else
 		spin_unlock(&vb->lock);
-		vunmap_page_range((unsigned long)addr, (unsigned long)addr + size);
-	}
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
