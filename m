Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED256B0007
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 05:04:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h26-v6so361272eds.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 02:04:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f6-v6si8853429edt.166.2018.08.15.02.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 02:04:39 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7F947H7172171
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 05:04:38 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kverhdrvd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 05:04:37 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 15 Aug 2018 10:04:36 +0100
Date: Wed, 15 Aug 2018 12:04:29 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] docs/core-api: add memory allocation guide
References: <1534314887-9202-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180815063649.GB24091@rapoport-lnx>
 <20180815081539.GN32645@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815081539.GN32645@dhcp22.suse.cz>
Message-Id: <20180815090428.GD24091@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Aug 15, 2018 at 10:15:39AM +0200, Michal Hocko wrote:
> On Wed 15-08-18 09:36:49, Mike Rapoport wrote:
> > (this time with the subject, sorry for the noise)
> > 
> > On Wed, Aug 15, 2018 at 09:34:47AM +0300, Mike Rapoport wrote:
> > > As Vlastimil mentioned at [1], it would be nice to have some guide about
> > > memory allocation. I've drafted an initial version that tries to summarize
> > > "best practices" for allocation functions and GFP usage.
> > > 
> > > [1] https://www.spinics.net/lists/netfilter-devel/msg55542.html
> > > 
> > > From 8027c0d4b750b8dbd687234feda63305d0d5a057 Mon Sep 17 00:00:00 2001
> > > From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > Date: Wed, 15 Aug 2018 09:10:06 +0300
> > > Subject: [RFC PATCH] docs/core-api: add memory allocation guide
> > > 
> > > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > ---
> > >  Documentation/core-api/gfp_mask-from-fs-io.rst |   2 +
> > >  Documentation/core-api/index.rst               |   1 +
> > >  Documentation/core-api/memory-allocation.rst   | 117 +++++++++++++++++++++++++
> > >  Documentation/core-api/mm-api.rst              |   2 +
> > >  4 files changed, 122 insertions(+)
> > >  create mode 100644 Documentation/core-api/memory-allocation.rst
> > > 
> > > diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
> > > index e0df8f4..e7c32a8 100644
> > > --- a/Documentation/core-api/gfp_mask-from-fs-io.rst
> > > +++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
> > > @@ -1,3 +1,5 @@
> > > +.. _gfp_mask_from_fs_io:
> > > +
> > >  =================================
> > >  GFP masks used from FS/IO context
> > >  =================================
> > > diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
> > > index cdc2020..8afc0da 100644
> > > --- a/Documentation/core-api/index.rst
> > > +++ b/Documentation/core-api/index.rst
> > > @@ -27,6 +27,7 @@ Core utilities
> > >     errseq
> > >     printk-formats
> > >     circular-buffers
> > > +   memory-allocation
> > >     mm-api
> > >     gfp_mask-from-fs-io
> > >     timekeeping
> > > diff --git a/Documentation/core-api/memory-allocation.rst b/Documentation/core-api/memory-allocation.rst
> > > new file mode 100644
> > > index 0000000..b1f2ad5
> > > --- /dev/null
> > > +++ b/Documentation/core-api/memory-allocation.rst
> > > @@ -0,0 +1,117 @@
> > > +=======================
> > > +Memory Allocation Guide
> > > +=======================
> > > +
> > > +Linux supplies variety of APIs for memory allocation. You can allocate
> > > +small chunks using `kmalloc` or `kmem_cache_alloc` families, large
> > > +virtually contiguous areas using `vmalloc` and it's derivatives, or
> > > +you can directly request pages from the page allocator with
> > > +`__get_free_pages`. It is also possible to use more specialized
> 
> I would rather not mention __get_free_pages. alloc_pages is a more
> generic API and less subtle one. If you want to mention __get_free_pages
> then please make sure to mention the subtlety (namely that is can
> allocate only lowmem memory).
> 
> > > +allocators, for instance `cma_alloc` or `zs_malloc`.
> > > +
> > > +Most of the memory allocations APIs use GFP flags to express how that
> > > +memory should be allocated. The GFP acronym stands for "get free
> > > +pages", the underlying memory allocation function.
> > > +
> > > +Diversity of the allocation APIs combined with the numerous GFP flags
> > > +makes the question "How should I allocate memory?" not that easy to
> > > +answer, although very likely you should use
> > > +
> > > +::
> > > +
> > > +  kzalloc(<size>, GFP_KERNEL);
> > > +
> > > +Of course there are cases when other allocation APIs and different GFP
> > > +flags must be used.
> > > +
> > > +Get Free Page flags
> > > +===================
> > > +
> > > +The GFP flags control the allocators behavior. They tell what memory
> > > +zones can be used, how hard the allocator should try to find a free
> > > +memory, whether the memory can be accessed by the userspace etc. The
> > > +:ref:`Documentation/core-api/mm-api.rst <mm-api-gfp-flags>` provides
> > > +reference documentation for the GFP flags and their combinations and
> > > +here we briefly outline their recommended usage:
> > > +
> > > +  * Most of the times ``GFP_KERNEL`` is what you need. Memory for the
> > > +    kernel data structures, DMAable memory, inode cache, all these and
> > > +    many other allocations types can use ``GFP_KERNEL``. Note, that
> > > +    using ``GFP_KERNEL`` implies ``GFP_RECLAIM``, which means that
> > > +    direct reclaim may be triggered under memory pressure; the calling
> > > +    context must be allowed to sleep.
> > > +  * If the allocation is performed from an atomic context, e.g
> > > +    interrupt handler, use ``GFP_ATOMIC``.
> 
> GFP_NOWAIT please. GFP_ATOMIC should be only used if accessing memory
> reserves is justified. E.g. fallback allocation would be too costly. It
> should be also noted that these allocation are quite likely to fail
> especially under memory pressure.
 
