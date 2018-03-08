Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5ED6B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 01:51:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v3so2522550pfm.21
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 22:51:27 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id y7-v6si5554653plk.353.2018.03.07.22.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 22:51:26 -0800 (PST)
Subject: Re: [PATCH] slub: Fix misleading 'age' in verbose slub prints
References: <1520423266-28830-1-git-send-email-cpandya@codeaurora.org>
 <alpine.DEB.2.20.1803071212150.6373@nuc-kabylake>
 <20180307182212.GA23411@bombadil.infradead.org>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <da1be252-403f-6725-a1b8-223222f7f946@codeaurora.org>
Date: Thu, 8 Mar 2018 12:21:19 +0530
MIME-Version: 1.0
In-Reply-To: <20180307182212.GA23411@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/7/2018 11:52 PM, Matthew Wilcox wrote:
> On Wed, Mar 07, 2018 at 12:13:56PM -0600, Christopher Lameter wrote:
>> On Wed, 7 Mar 2018, Chintan Pandya wrote:
>>> In this case, object got freed later but 'age' shows
>>> otherwise. This could be because, while printing
>>> this info, we print allocation traces first and
>>> free traces thereafter. In between, if we get schedule
>>> out, (jiffies - t->when) could become meaningless.
>>
>> Ok then get the jiffies earlier?
>>
>>> So, simply print when the object was allocated/freed.
>>
>> The tick value may not related to anything in the logs that is why the
>> "age" is there. How do I know how long ago the allocation was if I look at
>> the log and only see long and large number of ticks since bootup?
> 
> I missed that the first read-through too.  The trick is that there are two printks:
> 
> [ 6044.170804] INFO: Allocated in binder_transaction+0x4b0/0x2448 age=731 cpu=3 pid=5314
> ...
> [ 6044.216696] INFO: Freed in binder_free_transaction+0x2c/0x58 age=735 cpu=6 pid=2079
> 
> If you print the raw value, then you can do the subtraction yourself;
> if you've subtracted it from jiffies each time, you've at least introduced
> jitter, and possibly enough jitter to confuse and mislead.
> 
This is exactly what I was thinking. But looking up 'age' is easy 
compared to 'when' and this seems required as from Christopher's
reply. So, will raise new patch cleaning commit message a bit.

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
