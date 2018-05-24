Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 146ED6B026C
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:44:58 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t66-v6so704646oih.9
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:44:58 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 22-v6si7608553otu.183.2018.05.24.04.44.57
        for <linux-mm@kvack.org>;
        Thu, 24 May 2018 04:44:57 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
 <5B0536A3.1000304@huawei.com>
Message-ID: <cd13f60d-b282-3804-4ca7-2d34476c597f@arm.com>
Date: Thu, 24 May 2018 12:44:47 +0100
MIME-Version: 1.0
In-Reply-To: <5B0536A3.1000304@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xu Zaibo <xuzaibo@huawei.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, okaya@codeaurora.org, liguozhu <liguozhu@hisilicon.com>, ashok.raj@intel.com, bharatku@xilinx.com, rfranz@cavium.com, rgummal@xilinx.com, dwmw2@infradead.org, ilias.apalodimas@linaro.org, christian.koenig@amd.com

Hi,

On 23/05/18 10:38, Xu Zaibo wrote:
>> +static int vfio_iommu_bind_group(struct vfio_iommu *iommu,
>> +A A A A A A A A A A A A A A A A  struct vfio_group *group,
>> +A A A A A A A A A A A A A A A A  struct vfio_mm *vfio_mm)
>> +{
>> +A A A  int ret;
>> +A A A  bool enabled_sva = false;
>> +A A A  struct vfio_iommu_sva_bind_data data = {
>> +A A A A A A A  .vfio_mmA A A  = vfio_mm,
>> +A A A A A A A  .iommuA A A A A A A  = iommu,
>> +A A A A A A A  .countA A A A A A A  = 0,
>> +A A A  };
>> +
>> +A A A  if (!group->sva_enabled) {
>> +A A A A A A A  ret = iommu_group_for_each_dev(group->iommu_group, NULL,
>> +A A A A A A A A A A A A A A A A A A A A A A A A A A  vfio_iommu_sva_init);
> Do we need to do *sva_init here or do anything to avoid repeated
> initiation?
> while another process already did initiation at this device, I think
> that current process will get an EEXIST.

Right, sva_init() must be called once for any device that intends to use
bind(). For the second process though, group->sva_enabled will be true
so we won't call sva_init() again, only bind().

Thanks,
Jean
