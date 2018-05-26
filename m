Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 635FE6B0007
	for <linux-mm@kvack.org>; Fri, 25 May 2018 20:32:53 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 89-v6so3983387plc.1
        for <linux-mm@kvack.org>; Fri, 25 May 2018 17:32:53 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r10-v6si18805168pgv.499.2018.05.25.17.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 17:32:51 -0700 (PDT)
Date: Fri, 25 May 2018 17:35:44 -0700
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v2 07/40] iommu: Add a page fault handler
Message-ID: <20180525173544.05638510@jacob-builder>
In-Reply-To: <bdf9f221-ab97-2168-d072-b7f6a0dba840@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-8-jean-philippe.brucker@arm.com>
	<20180518110434.150a0e64@jacob-builder>
	<8a640794-a6f3-fa01-82a9-06479a6f779a@arm.com>
	<20180522163521.413e60c6@jacob-builder>
	<bdf9f221-ab97-2168-d072-b7f6a0dba840@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "christian.koenig@amd.com" <christian.koenig@amd.com>, jacob.jun.pan@linux.intel.com

On Thu, 24 May 2018 12:44:38 +0100
Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:

> On 23/05/18 00:35, Jacob Pan wrote:
> >>>> +			/* Insert *before* the last fault */
> >>>> +			list_move(&fault->head, &group->faults);
> >>>> +	}
> >>>> +    
> >>> If you already sorted the group list with last fault at the end,
> >>> why do you need a separate entry to track the last fault?    
> >>
> >> Not sure I understand your question, sorry. Do you mean why the
> >> iopf_group.last_fault? Just to avoid one more kzalloc.
> >>  
> > kind of :) what i thought was that why can't the last_fault
> > naturally be the last entry in your group fault list? then there is
> > no need for special treatment in terms of allocation of the last
> > fault. just my preference.  
> 
> But we need a kzalloc for the last fault anyway, so I thought I'd just
> piggy-back on the group allocation. And if I don't add the last fault
> at the end of group->faults, then it's iopf_handle_group that requires
> special treatment. I'm still not sure I understood your question
> though, could you send me a patch that does it?
> 
> >>>> +
> >>>> +	queue->flush(queue->flush_arg, dev);
> >>>> +
> >>>> +	/*
> >>>> +	 * No need to clear the partial list. All PRGs
> >>>> containing the PASID that
> >>>> +	 * needs to be decommissioned are whole (the device
> >>>> driver made sure of
> >>>> +	 * it before this function was called). They have been
> >>>> submitted to the
> >>>> +	 * queue by the above flush().
> >>>> +	 */    
> >>> So you are saying device driver need to make sure LPIG PRQ is
> >>> submitted in the flush call above such that partial list is
> >>> cleared?    
> >>
> >> Not exactly, it's the IOMMU driver that makes sure all LPIG in its
> >> queues are submitted by the above flush call. In more details the
> >> flow is:
> >>
> >> * Either device driver calls unbind()/sva_device_shutdown(), or the
> >> process exits.
> >> * If the device driver called, then it already told the device to
> >> stop using the PASID. Otherwise we use the mm_exit() callback to
> >> tell the device driver to stop using the PASID.
Sorry I still need more clarification. For the PASID termination
initiated by vfio unbind, I don't see device driver given a chance to
stop PASID. Seems just call __iommu_sva_unbind_device() which already
assume device stopped issuing DMA with the PASID.
So it is the vfio unbind caller responsible for doing driver callback
to stop DMA on a given PASID?

> >> * In either case, when receiving a stop request from the driver,
> >> the device sends the LPIGs to the IOMMU queue.
> >> * Then, the flush call above ensures that the IOMMU reports the
> >> LPIG with iommu_report_device_fault.
> >> * While submitting all LPIGs for this PASID to the work queue,
> >> ipof_queue_fault also picked up all partial faults, so the partial
> >> list is clean.
> >>
> >> Maybe I should improve this comment?
> >>  
> > thanks for explaining. LPIG submission is done by device
> > asynchronously w.r.t. driver stopping/decommission PASID.  
> 
> Hmm, it should really be synchronous, otherwise there is no way to
> know when the PASID can be decommissioned. We need a guarantee such
> as the one in 6.20.1 of the PCIe spec, "Managing PASID TLP Prefix
> Usage":
> 
> "When the stop request mechanism indicates completion, the Function
> has:
> * Completed all Non-Posted Requests associated with this PASID.
> * Flushed to the host all Posted Requests addressing host memory in
> all TCs that were used by the PASID."
> 
> That's in combination with "The function shall [...] finish
> transmitting any multi-page Page Request Messages for this PASID
> (i.e. send the Page Request Message with the L bit Set)." from the
> ATS spec.
> 
I am not contesting on the device side, what I meant was from the
host IOMMU driver perspective, LPIG is received via IOMMU host queue,
therefore asynchronous. Not sure about ARM, but on VT-d LPIG submission
could meet queue full condition. So per VT-d spec, iommu will generate a
successful auto response to the device. At this point, assume we
already stopped the given PASID on the device, there might not be
another LPIG sent for the device. Therefore, you could have a partial
list. I think we can just drop the requests in the partial list for
that PASID until the PASID gets re-allocated.


> (If I remember correctly a PRI Page Request is a Posted Request.) Only
> after this stop request completes can the driver call unbind(), or
> return from exit_mm(). Then we know that if there was a LPIG for that
> PASID, it is in the IOMMU's PRI queue (or already completed) once we
> call flush().
> 
agreed.
> > so if we were to use this
> > flow on vt-d, which does not stall page request queue, then we
> > should use the iommu model specific flush() callback to ensure LPIG
> > is received? There could be queue full condition and retry. I am
> > just trying to understand how and where we can make sure LPIG is
> > received and all groups are whole.  
> 
> For SMMU in patch 30, the flush() callback waits until the PRI queue
> is empty or, when the PRI thread is running in parallel, until the
> thread has done a full circle (handled as many faults as the queue
> size). It's really unpleasant to implement because the flush()
> callback takes a lock to inspect the hardware state, but I don't
> think we have a choice.
> 
yes, vt-d has similar situation in page request queue. one option is to
track queue head (SW update) to make sure one complete cycle when queue
tail(HW update) crosses. Or we(suggested by Ashok Raj) can take a
snapshot of the entire queue and process (drops PRQs belong to the
terminated PASID) without holding the queue.

Thanks,

Jacob
