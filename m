Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 345B56B008C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 00:00:20 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so360130pad.36
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 21:00:19 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id c4si3088961pds.247.2014.10.23.21.00.18
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 21:00:19 -0700 (PDT)
Message-ID: <5449C8A6.9080403@cn.fujitsu.com>
Date: Fri, 24 Oct 2014 11:33:58 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/6] SRCU free VMAs
References: <20141020215633.717315139@infradead.org> <20141020222841.419869904@infradead.org> <5448D515.90006@cn.fujitsu.com> <20141023110346.GP21513@worktop.programming.kicks-ass.net>
In-Reply-To: <20141023110346.GP21513@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/23/2014 07:03 PM, Peter Zijlstra wrote:
> On Thu, Oct 23, 2014 at 06:14:45PM +0800, Lai Jiangshan wrote:
>>
>>>  
>>> +struct vm_area_struct *find_vma_srcu(struct mm_struct *mm, unsigned long addr)
>>> +{
>>> +	struct vm_area_struct *vma;
>>> +	unsigned int seq;
>>> +
>>> +	WARN_ON_ONCE(!srcu_read_lock_held(&vma_srcu));
>>> +
>>> +	do {
>>> +		seq = read_seqbegin(&mm->mm_seq);
>>> +		vma = __find_vma(mm, addr);
>>
>> will the __find_vma() loops for ever due to the rotations in the RBtree?
> 
> No, a rotation takes a tree and generates a tree, furthermore the
> rotation has a fairly strict fwd progress guarantee seeing how its now
> done with preemption disabled.

I can't get the magic.

__find_vma is visiting vma_a,
vma_a is rotated to near the top due to multiple updates to the mm.
__find_vma is visiting down to near the bottom, vma_b.
now vma_b is rotated up to near the top again.
__find_vma is visiting down to near the bottom, vma_c.
now vma_c is rotated up to near the top again.

...




> 
> Therefore, even if we're in a node that's being rotated up, we can only
> 'loop' for as long as it takes for the new pointer stores to become
> visible on our CPU.
> 
> Thus we have a tree descent termination guarantee.
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
