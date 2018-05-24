Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6568E6B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 12:40:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u127-v6so1662997qka.9
        for <linux-mm@kvack.org>; Thu, 24 May 2018 09:40:16 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0092.outbound.protection.outlook.com. [104.47.1.92])
        by mx.google.com with ESMTPS id f5-v6si5051763qtd.130.2018.05.24.09.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 24 May 2018 09:40:15 -0700 (PDT)
Subject: Re: [PATCH] userfaultfd: prevent non-cooperative events vs
 mcopy_atomic races
References: <1527061324-19949-1-git-send-email-rppt@linux.vnet.ibm.com>
 <0e1ce040-1beb-fd96-683c-1b18eb635fd6@virtuozzo.com>
 <20180524115613.GA16908@rapoport-lnx>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <e42a383f-491a-b42a-347c-effe4b86b982@virtuozzo.com>
Date: Thu, 24 May 2018 19:40:07 +0300
MIME-Version: 1.0
In-Reply-To: <20180524115613.GA16908@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrei Vagin <avagin@virtuozzo.com>

On 05/24/2018 02:56 PM, Mike Rapoport wrote:
> On Thu, May 24, 2018 at 02:24:37PM +0300, Pavel Emelyanov wrote:
>> On 05/23/2018 10:42 AM, Mike Rapoport wrote:
>>> If a process monitored with userfaultfd changes it's memory mappings or
>>> forks() at the same time as uffd monitor fills the process memory with
>>> UFFDIO_COPY, the actual creation of page table entries and copying of the
>>> data in mcopy_atomic may happen either before of after the memory mapping
>>> modifications and there is no way for the uffd monitor to maintain
>>> consistent view of the process memory layout.
>>>
>>> For instance, let's consider fork() running in parallel with
>>> userfaultfd_copy():
>>>
>>> process        		         |	uffd monitor
>>> ---------------------------------+------------------------------
>>> fork()        		         | userfaultfd_copy()
>>> ...        		         | ...
>>>     dup_mmap()        	         |     down_read(mmap_sem)
>>>     down_write(mmap_sem)         |     /* create PTEs, copy data */
>>>         dup_uffd()               |     up_read(mmap_sem)
>>>         copy_page_range()        |
>>>         up_write(mmap_sem)       |
>>>         dup_uffd_complete()      |
>>>             /* notify monitor */ |
>>>
>>> If the userfaultfd_copy() takes the mmap_sem first, the new page(s) will be
>>> present by the time copy_page_range() is called and they will appear in the
>>> child's memory mappings. However, if the fork() is the first to take the
>>> mmap_sem, the new pages won't be mapped in the child's address space.
>>
>> But in this case child should get an entry, that emits a message to uffd when step upon!
>> And uffd will just userfaultfd_copy() it again. No?
>  
> There will be a message, indeed. But there is no way for monitor to tell
> whether the pages it copied are present or not in the child.

If there's a message, then they are not present, that's for sure :)

> Since the monitor cannot assume that the process will access all its memory
> it has to copy some pages "in the background". A simple monitor may look
> like:
> 
> 	for (;;) {
> 		wait_for_uffd_events(timeout);
> 		handle_uffd_events();
> 		uffd_copy(some not faulted pages);
> 	}
> 
> Then, if the "background" uffd_copy() races with fork, the pages we've
> copied may be already present in parent's mappings before the call to
> copy_page_range() and may be not.
> 
> If the pages were not present, uffd_copy'ing them again to the child's
> memory would be ok.

Yes.

> But if uffd_copy() was first to catch mmap_sem, and we would uffd_copy them
> again, child process will get memory corruption.

You mean the background uffd_copy()? But doesn't it race even with regular PF handling,
not only the fork? How do we handle this race?

-- Pavel
