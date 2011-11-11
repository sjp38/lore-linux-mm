Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A9E126B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 03:33:19 -0500 (EST)
Subject: Re: [patch 3/5]thp: add tlb_remove_pmd_tlb_entry
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20111111065327.GP5075@redhat.com>
References: <1319511571.22361.139.camel@sli10-conroe>
	 <20111110153651.GZ5075@redhat.com>
	 <1320993389.22361.256.camel@sli10-conroe>
	 <20111111065327.GP5075@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 11 Nov 2011 16:42:34 +0800
Message-ID: <1321000954.22361.264.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri, 2011-11-11 at 14:53 +0800, Andrea Arcangeli wrote:
> On Fri, Nov 11, 2011 at 02:36:29PM +0800, Shaohua Li wrote:
> > On Thu, 2011-11-10 at 23:36 +0800, Andrea Arcangeli wrote:
> > > On Tue, Oct 25, 2011 at 10:59:31AM +0800, Shaohua Li wrote:
> > > > Index: linux/arch/x86/include/asm/tlb.h
> > > > ===================================================================
> > > > --- linux.orig/arch/x86/include/asm/tlb.h	2011-10-25 09:00:39.000000000 +0800
> > > > +++ linux/arch/x86/include/asm/tlb.h	2011-10-25 09:02:52.000000000 +0800
> > > > @@ -4,6 +4,7 @@
> > > >  #define tlb_start_vma(tlb, vma) do { } while (0)
> > > >  #define tlb_end_vma(tlb, vma) do { } while (0)
> > > >  #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
> > > > +#define __tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do { } while (0)
> > > >  #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
> > > 
> > > This is superfluous, it's already define below as noop.
> > > 
> > > >  
> > > >  #include <asm-generic/tlb.h>
> > > > Index: linux/include/asm-generic/tlb.h
> > > > ===================================================================
> > > > --- linux.orig/include/asm-generic/tlb.h	2011-10-25 09:00:23.000000000 +0800
> > > > +++ linux/include/asm-generic/tlb.h	2011-10-25 09:18:01.000000000 +0800
> > > > @@ -139,6 +139,16 @@ static inline void tlb_remove_page(struc
> > > >  		__tlb_remove_tlb_entry(tlb, ptep, address);	\
> > > >  	} while (0)
> > > >  
> > > > +#ifndef __tlb_remove_pmd_tlb_entry
> > > > +#define __tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do {} while(0)
> > > > +#endif
> > > > +
> > > > +#define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)		\
> > > > +	do {							\
> > > > +		tlb->need_flush = 1;				\
> > > > +		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
> > > > +	} while (0)
> > > 
> > > this looks weird, why do we set need_flush = 1 again, considering that
> > > we're doing tlb_remove_page() just a few lines later (which also sets
> > > tlb->need_flush = 1).
> > > 
> > > Ok that other archs may need the __tlb_remove_pmd_tlb_entry to be
> > > called (and I've no idea why), but the need_flush = 1 seems
> > > unnecessary.
> > > 
> > > Why other archs need the __tlb_remove_pmd_tlb_entry to be called?
> > > 
> > > One way to go would be to change the tlb->need_flush = 1 in
> > > __tlb_remove_page to a VM_BUG_ON(!tlb->need_flush) and then we keep it
> > > above and we add the __tlb_remove_pmd_tlb_entry call.
> > > 
> > > Or is there any place where __tlb_remove_page is called without a
> > > tlb_remove_*tlb_entry being called before it?
> > > 
> > > In any case the VM_BUG_ON will verify this.
> > ok, I made the whole tlb_remove_pmd_tlb_entry() noop now. we don't need
> > add anything on it for x86 currently. We can change it later if
> > necessary.
> 
> I thought it'd be cleaner to have only the __tlb_remove_*tlb_entry
> variants set need_flush=1 and have __tlb_remove_page just check that
> is set under a VM_BUG_ON. That would also avoid a second unnecessary
> need_flush = 1 for the pte case which is repeated now (it's not the
> repeated in the pmd case in your patch because it's a noop, but the
> pte case it's not a noop). Maybe it's not possible but if it's
> possible it looks better.
makes sense to me. __tlb_remove_page should always follow after
__tlb_remove_*tlb_entry. if we set need_flush=1 in
__tlb_remove_*tlb_entry, tlb_remove_*tlb_entry == __tlb_remove_*tlb
entry then, we can delete __xxx. But this sounds not related to the
issue, I'd prefer another patch to clean it up. how do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
