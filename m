Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D74755F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 18:12:32 -0400 (EDT)
Date: Tue, 14 Apr 2009 16:12:40 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [RFC][PATCH 5/9] vfs: Introduce basic infrastructure for
 revoking a file
Message-ID: <20090414161240.73fe6bcd@bike.lwn.net>
In-Reply-To: <m163hb75ph.fsf@fess.ebiederm.org>
References: <m1skkf761y.fsf@fess.ebiederm.org>
	<m163hb75ph.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Hi, Eric,

One little thing I noticed as I was looking at this...

> +int fops_substitute(struct file *file, const struct file_operations *f_op,
> +			struct vm_operations_struct *vm_ops)
> +{

 [...]

> +	/*
> +	 * Wait until there are no more callers in the original
> +	 * file_operations methods.
> +	 */
> +	while (atomic_long_read(&file->f_use) > 0)
> +		schedule_timeout_interruptible(1);

You use an interruptible sleep here, but there's no signal check to get you
out of the loop.  So it's not really interruptible.  If f_use never goes to
zero (a distressingly likely possibility, I fear), this code will create
the equivalent of an unkillable D-wait state without ever actually showing
up that way in "ps".

Actually, now that I look, once you've got a signal pending you'll stay
in TASK_RUNNING, so the above could turn into a busy-wait.

Unless I've missed something...?

I have no idea what the right thing to do in the face of a signal would
be.  Perhaps the wait-for-zero and release() call stuff should be dumped
into a workqueue and done asynchronously?  OTOH, I can see a need to know
when the revoke operation is really done...

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
