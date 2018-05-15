Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD006B02A5
	for <linux-mm@kvack.org>; Tue, 15 May 2018 10:17:09 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id c6-v6so229985otk.9
        for <linux-mm@kvack.org>; Tue, 15 May 2018 07:17:09 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 38-v6si49301ota.301.2018.05.15.07.17.07
        for <linux-mm@kvack.org>;
        Tue, 15 May 2018 07:17:07 -0700 (PDT)
Date: Tue, 15 May 2018 15:16:58 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 16/40] arm64: mm: Pin down ASIDs for sharing mm with
 devices
Message-ID: <20180515141658.vivrgcyww2pxumye@armageddon.cambridge.arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-17-jean-philippe.brucker@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180511190641.23008-17-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, xieyisheng1@huawei.com, liubo95@huawei.com, xuzaibo@huawei.com, thunder.leizhen@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, yi.l.liu@intel.com, ashok.raj@intel.com, tn@semihalf.com, joro@8bytes.org, bharatku@xilinx.com, liudongdong3@huawei.com, rfranz@cavium.com, kevin.tian@intel.com, jacob.jun.pan@linux.intel.com, jcrouse@codeaurora.org, rgummal@xilinx.com, jonathan.cameron@huawei.com, shunyong.yang@hxt-semitech.com, robin.murphy@arm.com, ilias.apalodimas@linaro.org, alex.williamson@redhat.com, robdclark@gmail.com, dwmw2@infradead.org, christian.koenig@amd.com, nwatters@codeaurora.org, baolu.lu@linux.intel.com

Hi Jean-Philippe,

On Fri, May 11, 2018 at 08:06:17PM +0100, Jean-Philippe Brucker wrote:
> +unsigned long mm_context_get(struct mm_struct *mm)
> +{
> +	unsigned long flags;
> +	u64 asid;
> +
> +	raw_spin_lock_irqsave(&cpu_asid_lock, flags);
> +
> +	asid = atomic64_read(&mm->context.id);
> +
> +	if (mm->context.pinned) {
> +		mm->context.pinned++;
> +		asid &= ~ASID_MASK;
> +		goto out_unlock;
> +	}
> +
> +	if (nr_pinned_asids >= max_pinned_asids) {
> +		asid = 0;
> +		goto out_unlock;
> +	}
> +
> +	if (!asid_gen_match(asid)) {
> +		/*
> +		 * We went through one or more rollover since that ASID was
> +		 * used. Ensure that it is still valid, or generate a new one.
> +		 * The cpu argument isn't used by new_context.
> +		 */
> +		asid = new_context(mm, 0);
> +		atomic64_set(&mm->context.id, asid);
> +	}
> +
> +	asid &= ~ASID_MASK;
> +
> +	nr_pinned_asids++;
> +	__set_bit(asid2idx(asid), pinned_asid_map);
> +	mm->context.pinned++;
> +
> +out_unlock:
> +	raw_spin_unlock_irqrestore(&cpu_asid_lock, flags);
> +
> +	return asid;
> +}

With CONFIG_UNMAP_KERNEL_AT_EL0 (a.k.a. KPTI), the hardware ASID has bit
0 set automatically when entering user space (and cleared when getting
back to the kernel). If the returned asid value here is going to be used
as is in the calling code, you should probably set bit 0 when KPTI is
enabled.

-- 
Catalin
