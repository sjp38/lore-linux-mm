Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 297B16B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:18:35 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id o29so11530575qto.12
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 11:18:35 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s123si3683618qkf.350.2017.11.21.11.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 11:18:33 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
 <CACT4Y+Zi9bNdnei_kXWu_3BHOobbhOgRKJ6Vk9QGs3c6NCdqXw@mail.gmail.com>
 <37111d5b-7042-dfff-9ac7-8733b77930e8@oracle.com>
 <CACT4Y+ZEvLJbM_b6nWqLPvVJgWjAp-eYsmbO5vT2qQ3_zH-2+A@mail.gmail.com>
 <de1e0f95-4daa-0b00-a7bf-0ce2e9a3371b@oracle.com>
 <CACT4Y+aOOkm6aqPKaNmi-aBU4-F8SQTZe=-UkAQry-eQWxsS8w@mail.gmail.com>
From: Wengang Wang <wen.gang.wang@oracle.com>
Message-ID: <71bad1f0-2526-e873-8507-bd1cbceb4e93@oracle.com>
Date: Tue, 21 Nov 2017 11:17:36 -0800
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aOOkm6aqPKaNmi-aBU4-F8SQTZe=-UkAQry-eQWxsS8w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>



On 2017/11/21 1:54, Dmitry Vyukov wrote:
> On Mon, Nov 20, 2017 at 9:29 PM, Wengang <wen.gang.wang@oracle.com> wrote:
>>
>> On 11/20/2017 12:20 PM, Dmitry Vyukov wrote:
>>> On Mon, Nov 20, 2017 at 9:05 PM, Wengang <wen.gang.wang@oracle.com> wrote:
>>>>
>>>> On 11/20/2017 12:41 AM, Dmitry Vyukov wrote:
>>>>>
>>>>>> The reason I didn't submit the vchecker to mainline is that I didn't
>>>>>> find
>>>>>> the case that this tool is useful in real life. Most of the system
>>>>>> broken
>>>>>> case
>>>>>> can be debugged by other ways. Do you see the real case that this tool
>>>>>> is
>>>>>> helpful?
>>>>> Hi,
>>>>>
>>>>> Yes, this is the main question here.
>>>>> How is it going to be used in real life? How widely?
>>>>>
>>>> I think the owner check can be enabled in the cases where KASAN is used.
>>>> --
>>>> That is that we found there is memory issue, but don't know how it
>>>> happened.
>>>
>>> But KASAN generally pinpoints the corruption as it happens. Why do we
>>> need something else?
>>
>> Currently (without this patch set) kasan can't detect the overwritten issues
>> that happen on allocated memory.
>>
>> Say, A allocated a 128 bytes memory and B write to that memory at offset 0
>> with length 100 unexpectedly.  Currently kasan won't report error for any
>> writing to the offset 0 with len <= 128 including the B writting.  This
>> patch lets kasan report the B writing to offset 0 with length 100.
>
> So this will be used for manual debugging and you don't have plans to
> annotate kernel code with additional tags, right?
I am not sure what do you mean by "manual debugging". What is needed to 
use the owner check is:
The memory user needs to do:
1)A  code change: register the checker with the allowed functions
2)A  code change: bind the memory to the checker
3)A  recompile the kernel
4)A  run with the recompiled kernel and reproduce the issue

By "additional tags", if you meant "add some explanation comment", I 
think one can refer to the commit message about the code change;
if you meant "additional kernel config item to enable/disable code", I 
have no such plan.A  If no "owner checker" is registered, it just acts 
like the basic kasan (without this patch) with almost same performance. 
Even with "owner checker" registered,A  and memories are bound to the 
checker,A  it's still the rare case to do the owner check. So the 
overheard caused by owner check is slight. I don't find the reason we 
need an additional kernel config.

>
> If this meant to be used by kernel developers during debugging, this
> feature needs to be documented in Documentation/dev-tools/kasan.rst
> including an example. It's hard to spread knowledge about such
> features especially if there are no mentions in docs. Documentation
> can then be quickly referenced e.g. as a suggestion of how to tackle a
> particular bug.
Yes, this is a good idea. I was/am thinking so.

