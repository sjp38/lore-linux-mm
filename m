Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id E56AC6B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 22:30:28 -0400 (EDT)
Received: by igui7 with SMTP id i7so53166086igu.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 19:30:28 -0700 (PDT)
Received: from BLU004-OMC1S31.hotmail.com (blu004-omc1s31.hotmail.com. [65.55.116.42])
        by mx.google.com with ESMTPS id h5si2924620igt.89.2015.08.11.19.30.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Aug 2015 19:30:28 -0700 (PDT)
Message-ID: <BLU436-SMTP2364526E166A607E08BB09807E0@phx.gbl>
Subject: Re: [PATCH v2 3/5] mm/hwpoison: introduce put_hwpoison_page to put
 refcount for memory error handling
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP127AFDD347F96AC6BDED54C80700@phx.gbl>
 <20150811162449.77212ec2a80258f5aff8a224@linux-foundation.org>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Wed, 12 Aug 2015 10:30:21 +0800
MIME-Version: 1.0
In-Reply-To: <20150811162449.77212ec2a80258f5aff8a224@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/12/15 7:24 AM, Andrew Morton wrote:
> On Mon, 10 Aug 2015 19:28:21 +0800 Wanpeng Li <wanpeng.li@hotmail.com> wrote:
>
>> Introduce put_hwpoison_page to put refcount for memory
>> error handling.
>>
>> ...
>>
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -922,6 +922,27 @@ int get_hwpoison_page(struct page *page)
>>   }
>>   EXPORT_SYMBOL_GPL(get_hwpoison_page);
>>   
>> +/**
>> + * put_hwpoison_page() - Put refcount for memory error handling:
>> + * @page:	raw error page (hit by memory error)
>> + */
>> +void put_hwpoison_page(struct page *page)
>> +{
>> +	struct page *head = compound_head(page);
>> +
>> +	if (PageHuge(head)) {
>> +		put_page(head);
>> +		return;
>> +	}
>> +
>> +	if (PageTransHuge(head))
>> +		if (page != head)
>> +			put_page(head);
>> +
>> +	put_page(page);
>> +}
>> +EXPORT_SYMBOL_GPL(put_hwpoison_page);
> I don't believe the export is needed?

ERROR: "put_hwpoison_page" [mm/hwpoison-inject.ko] undefined!
So I'm afraid it should be needed.

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
