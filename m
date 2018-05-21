Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1B8B6B0005
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:48:15 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id 37-v6so12354733otv.2
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:48:15 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g10-v6si4980525otb.420.2018.05.21.07.48.14
        for <linux-mm@kvack.org>;
        Mon, 21 May 2018 07:48:15 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 07/40] iommu: Add a page fault handler
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-8-jean-philippe.brucker@arm.com>
 <20180517162555.00002bd3@huawei.com>
Message-ID: <d00405e5-9742-1b24-d6b0-6d389bb815ab@arm.com>
Date: Mon, 21 May 2018 15:48:05 +0100
MIME-Version: 1.0
In-Reply-To: <20180517162555.00002bd3@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: kvm@vger.kernel.org, linux-pci@vger.kernel.org, xuzaibo@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, linux-mm@kvack.org, ashok.raj@intel.com, bharatku@xilinx.com, linux-acpi@vger.kernel.org, rfranz@cavium.com, devicetree@vger.kernel.org, rgummal@xilinx.com, linux-arm-kernel@lists.infradead.org, dwmw2@infradead.org, ilias.apalodimas@linaro.org, iommu@lists.linux-foundation.org, christian.koenig@amd.com

On 17/05/18 16:25, Jonathan Cameron wrote:
> On Fri, 11 May 2018 20:06:08 +0100
> Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:
> 
>> Some systems allow devices to handle I/O Page Faults in the core mm. For
>> example systems implementing the PCI PRI extension or Arm SMMU stall
>> model. Infrastructure for reporting these recoverable page faults was
>> recently added to the IOMMU core for SVA virtualisation. Add a page fault
>> handler for host SVA.
>>
>> IOMMU driver can now instantiate several fault workqueues and link them to
>> IOPF-capable devices. Drivers can choose between a single global
>> workqueue, one per IOMMU device, one per low-level fault queue, one per
>> domain, etc.
>>
>> When it receives a fault event, supposedly in an IRQ handler, the IOMMU
>> driver reports the fault using iommu_report_device_fault(), which calls
>> the registered handler. The page fault handler then calls the mm fault
>> handler, and reports either success or failure with iommu_page_response().
>> When the handler succeeded, the IOMMU retries the access.
>>
>> The iopf_param pointer could be embedded into iommu_fault_param. But
>> putting iopf_param into the iommu_param structure allows us not to care
>> about ordering between calls to iopf_queue_add_device() and
>> iommu_register_device_fault_handler().
>>
>> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
> 
> Hi Jean-Phillipe,
> 
> One question below on how we would end up with partial faults left when
> doing the queue remove. Code looks fine, but I'm not seeing how that
> would happen without buggy hardware... + we presumably have to rely on
> the hardware timing out on that request or it's dead anyway...

>> +/**
>> + * iopf_queue_remove_device - Remove producer from fault queue
>> + * @dev: device to remove
>> + *
>> + * Caller makes sure that no more fault is reported for this device, and no more
>> + * flush is scheduled for this device.
>> + *
>> + * Note: safe to call unconditionally on a cleanup path, even if the device
>> + * isn't registered to any IOPF queue.
>> + *
>> + * Return 0 if the device was attached to the IOPF queue
>> + */
>> +int iopf_queue_remove_device(struct device *dev)
>> +{
>> +	struct iopf_context *fault, *next;
>> +	struct iopf_device_param *iopf_param;
>> +	struct iommu_param *param = dev->iommu_param;
>> +
>> +	if (!param)
>> +		return -EINVAL;
>> +
>> +	mutex_lock(&param->lock);
>> +	iopf_param = param->iopf_param;
>> +	if (iopf_param) {
>> +		refcount_dec(&iopf_param->queue->refs);
>> +		param->iopf_param = NULL;
>> +	}
>> +	mutex_unlock(&param->lock);
>> +	if (!iopf_param)
>> +		return -EINVAL;
>> +
>> +	list_for_each_entry_safe(fault, next, &iopf_param->partial, head)
>> +		kfree(fault);
>> +
> 
> Why would we end up here with partials still in the list?  Buggy hardware?

Buggy hardware is one possibility. There also is the nasty case of PRI
queue overflow. If the PRI queue is full, then the SMMU discards new
Page Requests from the device. It may discard a 'last' PR of a group
that is already in iopf_param->partial. This group will never be freed
until this cleanup.

The spec dismisses PRIq overflows because the OS is supposed to allocate
PRI credits to devices such that they can't send more than the PRI queue
size. This isn't possible in Linux because we don't know exactly how
many PRI-capable devices will share a queue (the upper limit is 2**32,
and devices may be hotplugged well after we allocated the PRI queue). So
PRIq overflow is possible.

Ideally when detecting a PRIq overflow we need to immediately remove all
partial faults of all devices sharing this queue. Since I can't easily
test that case (my device doesn't do PRGs) and it's complicated code, I
left it as TODO in patch 39, and this is our only chance to free
orphaned page requests.

>> +void iopf_queue_free(struct iopf_queue *queue)
>> +{
>> +
> 
> Nitpick : Blank line here doesn't add anything.

Ok

Thanks,
Jean
