Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 9751A6B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 10:19:28 -0400 (EDT)
Received: by yhr47 with SMTP id 47so11781400yhr.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 07:19:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207050924330.4138@router.home>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	<1340389359-2407-3-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207050924330.4138@router.home>
Date: Fri, 6 Jul 2012 23:19:27 +0900
Message-ID: <CAAmzW4NJyX9e_dMyJBA5zDiVYVmL1vbUkaRHNoSbbhDZWW7iMg@mail.gmail.com>
Subject: Re: [PATCH 3/3] slub: release a lock if freeing object with a lock is
 failed in __slab_free()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/7/5 Christoph Lameter <cl@linux.com>:
> On Sat, 23 Jun 2012, Joonsoo Kim wrote:
>
>> In some case of __slab_free(), we need a lock for manipulating partial list.
>> If freeing object with a lock is failed, a lock doesn't needed anymore
>> for some reasons.
>>
>> Case 1. prior is NULL, kmem_cache_debug(s) is true
>>
>> In this case, another free is occured before our free is succeed.
>> When slab is full(prior is NULL), only possible operation is slab_free().
>> So in this case, we guess another free is occured.
>> It may make a slab frozen, so lock is not needed anymore.
>
> A free cannot freeze the slab without taking the lock. The taken lock
> makes sure that the thread that first enters slab_free() will be able to
> hold back the thread that wants to freeze the slab.

I don't mean we can freeze the slab without taking the lock.
We can fail cmpxchg_double_slab with taking the lock.
And in this case, we don't need lock anymore, so let's release lock.

For example,
When we try to free object A at cpu 1, another process try to free
object B at cpu 2 at the same time.
object A, B is in same slab, and this slab is in full list.

CPU 1                           CPU 2
prior = page->freelist;    prior = page->freelist
....                                  ...
new.inuse--;                   new.inuse--;
taking lock                      try to take the lock, but failed, so
spinning...
free success                   spinning...
add_partial
release lock                    taking lock
                                       fail cmpxchg_double_slab
                                       retry
                                       currently, we don't need lock

At CPU2, we don't need lock anymore, because this slab already in partial list.

Case 2 is similar as case 1.
So skip explain.

Case 1, 2 in commit message explain almost retry case with taking lock.
So, below is reasonable.

@@ -2450,13 +2449,17 @@ static void __slab_free(struct kmem_cache *s,
struct page *page,
                return;

        do {
+               if (unlikely(n)) {
+                       spin_unlock_irqrestore(&n->list_lock, flags);
+                       n = NULL;
+               }
                prior = page->freelist;
                counters = page->counters;
                set_freepointer(s, object, prior);


>> Case 2. inuse is NULL
>>
>> In this case, acquire_slab() is occured before out free is succeed.
>> We have a last object for slab, so other operation for this slab is
>> not possible except acquire_slab().
>> Acquire_slab() makes a slab frozen, so lock is not needed anymore.
>
> acquire_slab() also requires lock acquisition and would be held of by
> slab_free holding the lock.

See above explain.

>> This also make logic somehow simple that 'was_frozen with a lock' case
>> is never occured. Remove it.
>
> That is actually interesting and would be a good optimization.
>

So, I think patch is valid.
Thanks for comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
