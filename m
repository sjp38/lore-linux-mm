Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 353A96B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 09:08:30 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 77so4196833pgc.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:08:30 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id z15si119265pll.224.2017.03.07.06.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 06:08:29 -0800 (PST)
Subject: Re: [RFC PATCH] mm: enable page poisoning early at boot
References: <1488809775-18347-1-git-send-email-vinmenon@codeaurora.org>
 <83fef5a7-11e8-a46e-e624-82362f651fe8@redhat.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <4fdbbcd9-8779-9bab-2597-56f3125b4c74@codeaurora.org>
Date: Tue, 7 Mar 2017 19:38:22 +0530
MIME-Version: 1.0
In-Reply-To: <83fef5a7-11e8-a46e-e624-82362f651fe8@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, iamjoonsoo.kim@lge.com, mhocko@suse.com, akpm@linux-foundation.org
Cc: shashim@codeaurora.org, linux-mm@kvack.org


On 3/7/2017 4:47 AM, Laura Abbott wrote:
> On 03/06/2017 06:16 AM, Vinayak Menon wrote:
>> On SPARSEMEM systems page poisoning is enabled after buddy is up, because
>> of the dependency on page extension init. This causes the pages released
>> by free_all_bootmem not to be poisoned. This either delays or misses
>> the identification of some issues because the pages have to undergo another
>> cycle of alloc-free-alloc for any corruption to be detected.
>> Enable page poisoning early by getting rid of the PAGE_EXT_DEBUG_POISON
>> flag. Since all the free pages will now be poisoned, the flag need not be
>> verified before checking the poison during an alloc.
>>
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>> ---
>>
>> Sending it as an RFC because I am not sure if I have missed a code path
>> that can free pages to buddy skipping kernel_poison_pages, making
>> the flag PAGE_EXT_DEBUG_POISON a necessity.
>>
> Have you tested this with hibernation? That's one place which tends
> to cause problems with poisoning.
Today I tried that on qemu and did not see any issue, and did not expect to hit any problems since
CONFIG_PAGE_POISONING_NO_SANITY gets enabled with HIBERNATION.
>
> I'm curious what issues you've caught with this patch.
This patch is used to catch corruptions during/soon after boot due to DDR instability. The free list can be
traversed in a dump and corrupted physical addresses can be analyzed for patterns. But I think, this
would also be useful in catching software induced corruptions which could be missed now because the page
has to undergo a cycle of alloc-free-alloc for any corruption to be detected. And on systems with more
RAM, it can take time for every page to complete this cycle.

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
