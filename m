Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4130D6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:29:26 -0400 (EDT)
Received: by obbhe7 with SMTP id he7so22398716obb.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:29:26 -0700 (PDT)
Received: from BLU004-OMC1S29.hotmail.com (blu004-omc1s29.hotmail.com. [65.55.116.40])
        by mx.google.com with ESMTPS id 15si1628756oib.131.2015.08.10.01.29.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Aug 2015 01:29:25 -0700 (PDT)
Message-ID: <BLU436-SMTP6090BE1965823BCE9FBC4580700@phx.gbl>
Subject: Re: [PATCH 1/2] mm/hwpoison: fix fail to split THP w/ refcount held
References: <BLU436-SMTP188C7B16D46EEDEB4A9B9F980700@phx.gbl>
 <20150810081019.GA21282@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Mon, 10 Aug 2015 16:29:18 +0800
MIME-Version: 1.0
In-Reply-To: <20150810081019.GA21282@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Naoya,

On 8/10/15 4:10 PM, Naoya Horiguchi wrote:
> On Mon, Aug 10, 2015 at 02:32:30PM +0800, Wanpeng Li wrote:
>> THP pages will get a refcount in madvise_hwpoison() w/ MF_COUNT_INCREASED
>> flag, however, the refcount is still held when fail to split THP pages.
>>
>> Fix it by reducing the refcount of THP pages when fail to split THP.
>>
>> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
> It seems that the same conditional put_page() would be added to
> "soft offline: %#lx page already poisoned" branch too, right?

PageHWPoison() is just called before the soft_offline_page() in 
madvise_hwpoion(). I think the PageHWPosion()
check in soft_offline_page() makes more sense for the other 
soft_offline_page() callsites which don't have the
refcount held.

Regards,
Wanpeng Li

>
>> ---
>>   mm/memory-failure.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 8077b1c..56b8a71 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1710,6 +1710,8 @@ int soft_offline_page(struct page *page, int flags)
>>   		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
>>   			pr_info("soft offline: %#lx: failed to split THP\n",
>>   				pfn);
>> +			if (flags & MF_COUNT_INCREASED)
>> +				put_page(page);
>>   			return -EBUSY;
>>   		}
>>   	}
>> -- 
>> 1.7.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