> General comments:
>
> 1. The check must not affect fast-path. I think we need to move it
> into kasan_report (and then rename kasan_report to something else).
> Closer to what Joonsoo did in his version, but move then check even
> further. This will also make inline instrumentation work because it
> calls kasan_report, then kasan_report will do the additional check and
> potentially return without actually reporting a bug.
> The idea is that the check reserves some range of bad values in shadow
> and poison the object with that special value. Then all accesses to
> the protected memory will be detected as bad and go into kasan_report.
> Then kasan_report will do the additional check and potentially return
> without reporting.
> This has 0 overhead when the feature is not used, enables inline
> instrumentation and is less intrusive.
The owner check can be moved to kasan_report() by letting the poison check
routine return "possible violation" when the memory is bound to a owner
and then kasan_report() will get the chance to do further (owner) check.

Well I wonder how that moving would benefit.
If the purpose is to remove overhead,A A  the moving didn't remove of any 
run of
owner check. It would just move it to a different place and it will run 
just a bit later.
I think even current implementation, it has almost 0 overhead when no 
memory is
bound to owners.A  The owner check is performed only when the memory is 
bound (the
bound check is light), if memory is not bound, no owner check is performed.
I am predicting the code that has owner check routine moved to 
kasan_report(), it
should be like this:
(fake code)
in poison check routines:
 A A A A A A  ...
 A A A A A A  after all case that returns "Yes",
 A A A A A A  if bound check returns true (memory is bound):A A A  --> bound 
check is here
 A A A  A A A  A A A A  return "possible"
 A A A A A A  ...
in the caller of poison check routines:
 A A A A A A  ...
 A A A A A A  if poison check routine returns "yes" or "possible":
 A A A A A A A A A A A A  calls kasan_report()

in kasan_report():
 A A A A A A  ....
 A A A A A A  if no basic violation found:
 A A A  A A A A A A  run owner 
checkA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  --> owner check 
is here
 A A A A A A  ...

Current code is like this:
in poison check routines:
 A A A A A A  ...
 A A A A A A  after all case that returns "yes",
 A A A A A A  if bound check returns true (memory is bound):A  --> bound check 
is here
 A A A  A A  A A A  A A A  run owner 
checkA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  --> owner check is here

Comparing to current implementation,
anyway the "bound check" is done either in the poison check routines or 
in kasan_report().
anyway the "owner check" is done either in the poison check routines or 
in kasan_report().
I don't see we have reduced number of calls of "bound check" and/or 
"owner check".
Can you pinpoint which part will be reduced?

If the purpose is to make inline instrumentation work for owner check, 
it interests
me!A  This implementation only works fine in outline instrumentation and 
seems the
poison checks are not called at all with inline compile type. Could you 
share more on this?

The badness of moving owner check to kasan_report() is that it breaks 
the function
clearness in the code.A  From this point of view, check is just check, it 
should say "yes" or
"no", not "possible";A  report is just report, no checks should be 
performed in report.

> 2. Moving this to a separate .c/.h files sounds like a good idea.
> kasan.c is a bit of a mess already. If we do (1), changes to kasan.c
> will be minimal. Again closer to what Joonsoo did.
If the owner checks would remain in the poison check routines, it would 
be in kasan.c.
If we have enough points to support the moving, say that makes inline 
instrumentation
work, it can be in a separated .c/.h and yes that would be better then.

> 3. We need to rename it from "advanced" to something else (owner
> check?). Features must be named based on what they do, rather then how
> advanced they are. If we add other complex checks, how should we name
> them? even_more_advanced?

LoL,A  No and Yes.
The feature I am adding is "owner check" and I define it as one of the 
"advanced check",
By looking at the patch its self (especially enum kasan_adv_chk_type in 
patch 4/5)A  , you
can see, I was leaving spaces for other kind of "advanced checks". And 
(future) different
"advanced checks" can be added -- say "old value validation", "new value 
validation"
 A -- though the new value is notA  supported by compiler yet.A  But yes 
the name "advanced"
is really not what I want, but I failed to find an accurate one. How do 
you think?


>
> I am fine with adding such feature provided that it does not affect
> performance/memory consumption if not used, works with inline
> instrumentation and is separated into separate files. But it also
> needs to be advertised somehow among kernel developers, otherwise only
> you guys will use it.
So far it should has almost same performance if feature is not used; 
definitely
no more memory consumption.A  Now it doesn't work with inline 
instrumentation,
could you share more information on how to make it also work with inline 
mode?
It technically can be moved to separated files. I will add the doc.

thanks,
wengang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
