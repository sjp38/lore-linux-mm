Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 797DA6B000A
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 18:31:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j9-v6so2822173pfn.20
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:31:37 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 63-v6si5930638pgj.221.2018.10.24.15.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 15:31:36 -0700 (PDT)
Date: Wed, 24 Oct 2018 15:31:35 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: Re: [kvm PATCH 2/2] kvm: vmx: use vmalloc() to allocate vcpus
Message-ID: <20181024223135.GA23176@linux.intel.com>
References: <20181020211200.255171-1-marcorr@google.com>
 <20181020211200.255171-3-marcorr@google.com>
 <CAA03e5HWA4Vca=_J=VuQ__bLAdO8ohUU4r-hmxY1EbnVzsQHww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA03e5HWA4Vca=_J=VuQ__bLAdO8ohUU4r-hmxY1EbnVzsQHww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Tue, Oct 23, 2018 at 05:13:40PM -0400, Marc Orr wrote:
> Adding everyone that's cc'd on [kvm PATCH 1/2] mm: export
> __vmalloc_node_range().
> Thanks,
> Marc
> On Sat, Oct 20, 2018 at 5:13 PM Marc Orr <marcorr@google.com> wrote:
> >
> > Previously, vcpus were allocated through the kmem_cache_zalloc() API,
> > which requires the underlying physical memory to be contiguous.
> > Because the x86 vcpu struct, struct vcpu_vmx, is relatively large
> > (e.g., currently 47680 bytes on my setup), it can become hard to find
> > contiguous memory.
> >
> > At the same time, the comments in the code indicate that the primary
> > reason for using the kmem_cache_zalloc() API is to align the memory
> > rather than to provide physical contiguity.
> >
> > Thus, this patch updates the vcpu allocation logic for vmx to use the
> > vmalloc() API.
> >
> > Signed-off-by: Marc Orr <marcorr@google.com>
> > ---
> >  arch/x86/kvm/vmx.c  | 98 +++++++++++++++++++++++++++++++++++++++++----
> >  virt/kvm/kvm_main.c | 28 +++++++------
> >  2 files changed, 106 insertions(+), 20 deletions(-)
> >
> > diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> > index abeeb45d1c33..d480a2cc0667 100644
> > --- a/arch/x86/kvm/vmx.c
> > +++ b/arch/x86/kvm/vmx.c
> > @@ -898,7 +898,14 @@ struct nested_vmx {
> >  #define POSTED_INTR_ON  0
> >  #define POSTED_INTR_SN  1
> >
> > -/* Posted-Interrupt Descriptor */
> > +/*
> > + * Posted-Interrupt Descriptor
> > + *
> > + * Note, the physical address of this structure is used by VMX. Furthermore, the
> > + * translation code assumes that the entire pi_desc struct resides within a
> > + * single page, which will be true because the struct is 64 bytes and 64-byte
> > + * aligned.
> > + */
> >  struct pi_desc {
> >         u32 pir[8];     /* Posted interrupt requested */
> >         union {
> > @@ -970,8 +977,25 @@ static inline int pi_test_sn(struct pi_desc *pi_desc)
> >
> >  struct vmx_msrs {
> >         unsigned int            nr;
> > -       struct vmx_msr_entry    val[NR_AUTOLOAD_MSRS];
> > +       struct vmx_msr_entry    *val;
> >  };
> > +struct kmem_cache *vmx_msr_entry_cache;

The vmx_msr_entry changes should be done as a separate prereq patch,
e.g. for bisecting and/or revert in case there is a bug.  AFAICT they
don't depend on moving to vmalloc.
