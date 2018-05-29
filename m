Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8088D6B000A
	for <linux-mm@kvack.org>; Tue, 29 May 2018 06:27:48 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id e32-v6so9356272ote.23
        for <linux-mm@kvack.org>; Tue, 29 May 2018 03:27:48 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i9-v6si3349437otb.204.2018.05.29.03.27.47
        for <linux-mm@kvack.org>;
        Tue, 29 May 2018 03:27:47 -0700 (PDT)
Subject: Re: [PATCH v2 39/40] iommu/arm-smmu-v3: Add support for PRI
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-40-jean-philippe.brucker@arm.com>
 <BLUPR0201MB150513BBAA161355DE9B3A48A5690@BLUPR0201MB1505.namprd02.prod.outlook.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <4e36ddb0-f1c3-f434-d330-be2dc9b88bb8@arm.com>
Date: Tue, 29 May 2018 11:27:33 +0100
MIME-Version: 1.0
In-Reply-To: <BLUPR0201MB150513BBAA161355DE9B3A48A5690@BLUPR0201MB1505.namprd02.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bharat Kumar Gogada <bharatku@xilinx.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, Ravikiran Gummaluri <rgummal@xilinx.com>

On 25/05/18 15:08, Bharat Kumar Gogada wrote:
>> +	master->can_fault = true;
>> +	master->ste.prg_resp_needs_ssid =
>> pci_prg_resp_requires_prefix(pdev);
> 
> Any reason why this is not cleared in arm_smmu_disable_pri ?

Actually, setting it here is wrong. Since we now call enable_pri()
lazily, prg_resp_needs_ssid isn't initialized when writing the STE. That
bit is read by the SMMU when the PRIQ is full and it needs to
auto-respond. Fortunately the PRI doesn't need to be enabled in order to
read this bit, so we can move pci_prg_resp_requires_prefix() to
add_device() and clear the bit in remove_device(). Thanks for catching this.

Jean
