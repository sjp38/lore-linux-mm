Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 719126B000D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:21:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e18so3121967pfi.23
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:21:06 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0132.outbound.protection.outlook.com. [104.47.2.132])
        by mx.google.com with ESMTPS id m13si10522005pgc.35.2018.03.26.08.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 08:21:05 -0700 (PDT)
Subject: Re: [PATCH 02/10] mm: Maintain memcg-aware shrinkers in mcg_shrinkers
 array
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163848990.21546.2153496613786165374.stgit@localhost.localdomain>
 <20180324184516.rogvydnnupr7ah2l@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <448bb904-a861-c2ae-0d3f-427e6a26f61e@virtuozzo.com>
Date: Mon, 26 Mar 2018 18:20:55 +0300
MIME-Version: 1.0
In-Reply-To: <20180324184516.rogvydnnupr7ah2l@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On 24.03.2018 21:45, Vladimir Davydov wrote:
> On Wed, Mar 21, 2018 at 04:21:29PM +0300, Kirill Tkhai wrote:
>> The patch introduces mcg_shrinkers array to keep memcg-aware
>> shrinkers in order of their shrinker::id.
>>
>> This allows to access the shrinkers dirrectly by the id,
>> without iteration over shrinker_list list.
> 
> Why don't you simply use idr instead of ida? With idr you wouldn't need
> the array mapping shrinker id to shrinker ptr. AFAIU you need this
> mapping to look up the shrinker by id in shrink_slab. The latter doesn't
> seem to be a hot path so using idr there should be acceptable. Since we
> already have shrinker_rwsem, which is taken for reading by shrink_slab,
> we wouldn't even need any additional locking for it.

The reason is ida may allocate memory, and since list_lru_add() can't fail,
we can't do that there. If we allocate all the ida memory at the time of
memcg creation (i.e., preallocate it), this is not different to the way
the bitmap makes.

While bitmap has the agvantage, since it's simplest data structure (while
ida has some radix tree overhead).

Also, bitmap does not require a lock, there is single atomic operation
to set or clear a bit, and it scales better, when anything.

Kirill
