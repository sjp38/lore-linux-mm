Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E075D6B0269
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:07:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i123-v6so7841110pfc.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 02:07:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z9-v6si20678086pfg.46.2018.07.11.02.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 02:07:01 -0700 (PDT)
Date: Wed, 11 Jul 2018 11:06:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v2 13/27] mm: Handle shadow stack page fault
Message-ID: <20180711090656.GS2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-14-yu-cheng.yu@intel.com>
 <2f3ff321-c629-3e00-59f6-8bca510650d4@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f3ff321-c629-3e00-59f6-8bca510650d4@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, Jul 10, 2018 at 04:06:25PM -0700, Dave Hansen wrote:
> On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> > +	if (is_shstk_mapping(vma->vm_flags))
> > +		entry = pte_mkdirty_shstk(entry);
> > +	else
> > +		entry = pte_mkdirty(entry);
> > +
> > +	entry = maybe_mkwrite(entry, vma);
> >  	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
> >  		update_mmu_cache(vma, vmf->address, vmf->pte);
> >  	pte_unmap_unlock(vmf->pte, vmf->ptl);
> > @@ -2526,7 +2532,11 @@ static int wp_page_copy(struct vm_fault *vmf)
> >  		}
> >  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
> >  		entry = mk_pte(new_page, vma->vm_page_prot);
> > -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> > +		if (is_shstk_mapping(vma->vm_flags))
> > +			entry = pte_mkdirty_shstk(entry);
> > +		else
> > +			entry = pte_mkdirty(entry);
> > +		entry = maybe_mkwrite(entry, vma);
> 
> Do we want to lift this hunk of code and put it elsewhere?  Maybe:
> 
> 	entry = pte_set_vma_features(entry, vma);
> 
> and then:
> 
> pte_t pte_set_vma_features(pte_t entry, struct vm_area_struct)
> {
> 		/*
> 		 * Shadow stack PTEs are always dirty and always
> 		 * writable.  They have a different encoding for
> 		 * this than normal PTEs, though.
> 		 */
> 		if (is_shstk_mapping(vma->vm_flags))
> 			entry = pte_mkdirty_shstk(entry);
> 		else
> 			entry = pte_mkdirty(entry);
> 
> 		entry = maybe_mkwrite(entry, vma);
> 
> 	return entry;
> }

Yes, that wants a helper like that. Not sold on the name, but whatever.

Is there any way we can hide all the shadow stack magic in arch code?
