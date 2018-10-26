Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAE0A6B0311
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 08:29:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i81-v6so583398pfj.1
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 05:29:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q188-v6si11631533pfb.132.2018.10.26.05.29.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Oct 2018 05:29:52 -0700 (PDT)
Date: Fri, 26 Oct 2018 05:29:48 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [kvm PATCH v4 0/2] use vmalloc to allocate vmx vcpus
Message-ID: <20181026122948.GQ25444@bombadil.infradead.org>
References: <20181026075900.111462-1-marcorr@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026075900.111462-1-marcorr@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, sean.j.christopherson@intel.com

On Fri, Oct 26, 2018 at 12:58:58AM -0700, Marc Orr wrote:
> A couple of patches to allocate vmx vcpus with vmalloc instead of
> kalloc, which enables vcpu allocation to succeeed when contiguous
> physical memory is sparse.

A question that may have been asked already, but if so I didn't see it ...
does kvm_vcpu need to be so damn big?  It's 22kB with the random .config
I happen to have (which gets rounded to 32kB, an order-3 allocation).  If
we can knock 6kB off it (either by allocating pieces separately), it becomes
an order-2 allocation.  So, biggest chunks:

        struct kvm_vcpu_arch       arch;                 /*   576 21568 */

        struct kvm_mmu             mmu;                  /*   336   400 */
        struct kvm_mmu             nested_mmu;           /*   736   400 */
        struct fpu                 user_fpu;             /*  2176  4160 */
        struct fpu                 guest_fpu;            /*  6336  4160 */
        struct kvm_cpuid_entry2    cpuid_entries[80];    /* 10580  3200 */
        struct x86_emulate_ctxt    emulate_ctxt;         /* 13792  2656 */
        struct kvm_pmu             pmu;                  /* 17344  1520 */
        struct kvm_vcpu_hv         hyperv;               /* 18872  1872 */
                gfn_t              gfns[64];             /* 20832   512 */

that's about 19kB of the 22kB right there.  Can any of them be shrunk
in size or allocated separately?
