Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64FF16B0038
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 21:56:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k83so17121485pfa.2
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 18:56:02 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id sq1si32426942pab.29.2016.09.05.18.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Sep 2016 18:56:01 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id pp5so3650786pac.2
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 18:56:01 -0700 (PDT)
Subject: Re: [RESEND][v2][PATCH] KVM: PPC: Book3S HV: Migrate pinned pages out
 of CMA
References: <20160714042536.GG18277@balbir.ozlabs.ibm.com>
 <3ba0fa6c-bfe6-a395-9c32-db8d6261559d@ozlabs.ru>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <cf34d62d-164c-bc7b-5538-ebd3c22657a5@gmail.com>
Date: Tue, 6 Sep 2016 11:55:54 +1000
MIME-Version: 1.0
In-Reply-To: <3ba0fa6c-bfe6-a395-9c32-db8d6261559d@ozlabs.ru>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>



On 31/08/16 14:14, Alexey Kardashevskiy wrote:
> On 14/07/16 14:25, Balbir Singh wrote:
>>
>> From: Balbir Singh <bsingharora@gmail.com>
>> Subject: [RESEND][v2][PATCH] KVM: PPC: Book3S HV: Migrate pinned pages out of CMA
>>
>> When PCI Device pass-through is enabled via VFIO, KVM-PPC will
>> pin pages using get_user_pages_fast(). One of the downsides of
>> the pinning is that the page could be in CMA region. The CMA
>> region is used for other allocations like the hash page table.
>> Ideally we want the pinned pages to be from non CMA region.
>>
>> This patch (currently only for KVM PPC with VFIO) forcefully
>> migrates the pages out (huge pages are omitted for the moment).
>> There are more efficient ways of doing this, but that might
>> be elaborate and might impact a larger audience beyond just
>> the kvm ppc implementation.
>>
>> The magic is in new_iommu_non_cma_page() which allocates the
>> new page from a non CMA region.
>>
>> I've tested the patches lightly at my end, but there might be bugs
>> For example if after lru_add_drain(), the page is not isolated
>> is this a BUG?
>>
>> Previous discussion was at
>> http://permalink.gmane.org/gmane.linux.kernel.mm/136738
>>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Paul Mackerras <paulus@ozlabs.org>
>> Cc: Alexey Kardashevskiy <aik@ozlabs.ru>
>>
>> Signed-off-by: Balbir Singh <bsingharora@gmail.com>
> 
> 
> 
> Acked-by: Alexey Kardashevskiy <aik@ozlabs.ru>
> 

Thanks! I tested this patch against latest mainline and here are the test results


System RAM - 64GB

VM instance 1 - size 55GB

Before patch - nr_free_cma after launch 8900
After patch - nr_free_cma after launch 39500

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
