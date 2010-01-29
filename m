Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6164A6B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 14:00:05 -0500 (EST)
Date: Fri, 29 Jan 2010 19:59:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25 of 31] transparent hugepage core
Message-ID: <20100129185914.GG21747@random.random>
References: <patchbomb.1264689194@v2.random>
 <ac9bbf9e2c95840eb237.1264689219@v2.random>
 <20100128175753.GF7139@csn.ul.ie>
 <20100128223653.GL1217@random.random>
 <20100129152939.GI7139@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100129152939.GI7139@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 29, 2010 at 03:29:39PM +0000, Mel Gorman wrote:
> In that case, I'd suggest simply no_transparent_hugepage with the
> expectation that it's only used to get around early-boot problems that
> might crop up. While the opportunity for a user to hang themselves is
> always good for chuckles, there is little point giving them more rope
> than they need :)

I tend to agree.

> Unfortunately, I don't have a i915 but I'll be testing the patchset on
> the laptop over the weekend.

To debug this I sent this patch that makes khugepaged a readonly
thing, a pure pagetable scanner validator. And I asked to boot with
transparent_hugepage=16 (that only enables the crippled down version
of khugepaged that will never create transhuge pages). This way no
hugepage will ever be generated and no hugepmd either. So if i915
still trips on this, we'll know it's not my fault. Otherwise we've to
dig deeper in the patch.

the i915 bug triggers at boot time only with i915.modeset=1 but it
doesn't on my laptop also with i915 KMS=y. It starts before X. So I
think the explanation is some splash screen (which I don't have) is
mmapping the DRM framebuffer and DRM framebuffer corrupts some pte to
point to the agpgart area. Otherwise it means some hugepage is
confusing it, but nothing related to i915 should _ever_ care about
hugepages because hugepages are only generated on vm_ops = NULL, and
it must never happen that remap_pfn_range or vm_insert_pfn or anything
like that happens on a vma with vm_ops not null.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1552,8 +1552,10 @@ static int khugepaged_scan_pmd(struct mm
 		if (page_count(page) != 1)
 			goto out_unmap;
 	}
+#if 0
 	if (referenced)
 		ret = 1;
+#endif
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret) {

I think this is also a must to add for mainline in addition to the
above debugging trick (this will be the next step if the khugepaged
crippled down in readonly mode and transparent_hugepage=16 still show
the bug triggering, basically declaring transparent hugepage inocent,
if hugepage is innocent then the below will have a chance to expose
the bug).

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1678,6 +1680,7 @@ int vm_insert_pfn(struct vm_area_struct 
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
 	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+	BUG_ON(!vma->vm_ops);
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
@@ -1697,6 +1700,7 @@ int vm_insert_mixed(struct vm_area_struc
 			unsigned long pfn)
 {
 	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
+	BUG_ON(!vma->vm_ops);
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
@@ -1828,6 +1832,7 @@ int remap_pfn_range(struct vm_area_struc
 		return -EINVAL;
 
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
+	BUG_ON(!vma->vm_ops);
 
 	err = track_pfn_vma_new(vma, &prot, pfn, PAGE_ALIGN(size));
 	if (err) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
