Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 93C476B0254
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:55:12 -0400 (EDT)
Received: by oio137 with SMTP id 137so81707573oio.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:55:12 -0700 (PDT)
Received: from BLU004-OMC1S38.hotmail.com (blu004-omc1s38.hotmail.com. [65.55.116.49])
        by mx.google.com with ESMTPS id b188si992827oih.121.2015.08.10.01.55.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Aug 2015 01:55:11 -0700 (PDT)
Message-ID: <BLU436-SMTP3886BA6C827CC74CCF19EB80700@phx.gbl>
Subject: Re: [PATCH 2/2] mm/hwpoison: fix refcount of THP head page in
 no-injection case
References: <1439188351-24292-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP1881EF02196F4DFB4A0882B80700@phx.gbl>
 <20150810083529.GB21282@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Mon, 10 Aug 2015 16:54:39 +0800
MIME-Version: 1.0
In-Reply-To: <20150810083529.GB21282@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 8/10/15 4:35 PM, Naoya Horiguchi wrote:
> On Mon, Aug 10, 2015 at 02:32:31PM +0800, Wanpeng Li wrote:
>> Hwpoison injection takes a refcount of target page and another refcount
>> of head page of THP if the target page is the tail page of a THP. However,
>> current code doesn't release the refcount of head page if the THP is not
>> supported to be injected wrt hwpoison filter.
>>
>> Fix it by reducing the refcount of head page if the target page is the tail
>> page of a THP and it is not supported to be injected.
>>
>> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
>> ---
>>   mm/hwpoison-inject.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
>> index 5015679..c343a45 100644
>> --- a/mm/hwpoison-inject.c
>> +++ b/mm/hwpoison-inject.c
>> @@ -56,6 +56,8 @@ inject:
>>   	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
>>   put_out:
>>   	put_page(p);
>> +	if (p != hpage)
>> +		put_page(hpage);
> Yes, we need this when we inject to a thp tail page and "goto put_out" is
> called. But it seems that this code can be called also when injecting error
> to a hugetlb tail page and hwpoison_filter() returns non-zero, which is not
> expected. Unfortunately simply doing like below
>
> +	if (!PageHuge(p) && p != hpage)
> +		put_page(hpage);
>
> doesn't work, because exisiting put_page(p) can release refcount of hugetlb
> tail page, while get_hwpoison_page() takes refcount of hugetlb head page.
>
> So I feel that we need put_hwpoison_page() to properly release the refcount
> taken by memory error handlers.

Good point. I think I will continue to do it and will post it out soon. :)

Regards,
Wanpeng Li

> I'll post some patch(es) to address this problem this week.
>
> Thanks,
> Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
