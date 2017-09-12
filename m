Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08F8C6B032C
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 04:09:16 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id v140so9020004ita.3
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 01:09:16 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id j203si10098160ioe.226.2017.09.12.01.09.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Sep 2017 01:09:15 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
 <20170911145020.fat456njvyagcomu@docker>
 <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <431e2567-7600-3186-1489-93b855c395bd@huawei.com>
Date: Tue, 12 Sep 2017 16:05:22 +0800
MIME-Version: 1.0
In-Reply-To: <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@canonical.com>, Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, x86@kernel.org



On 2017/9/12 0:03, Juerg Haefliger wrote:
> 
> 
> On 09/11/2017 04:50 PM, Tycho Andersen wrote:
>> Hi Yisheng,
>>
>> On Mon, Sep 11, 2017 at 03:24:09PM +0800, Yisheng Xie wrote:
>>>> +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
>>>> +{
>>>> +	int i, flush_tlb = 0;
>>>> +	struct xpfo *xpfo;
>>>> +
>>>> +	if (!static_branch_unlikely(&xpfo_inited))
>>>> +		return;
>>>> +
>>>> +	for (i = 0; i < (1 << order); i++)  {
>>>> +		xpfo = lookup_xpfo(page + i);
>>>> +		if (!xpfo)
>>>> +			continue;
>>>> +
>>>> +		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
>>>> +		     "xpfo: unmapped page being allocated\n");
>>>> +
>>>> +		/* Initialize the map lock and map counter */
>>>> +		if (unlikely(!xpfo->inited)) {
>>>> +			spin_lock_init(&xpfo->maplock);
>>>> +			atomic_set(&xpfo->mapcount, 0);
>>>> +			xpfo->inited = true;
>>>> +		}
>>>> +		WARN(atomic_read(&xpfo->mapcount),
>>>> +		     "xpfo: already mapped page being allocated\n");
>>>> +
>>>> +		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
>>>> +			/*
>>>> +			 * Tag the page as a user page and flush the TLB if it
>>>> +			 * was previously allocated to the kernel.
>>>> +			 */
>>>> +			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
>>>> +				flush_tlb = 1;
>>>
>>> I'm not sure whether I am miss anything, however, when the page was previously allocated
>>> to kernel,  should we unmap the physmap (the kernel's page table) here? For we allocate
>>> the page to user now
>>>
>> Yes, I think you're right. Oddly, the XPFO_READ_USER test works

Hi Tycho,
Could you share this test? I'd like to know how it works.

Thanks

>> correctly for me, but I think (?) should not because of this bug...
> 
> IIRC, this is an optimization carried forward from the initial
> implementation. 
Hi Juerg,

hmm.. If below is the first version, then it seems this exist from the first version:
https://patchwork.kernel.org/patch/8437451/

> The assumption is that the kernel will map the user
> buffer so it's not unmapped on allocation but only on the first (and
> subsequent) call of kunmap.

IMO, before a page is allocated, it is in buddy system, which means it is free
and no other 'map' on the page except direct map. Then if the page is allocated
to user, XPFO should unmap the direct map. otherwise the ret2dir may works at
this window before it is freed. Or maybe I'm still missing anything.

Thanks
Yisheng Xie

>  I.e.:
>  - alloc  -> noop
>  - kmap   -> noop
>  - kunmap -> unmapped from the kernel
>  - kmap   -> mapped into the kernel
>  - kunmap -> unmapped from the kernel
> and so on until:
>  - free   -> mapped back into the kernel
> 
> I'm not sure if that make sense though since it leaves a window.
> 
> ...Juerg
> 
> 
> 
>> Tycho
>>
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
