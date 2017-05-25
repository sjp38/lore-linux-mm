Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91A246B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 21:07:08 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j66so231686586oib.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 18:07:08 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id 94si3203448otx.307.2017.05.24.18.07.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 18:07:07 -0700 (PDT)
Subject: Re: [Question] Mlocked count will not be decreased
References: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
 <85591559-2a99-f46b-7a5a-bc7affb53285@huawei.com>
 <93f1b063-6288-d109-117d-d3c1cf152a8e@suse.cz> <5925709F.1030105@huawei.com>
 <d354b321-0d11-4308-0b0e-aacef5a5e34b@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <73292b91-1290-6a30-902c-840696cf9ab5@huawei.com>
Date: Thu, 25 May 2017 09:00:33 +0800
MIME-Version: 1.0
In-Reply-To: <d354b321-0d11-4308-0b0e-aacef5a5e34b@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhongjiang <zhongjiang@huawei.com>

Hi Vlastimil,

Thanks for comment.
On 2017/5/24 19:52, Vlastimil Babka wrote:
> On 05/24/2017 01:38 PM, Xishi Qiu wrote:
>>>
>>> Race condition with what? Who else would isolate our pages?
>>>
>>
>> Hi Vlastimil,
>>
>> I find the root cause, if the page was not cached on the current cpu,
>> lru_add_drain() will not push it to LRU. So we should handle fail
>> case in mlock_vma_page().
> 
> Yeah that would explain it.
> 
>> follow_page_pte()
>> 		...
>> 		if (page->mapping && trylock_page(page)) {
>> 			lru_add_drain();  /* push cached pages to LRU */
>> 			/*
>> 			 * Because we lock page here, and migration is
>> 			 * blocked by the pte's page reference, and we
>> 			 * know the page is still mapped, we don't even
>> 			 * need to check for file-cache page truncation.
>> 			 */
>> 			mlock_vma_page(page);
>> 			unlock_page(page);
>> 		}
>> 		...
>>
>> I think we should add yisheng's patch, also we should add the following change.
>> I think it is better than use lru_add_drain_all().
> 
> I agree about yisheng's fix (but v2 didn't address my comments). I don't
> think we should add the hunk below, as that deviates from the rest of
> the design.
> 
Sorry, I have sent the patch before your comment. Anyway I will send another version
as your suggestion.

Thanks
Yisheng Xie



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
