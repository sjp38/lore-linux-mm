Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B13D96B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:43:03 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so29650250wic.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:43:03 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id bw2si24655232wjc.127.2015.10.23.05.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 05:42:58 -0700 (PDT)
Date: Fri, 23 Oct 2015 14:42:58 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH] iommu/vt-d: Add IOTLB flush support for kernel
 addresses
Message-ID: <20151023124257.GB27420@8bytes.org>
References: <1445356379.4486.56.camel@infradead.org>
 <20151020160328.GV27420@8bytes.org>
 <1445357824.4486.65.camel@infradead.org>
 <20151023102043.GZ27420@8bytes.org>
 <1445596413.4113.175.camel@infradead.org>
 <20151023110359.GA27420@8bytes.org>
 <1445600226.4113.196.camel@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1445600226.4113.196.camel@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Sudeep Dutt <sudeep.dutt@intel.com>

On Fri, Oct 23, 2015 at 12:37:06PM +0100, David Woodhouse wrote:
> It's more than that a?? it's equivalent to the situation *with* the
> IOMMU.
> 
> Having a *separate* PASID which is the only PASID we can use for kernel
> mode is *not* a security improvement. In the general case, if a user
> can trick the device into setting the 'supervisor mode' bit on a given
> access, it could probably just as easily trick the device into using
> the separate kernel PASID for that access. In neither case is it as
> simple as just asking the device to use a kernel address.
> 
> I'm not proposing it for that reason, which is why I'm objecting to
> your 'we have to...' response. Although maybe I should shut up, because
> I'm pleased you aren't objecting to my plan and saying that we *do*
> need to permit supervisor-mode access in normal PASIDs.

At best I'd like to avoid supervisor access for devices at all, but
there seems to be a need for it, so I looks like we need to provide it.
Therefore I think that your idea to have a seperate PASID for kernel
access, and only kernel access, is a good one. We even don't need to use
a defined PASID, we can randomize the PASID used for kernel accesses and
make it harder to guess this way.

But having both, kernel and supervisor access, allowed for a PASID is
another story, and I think we need to be careful with that (or at least
avoid that the driver writers need to care that much about it to prevent
userspace from getting access to kernel memory).

> You mean an inline function which checks for iommu->kernel_svm a?? iommu?
> And does the equivalent for other IOMMUs? I wouldn't want IOMMU
> -specific code in there; just a decision about whether to call the out
> -of-line function.
> 
> Or maybe if we are making PASID handling generic and system-wide, it
> really does become a case of 'if (init_mm.pasid != -1)' ...?

Yes, something like that, and of course independent of the iommu. When
we have a system-wide PASID registry we can check against that, or
introduce a global read_mostly flag. Using init_mm refcounting or flags
also sounds like a good idea.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
