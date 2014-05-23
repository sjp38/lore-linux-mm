Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0BA6B0037
	for <linux-mm@kvack.org>; Fri, 23 May 2014 08:29:02 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so4092744pbb.21
        for <linux-mm@kvack.org>; Fri, 23 May 2014 05:29:01 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fd3si3617574pbb.179.2014.05.23.05.29.01
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 05:29:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20140521133408.4d2f1a551e9652fb0e12265f@linux-foundation.org>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
 <537479E7.90806@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1405151026540.4664@eggly.anvils>
 <87wqdik4n5.fsf@rustcorp.com.au>
 <53797511.1050409@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1405191531150.1317@eggly.anvils>
 <20140519164301.eafd3dd288ccb88361ddcfc7@linux-foundation.org>
 <20140520004429.E660AE009B@blue.fi.intel.com>
 <87oaythsvk.fsf@rustcorp.com.au>
 <20140520102738.7F096E009B@blue.fi.intel.com>
 <20140520125956.aa61a3bfd84d4d6190740ce2@linux-foundation.org>
 <20140521134027.263DDE009B@blue.fi.intel.com>
 <20140521133408.4d2f1a551e9652fb0e12265f@linux-foundation.org>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
Content-Transfer-Encoding: 7bit
Message-Id: <20140523122854.BDB36E009B@blue.fi.intel.com>
Date: Fri, 23 May 2014 15:28:54 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Hugh Dickins <hughd@google.com>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

Andrew Morton wrote:
> On Wed, 21 May 2014 16:40:27 +0300 (EEST) "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > > Or something.  Can we please get some code commentary over
> > > do_fault_around() describing this design decision and explaining the
> > > reasoning behind it?
> > 
> > I'll do this. But if do_fault_around() rework is needed, I want to do that
> > first.
> 
> This sort of thing should be at least partially driven by observation
> and I don't have the data for that.  My seat of the pants feel is that
> after the first fault, accesses at higher addresses are more
> common/probable than accesses at lower addresses.

It's probably true for data, but the feature is mostly targeted to code pages
and situation is not that obvious to me with all jumps.

> But we don't need to do all that right now.  Let's get the current
> implementation wrapped up for 3.15: get the interface finalized (bytes,
> not pages!)

The patch above by thread is okay for that, right?

> and get the current design decisions appropriately documented.

Here it is. Based on patch to convert order->bytes.

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Fri, 23 May 2014 15:16:47 +0300
Subject: [PATCH] mm: document do_fault_around() feature

Some clarification on how faultaround works.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 252b319e8cdf..8d723b8d3c86 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3404,6 +3404,10 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 
 static unsigned long fault_around_bytes = 65536;
 
+/*
+ * fault_around_pages() and fault_around_mask() round down fault_around_bytes
+ * to nearest page order. It's what do_fault_around() expects to see.
+ */
 static inline unsigned long fault_around_pages(void)
 {
 	return rounddown_pow_of_two(fault_around_bytes) / PAGE_SIZE;
@@ -3445,6 +3449,29 @@ static int __init fault_around_debugfs(void)
 late_initcall(fault_around_debugfs);
 #endif
 
+/*
+ * do_fault_around() tries to map few pages around the fault address. The hope
+ * is that the pages will be needed soon and this would lower the number of
+ * faults to handle.
+ *
+ * It uses vm_ops->map_pages() to map the pages, which skips the page if it's
+ * not ready to be mapped: not up-to-date, locked, etc.
+ *
+ * This function is called with the page table lock taken. In the split ptlock
+ * case the page table lock only protects only those entries which belong to
+ * page table corresponding to the fault address.
+ *
+ * This function don't cross the VMA boundaries in order to call map_pages()
+ * only once.
+ *
+ * fault_around_pages() defines how many pages we'll try to map.
+ * do_fault_around() expects it to be power of two and less or equal to
+ * PTRS_PER_PTE.
+ *
+ * The virtual address of the area that we map is naturally aligned to the
+ * fault_around_pages() (and therefore to page order). This way it's easier to
+ * guarantee that we don't cross the page table boundaries.
+ */
 static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 		pte_t *pte, pgoff_t pgoff, unsigned int flags)
 {
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
