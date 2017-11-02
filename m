Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5912A6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 10:16:58 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id q80so2905805vkf.1
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 07:16:58 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b19si902249uak.241.2017.11.02.07.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 07:16:57 -0700 (PDT)
Subject: Re: [PATCH v1 1/1] mm: buddy page accessed before initialized
References: <20171031155002.21691-1-pasha.tatashin@oracle.com>
 <20171031155002.21691-2-pasha.tatashin@oracle.com>
 <20171102133235.2vfmmut6w4of2y3j@dhcp22.suse.cz>
 <a9b637b0-2ff0-80e8-76a7-801c5c0820a8@oracle.com>
 <20171102135423.voxnzk2qkvfgu5l3@dhcp22.suse.cz>
 <94ab73c0-cd18-f58f-eebe-d585fde319e4@oracle.com>
 <20171102140830.z5uqmrurb6ohfvlj@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <813ed7e3-9347-a1f2-1629-464d920f877d@oracle.com>
Date: Thu, 2 Nov 2017 10:16:49 -0400
MIME-Version: 1.0
In-Reply-To: <20171102140830.z5uqmrurb6ohfvlj@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>>>> Now, that memory is not zeroed, page_is_buddy() can return true after kexec
>>>> when memory is dirty (unfortunately memset(1) with CONFIG_VM_DEBUG does not
>>>> catch this case). And proceed further to incorrectly remove buddy from the
>>>> list.
>>>
>>> OK, I thought this was a regression from one of the recent patches. So
>>> the problem is not new. Why don't we see the same problem during the
>>> standard boot?
>>
>> Because, I believe, BIOS is zeroing all the memory for us.
> 
> I thought you were runnning with the debugging which poisons all the
> allocated memory...

Yes, but as I said, unfortunately memset(1) with CONFIG_VM_DEBUG does 
not catch this case. So, when CONFIG_VM_DEBUG is enabled kexec reboots 
without issues.

>   
>>>> This is why we must initialize the computed buddy page beforehand.
>>>
>>> Ble, this is really ugly. I will think about it more.
>>>
>>
>> Another approach that I considered is to split loop inside
>> deferred_init_range() into two loops: one where we initialize pages by
>> calling __init_single_page(), another where we free them to buddy allocator
>> by calling deferred_free_range().
> 
> Yes, that would make much more sense to me.
> 

Ok, so should I submit a new patch with two loops? (The logic within 
loops is going to be the same:

if (!pfn_valid_within(pfn)) {
} else if (!(pfn & nr_pgmask) && !pfn_valid(pfn)) {
} else if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
} else if (page && (pfn & nr_pgmask)) {

This fix was already added into mm-tree as
mm-deferred_init_memmap-improvements-fix-2.patch

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
