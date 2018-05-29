Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD6856B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 06:00:34 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id w10-v6so9514686otj.14
        for <linux-mm@kvack.org>; Tue, 29 May 2018 03:00:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k1-v6si2159247ote.124.2018.05.29.03.00.33
        for <linux-mm@kvack.org>;
        Tue, 29 May 2018 03:00:33 -0700 (PDT)
Subject: Re: [PATCH v2 07/40] iommu: Add a page fault handler
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-8-jean-philippe.brucker@arm.com>
 <20180518110434.150a0e64@jacob-builder>
 <8a640794-a6f3-fa01-82a9-06479a6f779a@arm.com>
 <20180522163521.413e60c6@jacob-builder>
 <bdf9f221-ab97-2168-d072-b7f6a0dba840@arm.com>
 <20180525173544.05638510@jacob-builder>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <6bd83326-2da0-1250-3dfc-7d6fbf58d701@arm.com>
Date: Tue, 29 May 2018 11:00:21 +0100
MIME-Version: 1.0
In-Reply-To: <20180525173544.05638510@jacob-builder>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jacob Pan <jacob.jun.pan@linux.intel.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "christian.koenig@amd.com" <christian.koenig@amd.com>

On 26/05/18 01:35, Jacob Pan wrote:
>>>> Not exactly, it's the IOMMU driver that makes sure all LPIG in its
>>>> queues are submitted by the above flush call. In more details the
>>>> flow is:
>>>>
>>>> * Either device driver calls unbind()/sva_device_shutdown(), or the
>>>> process exits.
>>>> * If the device driver called, then it already told the device to
>>>> stop using the PASID. Otherwise we use the mm_exit() callback to
>>>> tell the device driver to stop using the PASID.
> Sorry I still need more clarification. For the PASID termination
> initiated by vfio unbind, I don't see device driver given a chance to
> stop PASID. Seems just call __iommu_sva_unbind_device() which already
> assume device stopped issuing DMA with the PASID.
> So it is the vfio unbind caller responsible for doing driver callback
> to stop DMA on a given PASID?

Yes, but I don't know how to implement this. Since PCI doesn't formalize
the PASID stop mechanism and the device doesn't have a kernel driver,
VFIO would need help from the userspace driver for stopping PASID
(notify the userspace driver when an other process exits).


>>>> * In either case, when receiving a stop request from the driver,
>>>> the device sends the LPIGs to the IOMMU queue.
>>>> * Then, the flush call above ensures that the IOMMU reports the
>>>> LPIG with iommu_report_device_fault.
>>>> * While submitting all LPIGs for this PASID to the work queue,
>>>> ipof_queue_fault also picked up all partial faults, so the partial
>>>> list is clean.
>>>>
>>>> Maybe I should improve this comment?
>>>>  
>>> thanks for explaining. LPIG submission is done by device
>>> asynchronously w.r.t. driver stopping/decommission PASID.  
>>
>> Hmm, it should really be synchronous, otherwise there is no way to
>> know when the PASID can be decommissioned. We need a guarantee such
>> as the one in 6.20.1 of the PCIe spec, "Managing PASID TLP Prefix
>> Usage":
>>
>> "When the stop request mechanism indicates completion, the Function
>> has:
>> * Completed all Non-Posted Requests associated with this PASID.
>> * Flushed to the host all Posted Requests addressing host memory in
>> all TCs that were used by the PASID."
>>
>> That's in combination with "The function shall [...] finish
>> transmitting any multi-page Page Request Messages for this PASID
>> (i.e. send the Page Request Message with the L bit Set)." from the
>> ATS spec.
>>
> I am not contesting on the device side, what I meant was from the
> host IOMMU driver perspective, LPIG is received via IOMMU host queue,
> therefore asynchronous. Not sure about ARM, but on VT-d LPIG submission
> could meet queue full condition. So per VT-d spec, iommu will generate a
> successful auto response to the device. At this point, assume we
> already stopped the given PASID on the device, there might not be
> another LPIG sent for the device. Therefore, you could have a partial
> list. I think we can just drop the requests in the partial list for
> that PASID until the PASID gets re-allocated.

Indeed, I'll add this in next version. For a complete solution to the
queue-full condition (which seems to behave the same way on ARM) I was
thinking the IOMMU driver should also have a method for removing all
partial faults when detecting a queue overflow. Since it doesn't know
which PRGs did receive an auto-response, all it can do is remove all
partial faults, for all devices using this queue. But freeing the stuck
partial faults in flush() and remove_device() should be good enough

Thanks,
Jean
