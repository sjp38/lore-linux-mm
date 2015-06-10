Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 516166B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:48:54 -0400 (EDT)
Received: by qcnj1 with SMTP id j1so15310555qcn.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:48:54 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v5si8069820qcm.23.2015.06.10.02.48.52
        for <linux-mm@kvack.org>;
        Wed, 10 Jun 2015 02:48:52 -0700 (PDT)
Date: Wed, 10 Jun 2015 10:48:47 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] slub/slab: fix kmemleak didn't work on some case
Message-ID: <20150610094846.GD4808@e104818-lin.cambridge.arm.com>
References: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
 <alpine.DEB.2.11.1506080425350.10651@east.gentwo.org>
 <20150608101302.GB31349@e104818-lin.cambridge.arm.com>
 <55769F85.5060909@linux.intel.com>
 <20150609150303.GB4808@e104818-lin.cambridge.arm.com>
 <5577EB2E.8090505@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5577EB2E.8090505@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, "Liu, XinwuX" <xinwux.liu@intel.com>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "He, Bo" <bo.he@intel.com>, "Chen, Lin Z" <lin.z.chen@intel.com>

On Wed, Jun 10, 2015 at 08:45:50AM +0100, Zhang, Yanmin wrote:
> On 2015/6/9 23:03, Catalin Marinas wrote:
> > On Tue, Jun 09, 2015 at 09:10:45AM +0100, Zhang, Yanmin wrote:
> >> On 2015/6/8 18:13, Catalin Marinas wrote:
> >>> As I replied already, I don't think this is that bad, or at least not
> >>> worse than what kmemleak already does (looking at all data whether it's
> >>> pointer or not).
> >> It depends. As for memleak, developers prefers there are false alarms instead
> >> of missing some leaked memory.
> > Lots of false positives aren't that nice, you spend a lot of time
> > debugging them (I've been there in the early kmemleak days). Anyway,
> > your use case is not about false positives vs. negatives but just false
> > negatives.
> >
> > My point is that there is a lot of random, pointer-like data read by
> > kmemleak even without this memset (e.g. thread stacks, non-pointer data
> > in kmalloc'ed structures, data/bss sections). Just doing this memset may
> > reduce the chance of false negatives a bit but I don't think it would be
> > noticeable.
> >
> > If there is some serious memory leak (lots of objects), they would
> > likely show up at some point. Even if it's a one-off leak, it's possible
> > that it shows up after some time (e.g. the object pointing to this
> > memory block is freed).
> >
> >>>  It also doesn't solve the kmem_cache_alloc() case where
> >>> the original object size is no longer available.
> >> Such issue around kmem_cache_alloc() case happens only when the
> >> caller doesn't initialize or use the full object, so the object keeps
> >> old dirty data.
> > The kmem_cache blocks size would be aligned to a cache line, so you
> > still have some extra bytes never touched by the caller.
> >
> >> This patch is to resolve the redundant unused space (more than object size)
> >> although the full object is used by kernel.
> > So this solves only the cases where the original object size is still
> > known (e.g. kmalloc). It could also be solved by telling kmemleak the
> > actual object size.
> 
> Your explanation is reasonable. The patch is for debug purpose.
> Maintainers can make decision based on balance.

The patch, as it stands, should not go in:

- too much code duplication (I already commented that a function
  similar to kmemleak_erase would look much better)
- I don't think there is a noticeable benefit but happy to be proven
  wrong
- there are other ways of achieving the same

> Xinwu is a new developer in kernel community. Accepting the patch
> into kernel can encourage him definitely. :)

As would constructive feedback ;)

That said, it would probably be more beneficial to be able to tell
kmemleak of the actual object size via another callback. This solves the
scanning of the extra data in a slab, restricts pointer values
referencing the object and better identification of the leaked objects
(by printing its real size). Two options:

a) Use the existing kmemleak_free_part() function to free the end of the
   slab. This was originally meant for memblock freeing but can be
   improved slightly to avoid creating a new object and deleting the old
   one when only the last part of the block is freed.

b) Implement a new kmemleak_set_size(const void *ptr, size_t size). All
   it needs to do is update the object->size value, no need for
   re-inserting into the rb-tree.

Option (b) is probably better, especially with the latest patches I
posted where kmemleak_free*() always deletes the original object.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
