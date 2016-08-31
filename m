Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76EF66B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 03:54:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so90407727pfg.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 00:54:26 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b2si49590301pfg.14.2016.08.31.00.54.25
        for <linux-mm@kvack.org>;
        Wed, 31 Aug 2016 00:54:25 -0700 (PDT)
Date: Wed, 31 Aug 2016 08:54:21 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
Message-ID: <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 30, 2016 at 02:35:12PM -0400, Nicholas Krause wrote:
> This fixes a issue in the current locking logic of the function,
> __delete_object where we are trying to attempt to lock the passed
> object structure's spinlock again after being previously held
> elsewhere by the kmemleak code. Fix this by instead of assuming
> we are the only one contending for the object's lock their are
> possible other users and create two branches, one where we get
> the lock when calling spin_trylock_irqsave on the object's lock
> and the other when the lock is held else where by kmemleak.

Have you actually got a deadlock that requires this fix?

> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -631,12 +631,19 @@ static void __delete_object(struct kmemleak_object *object)
>  
>  	/*
>  	 * Locking here also ensures that the corresponding memory block
> -	 * cannot be freed when it is being scanned.
> +	 * cannot be freed when it is being scanned. Further more the
> +	 * object's lock may have been previously holded by another holder
> +	 * in the kmemleak code, therefore attempt to lock the object's lock
> +	 * before holding it and unlocking it.
>  	 */
> -	spin_lock_irqsave(&object->lock, flags);
> -	object->flags &= ~OBJECT_ALLOCATED;
> -	spin_unlock_irqrestore(&object->lock, flags);
> -	put_object(object);
> +	if (spin_trylock_irqsave(&object->lock, flags)) {
> +		object->flags &= ~OBJECT_ALLOCATED;
> +		spin_unlock_irqrestore(&object->lock, flags);
> +		put_object(object);
> +	} else {
> +		object->flags &= ~OBJECT_ALLOCATED;
> +		put_object(object);
> +	}

NAK. This lock here is needed, as described in the comment, to prevent
an object being freed while it is being scanned. The scan_object()
function acquires the same lock and checks for OBJECT_ALLOCATED before
accessing the memory (which could be vmalloc'ed for example, so freeing
would cause a page fault).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
