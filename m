Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B16BA6B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:10:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 66-v6so5008805plb.18
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:10:03 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x2-v6si5718443plv.388.2018.07.19.10.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 10:10:02 -0700 (PDT)
Message-ID: <1532019963.16711.61.camel@intel.com>
Subject: Re: [RFC PATCH v2 16/27] mm: Modify can_follow_write_pte/pmd for
 shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 19 Jul 2018 10:06:03 -0700
In-Reply-To: <f4c90626-51d8-5551-5b77-baaff81f16bb@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-17-yu-cheng.yu@intel.com>
	 <de510df6-7ea9-edc6-9c49-2f80f16472b4@linux.intel.com>
	 <1531328731.15351.3.camel@intel.com>
	 <45a85b01-e005-8cb6-af96-b23ce9b5fca7@linux.intel.com>
	 <1531868610.3541.21.camel@intel.com>
	 <fa9db8c5-41c8-05e9-ad8d-dc6aaf11cb04@linux.intel.com>
	 <1531944882.10738.1.camel@intel.com>
	 <3f158401-f0b6-7bf7-48ab-2958354b28ad@linux.intel.com>
	 <1531955428.12385.30.camel@intel.com>
	 <f4c90626-51d8-5551-5b77-baaff81f16bb@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-18 at 17:06 -0700, Dave Hansen wrote:
> > 
> > > 
> > > > 
> > > > -static inline bool can_follow_write_pte(pte_t pte, unsigned
> > > > int flags)
> > > > +static inline bool can_follow_write(pte_t pte, unsigned int
> > > > flags,
> > > > +				A A A A struct vm_area_struct
> > > > *vma)
> > > > A {
> > > > -	return pte_write(pte) ||
> > > > -		((flags & FOLL_FORCE) && (flags & FOLL_COW)
> > > > && pte_dirty(pte));
> > > > +	if (!is_shstk_mapping(vma->vm_flags)) {
> > > > +		if (pte_write(pte))
> > > > +			return true;
> > > Let me see if I can say this another way.
> > > 
> > > The bigger issue is that these patches change the semantics of
> > > pte_write().A A Before these patches, it meant that you *MUST*
> > > have this
> > > bit set to write to the page controlled by the PTE.A A Now, it
> > > means: you
> > > can write if this bit is set *OR* the shadowstack bit
> > > combination is set.
> > Here, we only figure out (1) if the page is pointed by a writable
> > PTE; or
> > (2) if the page is pointed by a RO PTE (data or SHSTK) and it has
> > been
> > copied and it still exists. A We are not trying to
> > determine if the
> > SHSTK PTE is writable (we know it is not).
> Please think about the big picture.A A I'm not just talking about this
> patch, but about every use of pte_write() in the kernel.
> 
> > 
> > > 
> > > That's the fundamental problem.A A We need some code in the kernel
> > > that
> > > logically represents the concept of "is this PTE a shadowstack
> > > PTE or a
> > > PTE with the write bit set", and we will call that pte_write(),
> > > or maybe
> > > pte_writable().
> > > 
> > > You *have* to somehow rectify this situation.A A We can absolutely
> > > no
> > > leave pte_write() in its current, ambiguous state where it has
> > > no real
> > > meaning or where it is used to mean _both_ things depending on
> > > context.
> > True, the processor can always write to a page through a shadow
> > stack
> > PTE, but it must do that with a CALL instruction. A Can we define
> > aA 
> > write operation as: MOV r1, *(r2). A Then we don't have any doubt
> > on
> > pte_write() any more.
> No, we can't just move the target. :)
> 
> You can define it this way, but then you also need to go to every
> spot
> in the kernel that calls pte_write() (and _PAGE_RW in fact) and
> audit it
> to ensure it means "mov ..." and not push.

Which pte_write() do you think is right?

bool is_shstk_pte(pte) {
	return (_PAGE_RW not set) &&
(_PAGE_DIRTY_HW set);
}

int pte_write_1(pte) {
	return (_PAGE_RW set) && !is_shstk_pte(pte);
}

int pte_write_2(pte) {
	return (_PAGE_RW set) || is_shstk_pte(pte);
}

Yu-cheng
