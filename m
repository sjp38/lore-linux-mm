Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E22DB8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:41:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 20-v6so2108775ois.21
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 05:41:04 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i5-v6si615627oii.19.2018.09.12.05.41.03
        for <linux-mm@kvack.org>;
        Wed, 12 Sep 2018 05:41:03 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-2-jean-philippe.brucker@arm.com>
 <bf42affd-e9d0-e4fc-6d28-f3c3f7795348@redhat.com>
 <03d31ba5-1eda-ea86-8c0c-91d14c86fe83@arm.com>
 <ed39159c-087e-7e56-7d29-d1de9fa1677f@amd.com>
 <f0b317d5-e2e9-5478-952c-05e8b97bd68b@arm.com>
 <2fd4a0a1-1a35-bf82-df84-b995cce011d9@amd.com>
 <65e7accd-4446-19f5-c667-c6407e89cfa6@arm.com>
 <5bbc0332-b94b-75cc-ca42-a9b196811daf@amd.com>
 <20180907142504.5034351e@jacob-builder>
 <3e3a6797-a233-911b-3a7d-d9b549160960@amd.com>
Message-ID: <9445a0be-fb5b-d195-4fdf-7ad6cb36ef4f@arm.com>
Date: Wed, 12 Sep 2018 13:40:43 +0100
MIME-Version: 1.0
In-Reply-To: <3e3a6797-a233-911b-3a7d-d9b549160960@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>
Cc: Auger Eric <eric.auger@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "tn@semihalf.com" <tn@semihalf.com>, "joro@8bytes.org" <joro@8bytes.org>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, Robin Murphy <Robin.Murphy@arm.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, Michal Hocko <mhocko@kernel.org>

On 08/09/2018 08:29, Christian KA?nig wrote:
> Yes, exactly. I just need a PASID which is never used by the OS for a 
> process and we can easily give that back when the last FD reference is 
> closed.

Alright, iommu-sva can get its PASID from this external allocator as
well, as long as it has an interface similar to idr. Where would it go,
drivers/base/, mm/, kernel/...?

>>>> The process dies, iommu-sva is notified and calls the mm_exit()
>>>> function passed by the device driver to iommu_sva_device_init(). In
>>>> mm_exit() the device driver needs to clear any reference to the
>>>> PASID in hardware and in its own structures. When the device driver
>>>> returns from mm_exit(), it effectively tells the core that it has
>>>> finished using the PASID, and iommu-sva can reuse the PASID for
>>>> another process. mm_exit() is allowed to block, so the device
>>>> driver has time to clean up and flush the queues.
>>>>
>>>> If the device driver finishes using the PASID before the process
>>>> exits, it just calls unbind().
>>> Exactly that's what Michal Hocko is probably going to not like at all.
>>>
>>> Can we have a different approach where each driver is informed by the
>>> mm_exit(), but needs to explicitly call unbind() before a PASID is
>>> reused?

It's awful from the IOMMU driver perspective. In addition to "enabled"
and "disabled" PASID states, you add "disabled but DMA still running
normally". Between that new state and "disabled", the IOMMU will be
flooded by translation faults (non-recoverable ones), which it needs to
ignore instead of reporting to the kernel. Not all IOMMUs can deal with
this in hardware (SMMU and VT-d can quiesce translation faults
per-PASID, but I don't think AMD IOMMU can.) Some drivers will have to
filter fault events themselves, depending on the PASID state.

>>> During that teardown transition it would be ideal if that PASID only
>>> points to a dummy root page directory with only invalid entries.
>>>
>> I guess this can be vendor specific, In VT-d I plan to mark PASID
>> entry not present and disable fault reporting while draining remaining
>> activities.
>
> Sounds good to me.
> 
> Point is at least in the case where the process was killed by the OOM 
> killer we should not block in mm_exit().
>
> Instead operations issued by the process to a device driver which uses 
> SVA needs to be terminated as soon as possible to make sure that the OOM 
> killer can advance.

I don't see how we're preventing the OOM killer from advancing, so I'm
looking for a stronger argument that justifies adding this complexity to
IOMMU drivers. Time limit of the release MMU notifier, locking
requirement, a concrete example where things break, even a comment
somewhere in mm/ would do...

In my tests I can't manage to disturb the OOM killer, but I could be
missing some special case. Even if the mm_exit() callback
(unrealistically) sleeps for 60 seconds, the OOM killer isn't affected
because oom_reap_task_mm() wipes the victim's address space in another
thread, either before or while the release notifier is running.

Thanks,
Jean
