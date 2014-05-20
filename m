Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 992C76B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 15:59:58 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id x10so625228pdj.17
        for <linux-mm@kvack.org>; Tue, 20 May 2014 12:59:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id eb4si3182938pbb.113.2014.05.20.12.59.57
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 12:59:57 -0700 (PDT)
Date: Tue, 20 May 2014 12:59:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
Message-Id: <20140520125956.aa61a3bfd84d4d6190740ce2@linux-foundation.org>
In-Reply-To: <20140520102738.7F096E009B@blue.fi.intel.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Hugh Dickins <hughd@google.com>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Tue, 20 May 2014 13:27:38 +0300 (EEST) "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Rusty Russell wrote:
> > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> > > Andrew Morton wrote:
> > >> On Mon, 19 May 2014 16:23:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> > >> 
> > >> > Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
> > >> > the order of the fault-around size in bytes, and fault_around_pages()
> > >> > use 1UL << (fault_around_order - PAGE_SHIFT)
> > >> 
> > >> Yes.  And shame on me for missing it (this time!) at review.
> > >> 
> > >> There's still time to fix this.  Patches, please.
> > >
> > > Here it is. Made at 3.30 AM, build tested only.
> > 
> > Prefer on top of Maddy's patch which makes it always a variable, rather
> > than CONFIG_DEBUG_FS.  It's got enough hair as it is.
> 
> Something like this?

This appears to be against mainline, not against Madhavan's patch.  As
mentioned previously, I'd prefer it that way but confused.


> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 20 May 2014 13:02:03 +0300
> Subject: [PATCH] mm: nominate faultaround area in bytes rather then page order
> 
> There are evidences that faultaround feature is less relevant on
> architectures with page size bigger then 4k. Which makes sense since
> page fault overhead per byte of mapped area should be less there.
> 
> Let's rework the feature to specify faultaround area in bytes instead of
> page order. It's 64 kilobytes for now.
> 
> The patch effectively disables faultaround on architectures with
> page size >= 64k (like ppc64).
> 
> It's possible that some other size of faultaround area is relevant for a
> platform. We can expose `fault_around_bytes' variable to arch-specific
> code once such platforms will be found.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/memory.c | 62 +++++++++++++++++++++++--------------------------------------
>  1 file changed, 23 insertions(+), 39 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 037b812a9531..252b319e8cdf 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3402,63 +3402,47 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>  	update_mmu_cache(vma, address, pte);
>  }
>  
> -#define FAULT_AROUND_ORDER 4
> +static unsigned long fault_around_bytes = 65536;
> +
> +static inline unsigned long fault_around_pages(void)
> +{
> +	return rounddown_pow_of_two(fault_around_bytes) / PAGE_SIZE;
> +}

I think we should round up, not down.  So if the user asks for 1kb,
they get one page.

So this becomes

	return PAGE_ALIGN(fault_around_bytes) / PAGE_SIZE;

> +static inline unsigned long fault_around_mask(void)
> +{
> +	return ~(rounddown_pow_of_two(fault_around_bytes) - 1) & PAGE_MASK;
> +}

And this has me a bit stumped.  It's not helpful that do_fault_around()
is undocumented.  Does it fault in N/2 pages ahead and N/2 pages
behind?  Or does it align the address down to the highest multiple of
fault_around_bytes?  It appears to be the latter, so the location of
the faultaround window around the fault address is basically random,
depending on what address userspace happened to pick.  I don't know why
we did this :(

Or something.  Can we please get some code commentary over
do_fault_around() describing this design decision and explaining the
reasoning behind it?


Also, "neast" is not a word.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
