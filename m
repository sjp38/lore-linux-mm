Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4E36B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 09:40:41 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id g10so1395779pdj.22
        for <linux-mm@kvack.org>; Wed, 21 May 2014 06:40:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zv2si5285759pbb.131.2014.05.21.06.40.39
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 06:40:40 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20140520125956.aa61a3bfd84d4d6190740ce2@linux-foundation.org>
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
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
Content-Transfer-Encoding: 7bit
Message-Id: <20140521134027.263DDE009B@blue.fi.intel.com>
Date: Wed, 21 May 2014 16:40:27 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Hugh Dickins <hughd@google.com>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

Andrew Morton wrote:
> On Tue, 20 May 2014 13:27:38 +0300 (EEST) "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Rusty Russell wrote:
> > > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> > > > Andrew Morton wrote:
> > > >> On Mon, 19 May 2014 16:23:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> > > >> 
> > > >> > Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
> > > >> > the order of the fault-around size in bytes, and fault_around_pages()
> > > >> > use 1UL << (fault_around_order - PAGE_SHIFT)
> > > >> 
> > > >> Yes.  And shame on me for missing it (this time!) at review.
> > > >> 
> > > >> There's still time to fix this.  Patches, please.
> > > >
> > > > Here it is. Made at 3.30 AM, build tested only.
> > > 
> > > Prefer on top of Maddy's patch which makes it always a variable, rather
> > > than CONFIG_DEBUG_FS.  It's got enough hair as it is.
> > 
> > Something like this?
> 
> This appears to be against mainline, not against Madhavan's patch.  As
> mentioned previously, I'd prefer it that way but confused.
> 
> 
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Tue, 20 May 2014 13:02:03 +0300
> > Subject: [PATCH] mm: nominate faultaround area in bytes rather then page order
> > 
> > There are evidences that faultaround feature is less relevant on
> > architectures with page size bigger then 4k. Which makes sense since
> > page fault overhead per byte of mapped area should be less there.
> > 
> > Let's rework the feature to specify faultaround area in bytes instead of
> > page order. It's 64 kilobytes for now.
> > 
> > The patch effectively disables faultaround on architectures with
> > page size >= 64k (like ppc64).
> > 
> > It's possible that some other size of faultaround area is relevant for a
> > platform. We can expose `fault_around_bytes' variable to arch-specific
> > code once such platforms will be found.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/memory.c | 62 +++++++++++++++++++++++--------------------------------------
> >  1 file changed, 23 insertions(+), 39 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 037b812a9531..252b319e8cdf 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3402,63 +3402,47 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
> >  	update_mmu_cache(vma, address, pte);
> >  }
> >  
> > -#define FAULT_AROUND_ORDER 4
> > +static unsigned long fault_around_bytes = 65536;
> > +
> > +static inline unsigned long fault_around_pages(void)
> > +{
> > +	return rounddown_pow_of_two(fault_around_bytes) / PAGE_SIZE;
> > +}
> 
> I think we should round up, not down.  So if the user asks for 1kb,
> they get one page.
> 
> So this becomes
> 
> 	return PAGE_ALIGN(fault_around_bytes) / PAGE_SIZE;

See below.

> > +static inline unsigned long fault_around_mask(void)
> > +{
> > +	return ~(rounddown_pow_of_two(fault_around_bytes) - 1) & PAGE_MASK;
> > +}
> 
> And this has me a bit stumped.  It's not helpful that do_fault_around()
> is undocumented.  Does it fault in N/2 pages ahead and N/2 pages
> behind?  Or does it align the address down to the highest multiple of
> fault_around_bytes?  It appears to be the latter, so the location of
> the faultaround window around the fault address is basically random,
> depending on what address userspace happened to pick.  I don't know why
> we did this :(

When we call ->map_pages() we need to make sure that we stay within VMA
and the page table. We don't want to cross page table boundary, because
page table is what ptlock covers in split ptlock case.

I've designed the feature with fault area nominated in page order in mind
and I found it's easier to make sure we don't cross boundaries, if we
would align virtual address of fault around area to PAGE_SIZE <<
FAULT_AROUND_ORDER.

And yes fault address may be anywhere within the area. You can think about
this as a virtual page with size PAGE_SIZE << FAULT_AROUND_ORDER: no matter
what is fault address, we handle area naturally aligned to page size which
fault address belong to.

I've used rounddown_pow_of_two() in the patch to align to nearest page
order, not to page size, because that's what current do_fault_around()
expect to see. And roundup is not an option: nobody expects fault around
area to be 128k if fault_around_bytes set to 64k + 1 bytes.

If you think we need this I can rework do_fault_around() to handle
non-pow-of-two fault_around_pages(), but I don't think it's good idea to
do this for v3.15. Anyway, patch I've proposed allows change
fault_around_bytes only from DEBUG_FS and roundown should be good
enough there.

> Or something.  Can we please get some code commentary over
> do_fault_around() describing this design decision and explaining the
> reasoning behind it?

I'll do this. But if do_fault_around() rework is needed, I want to do that
first.

> Also, "neast" is not a word.

:facepalm:

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Wed, 21 May 2014 16:36:42 +0300
Subject: [PATCH] mm: fix typo in comment in do_fault_around()

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 252b319e8cdf..f76663c31da6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3460,7 +3460,7 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 
 	/*
 	 *  max_pgoff is either end of page table or end of vma
-	 *  or fault_around_pages() from pgoff, depending what is neast.
+	 *  or fault_around_pages() from pgoff, depending what is nearest.
 	 */
 	max_pgoff = pgoff - ((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
 		PTRS_PER_PTE - 1;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
