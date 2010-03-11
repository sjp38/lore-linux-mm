Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 64A6F6B00A0
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 00:04:40 -0500 (EST)
Message-ID: <4B9879E1.6000606@cn.fujitsu.com>
Date: Thu, 11 Mar 2010 13:04:33 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and 	mems_allowed
References: <4B8E3F77.6070201@cn.fujitsu.com>	 <6599ad831003050403v2e988723k1b6bf38d48707ab1@mail.gmail.com>	 <4B931068.70900@cn.fujitsu.com> <6599ad831003091142t38c9ffc9rea7d351742ecbd98@mail.gmail.com>
In-Reply-To: <6599ad831003091142t38c9ffc9rea7d351742ecbd98@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-10 3:42, Paul Menage wrote:
> On Sat, Mar 6, 2010 at 6:33 PM, Miao Xie <miaox@cn.fujitsu.com> wrote:
>>
>> Before applying this patch, cpuset updates task->mems_allowed just like
>> what you said. But the allocator is still likely to see an empty nodemask.
>> This problem have been pointed out by Nick Piggin.
>>
>> The problem is following:
>> The size of nodemask_t is greater than the size of long integer, so loading
>> and storing of nodemask_t are not atomic operations. If task->mems_allowed
>> don't intersect with new_mask, such as the first word of the mask is empty
>> and only the first word of new_mask is not empty. When the allocator
>> loads a word of the mask before
>>
>>        current->mems_allowed |= new_mask;
>>
>> and then loads another word of the mask after
>>
>>        current->mems_allowed = new_mask;
>>
>> the allocator gets an empty nodemask.
> 
> Couldn't that be solved by having the reader read the nodemask twice
> and compare them? In the normal case there's no race, so the second
> read is straight from L1 cache and is very cheap. In the unlikely case
> of a race, the reader would keep trying until it got two consistent
> values in a row.

I think this method can't fix the problem because we can guarantee the second
read is after the update of mask completes.

Thanks!
Miao

> 
> Paul
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
