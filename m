Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5544E6B04FA
	for <linux-mm@kvack.org>; Thu, 17 May 2018 11:03:26 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id n3-v6so3621555otk.7
        for <linux-mm@kvack.org>; Thu, 17 May 2018 08:03:26 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k186-v6si1652394oia.433.2018.05.17.08.03.22
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 08:03:22 -0700 (PDT)
Subject: Re: [PATCH] KVM: arm/arm64: add WARN_ON if size is not PAGE_SIZE
 aligned in unmap_stage2_range
References: <1526537487-14804-1-git-send-email-hejianet@gmail.com>
 <698b0355-d430-86b8-cd09-83c6d9e566f8@arm.com>
 <fbb269c0-e915-a9f2-da3b-5ae3a2b31396@gmail.com>
From: Suzuki K Poulose <Suzuki.Poulose@arm.com>
Message-ID: <25dbb8c1-631f-c810-4d75-349a0b291cf8@arm.com>
Date: Thu, 17 May 2018 16:03:15 +0100
MIME-Version: 1.0
In-Reply-To: <fbb269c0-e915-a9f2-da3b-5ae3a2b31396@gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Christoffer Dall <christoffer.dall@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, "David S. Miller" <davem@davemloft.net>, Minchan Kim <minchan@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com

On 17/05/18 13:46, Jia He wrote:
> Hi Suzuki
> 
> On 5/17/2018 4:17 PM, Suzuki K Poulose Wrote:
>>
>> Hi Jia,
>>
>> On 17/05/18 07:11, Jia He wrote:
>>> I ever met a panic under memory pressure tests(start 20 guests and run
>>> memhog in the host).
>>
>> Please avoid using "I" in the commit description and preferably stick to
>> an objective description.
> 
> Thanks for the pointing
> 
>>
>>>
>>> The root cause might be what I fixed at [1]. But from arm kvm points of
>>> view, it would be better we caught the exception earlier and clearer.
>>>
>>> If the size is not PAGE_SIZE aligned, unmap_stage2_range might unmap the
>>> wrong(more or less) page range. Hence it caused the "BUG: Bad page
>>> state"
>>
>> I don't see why we should ever panic with a "positive" size value. Anyways,
>> the unmap requests must be in units of pages. So this check might be useful.
>>
>>
> 
> good question,
> 
> After further digging, maybe we need to harden the break condition as below?
> diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
> index 7f6a944..dac9b2e 100644
> --- a/virt/kvm/arm/mmu.c
> +++ b/virt/kvm/arm/mmu.c
> @@ -217,7 +217,7 @@ static void unmap_stage2_ptes(struct kvm *kvm, pmd_t *pmd,
> 
>                          put_page(virt_to_page(pte));
>                  }
> -       } while (pte++, addr += PAGE_SIZE, addr != end);
> +       } while (pte++, addr += PAGE_SIZE, addr < end);

I don't think this change is need as stage2_pgd_addr_end(addr, end) must return
the smaller of the next entry or end. Thus we can't miss "addr" == "end".

Suzuki
