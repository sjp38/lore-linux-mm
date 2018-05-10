Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 084FF6B0005
	for <linux-mm@kvack.org>; Thu, 10 May 2018 05:42:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s8-v6so621630pgf.0
        for <linux-mm@kvack.org>; Thu, 10 May 2018 02:42:46 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30122.outbound.protection.outlook.com. [40.107.3.122])
        by mx.google.com with ESMTPS id d21-v6si397583pll.460.2018.05.10.02.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 May 2018 02:42:45 -0700 (PDT)
Subject: Re: [PATCH v4 01/13] mm: Assign id to every memcg-aware shrinker
References: <152586686544.3048.15776787801312398314.stgit@localhost.localdomain>
 <152586701534.3048.9132875744525159636.stgit@localhost.localdomain>
 <20180509155511.9bb3de08b33d617559e5fb3a@linux-foundation.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <799ae1e9-1f16-baf9-6bfa-305f31ae2794@virtuozzo.com>
Date: Thu, 10 May 2018 12:42:37 +0300
MIME-Version: 1.0
In-Reply-To: <20180509155511.9bb3de08b33d617559e5fb3a@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On 10.05.2018 01:55, Andrew Morton wrote:
> On Wed, 09 May 2018 14:56:55 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> 
>> The patch introduces shrinker::id number, which is used to enumerate
>> memcg-aware shrinkers. The number start from 0, and the code tries
>> to maintain it as small as possible.
>>
>> This will be used as to represent a memcg-aware shrinkers in memcg
>> shrinkers map.
>>
>> ...
>>
>> --- a/fs/super.c
>> +++ b/fs/super.c
>> @@ -248,6 +248,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
>>  	s->s_time_gran = 1000000000;
>>  	s->cleancache_poolid = CLEANCACHE_NO_POOL;
>>  
>> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> 
> It would be more conventional to do this logic in Kconfig - define a
> new MEMCG_SHRINKER which equals MEMCG && !SLOB.
> 
> This ifdef occurs a distressing number of times in the patchset :( I
> wonder if there's something we can do about that.
> 
> Also, why doesn't it work with slob?  Please describe the issue in the
> changelogs somewhere.

All currently existing memcg-aware shrinkers are based on list_lru, which
does not introduce separate memcg lists for SLOB case. So, the optimization
made by this patchset is not need there.

I'll make MEMCG_SHRINKER in next version like you suggested. Even if we have
no such shrinkers at the moment, we may have them in the future, and this will
be useful anyway.
 
> It's a pretty big patchset.  I *could* merge it up in the hope that
> someone is planning do do a review soon.  But is there such a person?

Thanks,
Kirill
