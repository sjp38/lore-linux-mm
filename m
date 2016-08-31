Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD74D6B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 09:47:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l205so12407486oia.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 06:47:47 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id v13si26990689itb.79.2016.08.31.06.41.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 06:41:25 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id g185so499718ith.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 06:41:25 -0700 (PDT)
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
From: nick <xerofoify@gmail.com>
Message-ID: <e646694e-05fc-49dd-0123-70138213eab5@gmail.com>
Date: Wed, 31 Aug 2016 09:41:23 -0400
MIME-Version: 1.0
In-Reply-To: <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2016-08-31 03:54 AM, Catalin Marinas wrote:
> On Tue, Aug 30, 2016 at 02:35:12PM -0400, Nicholas Krause wrote:
>> This fixes a issue in the current locking logic of the function,
>> __delete_object where we are trying to attempt to lock the passed
>> object structure's spinlock again after being previously held
>> elsewhere by the kmemleak code. Fix this by instead of assuming
>> we are the only one contending for the object's lock their are
>> possible other users and create two branches, one where we get
>> the lock when calling spin_trylock_irqsave on the object's lock
>> and the other when the lock is held else where by kmemleak.
> 
> Have you actually got a deadlock that requires this fix?
> 
Yes it fixes when you run this test, https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/ipc/msgctl/msgctl10.c.
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -631,12 +631,19 @@ static void __delete_object(struct kmemleak_object *object)
>>  
>>  	/*
>>  	 * Locking here also ensures that the corresponding memory block
>> -	 * cannot be freed when it is being scanned.
>> +	 * cannot be freed when it is being scanned. Further more the
>> +	 * object's lock may have been previously holded by another holder
>> +	 * in the kmemleak code, therefore attempt to lock the object's lock
>> +	 * before holding it and unlocking it.
>>  	 */
>> -	spin_lock_irqsave(&object->lock, flags);
>> -	object->flags &= ~OBJECT_ALLOCATED;
>> -	spin_unlock_irqrestore(&object->lock, flags);
>> -	put_object(object);
>> +	if (spin_trylock_irqsave(&object->lock, flags)) {
>> +		object->flags &= ~OBJECT_ALLOCATED;
>> +		spin_unlock_irqrestore(&object->lock, flags);
>> +		put_object(object);
>> +	} else {
>> +		object->flags &= ~OBJECT_ALLOCATED;
>> +		put_object(object);
>> +	}
> 
> NAK. This lock here is needed, as described in the comment, to prevent
> an object being freed while it is being scanned. The scan_object()
> function acquires the same lock and checks for OBJECT_ALLOCATED before
> accessing the memory (which could be vmalloc'ed for example, so freeing
> would cause a page fault).
> 
That's the issue, right there. Your double locking in scan_object. If you look at the code:
/*
 * Once the object->lock is acquired, the corresponding memory block
          * cannot be freed (the same lock is acquired in delete_object).
*/
That test case exposes that issue in the logic, what happens if we are running this on separate kernel threads what
happens then ... deadlock. If you would like be to put the lock checking elsewhere that's fine but it does cause
a deadlock.
Regards,
Nick  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
