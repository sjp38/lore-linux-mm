Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE4266B0005
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:49:50 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id r104-v6so12351734ota.19
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:49:50 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r10-v6si4637084oib.265.2018.05.21.07.49.49
        for <linux-mm@kvack.org>;
        Mon, 21 May 2018 07:49:49 -0700 (PDT)
Subject: Re: [PATCH v2 07/40] iommu: Add a page fault handler
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-8-jean-philippe.brucker@arm.com>
 <20180518110434.150a0e64@jacob-builder>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <8a640794-a6f3-fa01-82a9-06479a6f779a@arm.com>
Date: Mon, 21 May 2018 15:49:40 +0100
MIME-Version: 1.0
In-Reply-To: <20180518110434.150a0e64@jacob-builder>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jacob Pan <jacob.jun.pan@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-pci@vger.kernel.org, xuzaibo@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, linux-mm@kvack.org, ashok.raj@intel.com, bharatku@xilinx.com, linux-acpi@vger.kernel.org, rfranz@cavium.com, devicetree@vger.kernel.org, rgummal@xilinx.com, linux-arm-kernel@lists.infradead.org, dwmw2@infradead.org, ilias.apalodimas@linaro.org, iommu@lists.linux-foundation.org, christian.koenig@amd.com

On 18/05/18 19:04, Jacob Pan wrote:
>> +struct iopf_context {
>> +	struct device			*dev;
>> +	struct iommu_fault_event	evt;
>> +	struct list_head		head;
>> +};
>> +
>> +struct iopf_group {
>> +	struct iopf_context		last_fault;
>> +	struct list_head		faults;
>> +	struct work_struct		work;
>> +};
>> +
> All the page requests in the group should belong to the same device,
> perhaps struct device tracking should be in iopf_group instead of
> iopf_context?

