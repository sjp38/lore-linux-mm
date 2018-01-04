Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED74280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 06:38:25 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id g33so982406plb.13
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 03:38:25 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id p91si2174213plb.255.2018.01.04.03.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 03:38:24 -0800 (PST)
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
 <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
 <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
 <7dd95219-f0be-b30a-0a43-2aadcc61899c@alibaba-inc.com>
 <20180104113451.j7dwal6mxbelt4p4@techsingularity.net>
From: "=?UTF-8?B?5aS35YiZKENhc3Bhcik=?=" <jinli.zjl@alibaba-inc.com>
Message-ID: <95536212-b626-2a3a-dfe4-87e3f9fc2f22@alibaba-inc.com>
Date: Thu, 04 Jan 2018 19:38:08 +0800
MIME-Version: 1.0
In-Reply-To: <20180104113451.j7dwal6mxbelt4p4@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?5p2o5YuHKOaZuuW9uyk=?= <zhiche.yy@alibaba-inc.com>, =?UTF-8?B?5Y2B5YiA?= <shidao.ytt@alibaba-inc.com>



On 2018/1/4 19:34, Mel Gorman wrote:
> On Thu, Jan 04, 2018 at 02:13:43PM +0800, ??????(Caspar) wrote:
>>
>>
>> On 2018/1/3 18:48, Mel Gorman wrote:
>>> On Wed, Jan 03, 2018 at 02:53:43PM +0800, ??????(Caspar) wrote:
>>>>
>>>>
>>>>> ?? 2017??12??23????12:16?????? <shidao.ytt@alibaba-inc.com> ??????
>>>>>
>>>>> From: "shidao.ytt" <shidao.ytt@alibaba-inc.com>
>>>>>
>>>>> in commit 441c228f817f7 ("mm: fadvise: document the
>>>>> fadvise(FADV_DONTNEED) behaviour for partial pages") Mel Gorman
>>>>> explained why partial pages should be preserved instead of discarded
>>>>> when using fadvise(FADV_DONTNEED), however the actual codes to calcuate
>>>>> end_index was unexpectedly wrong, the code behavior didn't match to the
>>>>> statement in comments; Luckily in another commit 18aba41cbf
>>>>> ("mm/fadvise.c: do not discard partial pages with POSIX_FADV_DONTNEED")
>>>>> Oleg Drokin fixed this behavior
>>>>>
>>>>> Here I come up with a new idea that actually we can still discard the
>>>>> last parital page iff the page-unaligned endbyte is also the end of
>>>>> file, since no one else will use the rest of the page and it should be
>>>>> safe enough to discard.
>>>>
>>>> +akpm...
>>>>
>>>> Hi Mel, Andrew:
>>>>
>>>> Would you please take a look at this patch, to see if this proposal
>>>> is reasonable enough, thanks in advance!
>>>>
>>>
>>> I'm backlogged after being out for the Christmas. Superficially the patch
>>> looks ok but I wondered how often it happened in practice as we already
>>> would discard files smaller than a page on DONTNEED. It also requires
>>
>> Actually, we would *not*. Let's look into the codes.
>>
> 
> You're right of course. I suggest updating the changelog with what you
> found and the test case. I think it's reasonable to special case the
> discarding of partial pages if it's the end of a file with the potential
> addendum of checking if the endbyte is past the end of the file. The man
> page should also be updated.

Sure, will do and send out v2.

Thanks,
Caspar
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
