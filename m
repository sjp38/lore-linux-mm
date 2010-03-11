Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A6D306B00B0
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 02:57:28 -0500 (EST)
Message-ID: <4B98A263.8030903@cn.fujitsu.com>
Date: Thu, 11 Mar 2010 15:57:23 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and 	mems_allowed
References: <4B8E3F77.6070201@cn.fujitsu.com> <6599ad831003050403v2e988723k1b6bf38d48707ab1@mail.gmail.com> <4B931068.70900@cn.fujitsu.com> <6599ad831003091142t38c9ffc9rea7d351742ecbd98@mail.gmail.com> <4B9879E1.6000606@cn.fujitsu.com> <20100311053059.GG5812@laptop>
In-Reply-To: <20100311053059.GG5812@laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-11 13:30, Nick Piggin wrote:
>>>> The problem is following:
>>>> The size of nodemask_t is greater than the size of long integer, so loading
>>>> and storing of nodemask_t are not atomic operations. If task->mems_allowed
>>>> don't intersect with new_mask, such as the first word of the mask is empty
>>>> and only the first word of new_mask is not empty. When the allocator
>>>> loads a word of the mask before
>>>>
>>>>        current->mems_allowed |= new_mask;
>>>>
>>>> and then loads another word of the mask after
>>>>
>>>>        current->mems_allowed = new_mask;
>>>>
>>>> the allocator gets an empty nodemask.
>>>
>>> Couldn't that be solved by having the reader read the nodemask twice
>>> and compare them? In the normal case there's no race, so the second
>>> read is straight from L1 cache and is very cheap. In the unlikely case
>>> of a race, the reader would keep trying until it got two consistent
>>> values in a row.
>>
>> I think this method can't fix the problem because we can guarantee the second
>> read is after the update of mask completes.
> 
> Any problem with using a seqlock?
> 
> The other thing you could do is store a pointer to the nodemask, and
> allocate a new nodemask when changing it, issue a smp_wmb(), and then
> store the new pointer. Read side only needs a smp_read_barrier_depends()

Comparing with my second version patch, I think both of these methods will cause worse
performance and the changing of code is more.

Thanks
Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