How about:

* If the allocation is performed from an atomic context, e.g interrupt
  handler, use ``GFP_NOWARN``. This flag prevents direct reclaim and IO or
  filesystem operations. Consequently, under memory pressure ``GFP_NOWARN``
  allocation is likely to fail.
* If you think that accessing memory reserves is justified and the kernel
  will be stressed unless allocation succeeds, you may use ``GFP_ATOMIC``.

> > > +  * Untrusted allocations triggered from userspace should be a subject
> > > +    of kmem accounting and must have ``__GFP_ACCOUNT`` bit set. There
> > > +    is handy ``GFP_KERNEL_ACCOUNT`` shortcut for ``GFP_KERNEL``
> > > +    allocations that should be accounted.
> > > +  * Userspace allocations should use either of the ``GFP_USER``,
> > > +    ``GFP_HIGHUSER`` and ``GFP_HIGHUSER_MOVABLE`` flags. The longer
> > > +    the flag name the less restrictive it is.
> > > +
> > > +    The ``GFP_HIGHUSER_MOVABLE`` does not require that allocated
> > > +    memory will be directly accessible by the kernel or the hardware
> > > +    and implies that the data may move.
> 
> @may move@is movable@

Ok
 
> > > +    The ``GFP_HIGHUSER`` means that the allocated memory is not
> > > +    movable, but it is not required to be directly accessible by the
> > > +    kernel or the hardware. An example may be a hardware allocation
> > > +    that maps data directly into userspace but has no addressing
> > > +    limitations.
> > > +
> > > +    The ``GFP_USER`` means that the allocated memory is not movable
> > > +    and it must be directly accessible by the kernel or the
> > > +    hardware. It is typically used by hardware for buffers that are
> > > +    mapped to userspace (e.g. graphics) that hardware still must DMA
> > > +    to.
> > > +
> > > +You may notice that quite a few allocations in the existing code
> > > +specify ``GFP_NOIO`` and ``GFP_NOFS``. Historically, they were used to
> > > +prevent recursion deadlocks caused by direct memory reclaim calling
> > > +back into the FS or IO paths and blocking on already held
> > > +resources. Since 4.12 the preferred way to address this issue is to
> > > +use new scope APIs described in
> > > +:ref:`Documentation/core-api/gfp_mask-from-fs-io.rst <gfp_mask_from_fs_io>`.
> > > +
> > > +Another legacy GFP flags are ``GFP_DMA`` and ``GFP_DMA32``. They are
> > > +used to ensure that the allocated memory is accessible by hardware
> > > +with limited addressing capabilities. So unless you are writing a
> > > +driver for a device with such restrictions, avoid using these flags.
> 
> And even with HW with restrictions it is preferable to use dma_alloc*
> APIs

Will add.
 
> Looks nice otherwise. Thanks! With the above changes feel free to add
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
