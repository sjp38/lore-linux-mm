Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 692696B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 17:29:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h5-v6so9175068pgs.13
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 14:29:16 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z19-v6si20584041pgi.388.2018.08.14.14.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 14:29:14 -0700 (PDT)
Message-ID: <1534282125.24160.9.camel@intel.com>
Subject: Re: [RFC PATCH v2 13/27] mm: Handle shadow stack page fault
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 14 Aug 2018 14:28:45 -0700
In-Reply-To: <20180711090656.GS2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-14-yu-cheng.yu@intel.com>
	 <2f3ff321-c629-3e00-59f6-8bca510650d4@linux.intel.com>
	 <20180711090656.GS2476@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 11:06 +0200, Peter Zijlstra wrote:
> On Tue, Jul 10, 2018 at 04:06:25PM -0700, Dave Hansen wrote:
> > 
> > On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> > > 
> > > +	if (is_shstk_mapping(vma->vm_flags))
> > > +		entry = pte_mkdirty_shstk(entry);
> > > +	else
> > > +		entry = pte_mkdirty(entry);
> > > +
> > > +	entry = maybe_mkwrite(entry, vma);
> > > A 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte,
> > > entry, 1))
> > > A 		update_mmu_cache(vma, vmf->address, vmf->pte);
> > > A 	pte_unmap_unlock(vmf->pte, vmf->ptl);
> > > @@ -2526,7 +2532,11 @@ static int wp_page_copy(struct vm_fault
> > > *vmf)
> > > A 		}
> > > A 		flush_cache_page(vma, vmf->address,
> > > pte_pfn(vmf->orig_pte));
> > > A 		entry = mk_pte(new_page, vma->vm_page_prot);
> > > -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> > > +		if (is_shstk_mapping(vma->vm_flags))
> > > +			entry = pte_mkdirty_shstk(entry);
> > > +		else
> > > +			entry = pte_mkdirty(entry);
> > > +		entry = maybe_mkwrite(entry, vma);
> > Do we want to lift this hunk of code and put it elsewhere?A A Maybe:
> > 
> > 	entry = pte_set_vma_features(entry, vma);
> > 
> > and then:
> > 
> > pte_t pte_set_vma_features(pte_t entry, struct vm_area_struct)
> > {
> > 		/*
> > 		A * Shadow stack PTEs are always dirty and always
> > 		A * writable.A A They have a different encoding for
> > 		A * this than normal PTEs, though.
> > 		A */
> > 		if (is_shstk_mapping(vma->vm_flags))
> > 			entry = pte_mkdirty_shstk(entry);
> > 		else
> > 			entry = pte_mkdirty(entry);
> > 
> > 		entry = maybe_mkwrite(entry, vma);
> > 
> > 	return entry;
> > }
> Yes, that wants a helper like that. Not sold on the name, but
> whatever.
> 
> Is there any way we can hide all the shadow stack magic in arch
> code?

We use is_shstk_mapping() only to determine PAGE_DIRTY_SW or
PAGE_DIRTY_HW should be set in a PTE. A One way to remove this shadow
stack code from generic code is changing pte_mkdirty(pte) to
pte_mkdirty(pte, vma), and in the arch code we handle shadow stack.
Is this acceptable?

Thanks,
Yu-cheng
