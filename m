Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E5D8D6B0512
	for <linux-mm@kvack.org>; Thu, 17 May 2018 12:57:36 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x32-v6so3181523pld.16
        for <linux-mm@kvack.org>; Thu, 17 May 2018 09:57:36 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u6-v6si5237582plz.461.2018.05.17.09.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 09:57:35 -0700 (PDT)
Date: Thu, 17 May 2018 10:00:23 -0700
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
Message-ID: <20180517100023.43585c42@jacob-builder>
In-Reply-To: <96c1e0f0-0aa7-badf-123e-cbb1b05e645e@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-2-jean-philippe.brucker@arm.com>
	<20180516134150.34fc8857@jacob-builder>
	<96c1e0f0-0aa7-badf-123e-cbb1b05e645e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, jacob.jun.pan@linux.intel.com

On Thu, 17 May 2018 11:02:02 +0100
Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:

> Hi Jacob,
> 
> Thanks for reviewing this
> 
> On 16/05/18 21:41, Jacob Pan wrote:
>  [...]  
> > seems the min_pasid never gets used. do you really need it?  
> 
> Yes, the SMMU sets it to 1 in patch 28/40, because it needs to reserve
> PASID 0
> 
>  [...]  
> > should it be !features?  
> 
> This checks if the user sets any unsupported bit in features. No
> feature is supported right now, but patch 09/40 adds
> IOMMU_SVA_FEAT_IOPF, and changes this line to "features &
> ~IOMMU_SVA_FEAT_IOPF"
> 
> >> +	mutex_lock(&dev->iommu_param->lock);
> >> +	param = dev->iommu_param->sva_param;
> >> +	dev->iommu_param->sva_param = NULL;
> >> +	mutex_unlock(&dev->iommu_param->lock);
> >> +	if (!param)
> >> +		return -ENODEV;
> >> +
> >> +	if (domain->ops->sva_device_shutdown)
> >> +		domain->ops->sva_device_shutdown(dev, param);  
> > seems a little mismatch here, do you need pass the param. I don't
> > think there is anything else model specific iommu driver need to do
> > for the param.  
> 
> SMMU doesn't use it, but maybe it would remind other IOMMU driver
> which features were enabled, so they don't have to keep track of that
> themselves? I can remove it if it isn't useful
> 
If there is a use case, I guess iommu driver can always retrieve the
param from struct device.
> Thanks,
> Jean

[Jacob Pan]
