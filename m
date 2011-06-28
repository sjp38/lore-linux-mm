Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7F30F6B0120
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 13:16:41 -0400 (EDT)
Subject: Re: [PATCH 2/2] mm: Document handle_mm_fault()
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110628170953.GA3482@redhat.com>
References: <20110628164750.281686775@goodmis.org>
	 <20110628165303.010143380@goodmis.org>  <20110628170953.GA3482@redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 28 Jun 2011 13:16:39 -0400
Message-ID: <1309281399.26417.11.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>

On Tue, 2011-06-28 at 20:09 +0300, Gleb Natapov wrote:

> > -/*
> > - * By the time we get here, we already hold the mm semaphore
> > +/**
> > + * handle_mm_fault - main routine for handling page faults
> > + * @mm:		the mm_struct of the target address space
> > + * @vma:	vm_area_struct holding the applicable pages
> > + * @address:	the address that took the fault
> > + * @flags:	flags modifying lookup behaviour
> > + *
> > + * Must have @mm->mmap_sem held.
> > + *
> > + * Note: if @flags has FAULT_FLAG_ALLOW_RETRY set then the mmap_sem
> > + *       may be released if it failed to arquire the page_lock. If the
> > + *       mmap_sem is released then it will return VM_FAULT_RETRY set.
> > + *       This is to keep the time mmap_sem is held when the page_lock
> > + *       is taken for IO.
> > + * Exception: If FAULT_FLAG_RETRY_NOWAIT is set, then it will
> > + *       not release the mmap_sem, but will still return VM_FAULT_RETRY
> > + *       if it failed to acquire the page_lock.
> I wouldn't describe it like that. It tells handle_mm_fault() to start
> IO if needed, but do not wait for its completion.

This isn't a description of the flag itself. It's a description of the
mmap_sem behavior for the flag. Again, this came about because of the
subtle locking that handle_mm_fault() does with mmap_sem. When it comes
to locking, we need things documented very well, as locking is usually
what most developers get wrong even when subtle locking does not exist.

> 
> > + *       This is for helping virtualization. See get_user_page_nowait().
> The virtialization is the only user right now, but I wouldn't describe
> this flag as virtialization specific. Why should we put this in the
> comment?  The comment will become outdated when other users arise
> and meanwhile a simple grep will reveal the above information anyway.

I've been going in the direction of adding comments about how things
help. OK, so it's the only user now. I could change this to, "This is
for helping things like virtualization." When reading code, it is nice
to know why something is done that is out of the ordinary.

If it changes, then we should change the comments. The best place for
keeping code documented and up to date, is right at the code. 
ie. comments.


-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
