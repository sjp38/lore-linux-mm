Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6555D6B026A
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 04:15:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y29so1775174pff.6
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 01:15:12 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0102.outbound.protection.outlook.com. [104.47.1.102])
        by mx.google.com with ESMTPS id h5si3039091pln.249.2017.09.29.01.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Sep 2017 01:15:10 -0700 (PDT)
Subject: Re: [PATCH] mm: Make count list_lru_one::nr_items lockless
References: <150583358557.26700.8490036563698102569.stgit@localhost.localdomain>
 <20170927141530.25286286fb92a2573c4b548f@linux-foundation.org>
 <fbb67bef-c13f-7fcb-fa6a-e3a7f6e5c82b@virtuozzo.com>
 <20170928140230.a9a0cd44a09eae9441a83bdc@linux-foundation.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <137a49f9-8286-8bf4-91c5-37b5f6b5a842@virtuozzo.com>
Date: Fri, 29 Sep 2017 11:15:04 +0300
MIME-Version: 1.0
In-Reply-To: <20170928140230.a9a0cd44a09eae9441a83bdc@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vdavydov.dev@gmail.com, apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com

On 29.09.2017 00:02, Andrew Morton wrote:
> On Thu, 28 Sep 2017 10:48:55 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> 
>>>> This patch aims to make super_cache_count() (and other functions,
>>>> which count LRU nr_items) more effective.
>>>> It allows list_lru_node::memcg_lrus to be RCU-accessed, and makes
>>>> __list_lru_count_one() count nr_items lockless to minimize
>>>> overhead introduced by locking operation, and to make parallel
>>>> reclaims more scalable.
>>>
>>> And...  what were the effects of the patch?  Did you not run the same
>>> performance tests after applying it?
>>
>> I've just detected the such high usage of shrink slab on production node. It's rather
>> difficult to make it use another kernel, than it uses, only kpatches are possible.
>> So, I haven't estimated how it acts on node's performance.
>> On test node I see, that the patch obviously removes raw_spin_lock from perf profile.
>> So, it's a little bit untested in this way.
> 
> Well that's a problem.  The patch increases list_lru.o text size by a
> lot (4800->5696) which will have a cost.  And we don't have proof that
> any benefit is worth that cost.  It shouldn't be too hard to cook up a
> synthetic test to trigger memcg slab reclaim and then run a
> before-n-after benchmark?

Ok, then, please, ignore this for a while, I'll try to do it a little bit later.

Kirill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
