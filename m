Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 683156B027D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 07:41:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a72-v6so3115729pfj.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 04:41:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y76-v6si4721786pfd.254.2018.10.24.04.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Oct 2018 04:41:48 -0700 (PDT)
Date: Wed, 24 Oct 2018 04:41:42 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [kvm PATCH 2/2] kvm: vmx: use vmalloc() to allocate vcpus
Message-ID: <20181024114142.GD25444@bombadil.infradead.org>
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
> > +       struct vcpu_vmx *vmx = __vmalloc_node_range(
> > +                       sizeof(struct vcpu_vmx),
> > +                       __alignof__(struct vcpu_vmx),
> > +                       VMALLOC_START,
> > +                       VMALLOC_END,
> > +                       GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO | __GFP_ACCOUNT,
> > +                       PAGE_KERNEL,
> > +                       0,
> > +                       NUMA_NO_NODE,
> > +                       __builtin_return_address(0));

I don't understand why you need to expose the lowest-level
__vmalloc_node_range to do what you need to do.

For example, __vmalloc_node would be easier for you to use while giving you
all the flexibility you think you want.

In fact, I don't think you need all the flexibility you're using.
vmalloc is always going to give you a page-aligned address, so
__alignof__(struct foo) isn't going to do anything worthwhile.

VMALLOC_START, VMALLOC_END, PAGE_KERNEL, 0, NUMA_NO_NODE, and
__builtin_return_address(0) are all the defaults.  So all you actually
need are these GFP flags.  __GFP_HIGHMEM isn't needed; vmalloc can
always allocate from highmem unless you're doing a DMA alloc.  So
it's just __GFP_ACCOUNT that's not supported by regular vzalloc().

I see __vmalloc_node_flags_caller is already non-static, so that would
be where I went and your call becomes simply:

	vmx = __vmalloc_node_flags_caller(sizeof(struct vcpu_vmx),
				NUMA_NO_NODE,
				GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT,
				__builtin_return_address(0));

I suspect a better option might be to add a vzalloc_account() call
and then your code becomes:

	vmx = vzalloc_account(sizeof(struct vcpu_vmx));

while vmalloc gains:

void *vmalloc_account(unsigned long size)
{
	return __vmalloc_node_flags(size, NUMA_NO_NODE,
				GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT);
}
EXPORT_SYMBOL(vmalloc_account);
