Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 540686B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:54:07 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id c85so2816497oib.13
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:54:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y90si1419058ota.487.2017.11.30.05.54.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 05:54:06 -0800 (PST)
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
 <20171130004252.GR4094@dastard>
From: Waiman Long <longman@redhat.com>
Message-ID: <209d1aea-2951-9d4f-5638-8bc037a6676c@redhat.com>
Date: Thu, 30 Nov 2017 08:54:04 -0500
MIME-Version: 1.0
In-Reply-To: <20171130004252.GR4094@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/29/2017 07:42 PM, Dave Chinner wrote:
> On Wed, Nov 29, 2017 at 01:53:19PM -0800, Andrew Morton wrote:
>> On Wed, 29 Nov 2017 09:17:34 -0500 Waiman Long <longman@redhat.com> wrote:
>>
>>> The list_lru_del() function removes the given item from the LRU list.
>>> The operation looks simple, but it involves writing into the cachelines
>>> of the two neighboring list entries in order to get the deletion done.
>>> That can take a while if the cachelines aren't there yet, thus
>>> prolonging the lock hold time.
>>>
>>> To reduce the lock hold time, the cachelines of the two neighboring
>>> list entries are now prefetched before acquiring the list_lru_node's
>>> lock.
>>>
>>> Using a multi-threaded test program that created a large number
>>> of dentries and then killed them, the execution time was reduced
>>> from 38.5s to 36.6s after applying the patch on a 2-socket 36-core
>>> 72-thread x86-64 system.
>> Patch looks good.
>>
>> Can someone (Dave?) please explain why list_lru_del() supports deletion
>> of an already list_empty(item)?
>> This seems a rather dangerous thing to
>> encourage.  Use cases I can think of are:
>>
>> a) item is already reliably deleted, so why the heck was the caller
>>    calling list_lru_del() and 
> Higher level operations can race. e.g. caller looks up an object,
> finds it on the LRU, takes a reference. Then calls list_lru_del()
> to remove it from the LRU. It blocks 'cause it can't get the list
> lock as....
>
> ... Meanwhile, the list shrinker is running, sees the object on the
> LRU list, sees it has a valid reference count, does lazy LRU cleanup
> by runnning list_lru_isolate() on the object which removes it from
> the LRU list. Eventually it drops the list lock, and ....
>
> ... the original thread gets the lock in list_lru_del() and sees the
> object has already been removed from the LRU....
>
> IOWs, this sort of boilerplate code is potentially dangerous if
> list_lru_del() can't handle items that have already been removed
> from the list:
>
> 	if (!list_empty(&obj->lru))
> 		list_lru_del(&obj->lru);
>
> Because this:
>
> 	if (!list_empty(&obj->lru))
> 		<preempt>
> 		<shrinker removes obj from LRU>
> 		list_lru_del(&obj->lru);
> 			<SPLAT>
>
> Would result in bad things happening....
>
> And, from that perspective, the racy shortcut in the proposed patch
> is wrong, too. Prefetch is fine, but in general shortcutting list
> empty checks outside the internal lock isn't.

For the record, I add one more list_empty() check at the beginning of
list_lru_del() in the patch for 2 purpose:
1. it allows the code to bail out early.
2. It make sure the cacheline of the list_head entry itself is loaded.

Other than that, I only add a likely() qualifier to the existing
list_empty() check within the lock critical region.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
