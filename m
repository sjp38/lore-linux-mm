Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 028B66B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:53:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so11526244wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:53:46 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id o8si3184278wmg.24.2016.04.26.05.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:53:45 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id w143so4173008wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:53:45 -0700 (PDT)
Date: Tue, 26 Apr 2016 14:53:41 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH v4 1/2] shmem: Support for registration of driver/file
 owner specific ops
Message-ID: <20160426125341.GF8291@phenom.ffwll.local>
References: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
 <20160424234250.GB6670@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160424234250.GB6670@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Akash Goel <akash.goel@intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.linux.org, Sourab Gupta <sourab.gupta@intel.com>

On Mon, Apr 25, 2016 at 02:42:50AM +0300, Kirill A. Shutemov wrote:
> On Mon, Apr 04, 2016 at 02:18:10PM +0100, Chris Wilson wrote:
> > From: Akash Goel <akash.goel@intel.com>
> > 
> > This provides support for the drivers or shmem file owners to register
> > a set of callbacks, which can be invoked from the address space
> > operations methods implemented by shmem.  This allow the file owners to
> > hook into the shmem address space operations to do some extra/custom
> > operations in addition to the default ones.
> > 
> > The private_data field of address_space struct is used to store the
> > pointer to driver specific ops.  Currently only one ops field is defined,
> > which is migratepage, but can be extended on an as-needed basis.
> > 
> > The need for driver specific operations arises since some of the
> > operations (like migratepage) may not be handled completely within shmem,
> > so as to be effective, and would need some driver specific handling also.
> > Specifically, i915.ko would like to participate in migratepage().
> > i915.ko uses shmemfs to provide swappable backing storage for its user
> > objects, but when those objects are in use by the GPU it must pin the
> > entire object until the GPU is idle.  As a result, large chunks of memory
> > can be arbitrarily withdrawn from page migration, resulting in premature
> > out-of-memory due to fragmentation.  However, if i915.ko can receive the
> > migratepage() request, it can then flush the object from the GPU, remove
> > its pin and thus enable the migration.
> > 
> > Since gfx allocations are one of the major consumer of system memory, its
> > imperative to have such a mechanism to effectively deal with
> > fragmentation.  And therefore the need for such a provision for initiating
> > driver specific actions during address space operations.
> 
> Hm. Sorry, my ignorance, but shouldn't this kind of flushing be done in
> response to mmu_notifier's ->invalidate_page?
> 
> I'm not aware about how i915 works and what's its expectation wrt shmem.
> Do you have some userspace VMA which is mirrored on GPU side?
> If yes, migration would cause unmapping of these pages and trigger the
> mmu_notifier's hook.

We do that for userptr pages (i.e. stuff we steal from userspace address
spaces). But we also have native gfx buffer objects based on shmem files,
and thus far we need to allocate them as !GFP_MOVEABLE. And we allocate a
_lot_ of those. And those files aren't mapped into any cpu address space
(ofc they're mapped on the gpu side, but that's driver private), from the
core mm they are pure pagecache. And afaiui for that we need to wire up
the migratepage hooks through shmem to i915_gem.c
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
