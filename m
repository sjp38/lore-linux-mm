Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE07F6B000C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 19:14:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j15-v6so2970588pff.12
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:14:24 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id y9-v6si4336618pll.291.2018.07.18.16.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 16:14:23 -0700 (PDT)
Message-ID: <1531955428.12385.30.camel@intel.com>
Subject: Re: [RFC PATCH v2 16/27] mm: Modify can_follow_write_pte/pmd for
 shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 18 Jul 2018 16:10:28 -0700
In-Reply-To: <3f158401-f0b6-7bf7-48ab-2958354b28ad@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-17-yu-cheng.yu@intel.com>
	 <de510df6-7ea9-edc6-9c49-2f80f16472b4@linux.intel.com>
	 <1531328731.15351.3.camel@intel.com>
	 <45a85b01-e005-8cb6-af96-b23ce9b5fca7@linux.intel.com>
	 <1531868610.3541.21.camel@intel.com>
	 <fa9db8c5-41c8-05e9-ad8d-dc6aaf11cb04@linux.intel.com>
	 <1531944882.10738.1.camel@intel.com>
	 <3f158401-f0b6-7bf7-48ab-2958354b28ad@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-18 at 14:45 -0700, Dave Hansen wrote:
> On 07/18/2018 01:14 PM, Yu-cheng Yu wrote:
> > 
> > On Tue, 2018-07-17 at 16:15 -0700, Dave Hansen wrote:
> > > 
> > > On 07/17/2018 04:03 PM, Yu-cheng Yu wrote:
> > > > 
> > > > 
> > > > We need to find a way to differentiate "someone can write to this PTE"
> > > > from "the write bit is set in this PTE".
> > > Please think about this:
> > > 
> > > 	Should pte_write() tell us whether PTE.W=1, or should it tell us
> > > 	that *something* can write to the PTE, which would include
> > > 	PTE.W=0/D=1?
> > 
> > Is it better now?
> > 
> > 
> > Subject: [PATCH] mm: Modify can_follow_write_pte/pmd for shadow stack
> > 
> > can_follow_write_pte/pmd look for the (RO & DIRTY) PTE/PMD to
> > verify a non-sharing RO page still exists after a broken COW.
> > 
> > However, a shadow stack PTE is always RO & DIRTY; it can be:
> > 
> > A  RO & DIRTY_HW - is_shstk_pte(pte) is true; or
> > A  RO & DIRTY_SW - the page is being shared.
> > 
> > Update these functions to check a non-sharing shadow stack page
> > still exists after the COW.
> > 
> > Also rename can_follow_write_pte/pmd() to can_follow_write() to
> > make their meaning clear; i.e. "Can we write to the page?", not
> > "Is the PTE writable?"
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> > A mm/gup.cA A A A A A A A A | 38 ++++++++++++++++++++++++++++++++++----
> > A mm/huge_memory.c | 19 ++++++++++++++-----
> > A 2 files changed, 48 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/gup.c b/mm/gup.c
> > index fc5f98069f4e..316967996232 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -63,11 +63,41 @@ static int follow_pfn_pte(struct vm_area_struct *vma, unsigned long address,
> > A /*
> > A  * FOLL_FORCE can write to even unwritable pte's, but only
> > A  * after we've gone through a COW cycle and they are dirty.
> > + *
> > + * Background:
> > + *
> > + * When we force-write to a read-only page, the page fault
> > + * handler copies the page and sets the new page's PTE to
> > + * RO & DIRTY.A A This routine tells
> > + *
> > + *A A A A A "Can we write to the page?"
> > + *
> > + * by checking:
> > + *
> > + *A A A A A (1) The page has been copied, i.e. FOLL_COW is set;
> > + *A A A A A (2) The copy still exists and its PTE is RO & DIRTY.
> > + *
> > + * However, a shadow stack PTE is always RO & DIRTY; it can
> > + * be:
> > + *
> > + *A A A A A RO & DIRTY_HW: when is_shstk_pte(pte) is true; or
> > + *A A A A A RO & DIRTY_SW: when the page is being shared.
> > + *
> > + * To test a shadow stack's non-sharing page still exists,
> > + * we verify that the new page's PTE is_shstk_pte(pte).
> The content is getting there, but we need it next to the code, please.
> 
> > 
> > A  */
> > -static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
> > +static inline bool can_follow_write(pte_t pte, unsigned int flags,
> > +				A A A A struct vm_area_struct *vma)
> > A {
> > -	return pte_write(pte) ||
> > -		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
> > +	if (!is_shstk_mapping(vma->vm_flags)) {
> > +		if (pte_write(pte))
> > +			return true;
> Let me see if I can say this another way.
> 
> The bigger issue is that these patches change the semantics of
> pte_write().A A Before these patches, it meant that you *MUST* have this
> bit set to write to the page controlled by the PTE.A A Now, it means: you
> can write if this bit is set *OR* the shadowstack bit combination is set.

Here, we only figure out (1) if the page is pointed by a writable PTE; or
(2) if the page is pointed by a RO PTE (data or SHSTK) and it has been
copied and it still exists. A We are not trying to
determine if the
SHSTK PTE is writable (we know it is not).

We look for the dirty bit to be sure the COW'ed page is still there.
The difference for the shadow stack case is that we look for the *hardware*
dirty bit. A Perhaps we can create another macro, pte_ro_dirty_hw(), which
is equivalent to is_shstk_pte().

> 
> That's the fundamental problem.A A We need some code in the kernel that
> logically represents the concept of "is this PTE a shadowstack PTE or a
> PTE with the write bit set", and we will call that pte_write(), or maybe
> pte_writable().
> 
> You *have* to somehow rectify this situation.A A We can absolutely no
> leave pte_write() in its current, ambiguous state where it has no real
> meaning or where it is used to mean _both_ things depending on context.

True, the processor can always write to a page through a shadow stack
PTE, but it must do that with a CALL instruction. A Can we define aA 
write operation as: MOV r1, *(r2). A Then we don't have any doubt on
pte_write() any more.

> 
> > 
> > +		return ((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
> > +			pte_dirty(pte));
> > +	} else {
> > +		return ((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
> > +			is_shstk_pte(pte));
> > +	}
> > A }
> Ok, it's rewrite time I guess.
> 
> Yu-cheng, you may not know all the history, but this code is actually
> the source of the "Dirty COW" security issue.A A We need to be very, very
> careful with it, and super-explicit about all the logic.A A This is the
> time to blow up the comments and walk folks through exactly what we
> expect to happen.
> 
> Anybody think I'm being too verbose?A A Is there a reason not to just go
> whole-hog on this sucker?
> 
> static inline bool can_follow_write(pte_t pte, unsigned int flags,
> 				A A A A struct vm_area_struct *vma)
> {
> 	/*
> 	 * FOLL_FORCE can "write" to hardware read-only PTEs, but
> 	 * has to do a COW operation first.A A Do not allow the
> 	 * hardware protection override unless we see FOLL_FORCE
> 	 * *and* the COW has been performed by the fault code.
> 	 */
> 	bool gup_cow_ok = (flags & FOLL_FORCE) &&
> 			A A (flags & FOLL_COW);
> 
> 	/*
> 	 * FOLL_COW flags tell us whether the page fault code did a COW
> 	 * operation but not whether the PTE we are dealing with here
> 	 * was COW'd.A A It could have been zapped and refaulted since the
> 	 * COW operation.
> 	 */
> 	bool pte_cow_ok;
> 
> 	/* We have two COW pte "formats" */
> 	if (!is_shstk_mapping(vma->vm_flags)) {
> 		if (pte_write(pte)) {
> 			/* Any hardware-writable PTE is writable here */
> 			pte_cow_ok = true;
> 		} else {
> 			/* Is the COW-set dirty bit still there? */
> 			pte_cow_ok = pte_dirty(pte));
> 		}
> 	} else {
> 		/* Shadow stack PTEs are always hardware-writable */
> 
> 		/*
> 		A * Shadow stack pages do copy-on-access, so any present
> 		A * shadow stack page has had a COW-equivalent performed.
> 		A */
> 		pte_cow_ok = is_shstk_pte(pte));
> 	}
> 
> 	return gup_cow_ok && pte_cow_ok;
> }

Ok, I will change it.

Yu-cheng
