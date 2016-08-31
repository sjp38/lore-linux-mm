Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85D916B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 09:24:46 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i4so8576681oih.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 06:24:46 -0700 (PDT)
Received: from mail-it0-x22d.google.com (mail-it0-x22d.google.com. [2607:f8b0:4001:c0b::22d])
        by mx.google.com with ESMTPS id g18si12825778itb.67.2016.08.31.06.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 06:24:29 -0700 (PDT)
Received: by mail-it0-x22d.google.com with SMTP id i184so7496241itf.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 06:24:29 -0700 (PDT)
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
From: nick <xerofoify@gmail.com>
Message-ID: <e2e8b8fc-3deb-aa23-c54e-43f12dd0a941@gmail.com>
Date: Wed, 31 Aug 2016 09:24:27 -0400
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
Yes I have got a deadlock that this does fix.
Nick
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
