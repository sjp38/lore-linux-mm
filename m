Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB536B03AE
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:01:35 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n11so30346677wma.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:01:35 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id 18si15147406wms.61.2017.03.06.08.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 08:01:33 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id u108so18341327wrb.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:01:33 -0800 (PST)
Date: Mon, 6 Mar 2017 17:01:30 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
Message-ID: <20170306160130.bwp73tkkkxafbizg@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <10344634.XsotFaGzfj@avalon>
 <20170306103820.ixuvs7fd6s4tvfzy@phenom.ffwll.local>
 <9366352.DJUlrUijoL@avalon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9366352.DJUlrUijoL@avalon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org, Laura Abbott <labbott@redhat.com>, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Riley Andrews <riandrews@android.com>, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Mon, Mar 06, 2017 at 05:02:05PM +0200, Laurent Pinchart wrote:
> Hi Daniel,
> 
> On Monday 06 Mar 2017 11:38:20 Daniel Vetter wrote:
> > On Fri, Mar 03, 2017 at 06:45:40PM +0200, Laurent Pinchart wrote:
> > > - I haven't seen any proposal how a heap-based solution could be used in a
> > > generic distribution. This needs to be figured out before committing to
> > > any API/ABI.
> > 
> > Two replies from my side:
> > 
> > - Just because a patch doesn't solve world hunger isn't really a good
> >   reason to reject it.
> 
> As long as it goes in the right direction, sure :-) The points I mentioned 
> were to be interpreted that way, I want to make sure we're not going in a 
> dead-end (or worse, driving full speed into a wall).
> 
> > - Heap doesn't mean its not resizeable (but I'm not sure that's really
> >   your concern).
> 
> Not really, no. Heap is another word to mean pool here. It might not be the 
> best term in this context as it has a precise meaning in the context of memory 
> allocation, but that's a detail.
> 
> > - Imo ION is very much part of the picture here to solve this for real. We
> >   need to bits:
> > 
> >   * Be able to allocate memory from specific pools, not going through a
> >     specific driver. ION gives us that interface. This is e.g. also needed
> >     for "special" memory, like SMA tries to expose.
> > 
> >   * Some way to figure out how&where to allocate the buffer object. This
> >     is purely a userspace problem, and this is the part the unix memory
> >     allocator tries to solve. There's no plans in there for big kernel
> >     changes, instead userspace does a dance to reconcile all the
> >     constraints, and one of the constraints might be "you have to allocate
> >     this from this special ION heap". The only thing the kernel needs to
> >     expose is which devices use which ION heaps (we kinda do that
> >     already), and maybe some hints of how they can be generalized (but I
> >     guess stuff like "minimal pagesize of x KB" is also fulfilled by any
> >     CMA heap is knowledge userspace needs).
> 
> The constraint solver could live in userspace, I'm open to a solution that 
> would go in that direction, but it will require help from the kernel to fetch 
> the constraints from the devices that need to be involved in buffer sharing.
> 
> Given a userspace constraint resolver, the interface with the kernel allocator 
> will likely be based on pools. I'm not opposed to that, as long as pool are 
> identified by opaque handles. I don't want userspace to know about the meaning 
> of any particular ION heap. Application must not attempt to "allocate from 
> CMA" for instance, that would lock us to a crazy API that will grow completely 
> out of hands as vendors will start adding all kind of custom heaps, and 
> applications will have to follow (or will be patched out-of-tree by vendors).
> 
> > Again I think waiting for this to be fully implemented before we merge any
> > part is going to just kill any upstreaming efforts. ION in itself, without
> > the full buffer negotiation dance seems clearly useful (also for stuff
> > like SMA), and having it merged will help with moving the buffer
> > allocation dance forward.
> 
> Again I'm not opposed to a kernel allocator based on pools/heaps, as long as
> 
> - pools/heaps stay internal to the kernel and are not directly exposed to 
> userspace

Agreed (and I think ION doesn't have fixed pools afaik, just kinda
conventions, at least after Laura's patches). But on a fixed board with a
fixed DT (for the cma regions) and fixed .config (for the generic heaps)
you can hardcode your heaps. You'll make your code non-portable, but hey
that's not our problem imo. E.g. board-specific code can also hard-code
how to wire connectors and which one is which in kms (and I've seen this).
I don't think the possibility of abusing the uabi should be a good reason
to prevent it from merging. Anything that provides something with indirect
connections can be abused by hardcoding the names or the indizes.

We do have a TODO entry that talks about exposing the device -> cma heap
link in sysfs or somewhere. I'm not versed enough to know whether Laura's
patches fixed that, this here mostly seems to tackle the fundamentals of
the dma api abuse first.

> - a reasonable way to size the different kinds of pools in a generic 
> distribution kernel can be found

So for the CMA heaps, you can't resize them at runtime, for obvious
reasons. For boot-time you can adjust them through DT, and I thought
everyone agreed that for different use-cases you might need to adjust your
reserved regions.

For all other heaps, they just use the normal allocator functions
(e.g. alloc_pages). There's not limit on those except OOM, so nothing to
adjust really.

I guess I'm still not entirely clear on your "memory pool" concern ... If
it's just the word, we have lots of auto-resizing heaps/pools all around.
And if it's just sizing, I think that's already solved as good as possible
(assuming there's not a silly limit on the system heap that we should
remove ...).

Cheers, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
