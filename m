Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7A4C06B0073
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 10:59:32 -0400 (EDT)
Received: by yhr47 with SMTP id 47so11839219yhr.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 07:59:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207060928580.26790@router.home>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	<1340389359-2407-3-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207050924330.4138@router.home>
	<CAAmzW4NJyX9e_dMyJBA5zDiVYVmL1vbUkaRHNoSbbhDZWW7iMg@mail.gmail.com>
	<alpine.DEB.2.00.1207060928580.26790@router.home>
Date: Fri, 6 Jul 2012 23:59:31 +0900
Message-ID: <CAAmzW4P941qeKy6UH079r73zR5VjUeNZNB53Mi4wiHE28f==gg@mail.gmail.com>
Subject: Re: [PATCH 3/3] slub: release a lock if freeing object with a lock is
 failed in __slab_free()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/7/6 Christoph Lameter <cl@linux.com>:
> On Fri, 6 Jul 2012, JoonSoo Kim wrote:
>
>> For example,
>> When we try to free object A at cpu 1, another process try to free
>> object B at cpu 2 at the same time.
>> object A, B is in same slab, and this slab is in full list.
>>
>> CPU 1                           CPU 2
>> prior = page->freelist;    prior = page->freelist
>> ....                                  ...
>> new.inuse--;                   new.inuse--;
>> taking lock                      try to take the lock, but failed, so
>> spinning...
>> free success                   spinning...
>> add_partial
>> release lock                    taking lock
>>                                        fail cmpxchg_double_slab
>>                                        retry
>>                                        currently, we don't need lock
>>
>> At CPU2, we don't need lock anymore, because this slab already in partial list.
>
> For that scenario we could also simply do a trylock there and redo
> the loop if we fail. But still what guarantees that another process will
> not modify the page struct between fetching the data and a successful
> trylock?


I'm not familiar with English, so take my ability to understand into
consideration.

we don't need guarantees that another process will not modify
the page struct between fetching the data and a successful trylock.

As I understand, do u ask below scenario?

CPU A               CPU B
lock
cmpxchg fail
retry
unlock
...                       modify page strcut
...
cmpxchg~~

In this case, cmpxchg will fail and just redo the loop.
If we need the lock again during redo, re-take the lock.
But I think this is not common case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
