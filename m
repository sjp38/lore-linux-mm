Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB6526B0007
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 14:05:33 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id h15-v6so4942824wmd.0
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 11:05:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f198-v6sor3919016wmd.26.2018.10.24.11.05.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 11:05:32 -0700 (PDT)
MIME-Version: 1.0
References: <20181020211200.255171-1-marcorr@google.com> <20181020211200.255171-3-marcorr@google.com>
 <CAA03e5HWA4Vca=_J=VuQ__bLAdO8ohUU4r-hmxY1EbnVzsQHww@mail.gmail.com> <20181024114142.GD25444@bombadil.infradead.org>
In-Reply-To: <20181024114142.GD25444@bombadil.infradead.org>
From: Marc Orr <marcorr@google.com>
Date: Wed, 24 Oct 2018 19:05:19 +0100
Message-ID: <CAA03e5GsKySE76v1fwqvawqhNFL7V_Te8ZzNArNNtUiF+podgg@mail.gmail.com>
Subject: Re: [kvm PATCH 2/2] kvm: vmx: use vmalloc() to allocate vcpus
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Wed, Oct 24, 2018 at 12:41 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Tue, Oct 23, 2018 at 05:13:40PM -0400, Marc Orr wrote:
> > > +       struct vcpu_vmx *vmx = __vmalloc_node_range(
> > > +                       sizeof(struct vcpu_vmx),
> > > +                       __alignof__(struct vcpu_vmx),
> > > +                       VMALLOC_START,
> > > +                       VMALLOC_END,
> > > +                       GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO | __GFP_ACCOUNT,
> > > +                       PAGE_KERNEL,
> > > +                       0,
> > > +                       NUMA_NO_NODE,
> > > +                       __builtin_return_address(0));
>
> I don't understand why you need to expose the lowest-level
> __vmalloc_node_range to do what you need to do.
>
> For example, __vmalloc_node would be easier for you to use while giving you
> all the flexibility you think you want.
>
> In fact, I don't think you need all the flexibility you're using.
> vmalloc is always going to give you a page-aligned address, so
> __alignof__(struct foo) isn't going to do anything worthwhile.
>
> VMALLOC_START, VMALLOC_END, PAGE_KERNEL, 0, NUMA_NO_NODE, and
> __builtin_return_address(0) are all the defaults.  So all you actually
> need are these GFP flags.  __GFP_HIGHMEM isn't needed; vmalloc can
> always allocate from highmem unless you're doing a DMA alloc.  So
> it's just __GFP_ACCOUNT that's not supported by regular vzalloc().
>
> I see __vmalloc_node_flags_caller is already non-static, so that would
> be where I went and your call becomes simply:
>
>         vmx = __vmalloc_node_flags_caller(sizeof(struct vcpu_vmx),
>                                 NUMA_NO_NODE,
>                                 GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT,
>                                 __builtin_return_address(0));
>
> I suspect a better option might be to add a vzalloc_account() call
> and then your code becomes:
>
>         vmx = vzalloc_account(sizeof(struct vcpu_vmx));
>
> while vmalloc gains:
>
> void *vmalloc_account(unsigned long size)
> {
>         return __vmalloc_node_flags(size, NUMA_NO_NODE,
>                                 GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT);
> }
> EXPORT_SYMBOL(vmalloc_account);

I 100% agree with this review! I only need the __GFP_ACCOUNT flag.
Actually, the first version of this patch that I developed downstream,
resembled what you're suggesting here. But I've never touched the mm
subsystem before, and we were not confident on how to shape the patch
for upstreaming, so that's how we ended up with this version, which
makes minimal changes to the mm subsystem.

Anyway, let me refactor the patch exactly as you've suggested in your
review, and send out a new version.
