Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBC96B005D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 03:21:49 -0400 (EDT)
Message-ID: <49C0A0FE.2000403@cs.columbia.edu>
Date: Wed, 18 Mar 2009 03:21:34 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v13][PATCH 05/14] x86 support for checkpoint/restart
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1233076092-8660-6-git-send-email-orenl@cs.columbia.edu> <20090224014739.1b82fc35@thinkcentre.lan>
In-Reply-To: <20090224014739.1b82fc35@thinkcentre.lan>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Lynch <ntl@pobox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



Nathan Lynch wrote:
> Hi, this is an old thread I guess, but I just noticed some issues while
> looking at this code.
> 
> On Tue, 27 Jan 2009 12:08:03 -0500
> Oren Laadan <orenl@cs.columbia.edu> wrote:
>> +static int cr_read_cpu_fpu(struct cr_ctx *ctx, struct task_struct *t)
>> +{
>> +	void *xstate_buf = cr_hbuf_get(ctx, xstate_size);
>> +	int ret;
>> +
>> +	ret = cr_kread(ctx, xstate_buf, xstate_size);
>> +	if (ret < 0)
>> +		goto out;
>> +
>> +	/* i387 + MMU + SSE */
>> +	preempt_disable();
>> +
>> +	/* init_fpu() also calls set_used_math() */
>> +	ret = init_fpu(current);
>> +	if (ret < 0)
>> +		return ret;
> 
> Several problems here:
> * init_fpu can call kmem_cache_alloc(GFP_KERNEL), but is called here
>   with preempt disabled (init_fpu could use a might_sleep annotation?)
> * if init_fpu returns an error, we get preempt imbalance
> * if init_fpu returns an error, we "leak" the cr_hbuf_get for
>   xstate_buf

Fixed, thanks.

> 
> Speaking of cr_hbuf_get... I'd prefer to see that "allocator" go away
> and its users converted to kmalloc/kfree (this is what I've done for
> the powerpc C/R code, btw).
> 
> Using the slab allocator would:
> 
> * make the code less obscure and easier to review
> * make the code more amenable to static analysis
> * gain the benefits of slab debugging at runtime
> 
> But I think this has been pointed out before.  If I understand the
> justification for cr_hbuf_get correctly, the allocations it services
> are somehow known to be bounded in size and nesting.  But even if that
> is the case, it's not much of a reason to avoid using kmalloc, is it?
> 

The reason I want these wrappers (as opposed to allocators) in place is
allow an optimization that will reduce application downtime during checkpoint.

Since we freeze the container during checkpoint, the applications inside are
unresponsive. The idea is to minimize the downtime by buffering the checkpoint
data in the kernel while the applications are frozen, and defer the (slow)
write-back of the buffer until after the application is allowed to resume
execution. (Memory pages will be marked COW instead of a physical copy in the
kernel).

To that, we'll need the wrapper to not only allocate memory, but also track
all the pieces together as a long buffer. Actual implementation details are
not important now, but having a wrapper in place is.

Consequently, although I prefer not to change the current implementation of
cr_hbuf_get/put(), if you find it really helpful to change to kmalloc/kfree
I won't stand in the way. However, I do insist that the wrappers remain.

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
