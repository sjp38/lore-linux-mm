Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6CC66B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 15:49:05 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w78so3323216oiw.6
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 12:49:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p23si1860571oth.295.2017.11.30.12.49.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 12:49:04 -0800 (PST)
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
 <20171130004252.GR4094@dastard>
 <209d1aea-2951-9d4f-5638-8bc037a6676c@redhat.com>
 <20171130124736.e60c75d120b74314c049c02b@linux-foundation.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <377e9162-3d26-f553-c945-458738ebacf5@redhat.com>
Date: Thu, 30 Nov 2017 15:49:03 -0500
MIME-Version: 1.0
In-Reply-To: <20171130124736.e60c75d120b74314c049c02b@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/30/2017 03:47 PM, Andrew Morton wrote:
> On Thu, 30 Nov 2017 08:54:04 -0500 Waiman Long <longman@redhat.com> wrote:
>
>>> And, from that perspective, the racy shortcut in the proposed patch
>>> is wrong, too. Prefetch is fine, but in general shortcutting list
>>> empty checks outside the internal lock isn't.
>> For the record, I add one more list_empty() check at the beginning of
>> list_lru_del() in the patch for 2 purpose:
>> 1. it allows the code to bail out early.
>> 2. It make sure the cacheline of the list_head entry itself is loaded.
>>
>> Other than that, I only add a likely() qualifier to the existing
>> list_empty() check within the lock critical region.
> But it sounds like Dave thinks that unlocked check should be removed?
>
> How does this adendum look?
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
>
> include prefetch.h, remove unlocked list_empty() test, per Dave
>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Waiman Long <longman@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/list_lru.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff -puN mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix mm/list_lru.c
> --- a/mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
> +++ a/mm/list_lru.c
> @@ -8,6 +8,7 @@
>  #include <linux/module.h>
>  #include <linux/mm.h>
>  #include <linux/list_lru.h>
> +#include <linux/prefetch.h>
>  #include <linux/slab.h>
>  #include <linux/mutex.h>
>  #include <linux/memcontrol.h>
> @@ -135,13 +136,11 @@ bool list_lru_del(struct list_lru *lru,
>  	/*
>  	 * Prefetch the neighboring list entries to reduce lock hold time.
>  	 */
> -	if (unlikely(list_empty(item)))
> -		return false;
>  	prefetchw(item->prev);
>  	prefetchw(item->next);
>  
>  	spin_lock(&nlru->lock);
> -	if (likely(!list_empty(item))) {
> +	if (!list_empty(item)) {
>  		l = list_lru_from_kmem(nlru, item);
>  		list_del_init(item);
>  		l->nr_items--;
> _
>
Yes, that look good to me.

Thanks for fixing that.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