Right, this is a leftover from when we kept a global list of partial
faults. Since the list is now per-device, I can move the dev pointer (I
think I should also rename iopf_context to iopf_fault, if that's all right)

>> +static int iopf_complete(struct device *dev, struct
>> iommu_fault_event *evt,
>> +			 enum page_response_code status)
>> +{
>> +	struct page_response_msg resp = {
>> +		.addr			= evt->addr,
>> +		.pasid			= evt->pasid,
>> +		.pasid_present		= evt->pasid_valid,
>> +		.page_req_group_id	= evt->page_req_group_id,
>> +		.private_data		= evt->iommu_private,
>> +		.resp_code		= status,
>> +	};
>> +
>> +	return iommu_page_response(dev, &resp);
>> +}
>> +
>> +static enum page_response_code
>> +iopf_handle_single(struct iopf_context *fault)
>> +{
>> +	/* TODO */
>> +	return -ENODEV;
>> +}
>> +
>> +static void iopf_handle_group(struct work_struct *work)
>> +{
>> +	struct iopf_group *group;
>> +	struct iopf_context *fault, *next;
>> +	enum page_response_code status = IOMMU_PAGE_RESP_SUCCESS;
>> +
>> +	group = container_of(work, struct iopf_group, work);
>> +
>> +	list_for_each_entry_safe(fault, next, &group->faults, head) {
>> +		struct iommu_fault_event *evt = &fault->evt;
>> +		/*
>> +		 * Errors are sticky: don't handle subsequent faults
>> in the
>> +		 * group if there is an error.
>> +		 */
> There might be performance benefit for certain device to continue in
> spite of error in that the ATS retry may have less fault. Perhaps a
> policy decision for later enhancement.

Yes I think we should leave it to future work. My current reasoning is
that subsequent requests are more likely to fail as well and reporting
the error is more urgent, but we need real workloads to confirm this.

>> +		if (status == IOMMU_PAGE_RESP_SUCCESS)
>> +			status = iopf_handle_single(fault);
>> +
>> +		if (!evt->last_req)
>> +			kfree(fault);
>> +	}
>> +
>> +	iopf_complete(group->last_fault.dev, &group->last_fault.evt,
>> status);
>> +	kfree(group);
>> +}
>> +
>> +/**
>> + * iommu_queue_iopf - IO Page Fault handler
>> + * @evt: fault event
>> + * @cookie: struct device, passed to
>> iommu_register_device_fault_handler.
>> + *
>> + * Add a fault to the device workqueue, to be handled by mm.
>> + */
>> +int iommu_queue_iopf(struct iommu_fault_event *evt, void *cookie)
>> +{
>> +	struct iopf_group *group;
>> +	struct iopf_context *fault, *next;
>> +	struct iopf_device_param *iopf_param;
>> +
>> +	struct device *dev = cookie;
>> +	struct iommu_param *param = dev->iommu_param;
>> +
>> +	if (WARN_ON(!mutex_is_locked(&param->lock)))
>> +		return -EINVAL;
>> +
>> +	if (evt->type != IOMMU_FAULT_PAGE_REQ)
>> +		/* Not a recoverable page fault */
>> +		return IOMMU_PAGE_RESP_CONTINUE;
>> +
>> +	/*
>> +	 * As long as we're holding param->lock, the queue can't be
>> unlinked
>> +	 * from the device and therefore cannot disappear.
>> +	 */
>> +	iopf_param = param->iopf_param;
>> +	if (!iopf_param)
>> +		return -ENODEV;
>> +
>> +	if (!evt->last_req) {
>> +		fault = kzalloc(sizeof(*fault), GFP_KERNEL);
>> +		if (!fault)
>> +			return -ENOMEM;
>> +
>> +		fault->evt = *evt;
>> +		fault->dev = dev;
>> +
>> +		/* Non-last request of a group. Postpone until the
>> last one */
>> +		list_add(&fault->head, &iopf_param->partial);
>> +
>> +		return IOMMU_PAGE_RESP_HANDLED;
>> +	}
>> +
>> +	group = kzalloc(sizeof(*group), GFP_KERNEL);
>> +	if (!group)
>> +		return -ENOMEM;
>> +
>> +	group->last_fault.evt = *evt;
>> +	group->last_fault.dev = dev;
>> +	INIT_LIST_HEAD(&group->faults);
>> +	list_add(&group->last_fault.head, &group->faults);
>> +	INIT_WORK(&group->work, iopf_handle_group);
>> +
>> +	/* See if we have partial faults for this group */
>> +	list_for_each_entry_safe(fault, next, &iopf_param->partial,
>> head) {
>> +		if (fault->evt.page_req_group_id ==
>> evt->page_req_group_id)
> If all 9 bit group index are used, there can be lots of PRGs. For
> future enhancement, maybe we can have per group partial list ready to
> go when LPIG comes in? I will be less searching.

Yes, allocating the PRG from the start could be more efficient. I think
it's slightly more complicated code so I'd rather see performance
numbers before implementing it

>> +			/* Insert *before* the last fault */
>> +			list_move(&fault->head, &group->faults);
>> +	}
>> +
> If you already sorted the group list with last fault at the end, why do
> you need a separate entry to track the last fault?

Not sure I understand your question, sorry. Do you mean why the
iopf_group.last_fault? Just to avoid one more kzalloc.

>> +
>> +	queue->flush(queue->flush_arg, dev);
>> +
>> +	/*
>> +	 * No need to clear the partial list. All PRGs containing
>> the PASID that
>> +	 * needs to be decommissioned are whole (the device driver
>> made sure of
>> +	 * it before this function was called). They have been
>> submitted to the
>> +	 * queue by the above flush().
>> +	 */
> So you are saying device driver need to make sure LPIG PRQ is submitted
> in the flush call above such that partial list is cleared?

Not exactly, it's the IOMMU driver that makes sure all LPIG in its
queues are submitted by the above flush call. In more details the flow is:

* Either device driver calls unbind()/sva_device_shutdown(), or the
process exits.
* If the device driver called, then it already told the device to stop
using the PASID. Otherwise we use the mm_exit() callback to tell the
device driver to stop using the PASID.
* In either case, when receiving a stop request from the driver, the
device sends the LPIGs to the IOMMU queue.
* Then, the flush call above ensures that the IOMMU reports the LPIG
with iommu_report_device_fault.
* While submitting all LPIGs for this PASID to the work queue,
ipof_queue_fault also picked up all partial faults, so the partial list
is clean.

Maybe I should improve this comment?

> what if
> there are device failures where device needs to reset (either whole
> function level or PASID level), should there still be a need to clear
> the partial list for all associated PASID/group?

I guess the simplest way out, when resetting the device, is for the
device driver to call iommu_sva_device_shutdown(). Both the IOMMU
driver's sva_device_shutdown() and remove_device() ops should call
iopf_queue_remove_device(), which clears the partial list.

Thanks,
Jean
