Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02D606B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 08:36:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id y16-v6so1021832pgv.23
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 05:36:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t67-v6si3737604pfd.364.2018.08.08.05.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 05:36:25 -0700 (PDT)
Subject: Re: [PATCH RFC 02/10] mm: Make shrink_slab() lockless
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365626605.19074.16202958374930777592.stgit@localhost.localdomain>
 <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <e6489e38-6f73-2f5d-61b6-ffd1f6462aab@i-love.sakura.ne.jp>
Date: Wed, 8 Aug 2018 21:36:18 +0900
MIME-Version: 1.0
In-Reply-To: <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: mhocko@suse.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/08/08 20:51, Kirill Tkhai wrote:
> @@ -192,7 +193,6 @@ static int prealloc_memcg_shrinker(struct shrinker *shrinker)
>  	int id, ret = -ENOMEM;
>  
>  	down_write(&shrinker_rwsem);
> -	/* This may call shrinker, so it must use down_read_trylock() */
>  	id = idr_alloc(&shrinker_idr, SHRINKER_REGISTERING, 0, 0, GFP_KERNEL);
>  	if (id < 0)
>  		goto unlock;

I don't know why perf reports down_read_trylock(&shrinker_rwsem). But
above code is already bad. GFP_KERNEL allocation involves shrinkers and
the OOM killer would be invoked because shrinkers are defunctional due to
this down_write(&shrinker_rwsem). Please avoid blocking memory allocation
with shrinker_rwsem held.
