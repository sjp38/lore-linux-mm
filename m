Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B48806B02D9
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 12:03:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d6so9210420wrd.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 09:03:59 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id u13si7130278wma.51.2017.09.11.09.03.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 09:03:58 -0700 (PDT)
Received: from mail-wm0-f69.google.com ([74.125.82.69])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <juerg.haefliger@canonical.com>)
	id 1drRBl-0000i8-Lj
	for linux-mm@kvack.org; Mon, 11 Sep 2017 16:03:57 +0000
Received: by mail-wm0-f69.google.com with SMTP id p17so7839326wmd.3
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 09:03:57 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
 <20170911145020.fat456njvyagcomu@docker>
From: Juerg Haefliger <juerg.haefliger@canonical.com>
Message-ID: <57e95ad2-81d8-bf83-3e78-1313daa1bb80@canonical.com>
Date: Mon, 11 Sep 2017 18:03:55 +0200
MIME-Version: 1.0
In-Reply-To: <20170911145020.fat456njvyagcomu@docker>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, x86@kernel.org



On 09/11/2017 04:50 PM, Tycho Andersen wrote:
> Hi Yisheng,
> 
> On Mon, Sep 11, 2017 at 03:24:09PM +0800, Yisheng Xie wrote:
>>> +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
>>> +{
>>> +	int i, flush_tlb = 0;
>>> +	struct xpfo *xpfo;
>>> +
>>> +	if (!static_branch_unlikely(&xpfo_inited))
>>> +		return;
>>> +
>>> +	for (i = 0; i < (1 << order); i++)  {
>>> +		xpfo = lookup_xpfo(page + i);
>>> +		if (!xpfo)
>>> +			continue;
>>> +
>>> +		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
>>> +		     "xpfo: unmapped page being allocated\n");
>>> +
>>> +		/* Initialize the map lock and map counter */
>>> +		if (unlikely(!xpfo->inited)) {
>>> +			spin_lock_init(&xpfo->maplock);
>>> +			atomic_set(&xpfo->mapcount, 0);
>>> +			xpfo->inited = true;
>>> +		}
>>> +		WARN(atomic_read(&xpfo->mapcount),
>>> +		     "xpfo: already mapped page being allocated\n");
>>> +
>>> +		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
>>> +			/*
>>> +			 * Tag the page as a user page and flush the TLB if it
>>> +			 * was previously allocated to the kernel.
>>> +			 */
>>> +			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
>>> +				flush_tlb = 1;
>>
>> I'm not sure whether I am miss anything, however, when the page was previously allocated
>> to kernel,  should we unmap the physmap (the kernel's page table) here? For we allocate
>> the page to user now
>> 
> Yes, I think you're right. Oddly, the XPFO_READ_USER test works
> correctly for me, but I think (?) should not because of this bug...

IIRC, this is an optimization carried forward from the initial
implementation. The assumption is that the kernel will map the user
buffer so it's not unmapped on allocation but only on the first (and
subsequent) call of kunmap. I.e.:
 - alloc  -> noop
 - kmap   -> noop
 - kunmap -> unmapped from the kernel
 - kmap   -> mapped into the kernel
 - kunmap -> unmapped from the kernel
and so on until:
 - free   -> mapped back into the kernel

I'm not sure if that make sense though since it leaves a window.

...Juerg



> Tycho
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
