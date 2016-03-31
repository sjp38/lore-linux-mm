Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 26DE06B025E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 22:28:51 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id x3so57539383pfb.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 19:28:51 -0700 (PDT)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id ew7si10468230pad.131.2016.03.30.19.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 30 Mar 2016 19:28:50 -0700 (PDT)
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gwshan@linux.vnet.ibm.com>;
	Thu, 31 Mar 2016 12:28:46 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 194513578056
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 13:28:38 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2V2SPY22097428
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 13:28:38 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2V2Rxi5018961
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 13:27:59 +1100
Date: Thu, 31 Mar 2016 13:27:34 +1100
From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [RFC] mm: Fix memory corruption caused by deferred page
 initialization
Message-ID: <20160331022734.GA12552@gwshan>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
References: <1458921929-15264-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <3qXFh60DRNz9sDH@ozlabs.org>
 <20160326133708.GA382@gwshan>
 <20160327134827.GA24644@gwshan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160327134827.GA24644@gwshan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, mgorman@suse.de, zhlcindy@linux.vnet.ibm.com

On Mon, Mar 28, 2016 at 12:48:27AM +1100, Gavin Shan wrote:
>On Sun, Mar 27, 2016 at 12:37:09AM +1100, Gavin Shan wrote:
>>On Sat, Mar 26, 2016 at 08:47:17PM +1100, Michael Ellerman wrote:
>>>Hi Gavin,
>>>
>>>On Fri, 2016-25-03 at 16:05:29 UTC, Gavin Shan wrote:
>>>> During deferred page initialization, the pages are moved from memblock
>>>> or bootmem to buddy allocator without checking they were reserved. Those
>>>> reserved pages can be reallocated to somebody else by buddy/slab allocator.
>>>> It leads to memory corruption and potential kernel crash eventually.
>>>
>>>Can you give me a bit more detail on what the bug is?
>>>
>>>I haven't seen any issues on my systems, but I realise now I haven't enabled
>>>DEFERRED_STRUCT_PAGE_INIT - I assumed it was enabled by default.
>>>
>>>How did this get tested before submission?
>>>
>>
>>Michael, I have to reply with same context in another thread in case 
>>somebody else wants to understand more: Li, who is in the cc list, is
>>backporting deferred page initialization (CONFIG_DEFERRED_STRUCT_PAGE_INIT)
>>from upstream kernel to RHEL 7.2 or 7.3 kernel (3.10.0-357.el7). RHEL kernel
>>has (!CONFIG_NO_BOOTMEM && CONFIG_DEFERRED_STRUCT_PAGE_INIT), meaning
>>bootmem is enabled. She eventually runs into kernel crash and I jumped
>>in to help understanding the root cause.
>>
>>There're two related kernel config options: ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>>and DEFERRED_STRUCT_PAGE_INIT. The former one is enabled on PPC by default.
>>The later one isn't enabled by default.
>>
>>There are two test cases I had:
>>
>>- With (!CONFIG_NO_BOOTMEM && CONFIG_DEFERRED_STRUCT_PAGE_INIT)
>>on PowerNV platform, upstream kernel (4.5.rc7) and additional patch to support
>>bootmem as it was removed on powerpc a while ago.
>>
>>- With (CONFIG_NO_BOOTMEM && CONFIG_DEFERRED_STRUCT_PAGE_INIT) on PowerNV platform,
>>upstream kernel (4.5.rc7), I dumped the reserved memblock regions and added printk
>>in function deferred_init_memmap() to check if memblock reserved PFN 0x1fff80 (one
>>page in memblock reserved region#31, refer to the below kernel log) is released
>>to buddy allocator or not when doing deferred page struct initialization. I did
>>see that PFN is released to buddy allocator at that time. However, I didn't see
>>kernel crash and it would be luck and the current deferred page struct initialization
>>implementation: The pages in region [0, 2GB] except the memblock reserved ones are
>>presented to buddy allocator at early stage. It's not deferred. So for the pages in
>>[0, 2GB], we don't have consistency issue between memblock and buddy allocator.
>>The pages in region [2GB ...] are all presented to buddy allocator despite they're
>>reserved in memblock or not. It ensures the kernel text section isn't corrupted
>>and we're lucky not seeing program interrupt because of illegal instruction.
>>
>
>After more debugging, it turns out that Michael is correct: we don't have problem
>when CONFIG_NO_BOOTMEM=y. In the case, the page frames in [2G ...] is marked as
>reserved in early stage (as below function calls reveal). During the deferred
>initialization stage, those reserved pages won't be released to buddy allocator:
>
>- Below function calls mark reserved pages according to memblock reserved regions:
>  init/main.c::start_kernel()
>  init/main.c::mm_init()
>  arch/powerpc/mm/mem.c::mem_init()
>  nobootmem.c::free_all_bootmem()            <-> bootmem.c::free_all_bootmem() on !CONFIG_NO_BOOTMEM
>  nobootmem.c::free_low_memory_core_early()
>  nobootmem.c::reserve_bootmem_region()
>
>- In page_alloc.c::deferred_init_memmap(), the reserved pages aren't released
>  to buddy allocator with below check:
>
>                        if (page->flags) {
>                                VM_BUG_ON(page_zone(page) != zone);
>                                goto free_range;
>                        }
>
>
>So the issue is only existing when CONFIG_NO_BOOTMEM=n. The alternative fix would
>be similar to what we have on !CONFIG_NO_BOOTMEM: In early stage, all page structs
>for bootmem reserved pages are initialized and mark them with PG_reserved. I'm
>not sure it's worthy to fix it as we won't support bootmem as Michael mentioned.
>

Mel, could you please confirm if we need a fix on !CONFIG_NO_BOOTMEM? If we need,
I'll respin and send a patch for review.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
