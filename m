Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18FF36B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 19:32:34 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id j1-v6so587377pll.7
        for <linux-mm@kvack.org>; Tue, 22 May 2018 16:32:34 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n6-v6si16908642pfi.360.2018.05.22.16.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 16:32:32 -0700 (PDT)
Date: Tue, 22 May 2018 16:35:21 -0700
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v2 07/40] iommu: Add a page fault handler
Message-ID: <20180522163521.413e60c6@jacob-builder>
In-Reply-To: <8a640794-a6f3-fa01-82a9-06479a6f779a@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-8-jean-philippe.brucker@arm.com>
	<20180518110434.150a0e64@jacob-builder>
	<8a640794-a6f3-fa01-82a9-06479a6f779a@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: kvm@vger.kernel.org, linux-pci@vger.kernel.org, xuzaibo@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, linux-mm@kvack.org, ashok.raj@intel.com, bharatku@xilinx.com, linux-acpi@vger.kernel.org, rfranz@cavium.com, devicetree@vger.kernel.org, rgummal@xilinx.com, linux-arm-kernel@lists.infradead.org, dwmw2@infradead.org, ilias.apalodimas@linaro.org, iommu@lists.linux-foundation.org, christian.koenig@amd.com, jacob.jun.pan@linux.intel.com

On Mon, 21 May 2018 15:49:40 +0100
Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:

