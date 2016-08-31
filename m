Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD396B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 10:35:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so107511732pfg.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 07:35:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e2si210060pfk.26.2016.08.31.07.35.33
        for <linux-mm@kvack.org>;
        Wed, 31 Aug 2016 07:35:33 -0700 (PDT)
Date: Wed, 31 Aug 2016 15:35:29 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
Message-ID: <20160831143529.GA21622@e104818-lin.cambridge.arm.com>
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
 <e646694e-05fc-49dd-0123-70138213eab5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e646694e-05fc-49dd-0123-70138213eab5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 31, 2016 at 09:41:23AM -0400, nick wrote:
> On 2016-08-31 03:54 AM, Catalin Marinas wrote:
> > On Tue, Aug 30, 2016 at 02:35:12PM -0400, Nicholas Krause wrote:
> >> This fixes a issue in the current locking logic of the function,
> >> __delete_object where we are trying to attempt to lock the passed
> >> object structure's spinlock again after being previously held
> >> elsewhere by the kmemleak code. Fix this by instead of assuming
> >> we are the only one contending for the object's lock their are
> >> possible other users and create two branches, one where we get
> >> the lock when calling spin_trylock_irqsave on the object's lock
> >> and the other when the lock is held else where by kmemleak.
> > 
> > Have you actually got a deadlock that requires this fix?
> 
> Yes it fixes when you run this test,
> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/ipc/msgctl/msgctl10.c.

I haven't read the subject properly, you meant soft lockup, so no
deadlock here. Do you have any kernel message that you can post on the
list, showing the soft lockup?

> >> --- a/mm/kmemleak.c
> >> +++ b/mm/kmemleak.c
> >> @@ -631,12 +631,19 @@ static void __delete_object(struct kmemleak_object *object)
> >>  
> >>  	/*
> >>  	 * Locking here also ensures that the corresponding memory block
> >> -	 * cannot be freed when it is being scanned.
> >> +	 * cannot be freed when it is being scanned. Further more the
> >> +	 * object's lock may have been previously holded by another holder
> >> +	 * in the kmemleak code, therefore attempt to lock the object's lock
> >> +	 * before holding it and unlocking it.
> >>  	 */
> >> -	spin_lock_irqsave(&object->lock, flags);
> >> -	object->flags &= ~OBJECT_ALLOCATED;
> >> -	spin_unlock_irqrestore(&object->lock, flags);
> >> -	put_object(object);
> >> +	if (spin_trylock_irqsave(&object->lock, flags)) {
> >> +		object->flags &= ~OBJECT_ALLOCATED;
> >> +		spin_unlock_irqrestore(&object->lock, flags);
> >> +		put_object(object);
> >> +	} else {
> >> +		object->flags &= ~OBJECT_ALLOCATED;
> >> +		put_object(object);
> >> +	}
> > 
> > NAK. This lock here is needed, as described in the comment, to prevent
> > an object being freed while it is being scanned. The scan_object()
> > function acquires the same lock and checks for OBJECT_ALLOCATED before
> > accessing the memory (which could be vmalloc'ed for example, so freeing
> > would cause a page fault).
> 
> That's the issue, right there. Your double locking in scan_object. If
> you look at the code:
> /*
>  * Once the object->lock is acquired, the corresponding memory block
>           * cannot be freed (the same lock is acquired in delete_object).
> */
> That test case exposes that issue in the logic, what happens if we are
> running this on separate kernel threads what happens then ...
> deadlock.

There cannot be any deadlock since you can't have two threads on the
same CPU trying to acquire this spinlock, nor any dependency on another
lock that I'm aware of. As for the soft lockup, scan_object() in
kmemleak tries to avoid it by releasing this lock periodically and
calling cond_resched().

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
