Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCEE6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:41:38 -0400 (EDT)
Message-ID: <49B92D2B.2090100@ens-lyon.org>
Date: Thu, 12 Mar 2009 16:41:31 +0100
From: Brice Goglin <Brice.Goglin@ens-lyon.org>
MIME-Version: 1.0
Subject: Re: [PATCH] acquire mmap semaphore in pagemap_read.
References: <20090312113308.6fe18a93@skybase>	<20090312114533.GA2407@x200.localdomain>	<20090312125410.25400d18@skybase>	<1236871414.3213.50.camel@calx> <20090312162733.4e8fd197@skybase>
In-Reply-To: <20090312162733.4e8fd197@skybase>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:
> On Thu, 12 Mar 2009 10:23:34 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
>> On Thu, 2009-03-12 at 12:54 +0100, Martin Schwidefsky wrote:
>>> On Thu, 12 Mar 2009 14:45:33 +0300
>>> Alexey Dobriyan <adobriyan@gmail.com> wrote:
>>>
>>>> On Thu, Mar 12, 2009 at 11:33:08AM +0100, Martin Schwidefsky wrote:
>>>>> --- linux-2.6/fs/proc/task_mmu.c
>>>>> +++ linux-2.6-patched/fs/proc/task_mmu.c
>>>>> @@ -716,7 +716,9 @@ static ssize_t pagemap_read(struct file 
>>>>>  	 * user buffer is tracked in "pm", and the walk
>>>>>  	 * will stop when we hit the end of the buffer.
>>>>>  	 */
>>>>> +	down_read(&mm->mmap_sem);
>>>>>  	ret = walk_page_range(start_vaddr, end_vaddr, &pagemap_walk);
>>>>> +	up_read(&mm->mmap_sem);
>>>> This will introduce "put_user under mmap_sem" which is deadlockable.
>>> Hmm, interesting. In this case the pagemap interface is fundamentally broken.
>> Well it means we may have to reintroduce the very annoying double
>> buffering from various earlier implementations. But let's leave this
>> discussion until after we've figured out what to do about the walker
>> code.
> 
> Which would be really ugly. I still have not grasped why this will
> introduce a deadlock though. The worst the put_user can do is to cause
> a page fault, no? I do not see where the fault handler acquires the
> mmap_sem as writer. It takes the mmap_sem as reader and two readers
> should be fine.

Somebody else can acquire for write in the meantime, for instance
another thread doing mprotect. This writer is blocked by the first
reader, and the second reader is blocked by the writer. So both
tasks are blocked.

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
