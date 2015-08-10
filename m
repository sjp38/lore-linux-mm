Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9826B0255
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 05:25:20 -0400 (EDT)
Received: by obbop1 with SMTP id op1so119729550obb.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:25:20 -0700 (PDT)
Received: from BLU004-OMC1S24.hotmail.com (blu004-omc1s24.hotmail.com. [65.55.116.35])
        by mx.google.com with ESMTPS id k7si13934810oes.103.2015.08.10.02.25.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Aug 2015 02:25:20 -0700 (PDT)
Message-ID: <BLU436-SMTP511EE4B59AC79B5A43E8E880700@phx.gbl>
Subject: Re: [PATCH 2/2] mm/hwpoison: fix refcount of THP head page in
 no-injection case
References: <1439188351-24292-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP1881EF02196F4DFB4A0882B80700@phx.gbl>
 <20150810083529.GB21282@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP3886BA6C827CC74CCF19EB80700@phx.gbl>
 <BLU436-SMTP2382AA11A7E96E3F330B50F80700@phx.gbl>
 <20150810092020.GB28025@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Mon, 10 Aug 2015 17:24:36 +0800
MIME-Version: 1.0
In-Reply-To: <20150810092020.GB28025@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 8/10/15 5:20 PM, Naoya Horiguchi wrote:
> On Mon, Aug 10, 2015 at 05:06:25PM +0800, Wanpeng Li wrote:
> ...
>>>>> diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
>>>>> index 5015679..c343a45 100644
>>>>> --- a/mm/hwpoison-inject.c
>>>>> +++ b/mm/hwpoison-inject.c
>>>>> @@ -56,6 +56,8 @@ inject:
>>>>>      return memory_failure(pfn, 18, MF_COUNT_INCREASED);
>>>>>  put_out:
>>>>>      put_page(p);
>>>>> +    if (p != hpage)
>>>>> +        put_page(hpage);
>>>> Yes, we need this when we inject to a thp tail page and "goto put_out"
>>>> is
>>>> called. But it seems that this code can be called also when injecting
>>>> error
>>>> to a hugetlb tail page and hwpoison_filter() returns non-zero, which is
>>>> not
>>>> expected. Unfortunately simply doing like below
>>>>
>>>> +    if (!PageHuge(p) && p != hpage)
>>>> +        put_page(hpage);
>>>>
>>>> doesn't work, because exisiting put_page(p) can release refcount of
>>>> hugetlb
>>>> tail page, while get_hwpoison_page() takes refcount of hugetlb head
>>>> page.
>>>>
>>>> So I feel that we need put_hwpoison_page() to properly release the
>>>> refcount
>>>> taken by memory error handlers.
>>> Good point. I think I will continue to do it and will post it out soon. :)
>> How about something like this:
>>
>> +void put_hwpoison_page(struct page *page)
>> +{
>> +       struct page *head = compound_head(page);
>> +
>> +       if (PageHuge(head))
>> +               goto put_out;
>> +
>> +       if (PageTransHuge(head))
>> +               if (page != head)
>> +                       put_page(head);
>> +
>> +put_out:
>> +       put_page(page);
>> +       return;
>> +}
>> +
> Looks good.
>
>> Any comments are welcome, I can update the patch by myself. :)
> Most of callsites of put_page() in memory_failure(), soft_offline_page(),
> and unpoison_page() can be replaced with put_hwpoison_page().

Cool, thanks for your pointing out. I will do it soon. :)

Regards,
Wanpeng Li

>
> Thanks,
> Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
