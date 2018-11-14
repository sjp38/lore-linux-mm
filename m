Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2DC96B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:23:11 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id h135-v6so8806600oic.2
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:23:11 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y206-v6si9668741oiy.213.2018.11.14.00.23.10
        for <linux-mm@kvack.org>;
        Wed, 14 Nov 2018 00:23:10 -0800 (PST)
Subject: Re: [RFC][PATCH v1 11/11] mm: hwpoison: introduce
 clear_hwpoison_free_buddy_page()
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-12-git-send-email-n-horiguchi@ah.jp.nec.com>
 <d37c1be2-2069-a147-9ba8-4749cd386d0b@arm.com>
 <20181113001907.GD5945@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b5fb36d0-487c-cf6d-3aa0-a5b43c51b2d6@arm.com>
Date: Wed, 14 Nov 2018 13:53:04 +0530
MIME-Version: 1.0
In-Reply-To: <20181113001907.GD5945@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>



On 11/13/2018 05:49 AM, Naoya Horiguchi wrote:
> On Fri, Nov 09, 2018 at 05:03:06PM +0530, Anshuman Khandual wrote:
>>
>>
>> On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
>>> The new function is a reverse operation of set_hwpoison_free_buddy_page()
>>> to adjust unpoison_memory() to the new semantics.
>>>
>>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> snip
>>
>>> +
>>> +/*
>>> + * Reverse operation of set_hwpoison_free_buddy_page(), which is expected
>>> + * to work only on error pages isolated from buddy allocator.
>>> + */
>>> +bool clear_hwpoison_free_buddy_page(struct page *page)
>>> +{
>>> +	struct zone *zone = page_zone(page);
>>> +	bool unpoisoned = false;
>>> +
>>> +	spin_lock(&zone->lock);
>>> +	if (TestClearPageHWPoison(page)) {
>>> +		unsigned long pfn = page_to_pfn(page);
>>> +		int migratetype = get_pfnblock_migratetype(page, pfn);
>>> +
>>> +		__free_one_page(page, pfn, zone, 0, migratetype);
>>> +		unpoisoned = true;
>>> +	}
>>> +	spin_unlock(&zone->lock);
>>> +	return unpoisoned;
>>> +}
>>>  #endif
>>>
>>
>> Though there are multiple page state checks in unpoison_memory() leading
>> upto clearing HWPoison flag, the page must not be in buddy already if
>> __free_one_page() would be called on it.
> 
> Yes, you're right.
> clear_hwpoison_free_buddy_page() is intended to cancel the isolation by
> set_hwpoison_free_buddy_page() which removes the target page from buddy allocator,
> so the page clear_hwpoison_free_buddy_page() tries to handle is not a buddy page
> actually (not linked to any freelist).

Got it. Thanks for the explanation.
