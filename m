Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 780996B00CA
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 05:33:11 -0500 (EST)
Message-ID: <4B98C6DE.3060602@cn.fujitsu.com>
Date: Thu, 11 Mar 2010 18:33:02 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
References: <4B94CD2D.8070401@cn.fujitsu.com> <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com> <4B95F802.9020308@cn.fujitsu.com> <20100311081548.GJ5812@laptop>
In-Reply-To: <20100311081548.GJ5812@laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-11 16:15, Nick Piggin wrote:
> On Tue, Mar 09, 2010 at 03:25:54PM +0800, Miao Xie wrote:
>> on 2010-3-9 5:46, David Rientjes wrote:
>> [snip]
>>>> Considering the change of task->mems_allowed is not frequent, so in this patch,
>>>> I use two variables as a tag to indicate whether task->mems_allowed need be
>>>> update or not. And before setting the tag, cpuset caches the new mask of every
>>>> task at its task_struct.
>>>>
>>>
>>> So what exactly is the benefit of 58568d2 from last June that caused this 
>>> issue to begin with?  It seems like this entire patchset is a revert of 
>>> that commit.  So why shouldn't we just revert that one commit and then add 
>>> the locking and updating necessary for configs where
>>> MAX_NUMNODES > BITS_PER_LONG on top?
>>
>> I worried about the consistency of task->mempolicy with task->mems_allowed for
>> configs where MAX_NUMNODES <= BITS_PER_LONG. 
>>
>> The problem that I worried is fowllowing:
>> When the kernel allocator allocates pages for tasks, it will access task->mempolicy
>> first and get the allowed node, then check whether that node is allowed by
>> task->mems_allowed.
>>
>> But, Without this patch, ->mempolicy and ->mems_allowed is not updated at the same
>> time. the kernel allocator may access the inconsistent information of ->mempolicy
>> and ->mems_allowed, sush as the allocator gets the allowed node from old mempolicy,
>> but checks whether that node is allowed by new mems_allowed which does't intersect
>> old mempolicy.
>>
>> So I made this patchset.
> 
> I like your focus on keeping the hotpath light, but it is getting a bit
> crazy. I wonder if it wouldn't be better just to teach those places that
> matter to retry on finding an inconsistent nodemask? The only failure
> case to worry about is getting an empty nodemask, isn't it?
> 

Ok, I try to make a new patch by using seqlock.

Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
