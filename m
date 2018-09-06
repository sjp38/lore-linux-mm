Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65B086B79EA
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 13:41:11 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s200-v6so13664977oie.6
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 10:41:11 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f2-v6si3907997oih.58.2018.09.06.10.41.09
        for <linux-mm@kvack.org>;
        Thu, 06 Sep 2018 10:41:10 -0700 (PDT)
Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-4-jean-philippe.brucker@arm.com>
 <d785ec89-6743-d0f1-1a7f-85599a033e5b@redhat.com>
 <20180905111835.7f3ae40e@jacob-builder>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <574a1792-7ac5-e4db-6eae-16ef700cba02@arm.com>
Date: Thu, 6 Sep 2018 18:40:49 +0100
MIME-Version: 1.0
In-Reply-To: <20180905111835.7f3ae40e@jacob-builder>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jacob Pan <jacob.jun.pan@linux.intel.com>, Auger Eric <eric.auger@redhat.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "tn@semihalf.com" <tn@semihalf.com>, "joro@8bytes.org" <joro@8bytes.org>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, Robin Murphy <Robin.Murphy@arm.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>

On 05/09/2018 19:18, Jacob Pan wrote:
> On Wed, 5 Sep 2018 14:14:12 +0200
> Auger Eric <eric.auger@redhat.com> wrote:
> 
>>> + *
>>> + * On Arm and AMD IOMMUs, entry 0 of the PASID table can be used
>>> to hold
>>> + * non-PASID translations. In this case PASID 0 is reserved and
>>> entry 0 points
>>> + * to the io_pgtable base. On Intel IOMMU, the io_pgtable base
>>> would be held in
>>> + * the device table and PASID 0 would be available to the
>>> allocator.
>>> + */  
>> very nice explanation
> With the new Vt-d 3.0 spec., 2nd level IO page table base is no longer
> held in the device context table. Instead it is held in the PASID table
> entry pointed by the RID_PASID field in the device context entry. If
> RID_PASID = 0, then it is the same as ARM and AMD IOMMUs.
> You can refer to ch3.4.3 of the VT-d spec.

I could simplify that paragraph by removing the specific implementations:

"In some IOMMUs, entry 0 of the PASID table can be used to hold
non-PASID translations. In this case PASID 0 is reserved and entry 0
points to the io_pgtable base. In other IOMMUs the io_pgtable base is
held in the device table and PASID 0 is available to the allocator."

I guess in Linux there isn't any reason to set RID_PASID to a non-zero
value? Otherwise the iommu-sva allocator will need minor changes.

Thanks,
Jean
