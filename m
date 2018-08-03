Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 439066B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 18:51:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m2-v6so4038054plt.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 15:51:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x16-v6si5700619pgf.311.2018.08.03.15.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 15:51:21 -0700 (PDT)
Date: Fri, 3 Aug 2018 15:51:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Use special value SHRINKER_REGISTERING instead
 list_empty() check
Message-Id: <20180803155120.0d65511b46c100565b4f8a2c@linux-foundation.org>
In-Reply-To: <153331055842.22632.9290331685041037871.stgit@localhost.localdomain>
References: <153331055842.22632.9290331685041037871.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 03 Aug 2018 18:36:14 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> The patch introduces a special value SHRINKER_REGISTERING to use instead
> of list_empty() to detect a semi-registered shrinker.
> 
> This should be clearer for a reader since "list is empty"  is not
> an intuitive state of a shrinker), and this gives a better assembler
> code:
> 
> Before:
> callq  <idr_find>
> mov    %rax,%r15
> test   %rax,%rax
> je     <shrink_slab_memcg+0x1d5>
> mov    0x20(%rax),%rax
> lea    0x20(%r15),%rdx
> cmp    %rax,%rdx
> je     <shrink_slab_memcg+0xbd>
> mov    0x8(%rsp),%edx
> mov    %r15,%rsi
> lea    0x10(%rsp),%rdi
> callq  <do_shrink_slab>
> 
> After:
> callq  <idr_find>
> mov    %rax,%r15
> lea    -0x1(%rax),%rax
> cmp    $0xfffffffffffffffd,%rax
> ja     <shrink_slab_memcg+0x1cd>
> mov    0x8(%rsp),%edx
> mov    %r15,%rsi
> lea    0x10(%rsp),%rdi
> callq  ffffffff810cefd0 <do_shrink_slab>
> 
> Also, improve the comment.

All this isn't terribly nice.  Why can't we avoid installing the
shrinker into the idr until it is fully initialized?

Or extend the down_write(shrinker_rwsem) coverage so it protects the
entire initialization, instead of only in the prealloc_memcg_shrinker()
part of that initialization.  This is not as good - it would be better
to do all the initialization locklessly then just install the fully
initialized thing under the lock.

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -170,6 +170,21 @@ static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>  
>  #ifdef CONFIG_MEMCG_KMEM
> +
> +/*
> + * There is a window between prealloc_shrinker()
> + * and register_shrinker_prepared(). We don't want
> + * to clear bit of a shrinker in such the state
> + * in shrink_slab_memcg(), since this will impose
> + * restrictions on a code registering a shrinker
> + * (they would have to guarantee, their LRU lists
> + * are empty till shrinker is completely registered).
> + * So, we use this value to detect the situation,
> + * when id is assigned, but shrinker is not completely
> + * registered yet.
> + */

This comment is still quite hard to understand.  Could you please spend
a little more time over it?
