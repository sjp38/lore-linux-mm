Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 039066B02A0
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:30:10 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id p44so13605506qtj.17
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 11:30:09 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u7si7019129qka.307.2017.11.22.11.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 11:30:08 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <08db0958-220a-f31e-0ddb-273d7126150e@virtuozzo.com>
From: Wengang Wang <wen.gang.wang@oracle.com>
Message-ID: <9659392e-2b59-901e-a3bc-570946729b12@oracle.com>
Date: Wed, 22 Nov 2017 11:29:11 -0800
MIME-Version: 1.0
In-Reply-To: <08db0958-220a-f31e-0ddb-273d7126150e@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org
Cc: glider@google.com, dvyukov@google.com



On 2017/11/22 4:04, Andrey Ryabinin wrote:
> On 11/18/2017 01:30 AM, Wengang Wang wrote:
>> Kasan advanced check, I'm going to add this feature.
>> Currently Kasan provide the detection of use-after-free and out-of-bounds
>> problems. It is not able to find the overwrite-on-allocated-memory issue.
>> We sometimes hit this kind of issue: We have a messed up structure
>> (usually dynamially allocated), some of the fields in the structure were
>> overwritten with unreasaonable values. And kernel may panic due to those
>> overeritten values. We know those fields were overwritten somehow, but we
>> have no easy way to find out which path did the overwritten. The advanced
>> check wants to help in this scenario.
>>
>> The idea is to define the memory owner. When write accesses come from
>> non-owner, error should be reported. Normally the write accesses on a given
>> structure happen in only several or a dozen of functions if the structure
>> is not that complicated. We call those functions "allowed functions".
>> The work of defining the owner and binding memory to owner is expected to
>> be done by the memory consumer. In the above case, memory consume register
>> the owner as the functions which have write accesses to the structure then
>> bind all the structures to the owner. Then kasan will do the "owner check"
>> after the basic checks.
>>
>> As implementation, kasan provides a API to it's user to register their
>> allowed functions. The API returns a token to users.  At run time, users
>> bind the memory ranges they are interested in to the check they registered.
>> Kasan then checks the bound memory ranges with the allowed functions.
>>
> NAK. We don't add APIs with no users in the kernel.
> If nothing in the kernel uses this API than there is no way to tell if this works or not.
In production kernel, we don't want unnecessary APIs without users in 
the kernel because that
would consume binary size (a pure space waste) and leave "dead" code.
KASAN code is a bit different from other kernel components, its self is 
debugging purpose only.
When KASAN is enabled, the APIs would have potential users and the code 
is not "dead" code.
The size increasing in binary would be acceptable since the kernel with 
KASAN enabled only has
a short time life -- only used to find the root cause, when root caused 
is found, it will be no
longer used;A  Also the KASAN enabled kernel is used by limited user 
where they have a particular
issue. I say "potential users" because this functionality its self is 
dynamically used or to say a
one-shot use. The functionality is helpful.

I think even KASAN its self we don't know if it works or not when it is 
not enabled.
-- Before I tried it, I am curious if this can work well; After testing 
it, I know it works.
If we don't give users the chance, they will never know there is such a 
functionality and will never
get benefit from it.


> Besides, I'm bit skeptical about usefulness of this feature. Those kinds of issues that
> advanced check is supposed to catch, is almost always is just some sort of longstanding
> use after free, which eventually should be caught by kasan.
Yes, if luckily, the issue is possible to be catched by UAF check.
Well considering busy production systems, the memory is very likely to 
be reallocated rather than
staying in free state for very long time.A  That is the 
overwritten-to-allocated-memory is more
likely to happen than UAF does I think.A  When 
overwritten-to-allocated-memory happened,
UAF check has no chance to detect the problem.

KASAN is helpful to detect problematic memory usage, so does this patch set!
I really hope this can be included and developers can get benefit from it.

Thanks,
Wengang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
