Message-ID: <436EC2AF.4020202@yahoo.com.au>
Date: Mon, 07 Nov 2005 13:57:51 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>	<p73oe4z2f9h.fsf@verdi.suse.de>	<20051105201841.2591bacc.pj@sgi.com>	<200511061835.53575.ak@suse.de> <20051106124944.0b2ccca1.pj@sgi.com>
In-Reply-To: <20051106124944.0b2ccca1.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <ak@suse.de>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Andi wrote:
> 
>>>The current code in the kernel does the following:
>>>  1) The cpuset_update_current_mems_allowed() calls in the
>>>     various alloc_page*() paths in mm/mempolicy.c:
>>>	* take the task_lock spinlock on the current task
>>
>>That needs to go imho.
> 
> 
> The comment for refresh_mems(), where this is happening, explains
> why this lock is needed:
> 
>  * The task_lock() is required to dereference current->cpuset safely.
>  * Without it, we could pick up the pointer value of current->cpuset
>  * in one instruction, and then attach_task could give us a different
>  * cpuset, and then the cpuset we had could be removed and freed,
>  * and then on our next instruction, we could dereference a no longer
>  * valid cpuset pointer to get its mems_generation field.
> 
> Hmmm ... on second thought ... damn ... you're right.
> 
> I can just flat out remove that task_lock - without penalty.
> 
> It's *OK* if I dereference a no longer valid cpuset pointer to get
> its (used to be) mems_generation field.  Either that field will have
> already changed, or it won't.
> 

I don't think so because if the cpuset can be freed, then its page
might be unmapped from the kernel address space if use-after-free
debugging is turned on. And this is a use after free :)

Also, it may be reused for something else far into the future without
having its value changed - is this OK?

Anyway, I think the first problem is a showstopper. I'd look into
Hugh's SLAB_DESTROY_BY_RCU for this, which sounds like a good fit
if you need to go down this path (although I only had a quick skim
over the cpusets code).

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
