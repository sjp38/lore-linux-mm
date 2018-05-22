Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 441816B000C
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:40:46 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r4-v6so3025831pgq.2
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:40:46 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id h131-v6si16018076pfc.206.2018.05.22.09.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 09:40:45 -0700 (PDT)
Date: Tue, 22 May 2018 09:43:34 -0700
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
Message-ID: <20180522094334.71f0e36b@jacob-builder>
In-Reply-To: <de478769-9f7a-d40b-a55e-e2c63ad883e8@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-4-jean-philippe.brucker@arm.com>
	<20180516163117.622693ea@jacob-builder>
	<de478769-9f7a-d40b-a55e-e2c63ad883e8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, jacob.jun.pan@linux.intel.com

On Thu, 17 May 2018 11:02:42 +0100
Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:

> On 17/05/18 00:31, Jacob Pan wrote:
> > On Fri, 11 May 2018 20:06:04 +0100
> > I am a little confused about domain vs. pasid relationship. If
> > each domain represents a address space, should there be a domain for
> > each pasid?  
> 
> I don't think there is a formal definition, but from previous
> discussion the consensus seems to be: domains are a collection of
> devices that have the same virtual address spaces (one or many).
> 
> Keeping that definition makes things easier, in my opinion. Some time
> ago, I did try to represent PASIDs using "subdomains" (introducing a
> hierarchy of struct iommu_domain), but it required invasive changes in
> the IOMMU subsystem and probably all over the tree.
> 
> You do need some kind of "root domain" for each device, so that
> "iommu_get_domain_for_dev()" still makes sense. That root domain
> doesn't have a single address space but a collection of subdomains.
> If you need this anyway, representing a PASID with an iommu_domain
> doesn't seem preferable than using a different structure (io_mm),
> because they don't have anything in common.
> 
My main concern is the PASID table storage. If PASID table storage
is tied to domain, it is ok to scale up, i.e. multiple devices in a
domain share a single PASID table. But to scale down, e.g. further
partition device with VFIO mdev for assignment, each mdev may get its
own domain via vfio. But there is no IOMMU storage for PASID table at
mdev device level. Perhaps we do need root domain or some parent-child
relationship to locate PASID table.

> Thanks,
> Jean

[Jacob Pan]
