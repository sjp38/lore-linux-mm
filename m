Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2661B6B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 20:34:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g6so15557914pgn.11
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 17:34:55 -0700 (PDT)
Received: from out0-218.mail.aliyun.com (out0-218.mail.aliyun.com. [140.205.0.218])
        by mx.google.com with ESMTPS id s11si794625plp.812.2017.10.24.17.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 17:34:49 -0700 (PDT)
Subject: Re: [RFC PATCH] fs: fsnotify: account fsnotify metadata to kmemcg
References: <1508448056-21779-1-git-send-email-yang.s@alibaba-inc.com>
 <CAOQ4uxhPhXrMLu18TGKDA=ezUVHara95qJQ+BTCio8BHm-u6NA@mail.gmail.com>
 <b530521e-5215-f735-444a-13f722d90e40@alibaba-inc.com>
 <CAOQ4uxhFOoSknnG-0Jyv+=iCDjVNnAg6SiO-msxw4tORkVKJGQ@mail.gmail.com>
 <5b80a088-05f1-c9af-5b71-e1128fbb36a7@alibaba-inc.com>
 <CAOQ4uxiVbA1HxPt9mjn-AL0XzMuOYU5dMeMoHxZbxHLzaS=niQ@mail.gmail.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <1400291b-0fe7-3a22-2f8a-84ff488b8fc1@alibaba-inc.com>
Date: Wed, 25 Oct 2017 08:34:41 +0800
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxiVbA1HxPt9mjn-AL0XzMuOYU5dMeMoHxZbxHLzaS=niQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org



On 10/23/17 10:42 PM, Amir Goldstein wrote:
> On Tue, Oct 24, 2017 at 7:12 AM, Yang Shi <yang.s@alibaba-inc.com> wrote:
>>
>>
>> On 10/22/17 1:24 AM, Amir Goldstein wrote:
>>>
>>> On Sat, Oct 21, 2017 at 12:07 AM, Yang Shi <yang.s@alibaba-inc.com> wrote:
>>>>
>>>>
>>>>
>>>> On 10/19/17 8:14 PM, Amir Goldstein wrote:
>>>>>
>>>>>
>>>>> On Fri, Oct 20, 2017 at 12:20 AM, Yang Shi <yang.s@alibaba-inc.com>
>>>>> wrote:
>>>>>>
>>>>>>
>>>>>> We observed some misbehaved user applications might consume significant
>>>>>> amount of fsnotify slabs silently. It'd better to account those slabs
>>>>>> in
>>>>>> kmemcg so that we can get heads up before misbehaved applications use
>>>>>> too
>>>>>> much memory silently.
>>>>>
>>>>>
>>>>>
>>>>> In what way do they misbehave? create a lot of marks? create a lot of
>>>>> events?
>>>>> Not reading events in their queue?
>>>>
>>>>
>>>>
>>>> It looks both a lot marks and events. I'm not sure if it is the latter
>>>> case.
>>>> If I knew more about the details of the behavior, I would elaborated more
>>>> in
>>>> the commit log.
>>>
>>>
>>> If you are not sure, do not refer to user application as "misbehaved".
>>> Is updatedb(8) a misbehaved application because it produces a lot of
>>> access
>>> events?
>>
>>
>> Should be not. It sounds like our in-house applications. But, it is a sort
>> of blackbox to me.
>>
> 
> If you know which process is "misbehaving" you can look at
> ls -l /proc/<pid>/fd |grep notify
> and see the anonymous inotify/fanotify file descriptors
> 
> then you can look at  /proc/<pid>/fdinfo/<fd> file of those
> file descriptors to learn more about the fanotify flags etc.

Thanks for the hints.

> 
> ...
> 
>>
>>>
>>> But I think there is another problem, not introduced by your change, but
>>> could
>>> be amplified because of it - when a non-permission event allocation fails,
>>> the
>>> event is silently dropped, AFAICT, with no indication to listener.
>>> That seems like a bug to me, because there is a perfectly safe way to deal
>>> with
>>> event allocation failure - queue the overflow event.
>>
>>
>> I'm not sure if such issue could be amplified by the accounting since once
>> the usage exceeds the limit any following kmem allocation would fail. So, it
>> might fail at fsnotify event allocation, or other places, i.e. fork, open
>> syscall, etc. So, in most cases the generator even can't generate new event
>> any more.
>>
> 
> To be clear, I did not mean that kmem limit would cause a storm of dropped
> events. I meant if you have a listener outside memcp watching a single file
> for access/modifications and you have many containers each with its own
> limited memcg, then event drops probability goes to infinity as you run more
> of those kmem limited containers with event producers.
> 
>> The typical output from my LTP test is filesystem dcache allocation error or
>> fork error due to kmem limit is reached.
> 
> And that should be considered a success result of the test.
> The only failure case is when producer touches the file and event is
> not delivered
> nor an overflow event delivered.
> You can probably try to reduce allocation failure for fork and dentry by:
> 1. pin dentry cache of subject file on test init by opening the file
> 2. set the low kmem limit after forking
> 
> Then you should probably loop the test enough times
> in some of the times, producer may fail to access the file
> in others if will succeed and produce events properly
> and many some times, producer will access the file and event
> will be dropped, so event count is lower than access count.

I still have not very direct test result shows the patch works as 
expected. But, I did get some prove from running fanotify test *without* 
your overflow event patch.

Running fanotify without your overflow patch, sometimes I can see:

[  122.222455] SLUB: Unable to allocate memory on node -1, 
gfp=0x14000c0(GFP_KERNEL)
[  122.224198]   cache: fanotify_event_info(110:fsnotify), object size: 
56, buffer size: 88, default order: 0, min order: 0
[  122.226578]   node 0: slabs: 11, objs: 506, free: 0
[  122.227655]   node 1: slabs: 0, objs: 0, free: 0
[  122.229251] SLUB: Unable to allocate memory on node -1, 
gfp=0x14000c0(GFP_KERNEL)
[  122.230912]   cache: fanotify_event_info(110:fsnotify), object size: 
56, buffer size: 88, default order: 0, min order: 0
[  122.233266]   node 0: slabs: 11, objs: 506, free: 0
[  122.234337]   node 1: slabs: 0, objs: 0, free: 0

The slub oom information is printed a couple of times, it should mean 
neither the event is delivered nor the overflow event is delivered.

With your overflow patch, I've never seen such message.

Regards,
Yang

> 
> 
> 
>>
>>> I am not going to be the one to determine if fixing this alleged bug is a
>>> prerequisite for merging your patch, but I think enforcing memory limits
>>> on
>>> event allocation could amplify that bug, so it should be fixed.
>>>
>>> The upside is that with both your accounting fix and ENOMEM = overlflow
>>> fix, it going to be easy to write a test that verifies both of them:
>>> - Run a listener in memcg with limited kmem and unlimited (or very
>>> large) event queue
>>> - Produce events inside memcg without listener reading them
>>> - Read event and expect an OVERFLOW even
>>>
>>> This is a simple variant of LTP tests inotify05 and fanotify05.
>>
>>
>> I tried to test your patch with LTP, but it sounds not that easy to setup a
>> scenario to make fsnotify event allocation just hit the kmem limit, since
>> the limit may be hit before a new event is allocated, for example allocating
>> dentry cache in open syscall may hit the limit.
>>
>> So, it sounds the overflow event might be not generated by the producer in
>> most cases.
>>
> 
> Right. not as simple, but maybe still possible as I described above.
> Assuming that my patch is not buggy...
> 
> Thanks,
> Amir.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
