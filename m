Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 144766B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 00:59:46 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j3so4398677wrb.18
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 21:59:46 -0800 (PST)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id 36si270438wry.292.2018.03.08.21.59.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 21:59:44 -0800 (PST)
Date: Fri, 9 Mar 2018 06:59:43 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
In-Reply-To: <20180308230512.GD29073@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1803090654480.2321@hadrien>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org> <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com> <alpine.DEB.2.20.1803072212160.2814@hadrien> <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien> <20180308230512.GD29073@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>



On Thu, 8 Mar 2018, Matthew Wilcox wrote:

> On Thu, Mar 08, 2018 at 07:24:47AM +0100, Julia Lawall wrote:
> > On Wed, 7 Mar 2018, Matthew Wilcox wrote:
> > > On Wed, Mar 07, 2018 at 10:18:21PM +0100, Julia Lawall wrote:
> > > > > Otherwise, yes, please. We could build a coccinelle rule for
> > > > > additional replacements...
> > > >
> > > > A potential semantic patch and the changes it generates are attached
> > > > below.  Himanshu Jha helped with its development.  Working on this
> > > > uncovered one bug, where the allocated array is too large, because the
> > > > size provided for it was a structure size, but actually only pointers to
> > > > that structure were to be stored in it.
> > >
> > > This is cool!  Thanks for doing the coccinelle patch!  Diffstat:
> > >
> > >  50 files changed, 81 insertions(+), 124 deletions(-)
> > >
> > > I find that pretty compelling.  I'll repost the kvmalloc_struct patch
> > > imminently.
> >
> > Thanks.  So it's OK to replace kmalloc and kzalloc, even though they
> > didn't previously consider vmalloc and even though kmalloc doesn't zero?
>
> We'll also need to replace the corresponding places where those structs
> are freed with kvfree().  Can coccinelle handle that too?

This would be harder to do 100% reliably.  Coccinelle would have to rely
on the structure name or the structure type, if the free is in a different
function.  But I guess that the type should be mostly reliable, since all
instances of allocations of the same type should be transformed in the
same way.

>
> > There are a few other cases that use GFP_NOFS and GFP_NOWAIT, but I didn't
> > transform those because the comment says that the flags should be
> > GFP_KERNEL based.  Should those be transformed too?
>
> The problem with non-GFP_KERNEL allocations is that vmalloc may have to
> allocate page tables, which is always done with an implicit GFP_KERNEL
> allocation.  There's an intent to get rid of GFP_NOFS, but that's not
> been realised yet (and I'm not sure of our strategy to eliminate it ...
> I'll send a separate email about that).  I'm not sure why anything's
> trying to allocate with GFP_NOWAIT; can you send a list of those places?

drivers/dma/fsl-edma.c:

fsl_desc = kzalloc(sizeof(*fsl_desc) + sizeof(struct fsl_edma_sw_tcd) * sg_len, GFP_NOWAIT);

drivers/dma/st_fdma.c:

fdesc = kzalloc(sizeof(*fdesc) + sizeof(struct st_fdma_sw_node) * sg_len,
GFP_NOWAIT);

drivers/dma/pxa_dma.c:

sw_desc = kzalloc(sizeof(*sw_desc) + nb_hw_desc * sizeof(struct
pxad_desc_hw *), GFP_NOWAIT);

julia
