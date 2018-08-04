Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46AA36B0005
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 14:42:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e14-v6so7010004qtp.17
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 11:42:55 -0700 (PDT)
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60133.outbound.protection.outlook.com. [40.107.6.133])
        by mx.google.com with ESMTPS id y184-v6si774946qkc.216.2018.08.04.11.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 04 Aug 2018 11:42:53 -0700 (PDT)
Subject: Re: [PATCH] mm: Use special value SHRINKER_REGISTERING instead
 list_empty() check
References: <153331055842.22632.9290331685041037871.stgit@localhost.localdomain>
 <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <843169c5-a47a-e6cd-7412-611e72eb20ba@virtuozzo.com>
Date: Sat, 4 Aug 2018 21:42:05 +0300
MIME-Version: 1.0
In-Reply-To: <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04.08.2018 01:51, Andrew Morton wrote:
> On Fri, 03 Aug 2018 18:36:14 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> 
>> The patch introduces a special value SHRINKER_REGISTERING to use instead
>> of list_empty() to detect a semi-registered shrinker.
>>
>> This should be clearer for a reader since "list is empty"  is not
>> an intuitive state of a shrinker), and this gives a better assembler
>> code:
>>
>> Before:
>> callq  <idr_find>
>> mov    %rax,%r15
>> test   %rax,%rax
>> je     <shrink_slab_memcg+0x1d5>
>> mov    0x20(%rax),%rax
>> lea    0x20(%r15),%rdx
>> cmp    %rax,%rdx
>> je     <shrink_slab_memcg+0xbd>
>> mov    0x8(%rsp),%edx
>> mov    %r15,%rsi
>> lea    0x10(%rsp),%rdi
>> callq  <do_shrink_slab>
>>
>> After:
>> callq  <idr_find>
>> mov    %rax,%r15
>> lea    -0x1(%rax),%rax
>> cmp    $0xfffffffffffffffd,%rax
>> ja     <shrink_slab_memcg+0x1cd>
>> mov    0x8(%rsp),%edx
>> mov    %r15,%rsi
>> lea    0x10(%rsp),%rdi
>> callq  ffffffff810cefd0 <do_shrink_slab>
>>
>> Also, improve the comment.
> 
> All this isn't terribly nice.  Why can't we avoid installing the
> shrinker into the idr until it is fully initialized?

This is exactly the thing the patch makes. Instead of inserting a shrinker pointer
to idr, it inserts a fake value SHRINKER_REGISTERING there. The patch makes impossible
to dereference a shrinker unless it's completely registered. 

This value is used in shrink_slab_memcg() to differ a registering shrinker from
unregistered shrinker.

shrink_slab_memcg() clears a bit, when it can't find corresponding shrinker.
We do that, because we don't want to iterate all allocated maps and clear the bit
for each of them when shrinker is unregistering.

But we don't want shrinker_slab_memcg() clears a bit of registering shrinker
since it may be already set by a subsystem, which uses the shrinker, and we
don't want to introduce restrictions on subsystems design.
 
> Or extend the down_write(shrinker_rwsem) coverage so it protects the
> entire initialization, instead of only in the prealloc_memcg_shrinker()
> part of that initialization.  This is not as good - it would be better
> to do all the initialization locklessly then just install the fully
> initialized thing under the lock.

Current code (without patch) uses list_empty() as an indicator of
shrinker is completely registered. And it is changed under shrinekr_rwsem
in register_shrinker_prepared(). list_empty() is just like a flag.
Currently there is no a lockless inserts or races. The patch introduces
another indicator. I'm not sure I understand what you mean, please, clarify.

> 
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -170,6 +170,21 @@ static LIST_HEAD(shrinker_list);
>>  static DECLARE_RWSEM(shrinker_rwsem);
>>  
>>  #ifdef CONFIG_MEMCG_KMEM
>> +
>> +/*
>> + * There is a window between prealloc_shrinker()
>> + * and register_shrinker_prepared(). We don't want
>> + * to clear bit of a shrinker in such the state
>> + * in shrink_slab_memcg(), since this will impose
>> + * restrictions on a code registering a shrinker
>> + * (they would have to guarantee, their LRU lists
>> + * are empty till shrinker is completely registered).
>> + * So, we use this value to detect the situation,
>> + * when id is assigned, but shrinker is not completely
>> + * registered yet.
>> + */
> 
> This comment is still quite hard to understand.  Could you please spend
> a little more time over it?
> 
> 

Ok, I'll introduce better one in v2.


Kirill
