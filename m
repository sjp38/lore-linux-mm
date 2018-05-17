Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA3896B039D
	for <linux-mm@kvack.org>; Thu, 17 May 2018 04:17:51 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x134-v6so2469853oif.19
        for <linux-mm@kvack.org>; Thu, 17 May 2018 01:17:51 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e59-v6si1538079ote.206.2018.05.17.01.17.50
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 01:17:50 -0700 (PDT)
Subject: Re: [PATCH] KVM: arm/arm64: add WARN_ON if size is not PAGE_SIZE
 aligned in unmap_stage2_range
References: <1526537487-14804-1-git-send-email-hejianet@gmail.com>
From: Suzuki K Poulose <Suzuki.Poulose@arm.com>
Message-ID: <698b0355-d430-86b8-cd09-83c6d9e566f8@arm.com>
Date: Thu, 17 May 2018 09:17:44 +0100
MIME-Version: 1.0
In-Reply-To: <1526537487-14804-1-git-send-email-hejianet@gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Christoffer Dall <christoffer.dall@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, "David S. Miller" <davem@davemloft.net>, Minchan Kim <minchan@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com


Hi Jia,

On 17/05/18 07:11, Jia He wrote:
> I ever met a panic under memory pressure tests(start 20 guests and run
> memhog in the host).

Please avoid using "I" in the commit description and preferably stick to
an objective description.

> 
> The root cause might be what I fixed at [1]. But from arm kvm points of
> view, it would be better we caught the exception earlier and clearer.
> 
> If the size is not PAGE_SIZE aligned, unmap_stage2_range might unmap the
> wrong(more or less) page range. Hence it caused the "BUG: Bad page
> state"

I don't see why we should ever panic with a "positive" size value. Anyways,
the unmap requests must be in units of pages. So this check might be useful.


Reviewed-by: Suzuki K Poulose <suzuki.poulose@arm.com>

> 
> [1] https://lkml.org/lkml/2018/5/3/1042
> 
> Signed-off-by: jia.he@hxt-semitech.com
> ---
>   virt/kvm/arm/mmu.c | 2 ++
>   1 file changed, 2 insertions(+)
> 
> diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
> index 7f6a944..8dac311 100644
> --- a/virt/kvm/arm/mmu.c
> +++ b/virt/kvm/arm/mmu.c
> @@ -297,6 +297,8 @@ static void unmap_stage2_range(struct kvm *kvm, phys_addr_t start, u64 size)
>   	phys_addr_t next;
>   
>   	assert_spin_locked(&kvm->mmu_lock);
> +	WARN_ON(size & ~PAGE_MASK);
> +
>   	pgd = kvm->arch.pgd + stage2_pgd_index(addr);
>   	do {
>   		/*
> 
