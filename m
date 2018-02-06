Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0AD06B029B
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 13:57:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r82so1366915wme.0
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 10:57:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o204si70890wma.223.2018.02.06.10.57.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 10:57:58 -0800 (PST)
Date: Tue, 6 Feb 2018 10:48:44 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [RFC PATCH 00/64] mm: towards parallel address space operations
Message-ID: <20180206184844.olcd34engojudsxt@linux-n805>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
 <df29e9eb-22ad-7e96-6ea4-2fd0ad2509a9@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <df29e9eb-22ad-7e96-6ea4-2fd0ad2509a9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Davidlohr Bueso <dbueso@suse.de>, akpm@linux-foundation.org, mingo@kernel.org, peterz@infradead.org, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 05 Feb 2018, Laurent Dufour wrote:

>On 05/02/2018 02:26, Davidlohr Bueso wrote:
>> From: Davidlohr Bueso <dave@stgolabs.net>
>>
>> Hi,
>>
>> This patchset is a new version of both the range locking machinery as well
>> as a full mmap_sem conversion that makes use of it -- as the worst case
>> scenario as all mmap_sem calls are converted to a full range mmap_lock
>> equivalent. As such, while there is no improvement of concurrency perse,
>> these changes aim at adding the machinery to permit this in the future.
>
>Despite the massive rebase, what are the changes in this series compared to
>the one I sent in last May - you silently based on, by the way :
>https://lkml.org/lkml/2017/5/24/409

Hardly, but yes I meant to reference that. It ended up being easier to just
do a from scratch version. I haven't done a comparison, but at first I thought
you missed gup users (now not so much), this patchset allows testing on more
archs (see below), we remove the trylock in vm_insert_page(), etc.

>>
>> Direct users of the mm->mmap_sem can be classified as those that (1) acquire
>> and release the lock within the same context, and (2) those who directly
>> manipulate the mmap_sem down the callchain. For example:
>>
>> (1)  down_read(&mm->mmap_sem);
>>      /* do something */
>>      /* nobody down the chain uses mmap_sem directly */
>>      up_read(&mm->mmap_sem);
>>
>> (2a)  down_read(&mm->mmap_sem);
>>       /* do something that retuns mmap_sem unlocked */
>>       fn(mm, &locked);
>>       if (locked)
>>         up_read(&mm->mmap_sem);
>>
>> (2b)  down_read(&mm->mmap_sem);
>>       /* do something that in between released and reacquired mmap_sem */
>>       fn(mm);
>>       up_read(&mm->mmap_sem);
>
>Unfortunately, there are also indirect users which rely on the mmap_sem
>locking to protect their data. For the first step using a full range this
>doesn't matter, but when refining the range, these one would be the most
>critical ones as they would have to be reworked to take the range in account.

Of course. The value I see in this patchset is that we can determine whether or
not we move forward based on the worst case scenario numbers.

>> Testing: I have setup an mmtests config file with all the workloads described:
>> http://linux-scalability.org/mmtests-config
>
>Is this link still valid, I can't reach it ?

Sorry, that should have been:

https://linux-scalability.org/range-mmap_lock/mmtests-config

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
