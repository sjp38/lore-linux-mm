Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB9F6B0005
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:44:12 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id 37-v6so12348278otv.2
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:44:12 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u14-v6si4553899oie.441.2018.05.21.07.44.11
        for <linux-mm@kvack.org>;
        Mon, 21 May 2018 07:44:11 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-4-jean-philippe.brucker@arm.com>
 <20180517150516.000067ca@huawei.com>
Message-ID: <d3629e67-34ad-b080-3c03-bf48e5d780d5@arm.com>
Date: Mon, 21 May 2018 15:44:01 +0100
MIME-Version: 1.0
In-Reply-To: <20180517150516.000067ca@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: kvm@vger.kernel.org, linux-pci@vger.kernel.org, xuzaibo@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, linux-mm@kvack.org, ashok.raj@intel.com, bharatku@xilinx.com, linux-acpi@vger.kernel.org, rfranz@cavium.com, devicetree@vger.kernel.org, rgummal@xilinx.com, linux-arm-kernel@lists.infradead.org, dwmw2@infradead.org, ilias.apalodimas@linaro.org, iommu@lists.linux-foundation.org, christian.koenig@amd.com

On 17/05/18 15:25, Jonathan Cameron wrote:
>> +static struct io_mm *
>> +io_mm_alloc(struct iommu_domain *domain, struct device *dev,
>> +	    struct mm_struct *mm, unsigned long flags)
>> +{
>> +	int ret;
>> +	int pasid;
>> +	struct io_mm *io_mm;
>> +	struct iommu_sva_param *param = dev->iommu_param->sva_param;
>> +
>> +	if (!domain->ops->mm_alloc || !domain->ops->mm_free)
>> +		return ERR_PTR(-ENODEV);
>> +
>> +	io_mm = domain->ops->mm_alloc(domain, mm, flags);
>> +	if (IS_ERR(io_mm))
>> +		return io_mm;
>> +	if (!io_mm)
>> +		return ERR_PTR(-ENOMEM);
>> +
>> +	/*
>> +	 * The mm must not be freed until after the driver frees the io_mm
>> +	 * (which may involve unpinning the CPU ASID for instance, requiring a
>> +	 * valid mm struct.)
>> +	 */
>> +	mmgrab(mm);
>> +
>> +	io_mm->flags		= flags;
>> +	io_mm->mm		= mm;
>> +	io_mm->release		= domain->ops->mm_free;
>> +	INIT_LIST_HEAD(&io_mm->devices);
>> +
>> +	idr_preload(GFP_KERNEL);
>> +	spin_lock(&iommu_sva_lock);
>> +	pasid = idr_alloc(&iommu_pasid_idr, io_mm, param->min_pasid,
>> +			  param->max_pasid + 1, GFP_ATOMIC);
> 
> I'd expect the IDR cleanup to be in io_mm_free as that would 'match'
> against io_mm_alloc but it's in io_mm_release just before the io_mm_free
> call, perhaps move it or am I missing something?
> 
> Hmm. This is reworked in patch 5 to use call rcu to do the free.  I suppose
> we may be burning an idr entry if we take a while to get round to the
> free..  If so a comment to explain this would be great.

Ok, I'll see if I can come up with some comments for both patch 3 and 5.

>> +	io_mm->pasid = pasid;
>> +	spin_unlock(&iommu_sva_lock);
>> +	idr_preload_end();
>> +
>> +	if (pasid < 0) {
>> +		ret = pasid;
>> +		goto err_free_mm;
>> +	}
>> +
>> +	/* TODO: keep track of mm. For the moment, abort. */
> 
> From later patches, I can now see why we didn't init the kref
> here, but perhaps a comment would make that clear rather than
> people checking it is correctly used throughout?  Actually just grab
> the comment from patch 5 and put it in this one and that will
> do the job nicely.

Ok

>> +	ret = -ENOSYS;
>> +	spin_lock(&iommu_sva_lock);
>> +	idr_remove(&iommu_pasid_idr, io_mm->pasid);
>> +	spin_unlock(&iommu_sva_lock);
>> +
>> +err_free_mm:
>> +	domain->ops->mm_free(io_mm);
> 
> Really minor, but you now have io_mm->release set so to keep
> this obviously the same as the io_mm_free path, perhaps call
> that rather than mm_free directly.

Yes, makes sense

>> +static void io_mm_detach_locked(struct iommu_bond *bond)
>> +{
>> +	struct iommu_bond *tmp;
>> +	bool detach_domain = true;
>> +	struct iommu_domain *domain = bond->domain;
>> +
>> +	list_for_each_entry(tmp, &domain->mm_list, domain_head) {
>> +		if (tmp->io_mm == bond->io_mm && tmp->dev != bond->dev) {
>> +			detach_domain = false;
>> +			break;
>> +		}
>> +	}
>> +
>> +	domain->ops->mm_detach(domain, bond->dev, bond->io_mm, detach_domain);
>> +
> 
> I can't see an immediate reason to have a different order in her to the reverse of
> the attach above.   So I think you should be detaching after the list_del calls.
> If there is a reason, can we have a comment so I don't ask on v10.

I don't see a reason either right now, I'll see if it can be moved

> 
>> +	list_del(&bond->mm_head);
>> +	list_del(&bond->domain_head);
>> +	list_del(&bond->dev_head);
>> +	io_mm_put_locked(bond->io_mm);


>> +	/* If an io_mm already exists, use it */
>> +	spin_lock(&iommu_sva_lock);
>> +	idr_for_each_entry(&iommu_pasid_idr, io_mm, i) {
>> +		if (io_mm->mm == mm && io_mm_get_locked(io_mm)) {
>> +			/* ... Unless it's already bound to this device */
>> +			list_for_each_entry(tmp, &io_mm->devices, mm_head) {
>> +				if (tmp->dev == dev) {
>> +					bond = tmp;
> 
> Using bond for this is clear in a sense, but can we not just use ret
> so it is obvious here that we are going to return -EEXIST?
> At first glance I thought you were going to carry on with this bond
> and couldn't work out why it would ever make sense to have two bonds
> between a device an an io_mm (which it doesn't!)

Yes, using ret is nicer

Thanks,
Jean
