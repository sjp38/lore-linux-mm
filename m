Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 160BD6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 10:01:09 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 10so3945844qty.10
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 07:01:09 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g7si3143058qkf.184.2017.11.02.07.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 07:01:08 -0700 (PDT)
Subject: Re: [PATCH v1 1/1] mm: buddy page accessed before initialized
References: <20171031155002.21691-1-pasha.tatashin@oracle.com>
 <20171031155002.21691-2-pasha.tatashin@oracle.com>
 <20171102133235.2vfmmut6w4of2y3j@dhcp22.suse.cz>
 <a9b637b0-2ff0-80e8-76a7-801c5c0820a8@oracle.com>
 <20171102135423.voxnzk2qkvfgu5l3@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <94ab73c0-cd18-f58f-eebe-d585fde319e4@oracle.com>
Date: Thu, 2 Nov 2017 10:00:59 -0400
MIME-Version: 1.0
In-Reply-To: <20171102135423.voxnzk2qkvfgu5l3@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 11/02/2017 09:54 AM, Michal Hocko wrote:
> On Thu 02-11-17 09:39:58, Pavel Tatashin wrote:
> [...]
>> Hi Michal,
>>
>> Previously as before my project? That is because memory for all struct pages
>> was always zeroed in memblock, and in __free_one_page() page_is_buddy() was
>> always returning false, thus we never tried to incorrectly remove it from
>> the list:
>>
>> 837			list_del(&buddy->lru);
>>
>> Now, that memory is not zeroed, page_is_buddy() can return true after kexec
>> when memory is dirty (unfortunately memset(1) with CONFIG_VM_DEBUG does not
>> catch this case). And proceed further to incorrectly remove buddy from the
>> list.
> 
> OK, I thought this was a regression from one of the recent patches. So
> the problem is not new. Why don't we see the same problem during the
> standard boot?

Because, I believe, BIOS is zeroing all the memory for us.

> 
>> This is why we must initialize the computed buddy page beforehand.
> 
> Ble, this is really ugly. I will think about it more.
> 

Another approach that I considered is to split loop inside 
deferred_init_range() into two loops: one where we initialize pages by 
calling __init_single_page(), another where we free them to buddy 
allocator by calling deferred_free_range().

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
