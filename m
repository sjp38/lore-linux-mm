Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 385916B0496
	for <linux-mm@kvack.org>; Thu, 17 May 2018 06:02:57 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id e95-v6so3091484otb.15
        for <linux-mm@kvack.org>; Thu, 17 May 2018 03:02:57 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r126-v6si1497929oih.74.2018.05.17.03.02.56
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 03:02:56 -0700 (PDT)
Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-4-jean-philippe.brucker@arm.com>
 <20180516163117.622693ea@jacob-builder>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <de478769-9f7a-d40b-a55e-e2c63ad883e8@arm.com>
Date: Thu, 17 May 2018 11:02:42 +0100
MIME-Version: 1.0
In-Reply-To: <20180516163117.622693ea@jacob-builder>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jacob Pan <jacob.jun.pan@linux.intel.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>

On 17/05/18 00:31, Jacob Pan wrote:
> On Fri, 11 May 2018 20:06:04 +0100
> I am a little confused about domain vs. pasid relationship. If
> each domain represents a address space, should there be a domain for
> each pasid?

I don't think there is a formal definition, but from previous discussion
the consensus seems to be: domains are a collection of devices that have
the same virtual address spaces (one or many).

Keeping that definition makes things easier, in my opinion. Some time
ago, I did try to represent PASIDs using "subdomains" (introducing a
hierarchy of struct iommu_domain), but it required invasive changes in
the IOMMU subsystem and probably all over the tree.

You do need some kind of "root domain" for each device, so that
"iommu_get_domain_for_dev()" still makes sense. That root domain doesn't
have a single address space but a collection of subdomains. If you need
this anyway, representing a PASID with an iommu_domain doesn't seem
preferable than using a different structure (io_mm), because they don't
have anything in common.

Thanks,
Jean
