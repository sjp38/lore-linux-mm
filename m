Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56A696B0492
	for <linux-mm@kvack.org>; Thu, 17 May 2018 06:02:09 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id e32-v6so3037256ote.23
        for <linux-mm@kvack.org>; Thu, 17 May 2018 03:02:09 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h125-v6si1580418oic.283.2018.05.17.03.02.07
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 03:02:07 -0700 (PDT)
Subject: Re: [PATCH v2 16/40] arm64: mm: Pin down ASIDs for sharing mm with
 devices
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-17-jean-philippe.brucker@arm.com>
 <20180515141658.vivrgcyww2pxumye@armageddon.cambridge.arm.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <81662b4f-2210-665f-21cf-7679bfa9f97a@arm.com>
Date: Thu, 17 May 2018 11:01:55 +0100
MIME-Version: 1.0
In-Reply-To: <20180515141658.vivrgcyww2pxumye@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: ilias.apalodimas@linaro.org, kvm@vger.kernel.org, linux-pci@vger.kernel.org, xuzaibo@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, linux-mm@kvack.org, ashok.raj@intel.com, bharatku@xilinx.com, linux-acpi@vger.kernel.org, rfranz@cavium.com, devicetree@vger.kernel.org, rgummal@xilinx.com, linux-arm-kernel@lists.infradead.org, dwmw2@infradead.org, iommu@lists.linux-foundation.org, christian.koenig@amd.com

On 15/05/18 15:16, Catalin Marinas wrote:
> Hi Jean-Philippe,
> 
> On Fri, May 11, 2018 at 08:06:17PM +0100, Jean-Philippe Brucker wrote:
>> +unsigned long mm_context_get(struct mm_struct *mm)
>> +{
>> +	unsigned long flags;
>> +	u64 asid;
>> +
>> +	raw_spin_lock_irqsave(&cpu_asid_lock, flags);
>> +
>> +	asid = atomic64_read(&mm->context.id);
>> +
>> +	if (mm->context.pinned) {
>> +		mm->context.pinned++;
>> +		asid &= ~ASID_MASK;
>> +		goto out_unlock;
>> +	}
>> +
>> +	if (nr_pinned_asids >= max_pinned_asids) {
>> +		asid = 0;
>> +		goto out_unlock;
>> +	}
>> +
>> +	if (!asid_gen_match(asid)) {
>> +		/*
>> +		 * We went through one or more rollover since that ASID was
>> +		 * used. Ensure that it is still valid, or generate a new one.
>> +		 * The cpu argument isn't used by new_context.
>> +		 */
>> +		asid = new_context(mm, 0);
>> +		atomic64_set(&mm->context.id, asid);
>> +	}
>> +
>> +	asid &= ~ASID_MASK;
>> +
>> +	nr_pinned_asids++;
>> +	__set_bit(asid2idx(asid), pinned_asid_map);
>> +	mm->context.pinned++;
>> +
>> +out_unlock:
>> +	raw_spin_unlock_irqrestore(&cpu_asid_lock, flags);
>> +
>> +	return asid;
>> +}
> 
> With CONFIG_UNMAP_KERNEL_AT_EL0 (a.k.a. KPTI), the hardware ASID has bit
> 0 set automatically when entering user space (and cleared when getting
> back to the kernel). If the returned asid value here is going to be used
> as is in the calling code, you should probably set bit 0 when KPTI is
> enabled.
> 

Oh right, I'll change this

Thanks,
Jean
