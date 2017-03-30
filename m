Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6716B03AC
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 08:45:23 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u202so44103074pgb.9
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 05:45:23 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id n75si2086293pfi.266.2017.03.30.05.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 05:45:21 -0700 (PDT)
Subject: Re: [PATCH] mm: enable page poisoning early at boot
References: <1490358246-11001-1-git-send-email-vinmenon@codeaurora.org>
 <d9e8b184-b2a9-1174-4a6b-17ae1d2d6444@redhat.com>
 <765ba1d2-d273-e4b1-7ec2-523fe2784ae2@redhat.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <57ce5d1f-626e-8a0c-a877-1a894c69450a@codeaurora.org>
Date: Thu, 30 Mar 2017 18:15:16 +0530
MIME-Version: 1.0
In-Reply-To: <765ba1d2-d273-e4b1-7ec2-523fe2784ae2@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, iamjoonsoo.kim@lge.com, mhocko@suse.com, akpm@linux-foundation.org
Cc: shashim@codeaurora.org, linux-mm@kvack.org


On 3/29/2017 10:44 PM, Laura Abbott wrote:
> On 03/29/2017 10:04 AM, Laura Abbott wrote:
>> On 03/24/2017 05:24 AM, Vinayak Menon wrote:
>>> On SPARSEMEM systems page poisoning is enabled after buddy is up, because
>>> of the dependency on page extension init. This causes the pages released
>>> by free_all_bootmem not to be poisoned. This either delays or misses
>>> the identification of some issues because the pages have to undergo another
>>> cycle of alloc-free-alloc for any corruption to be detected.
>>> Enable page poisoning early by getting rid of the PAGE_EXT_DEBUG_POISON
>>> flag. Since all the free pages will now be poisoned, the flag need not be
>>> verified before checking the poison during an alloc.
>>>
>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>> ---
>>>
>>> An RFC was sent earlier (http://www.spinics.net/lists/linux-mm/msg123142.html)
>>> Not sure if there exists a code path that can free pages to buddy skipping
>>> kernel_poison_pages, making the flag PAGE_EXT_DEBUG_POISON a necessity. But
>>> the tests have not shown any issues. As per Laura's suggestion, the patch was
>>> tested with HIBERNATION enabled and no issues were seen.
>>>
>> I gave this a spin on some of my machines and it appears to be working
>> okay. 

Thanks Laura.

>> I wish we had a bit more context about why it was necessary to track
>> the poison in the page itself.
>>
>> This change means that we shouldn't need the "select PAGE_EXTENSION"
>> anymore so that can be dropped. If you do that, you can add
>>
>> Acked-by: Laura Abbott <labbott@redhat.com>
>>
> Actually never mind on dropping the select. It's still needed for
> the guard page as well. Longer term it might be worth separating
> that out as well.

Realized that there is now some redundant CONFIG_PAGE_POISONING checks in page_ext.c. So along
with that I have removed the "select PAGE_EXTENSION"from CONFIG_PAGE_POISONING. Could you
please take a look at v2 ?

>
> You can still take my Ack.
>
> Thanks,
> Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
