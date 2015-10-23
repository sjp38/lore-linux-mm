Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 79CA96B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 07:04:01 -0400 (EDT)
Received: by wijp11 with SMTP id p11so72023143wij.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 04:04:01 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id bz4si24235784wjb.25.2015.10.23.04.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 04:04:00 -0700 (PDT)
Date: Fri, 23 Oct 2015 13:03:59 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH] iommu/vt-d: Add IOTLB flush support for kernel
 addresses
Message-ID: <20151023110359.GA27420@8bytes.org>
References: <1445356379.4486.56.camel@infradead.org>
 <20151020160328.GV27420@8bytes.org>
 <1445357824.4486.65.camel@infradead.org>
 <20151023102043.GZ27420@8bytes.org>
 <1445596413.4113.175.camel@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1445596413.4113.175.camel@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Sudeep Dutt <sudeep.dutt@intel.com>

On Fri, Oct 23, 2015 at 11:33:33AM +0100, David Woodhouse wrote:
> Which means I'm pondering *renaming* tlb_flush_kernel_range() to
> something like arch_tlb_flush_kernel_range() everywhere, then having a
> tlb_flush_kernel_range() inline function which optionally calls
> iommu_flush_kernel_range() first.

That sounds like some work, but would be the super clean solution :)
Given that only a handful of architecture besides x86 will need it
(thinking of ARM64 and PPC), I prefer the solution below:

> Or I could reduce the churn by adding explicit calls to
> iommu_flush_kernel_range() at every location that calls
> tlb_flush_kernel_range(), but that's going to lead to some callers
> missing the IOMMU flush.

Exactly like this, but when do we miss a flush here?

> Not entirely. The device still gets to specify whether it's doing
> supervisor or user mode access, for each request it makes. It doesn't
> open the door to users just using kernel addresses and getting away
> with it!
> 
> Sure, we need to trust the *device* a?? but we need to trust it to
> provide the correct PASID too. Which basically means in the VFIO case
> where the user gets *full* control of the device, we have to ensure
> that it gets its own PASID table with only the *one* PASID in it, and
> *that* PASID can't have supervisor mode.

Exactly, we need to trust the device and the device driver. But thats
not different to a situation without an iommu. We just run into problems
when a device-driver allows sending requests to access kernel-memory
from user-space, so it needs more care from the driver writers/reviewers
too.

> +static inline void do_iommu_flush_ktlb(unsigned long start, unsigned long end)
> +{
> +	iommu_flush_ktlb_fn *fn;
> +	rcu_read_lock();
> +	fn = rcu_dereference(iommu_flush_ktlb);
> +	if (fn)
> +		(*fn)(start, end);
> +	rcu_read_unlock();
> +}

Yes, that'll work too. When you read/update the iommu_flush_ktlb pointer
atomically, you can even get away without rcu. The function it points to
will not go away, so you can still call it even when the pointer turned
NULL.

> Maybe we could keep it simple and just declare that once the function
> pointer is set, it may never be cleared? But I think we really do want
> to avoid the out-of-line function call altogether in the case where
> kernel PASIDs are not being used. Or at *least* the case where SVM
> isn't being used at all.

Yes, thats why I think an inline function which does the checks would be
a better solution. The mmu_notifiers implement it in the same way, so we
would stay consistent with them.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
