Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C06326B0319
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 10:45:34 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h9-v6so747618pgs.11
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 07:45:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g35-v6si11175733pgm.514.2018.10.26.07.45.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Oct 2018 07:45:33 -0700 (PDT)
Date: Fri, 26 Oct 2018 07:45:28 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Message-ID: <20181026144528.GS25444@bombadil.infradead.org>
References: <20181026075900.111462-1-marcorr@google.com>
 <20181026122948.GQ25444@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026122948.GQ25444@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Oct 26, 2018 at 05:29:48AM -0700, Matthew Wilcox wrote:
> A question that may have been asked already, but if so I didn't see it ...
> does kvm_vcpu need to be so damn big?  It's 22kB with the random .config
> I happen to have (which gets rounded to 32kB, an order-3 allocation).  If
> we can knock 6kB off it (either by allocating pieces separately), it becomes
> an order-2 allocation.  So, biggest chunks:
> 
>         struct kvm_vcpu_arch       arch;                 /*   576 21568 */
> 
>         struct kvm_mmu             mmu;                  /*   336   400 */
>         struct kvm_mmu             nested_mmu;           /*   736   400 */
>         struct fpu                 user_fpu;             /*  2176  4160 */
>         struct fpu                 guest_fpu;            /*  6336  4160 */
>         struct kvm_cpuid_entry2    cpuid_entries[80];    /* 10580  3200 */
>         struct x86_emulate_ctxt    emulate_ctxt;         /* 13792  2656 */
>         struct kvm_pmu             pmu;                  /* 17344  1520 */
>         struct kvm_vcpu_hv         hyperv;               /* 18872  1872 */
>                 gfn_t              gfns[64];             /* 20832   512 */
> 
> that's about 19kB of the 22kB right there.  Can any of them be shrunk
> in size or allocated separately?

I just had a fun conversation with Dave Hansen (cc'd) in which he
indicated that the fpu should definitely be dynamically allocated.
See also his commits from 2015 around XSAVE.

0c8c0f03e3a292e031596484275c14cf39c0ab7a
4109ca066b6b899ac7549bf3aac94b178ac95891
