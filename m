Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 914626B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 14:14:23 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 195so8317498wmf.0
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 11:14:23 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v2si2711749wmc.199.2018.04.04.11.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 11:14:21 -0700 (PDT)
Date: Wed, 4 Apr 2018 20:14:11 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 09/11] x86/pti: enable global pages for shared areas
In-Reply-To: <2D4AE288-DD01-416B-9633-1BC9B6A20BFF@vmware.com>
Message-ID: <alpine.DEB.2.21.1804042011550.1492@nanos.tec.linutronix.de>
References: <20180404010946.6186729B@viggo.jf.intel.com> <20180404011007.A381CC8A@viggo.jf.intel.com> <5DEE9F6E-535C-4DBF-A513-69D9FD5C0235@vmware.com> <50385d91-58a9-4b14-06bc-2340b99933c3@linux.intel.com> <2D4AE288-DD01-416B-9633-1BC9B6A20BFF@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, Hugh Dickins <hughd@google.com>, Juergen Gross <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

On Wed, 4 Apr 2018, Nadav Amit wrote:
> Dave Hansen <dave.hansen@linux.intel.com> wrote:
> > On 04/03/2018 09:45 PM, Nadav Amit wrote:
> >> Dave Hansen <dave.hansen@linux.intel.com> wrote:
> >>> void cea_set_pte(void *cea_vaddr, phys_addr_t pa, pgprot_t flags)
> >>> {
> >>> 	unsigned long va = (unsigned long) cea_vaddr;
> >>> +	pte_t pte = pfn_pte(pa >> PAGE_SHIFT, flags);
> >>> 
> >>> -	set_pte_vaddr(va, pfn_pte(pa >> PAGE_SHIFT, flags));
> >>> +	/*
> >>> +	 * The cpu_entry_area is shared between the user and kernel
> >>> +	 * page tables.  All of its ptes can safely be global.
> >>> +	 */
> >>> +	if (boot_cpu_has(X86_FEATURE_PGE))
> >>> +		pte = pte_set_flags(pte, _PAGE_GLOBAL);
> >> 
> >> I think it would be safer to check that the PTE is indeed present before
> >> setting _PAGE_GLOBAL. For example, percpu_setup_debug_store() sets PAGE_NONE
> >> for non-present entries. In this case, since PAGE_NONE and PAGE_GLOBAL use
> >> the same bit, everything would be fine, but it might cause bugs one day.
> > 
> > That's a reasonable safety thing to add, I think.
> > 
> > But, looking at it, I am wondering why we did this in
> > percpu_setup_debug_store():
> > 
> >        for (; npages; npages--, cea += PAGE_SIZE)
> >                cea_set_pte(cea, 0, PAGE_NONE);
> > 
> > Did we really want that to be PAGE_NONE, or was it supposed to create a
> > PTE that returns true for pte_none()?
> 
> I yield it to others to answer...

My bad. I should have used pgprot(0).

Thanks,

	tglx
