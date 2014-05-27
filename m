Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 866E76B003B
	for <linux-mm@kvack.org>; Tue, 27 May 2014 06:22:07 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so9100371pbc.28
        for <linux-mm@kvack.org>; Tue, 27 May 2014 03:22:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ah3si18393676pad.52.2014.05.27.03.22.06
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 03:22:06 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <53842FB1.7090909@linux.vnet.ibm.com>
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
 <53842FB1.7090909@linux.vnet.ibm.com>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
Content-Transfer-Encoding: 7bit
Message-Id: <20140527102200.012BBE009B@blue.fi.intel.com>
Date: Tue, 27 May 2014 13:21:59 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

Madhavan Srinivasan wrote:
> On Tuesday 20 May 2014 03:57 PM, Kirill A. Shutemov wrote:
> > Rusty Russell wrote:
> >> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> >>> Andrew Morton wrote:
> >>>> On Mon, 19 May 2014 16:23:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> >>>>
> >>>>> Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
> >>>>> the order of the fault-around size in bytes, and fault_around_pages()
> >>>>> use 1UL << (fault_around_order - PAGE_SHIFT)
> >>>>
> >>>> Yes.  And shame on me for missing it (this time!) at review.
> >>>>
> >>>> There's still time to fix this.  Patches, please.
> >>>
> >>> Here it is. Made at 3.30 AM, build tested only.
> >>
> >> Prefer on top of Maddy's patch which makes it always a variable, rather
> >> than CONFIG_DEBUG_FS.  It's got enough hair as it is.
> > 
> > Something like this?
> > 
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
> > +
> > +static inline unsigned long fault_around_mask(void)
> > +{
> > +	return ~(rounddown_pow_of_two(fault_around_bytes) - 1) & PAGE_MASK;
> > +}
> > 
> > -#ifdef CONFIG_DEBUG_FS
> > -static unsigned int fault_around_order = FAULT_AROUND_ORDER;
> > 
> > -static int fault_around_order_get(void *data, u64 *val)
> > +#ifdef CONFIG_DEBUG_FS
> > +static int fault_around_bytes_get(void *data, u64 *val)
> >  {
> > -	*val = fault_around_order;
> > +	*val = fault_around_bytes;
> >  	return 0;
> >  }
> > 
> > -static int fault_around_order_set(void *data, u64 val)
> > +static int fault_around_bytes_set(void *data, u64 val)
> >  {
> 
> Kindly ignore the question if not relevant. Even though we need root
> access to alter the value, will we be fine with
> negative value?.

val is u64. or I miss something?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
