Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1B92C5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 22:54:18 -0400 (EDT)
Subject: Re: [RFC][PATCH 5/9] vfs: Introduce basic infrastructure for revoking a file
References: <m1skkf761y.fsf@fess.ebiederm.org>
	<m163hb75ph.fsf@fess.ebiederm.org>
	<20090414161240.73fe6bcd@bike.lwn.net>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 14 Apr 2009 19:55:01 -0700
In-Reply-To: <20090414161240.73fe6bcd@bike.lwn.net> (Jonathan Corbet's message of "Tue\, 14 Apr 2009 16\:12\:40 -0600")
Message-ID: <m1tz4qwrqy.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Jonathan Corbet <corbet@lwn.net> writes:

> Hi, Eric,
>
> One little thing I noticed as I was looking at this...
>
>> +int fops_substitute(struct file *file, const struct file_operations *f_op,
>> +			struct vm_operations_struct *vm_ops)
>> +{
>
>  [...]
>
>> +	/*
>> +	 * Wait until there are no more callers in the original
>> +	 * file_operations methods.
>> +	 */
>> +	while (atomic_long_read(&file->f_use) > 0)
>> +		schedule_timeout_interruptible(1);
>
> You use an interruptible sleep here, but there's no signal check to get you
> out of the loop.  So it's not really interruptible.  If f_use never goes to
> zero (a distressingly likely possibility, I fear), this code will create
> the equivalent of an unkillable D-wait state without ever actually showing
> up that way in "ps".

I snagged this idiom out of srcu and hadn't given it much thought.

We have a number of places in the kernel where we aren't performing work
for user space where we fib about the kind of sleep we are doing, so
we don't increase the load.  In this case we are in fs code so I guess
calling this an uninterruptible sleep is fair, especially since it
looks like at some point this code path is going be called from
a syscall.

As for f_use not going to zero, we have strong progress guarantees:

- fops_read_lock at that point will not increment the count of any new
  users of the file.

- There is an additional awaken_all_waiters to wake up any wait queues
  that are causing syscalls to block in the kernel.  


> Actually, now that I look, once you've got a signal pending you'll stay
> in TASK_RUNNING, so the above could turn into a busy-wait.
>
> Unless I've missed something...?

Well we will always schedule, so it shouldn't be a pure busy-wait,
but overall I would call this a good catch.

> I have no idea what the right thing to do in the face of a signal would
> be.  Perhaps the wait-for-zero and release() call stuff should be dumped
> into a workqueue and done asynchronously?  OTOH, I can see a need to know
> when the revoke operation is really done...

Yes.

For sys_revoke the wait doesn't appear necessary.

For umount -f, rmmod, or pci hotunplug we need the wait to know when we it
is safe to free up underlying data structures.  And at least for the latter
two being truly interruptible is a correctness problem.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
