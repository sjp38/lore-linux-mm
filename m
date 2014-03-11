Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 878D96B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 16:12:57 -0400 (EDT)
Received: by mail-yh0-f43.google.com with SMTP id b6so9203597yha.30
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:12:57 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t49si38141945yhd.9.2014.03.11.13.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 13:12:57 -0700 (PDT)
Message-ID: <531F6E43.40901@oracle.com>
Date: Tue, 11 Mar 2014 16:12:51 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
References: <531F6689.60307@oracle.com> <1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/11/2014 04:07 PM, Davidlohr Bueso wrote:
> On Tue, 2014-03-11 at 15:39 -0400, Sasha Levin wrote:
>> Hi all,
>>
>> I've ended up deleting the log file by mistake, but this bug does seem to be important
>> so I'd rather not wait before the same issue is triggered again.
>>
>> The call chain is:
>>
>> 	mlock (mm/mlock.c:745)
>> 		__mm_populate (mm/mlock.c:700)
>> 			__mlock_vma_pages_range (mm/mlock.c:229)
>> 				VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
>
> So __mm_populate() is only called by mlock(2) and this VM_BUG_ON seems
> wrong as we call it without the lock held:
>
> 	up_write(&current->mm->mmap_sem);
> 	if (!error)
> 		error = __mm_populate(start, len, 0);
> 	return error;
> }
>
>>
>> It seems to be a rather simple trace triggered from userspace. The only recent patch
>> in the area (that I've noticed) was "mm/mlock: prepare params outside critical region".
>> I've reverted it and trying to testing without it.
>
> Odd, this patch should definitely *not* cause this. In any case every
> operation removed from the critical region is local to the function:
>
> 	lock_limit = rlimit(RLIMIT_MEMLOCK);
> 	lock_limit >>= PAGE_SHIFT;
> 	locked = len >> PAGE_SHIFT;
>
> 	down_write(&current->mm->mmap_sem);

Yeah, this patch doesn't look like it's causing it, I guess it was more of a "you touched this
code last - do you still remember what's going on here?" :).

It's semi-odd because it seems like an obvious issue to hit with trinity but it's the first time
I've seen it and it's probably been there for a while (that BUG_ON is there from 2009).


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
