Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E97E6B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 18:35:38 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id d206so5492830vka.22
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 15:35:38 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t19si287485vkb.65.2017.12.21.15.35.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 15:35:36 -0800 (PST)
Subject: Re: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration
 improvements
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171215093309.GU16951@dhcp22.suse.cz>
 <95ba8db3-f8aa-528a-db4b-80f9d2ba9d2b@ah.jp.nec.com>
 <20171220095328.GG4831@dhcp22.suse.cz>
 <233096d8-ecbc-353a-023a-4f6fa72ebb2f@oracle.com>
 <20171221072802.GY4831@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <659e21c7-ebed-8b64-053a-f01a31ef6e25@oracle.com>
Date: Thu, 21 Dec 2017 15:35:28 -0800
MIME-Version: 1.0
In-Reply-To: <20171221072802.GY4831@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 12/20/2017 11:28 PM, Michal Hocko wrote:
> On Wed 20-12-17 14:43:03, Mike Kravetz wrote:
>> On 12/20/2017 01:53 AM, Michal Hocko wrote:
>>> On Wed 20-12-17 05:33:36, Naoya Horiguchi wrote:
>>>> I have one comment on the code path from mbind(2).
>>>> The callback passed to migrate_pages() in do_mbind() (i.e. new_page())
>>>> calls alloc_huge_page_noerr() which currently doesn't call SetPageHugeTemporary(),
>>>> so hugetlb migration fails when h->surplus_huge_page >= h->nr_overcommit_huge_pages.
>>>
>>> Yes, I am aware of that. I should have been more explicit in the
>>> changelog. Sorry about that and thanks for pointing it out explicitly.
>>> To be honest I wasn't really sure what to do about this. The code path
>>> is really complex and it made my head spin. I fail to see why we have to
>>> call alloc_huge_page and mess with reservations at all.
>>
>> Oops!  I missed that in my review.
>>
>> Since alloc_huge_page was called with avoid_reserve == 1, it should not
>> do anything with reserve counts.  One potential issue with the existing
>> code is cgroup accounting done by alloc_huge_page.  When the new target
>> page is allocated, it is charged against the cgroup even though the original
>> page is still accounted for.  If we are 'at the cgroup limit', the migration
>> may fail because of this.
> 
> Yeah, the existing code seems just broken. I strongly suspect that the
> allocation API for hugetlb was so complicated that this was just a
> natural result of a confusion with some follow up changes on top.
> 
>> I like your new code below as it explicitly takes reserve and cgroup
>> accounting out of the picture for migration.  Let me think about it
>> for another day before providing a Reviewed-by.
> 
> Thanks a lot!

You can add,

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

I had some concerns about transferring huge page state during migration
not specific to this patch, so I did a bunch of testing.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
