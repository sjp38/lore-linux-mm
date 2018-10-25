Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2AE26B0297
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 08:58:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c6-v6so5226491pls.15
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:58:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x10-v6si7590733plo.100.2018.10.25.05.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 05:58:48 -0700 (PDT)
Date: Thu, 25 Oct 2018 14:58:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [kvm PATCH 2/2] kvm: vmx: use vmalloc() to allocate vcpus
Message-ID: <20181025125844.GR18839@dhcp22.suse.cz>
References: <20181020211200.255171-1-marcorr@google.com>
 <20181020211200.255171-3-marcorr@google.com>
 <CAA03e5HWA4Vca=_J=VuQ__bLAdO8ohUU4r-hmxY1EbnVzsQHww@mail.gmail.com>
 <20181024114142.GD25444@bombadil.infradead.org>
 <CAA03e5GsKySE76v1fwqvawqhNFL7V_Te8ZzNArNNtUiF+podgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA03e5GsKySE76v1fwqvawqhNFL7V_Te8ZzNArNNtUiF+podgg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: willy@infradead.org, kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Wed 24-10-18 19:05:19, Marc Orr wrote:
> On Wed, Oct 24, 2018 at 12:41 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Tue, Oct 23, 2018 at 05:13:40PM -0400, Marc Orr wrote:
> > > > +       struct vcpu_vmx *vmx = __vmalloc_node_range(
> > > > +                       sizeof(struct vcpu_vmx),
> > > > +                       __alignof__(struct vcpu_vmx),
> > > > +                       VMALLOC_START,
> > > > +                       VMALLOC_END,
> > > > +                       GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO | __GFP_ACCOUNT,
> > > > +                       PAGE_KERNEL,
> > > > +                       0,
> > > > +                       NUMA_NO_NODE,
> > > > +                       __builtin_return_address(0));
> >
> > I don't understand why you need to expose the lowest-level
> > __vmalloc_node_range to do what you need to do.
> >
> > For example, __vmalloc_node would be easier for you to use while giving you
> > all the flexibility you think you want.
> >
> > In fact, I don't think you need all the flexibility you're using.
> > vmalloc is always going to give you a page-aligned address, so
> > __alignof__(struct foo) isn't going to do anything worthwhile.
> >
> > VMALLOC_START, VMALLOC_END, PAGE_KERNEL, 0, NUMA_NO_NODE, and
> > __builtin_return_address(0) are all the defaults.  So all you actually
> > need are these GFP flags.  __GFP_HIGHMEM isn't needed; vmalloc can
> > always allocate from highmem unless you're doing a DMA alloc.  So
> > it's just __GFP_ACCOUNT that's not supported by regular vzalloc().
> >
> > I see __vmalloc_node_flags_caller is already non-static, so that would
> > be where I went and your call becomes simply:
> >
> >         vmx = __vmalloc_node_flags_caller(sizeof(struct vcpu_vmx),
> >                                 NUMA_NO_NODE,
> >                                 GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT,
> >                                 __builtin_return_address(0));
> >
> > I suspect a better option might be to add a vzalloc_account() call
> > and then your code becomes:
> >
> >         vmx = vzalloc_account(sizeof(struct vcpu_vmx));
> >
> > while vmalloc gains:
> >
> > void *vmalloc_account(unsigned long size)
> > {
> >         return __vmalloc_node_flags(size, NUMA_NO_NODE,
> >                                 GFP_KERNEL | __GFP_ZERO | __GFP_ACCOUNT);
> > }
> > EXPORT_SYMBOL(vmalloc_account);
> 
> I 100% agree with this review! I only need the __GFP_ACCOUNT flag.

__vmalloc is already exported. Can you use that instead?

> Actually, the first version of this patch that I developed downstream,
> resembled what you're suggesting here. But I've never touched the mm
> subsystem before, and we were not confident on how to shape the patch
> for upstreaming, so that's how we ended up with this version, which
> makes minimal changes to the mm subsystem.

And now you can see why there was a pushback to add the user of the
exported api in a single patch. It is much easier to review that way.
-- 
Michal Hocko
SUSE Labs