> On 18/05/18 19:04, Jacob Pan wrote:
> >> +struct iopf_context {
> >> +	struct device			*dev;
> >> +	struct iommu_fault_event	evt;
> >> +	struct list_head		head;
> >> +};
> >> +
> >> +struct iopf_group {
> >> +	struct iopf_context		last_fault;
> >> +	struct list_head		faults;
> >> +	struct work_struct		work;
> >> +};
> >> +  
> > All the page requests in the group should belong to the same device,
> > perhaps struct device tracking should be in iopf_group instead of
> > iopf_context?  
> 
> Right, this is a leftover from when we kept a global list of partial
> faults. Since the list is now per-device, I can move the dev pointer
> (I think I should also rename iopf_context to iopf_fault, if that's
> all right)
> 
> >> +static int iopf_complete(struct device *dev, struct
> >> iommu_fault_event *evt,
> >> +			 enum page_response_code status)
> >> +{
> >> +	struct page_response_msg resp = {
> >> +		.addr			= evt->addr,
> >> +		.pasid			= evt->pasid,
> >> +		.pasid_present		= evt->pasid_valid,
> >> +		.page_req_group_id	=
> >> evt->page_req_group_id,
> >> +		.private_data		= evt->iommu_private,
> >> +		.resp_code		= status,
> >> +	};
> >> +
> >> +	return iommu_page_response(dev, &resp);
> >> +}
> >> +
> >> +static enum page_response_code
> >> +iopf_handle_single(struct iopf_context *fault)
> >> +{
> >> +	/* TODO */
> >> +	return -ENODEV;
> >> +}
> >> +
> >> +static void iopf_handle_group(struct work_struct *work)
> >> +{
> >> +	struct iopf_group *group;
> >> +	struct iopf_context *fault, *next;
> >> +	enum page_response_code status = IOMMU_PAGE_RESP_SUCCESS;
> >> +
> >> +	group = container_of(work, struct iopf_group, work);
> >> +
> >> +	list_for_each_entry_safe(fault, next, &group->faults,
> >> head) {
> >> +		struct iommu_fault_event *evt = &fault->evt;
> >> +		/*
> >> +		 * Errors are sticky: don't handle subsequent
> >> faults in the
> >> +		 * group if there is an error.
> >> +		 */  
> > There might be performance benefit for certain device to continue in
> > spite of error in that the ATS retry may have less fault. Perhaps a
> > policy decision for later enhancement.  
> 
> Yes I think we should leave it to future work. My current reasoning is
> that subsequent requests are more likely to fail as well and reporting
> the error is more urgent, but we need real workloads to confirm this.
> 
> >> +		if (status == IOMMU_PAGE_RESP_SUCCESS)
> >> +			status = iopf_handle_single(fault);
> >> +
> >> +		if (!evt->last_req)
> >> +			kfree(fault);
> >> +	}
> >> +
> >> +	iopf_complete(group->last_fault.dev,
> >> &group->last_fault.evt, status);
> >> +	kfree(group);
> >> +}
> >> +
> >> +/**
> >> + * iommu_queue_iopf - IO Page Fault handler
> >> + * @evt: fault event
> >> + * @cookie: struct device, passed to
> >> iommu_register_device_fault_handler.
> >> + *
> >> + * Add a fault to the device workqueue, to be handled by mm.
> >> + */
> >> +int iommu_queue_iopf(struct iommu_fault_event *evt, void *cookie)
> >> +{
> >> +	struct iopf_group *group;
> >> +	struct iopf_context *fault, *next;
> >> +	struct iopf_device_param *iopf_param;
> >> +
> >> +	struct device *dev = cookie;
> >> +	struct iommu_param *param = dev->iommu_param;
> >> +
> >> +	if (WARN_ON(!mutex_is_locked(&param->lock)))
> >> +		return -EINVAL;
> >> +
> >> +	if (evt->type != IOMMU_FAULT_PAGE_REQ)
> >> +		/* Not a recoverable page fault */
> >> +		return IOMMU_PAGE_RESP_CONTINUE;
> >> +
> >> +	/*
> >> +	 * As long as we're holding param->lock, the queue can't
> >> be unlinked
> >> +	 * from the device and therefore cannot disappear.
> >> +	 */
> >> +	iopf_param = param->iopf_param;
> >> +	if (!iopf_param)
> >> +		return -ENODEV;
> >> +
> >> +	if (!evt->last_req) {
> >> +		fault = kzalloc(sizeof(*fault), GFP_KERNEL);
> >> +		if (!fault)
> >> +			return -ENOMEM;
> >> +
> >> +		fault->evt = *evt;
> >> +		fault->dev = dev;
> >> +
> >> +		/* Non-last request of a group. Postpone until the
> >> last one */
> >> +		list_add(&fault->head, &iopf_param->partial);
> >> +
> >> +		return IOMMU_PAGE_RESP_HANDLED;
> >> +	}
> >> +
> >> +	group = kzalloc(sizeof(*group), GFP_KERNEL);
> >> +	if (!group)
> >> +		return -ENOMEM;
> >> +
> >> +	group->last_fault.evt = *evt;
> >> +	group->last_fault.dev = dev;
> >> +	INIT_LIST_HEAD(&group->faults);
> >> +	list_add(&group->last_fault.head, &group->faults);
> >> +	INIT_WORK(&group->work, iopf_handle_group);
> >> +
> >> +	/* See if we have partial faults for this group */
> >> +	list_for_each_entry_safe(fault, next,
> >> &iopf_param->partial, head) {
> >> +		if (fault->evt.page_req_group_id ==
> >> evt->page_req_group_id)  
> > If all 9 bit group index are used, there can be lots of PRGs. For
> > future enhancement, maybe we can have per group partial list ready
> > to go when LPIG comes in? I will be less searching.  
> 
> Yes, allocating the PRG from the start could be more efficient. I
> think it's slightly more complicated code so I'd rather see
> performance numbers before implementing it
> 
> >> +			/* Insert *before* the last fault */
> >> +			list_move(&fault->head, &group->faults);
> >> +	}
> >> +  
> > If you already sorted the group list with last fault at the end,
> > why do you need a separate entry to track the last fault?  
> 
> Not sure I understand your question, sorry. Do you mean why the
> iopf_group.last_fault? Just to avoid one more kzalloc.
> 
kind of :) what i thought was that why can't the last_fault naturally
be the last entry in your group fault list? then there is no need for
special treatment in terms of allocation of the last fault. just my
preference.
> >> +
> >> +	queue->flush(queue->flush_arg, dev);
> >> +
> >> +	/*
> >> +	 * No need to clear the partial list. All PRGs containing
> >> the PASID that
> >> +	 * needs to be decommissioned are whole (the device driver
> >> made sure of
> >> +	 * it before this function was called). They have been
> >> submitted to the
> >> +	 * queue by the above flush().
> >> +	 */  
> > So you are saying device driver need to make sure LPIG PRQ is
> > submitted in the flush call above such that partial list is
> > cleared?  
> 
> Not exactly, it's the IOMMU driver that makes sure all LPIG in its
> queues are submitted by the above flush call. In more details the
> flow is:
> 
> * Either device driver calls unbind()/sva_device_shutdown(), or the
> process exits.
> * If the device driver called, then it already told the device to stop
> using the PASID. Otherwise we use the mm_exit() callback to tell the
> device driver to stop using the PASID.
> * In either case, when receiving a stop request from the driver, the
> device sends the LPIGs to the IOMMU queue.
> * Then, the flush call above ensures that the IOMMU reports the LPIG
> with iommu_report_device_fault.
> * While submitting all LPIGs for this PASID to the work queue,
> ipof_queue_fault also picked up all partial faults, so the partial
> list is clean.
> 
> Maybe I should improve this comment?
> 
thanks for explaining. LPIG submission is done by device asynchronously
w.r.t. driver stopping/decommission PASID. so if we were to use this
flow on vt-d, which does not stall page request queue, then we should
use the iommu model specific flush() callback to ensure LPIG is
received? There could be queue full condition and retry. I am just
trying to understand how and where we can make sure LPIG is
received and all groups are whole.

> > what if
> > there are device failures where device needs to reset (either whole
> > function level or PASID level), should there still be a need to
> > clear the partial list for all associated PASID/group?  
> 
> I guess the simplest way out, when resetting the device, is for the
> device driver to call iommu_sva_device_shutdown(). Both the IOMMU
> driver's sva_device_shutdown() and remove_device() ops should call
> iopf_queue_remove_device(), which clears the partial list.
> 
yes. I think that should work for functional reset.
> Thanks,
> Jean

[Jacob Pan]
