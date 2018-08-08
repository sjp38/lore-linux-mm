Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3FE6B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 08:51:20 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u68-v6so2139705qku.5
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 05:51:20 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0127.outbound.protection.outlook.com. [104.47.1.127])
        by mx.google.com with ESMTPS id r77-v6si460904qke.292.2018.08.08.05.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Aug 2018 05:51:19 -0700 (PDT)
Subject: Re: [PATCH RFC 02/10] mm: Make shrink_slab() lockless
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365626605.19074.16202958374930777592.stgit@localhost.localdomain>
 <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
 <e6489e38-6f73-2f5d-61b6-ffd1f6462aab@i-love.sakura.ne.jp>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <411e77ce-90a6-8af6-dd57-bd3b6804beff@virtuozzo.com>
Date: Wed, 8 Aug 2018 15:51:11 +0300
MIME-Version: 1.0
In-Reply-To: <e6489e38-6f73-2f5d-61b6-ffd1f6462aab@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vdavydov.dev@gmail.com

On 08.08.2018 15:36, Tetsuo Handa wrote:
> On 2018/08/08 20:51, Kirill Tkhai wrote:
>> @@ -192,7 +193,6 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
>>  	int id, ret = -ENOMEM;
>>  
>>  	down_write(&shrinker_rwsem);
>> -	/* This may call shrinker, so it must use down_read_trylock() */
>>  	id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
>>  	if (id < 0)
>>  		goto unlock;
> 
> I don't know why perf reports down_read_trylock(&shrinker_rwsem).

This happens in the case of many cgroups and mounts on node. This
is often happen on the big machines with containers.

> But above code is already bad. GFP_KERNEL allocation involves shrinkers and
> the OOM killer would be invoked because shrinkers are defunctional due to
> this down_write(&shrinker_rwsem). Please avoid blocking memory allocation
> with shrinker_rwsem held.

There was non-blocking allocation in first versions of the patchset,
but it's gone away in the process of the review (CC Vladimir).

There are still pages lists shrinkers in case of shrink_slab() is
not available, while additional locks makes the code more difficult
and not worth this difficulties.

Kirill
