Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A78E382F64
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:20:45 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so24848911wic.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 03:20:45 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id lj8si24054532wjc.46.2015.10.23.03.20.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 03:20:44 -0700 (PDT)
Date: Fri, 23 Oct 2015 12:20:44 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH] iommu/vt-d: Add IOTLB flush support for kernel
 addresses
Message-ID: <20151023102043.GZ27420@8bytes.org>
References: <1445356379.4486.56.camel@infradead.org>
 <20151020160328.GV27420@8bytes.org>
 <1445357824.4486.65.camel@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445357824.4486.65.camel@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Sudeep Dutt <sudeep.dutt@intel.com>

On Tue, Oct 20, 2015 at 05:17:04PM +0100, David Woodhouse wrote:
> Can we assume that only one type of SVM-capable IOMMU will be present
> in the system at a time? Perhaps we could just register a single
> function (intel_iommu_flush_kernel_pasid in the VT-d case) to be used
> as a notifier callback from tlb_flush_kernel_range()? Rather than the
> overhead of a *list* of notifiers?

Yes, a single notifier is certainly preferable to a list. It is just
too easy for others to attach to this list silently and adding more
overhead to kernel TLB flushing.

> But... that's because the PASID-space is currently per-IOMMU. The plan
> is to have a *single* PASID-space system-wide, And then I still want to
> retain the property that there can be only *one* kernel PASID.

That makes a lot of sense. Then we can check in the call-back simply if
this pasid has users and bail out early when not.

> I have forbidden the use of a given PASID to access *both* kernel and
> user addresses. I'm hoping we can get away with putting that
> restriction into the generic SVM APIs.

We have to, having kernel-pasids already nullifies all protection the
IOMMU provides, giving kernel-access to a process-pasid is security wise
equivalent to accessing /dev/mem.

> So yeah, perhaps we can set the notifier pointer to NULL when there's
> no kernel PASID assigned, and only set it to point to
> ${MY_IOMMU}_flush_kernel_pasid() if/when there *is* one?

That sounds like it needs some clever locking. Instead of checking the
function pointer it is probably easier to put the check for pasid-users
into an inline function and just do the real flush-call only when
necessary.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
