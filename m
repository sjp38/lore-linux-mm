Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id E382D6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 09:14:55 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id m35so4315350oik.7
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 06:14:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i131si2173572oih.357.2017.12.01.06.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 06:14:55 -0800 (PST)
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
 <20171130004252.GR4094@dastard>
 <209d1aea-2951-9d4f-5638-8bc037a6676c@redhat.com>
 <20171130124736.e60c75d120b74314c049c02b@linux-foundation.org>
 <20171201000919.GA4439@bbox>
From: Waiman Long <longman@redhat.com>
Message-ID: <84b4b0ea-5e54-a0df-4fee-9892da2bf418@redhat.com>
Date: Fri, 1 Dec 2017 09:14:52 -0500
MIME-Version: 1.0
In-Reply-To: <20171201000919.GA4439@bbox>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/30/2017 07:09 PM, Minchan Kim wrote:
> On Thu, Nov 30, 2017 at 12:47:36PM -0800, Andrew Morton wrote:
>> On Thu, 30 Nov 2017 08:54:04 -0500 Waiman Long <longman@redhat.com> wr=
ote:
>>
>>>> And, from that perspective, the racy shortcut in the proposed patch
>>>> is wrong, too. Prefetch is fine, but in general shortcutting list
>>>> empty checks outside the internal lock isn't.
>>> For the record, I add one more list_empty() check at the beginning of=

>>> list_lru_del() in the patch for 2 purpose:
>>> 1. it allows the code to bail out early.
>>> 2. It make sure the cacheline of the list_head entry itself is loaded=
=2E
>>>
>>> Other than that, I only add a likely() qualifier to the existing
>>> list_empty() check within the lock critical region.
>> But it sounds like Dave thinks that unlocked check should be removed?
>>
>> How does this adendum look?
>>
>> From: Andrew Morton <akpm@linux-foundation.org>
>> Subject: list_lru-prefetch-neighboring-list-entries-before-acquiring-l=
ock-fix
>>
>> include prefetch.h, remove unlocked list_empty() test, per Dave
>>
>> Cc: Dave Chinner <david@fromorbit.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
>> Cc: Waiman Long <longman@redhat.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>>  mm/list_lru.c |    5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff -puN mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-bef=
ore-acquiring-lock-fix mm/list_lru.c
>> --- a/mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-=
acquiring-lock-fix
>> +++ a/mm/list_lru.c
>> @@ -8,6 +8,7 @@
>>  #include <linux/module.h>
>>  #include <linux/mm.h>
>>  #include <linux/list_lru.h>
>> +#include <linux/prefetch.h>
>>  #include <linux/slab.h>
>>  #include <linux/mutex.h>
>>  #include <linux/memcontrol.h>
>> @@ -135,13 +136,11 @@ bool list_lru_del(struct list_lru *lru,
>>  	/*
>>  	 * Prefetch the neighboring list entries to reduce lock hold time.
>>  	 */
>> -	if (unlikely(list_empty(item)))
>> -		return false;
>>  	prefetchw(item->prev);
>>  	prefetchw(item->next);
>> =20
>>  	spin_lock(&nlru->lock);
>> -	if (likely(!list_empty(item))) {
>> +	if (!list_empty(item)) {
>>  		l =3D list_lru_from_kmem(nlru, item);
>>  		list_del_init(item);
>>  		l->nr_items--;
> If we cannot guarantee it's likely !list_empty, prefetch with NULL poin=
ter
> would be harmful by the lesson we have learned.
>
>         https://lwn.net/Articles/444336/

FYI, when list_empty() is true, it just mean the links are pointing to
list entry itself. The pointers will never be NULL. So that won't cause
the NULL prefetch problem mentioned in the article.

> So, with considering list_lru_del is generic library, it cannot see
> whether a workload makes heavy lock contentions or not.
> Maybe, right place for prefetching would be in caller, not in library
> itself.

Yes, the prefetch operations will add some overhead to the whole
deletion operation when the lock isn't contended, but that is usually
rather small compared with the atomic ops involved in the locking
operation itself. On the other hand, the performance gain will be
noticeable when the lock is contended. I will ran some performance
measurement and report the results later.

Cheers,
Longman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
