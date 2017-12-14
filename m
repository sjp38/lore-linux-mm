Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 07F096B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 15:58:05 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id o29so5418202qto.12
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:58:05 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 202si308503qkl.26.2017.12.14.12.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 12:58:04 -0800 (PST)
Subject: Re: [RFC PATCH 3/5] mm, hugetlb: do not rely on overcommit limit
 during migration
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171204140117.7191-4-mhocko@kernel.org>
 <ec386202-9bee-e230-1b37-bc05c4cd8f49@oracle.com>
 <20171214074053.GC16951@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <1ce15f58-4b39-3e03-d0e3-4cd30bcc69b9@oracle.com>
Date: Thu, 14 Dec 2017 12:57:54 -0800
MIME-Version: 1.0
In-Reply-To: <20171214074053.GC16951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 12/13/2017 11:40 PM, Michal Hocko wrote:
> On Wed 13-12-17 15:35:33, Mike Kravetz wrote:
>> On 12/04/2017 06:01 AM, Michal Hocko wrote:
> [...]
>>> Before migration
>>> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
>>> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:1
>>> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
>>> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
>>> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:0
>>> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0
>>>
>>> After
>>>
>>> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
>>> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:0
>>> /sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
>>> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
>>> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:1
>>> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0
>>>
>>> with the previous implementation, both nodes would have nr_hugepages:1
>>> until the page is freed.
>>
>> With the previous implementation, the migration would have failed unless
>> nr_overcommit_hugepages was explicitly set.  Correct?
> 
> yes
> 
> [...]
> 
>> In the previous version of this patch, I asked about handling of 'free' huge
>> pages.  I did a little digging and IIUC, we do not attempt migration of
>> free huge pages.  The routine isolate_huge_page() has this check:
>>
>>         if (!page_huge_active(page) || !get_page_unless_zero(page)) {
>>                 ret = false;
>>                 goto unlock;
>>         }
>>
>> I believe one of your motivations for this effort was memory offlining.
>> So, this implies that a memory area can not be offlined if it contains
>> a free (not in use) huge page?
> 
> do_migrate_range will ignore this free huge page and then we will free
> it up in dissolve_free_huge_pages
> 
>> Just FYI and may be something we want to address later.
> 
> Maybe yes. The free pool might be reserved which would make
> dissolve_free_huge_pages to fail. Maybe we can be more clever and
> allocate a new huge page in that case.

Don't think we need to try and do anything more clever right now.  I was
just a little confused about the hot plug code.  Thanks for the explanation.

-- 
Mike Kravetz

>  
>> My other issues were addressed.
>>
>> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Thanks!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
