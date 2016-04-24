Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 287D76B007E
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 19:42:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so32717392wme.1
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 16:42:55 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id u7si11033712lbb.178.2016.04.24.16.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Apr 2016 16:42:53 -0700 (PDT)
Received: by mail-lb0-x232.google.com with SMTP id jj5so19401074lbc.0
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 16:42:53 -0700 (PDT)
Date: Mon, 25 Apr 2016 02:42:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 1/2] shmem: Support for registration of driver/file
 owner specific ops
Message-ID: <20160424234250.GB6670@node.shutemov.name>
References: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Akash Goel <akash.goel@intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.linux.org, Sourab Gupta <sourab.gupta@intel.com>

On Mon, Apr 04, 2016 at 02:18:10PM +0100, Chris Wilson wrote:
> From: Akash Goel <akash.goel@intel.com>
> 
> This provides support for the drivers or shmem file owners to register
> a set of callbacks, which can be invoked from the address space
> operations methods implemented by shmem.  This allow the file owners to
> hook into the shmem address space operations to do some extra/custom
> operations in addition to the default ones.
> 
> The private_data field of address_space struct is used to store the
> pointer to driver specific ops.  Currently only one ops field is defined,
> which is migratepage, but can be extended on an as-needed basis.
> 
> The need for driver specific operations arises since some of the
> operations (like migratepage) may not be handled completely within shmem,
> so as to be effective, and would need some driver specific handling also.
> Specifically, i915.ko would like to participate in migratepage().
> i915.ko uses shmemfs to provide swappable backing storage for its user
> objects, but when those objects are in use by the GPU it must pin the
> entire object until the GPU is idle.  As a result, large chunks of memory
> can be arbitrarily withdrawn from page migration, resulting in premature
> out-of-memory due to fragmentation.  However, if i915.ko can receive the
> migratepage() request, it can then flush the object from the GPU, remove
> its pin and thus enable the migration.
> 
> Since gfx allocations are one of the major consumer of system memory, its
> imperative to have such a mechanism to effectively deal with
> fragmentation.  And therefore the need for such a provision for initiating
> driver specific actions during address space operations.

Hm. Sorry, my ignorance, but shouldn't this kind of flushing be done in
response to mmu_notifier's ->invalidate_page?

I'm not aware about how i915 works and what's its expectation wrt shmem.
Do you have some userspace VMA which is mirrored on GPU side?
If yes, migration would cause unmapping of these pages and trigger the
mmu_notifier's hook.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
