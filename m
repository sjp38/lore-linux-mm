Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7LBCrRM002069
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 21:12:53 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7LBDvum279412
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 21:13:57 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7LBDvUa019979
	for <linux-mm@kvack.org>; Thu, 21 Aug 2008 21:13:57 +1000
Message-ID: <48AD4DF2.3050700@linux.vnet.ibm.com>
Date: Thu, 21 Aug 2008 16:43:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [discuss] memrlimit - potential applications that can use
References: <48AA73B5.7010302@linux.vnet.ibm.com> <1219161525.23641.125.camel@nimitz> <48AAF8C0.1010806@linux.vnet.ibm.com> <1219167669.23641.156.camel@nimitz> <48ABD545.8010209@linux.vnet.ibm.com> <1219249757.8960.22.camel@nimitz> <48ACE040.2030807@linux.vnet.ibm.com> <20080821164339.679212b2.kamezawa.hiroyu@jp.fujitsu.com> <48AD42E1.40204@linux.vnet.ibm.com> <20080821195915.f1ecd012.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080821195915.f1ecd012.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Andrea Righi <righi.andrea@gmail.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Aug 2008 15:56:41 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Thu, 21 Aug 2008 08:55:52 +0530
>>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>
>>>>>>> So, before we expand the use of those features to control groups by
>>>>>>> adding a bunch of new code, let's make sure that there will be users
>>>>>> for
>>>>>>> it and that those users have no better way of doing it.
>>>>>> I am all ears to better ways of doing it. Are you suggesting that overcommit was
>>>>>> added even though we don't actually need it?
>>>>> It serves a purpose, certainly.  We have have better ways of doing it
>>>>> now, though.  "i>>?So, before we expand the use of those features to
>>>>> control groups by adding a bunch of new code, let's make sure that there
>>>>> will be users for it and that those users have no better way of doing
>>>>> it."
>>>>>
>>>>> The one concrete user that's been offered so far is postgres.  I've
>>>> No, you've been offered several, including php and apache that use memory limits.
>>>>
>>>>> suggested something that I hope will be more effective than enforcing
>>>>> overcommit.  
>>> I'm sorry I miss the point. My concern on memrlimit (for overcommiting) is that
>>> it's not fair because an application which get -ENOMEM at mmap() is just someone
>>> unlucky.
>> It can happen today with overcommit turned on. Why is it unlucky?
>>
> Today's overcommit is also unlucky ;) 
> 
> For example) process A and B is under a memrlimit.
>  process A no memory leak, it often calls malloc() and free().
>  process B does memory leak, 100MB per night.
> 
> process A cannot do anything when it notices malloc() returns NULL.
> It controls his memory usage perfectly. He is unlucky and will die.
> process B can use up VSZ which is freed by process A.
> 

Yes, true that will happen. Why will A die because it sees NULL? Yes, many
applications do die, but that is not how malloc == NULL is expected to be
handled. If that is a concern, do not use any memrlimits for A and B, if you do
you will find the bug early.

Now consider the other scenario, if there really is a memory leak and process B
is using all that memory, two things to consider

1. Without swap controller, B will start swapping out A's memory and cause
excessive swapping and performance loss
2. With swap controller enabled, at some point we will hit the swap limit, what
happens then?

> (OOM-killer, is disliked by everyone, have some kind of fairness.
>  It checks usage.)
> 
>>  I think it's better to trigger some notifier to application or daemon
>>> rather than return -ENOMEM at mmap(). Notification like "Oh, it seems the VSZ
>>> of total application exceeds the limit you set. Although you can continue your
>>> operation, it's recommended that you should fix up the  situation".
>>> will be good.
>>>
>> So you are suggesting that when we are running out of memory (as defined by our
>> current resource constraints), we don't return -ENOMEM, but instead we now
>> handle a new event that states that we are running out of memory?
>>
> Not "running out of memory" Just "VSZ is over the limit you set/expected".
> 
> My point is an application witch can handle NULL returned by malloc() is
> not very popular, I think.
> 

Yes and that's why we have the flexibility, if the application can't deal with
it don't set memrlimits for those applications :)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
