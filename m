Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B1E386B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 21:11:19 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 65so184873937pff.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 18:11:19 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id h78si77207041pfd.42.2016.01.05.18.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 18:11:19 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id yy13so132166383pab.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 18:11:19 -0800 (PST)
Subject: Re: [RFC][PATCH 5/7] mm: Mark several cases as SLAB_NO_SANITIZE
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-6-git-send-email-laura@labbott.name>
 <CAGXu5jLF8WTQDEh+-M7_8pZUCEG0FVw1e1PS7Ew4EBy+hXdD_w@mail.gmail.com>
From: Laura Abbott <laura@labbott.name>
Message-ID: <568C77C5.2090003@labbott.name>
Date: Tue, 5 Jan 2016 18:11:17 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLF8WTQDEh+-M7_8pZUCEG0FVw1e1PS7Ew4EBy+hXdD_w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 1/5/16 4:21 PM, Kees Cook wrote:
> On Mon, Dec 21, 2015 at 7:40 PM, Laura Abbott <laura@labbott.name> wrote:
>>
>> Sanitization is useful for security but comes at the cost of performance
>> in clearing on free. Mark select caches as SLAB_NO_SANITIZE so
>> sanitization will not happen under the default configuration. The
>
> Can you describe why these were selected?
>

These were the cases that existed in grsecurity. From looking, these seem
to be performance critical caches that have a relatively lower risk. I'll
adjust the commit text.

>> kernel may be booted with the proper command line option to allow these
>> caches to be sanitized.
>
> Might be good to specifically mention the command line used to
> sanitize even these caches.

Sure.

>
> -Kees

Thanks,
Laura

>
>>
>> All credit for the original work should be given to Brad Spengler and
>> the PaX Team.
>>
>> Signed-off-by: Laura Abbott <laura@labbott.name>
>> ---
>> This is the initial set of excludes that the grsecurity patches had.
>> More may need to be added/removed as the series is tested.
>> ---
>>   fs/buffer.c       |  2 +-
>>   fs/dcache.c       |  2 +-
>>   kernel/fork.c     |  2 +-
>>   mm/rmap.c         |  4 ++--
>>   mm/slab.h         |  2 +-
>>   net/core/skbuff.c | 16 ++++++++--------
>>   6 files changed, 14 insertions(+), 14 deletions(-)
>>
>> diff --git a/fs/buffer.c b/fs/buffer.c
>> index 4f4cd95..f19e4ab 100644
>> --- a/fs/buffer.c
>> +++ b/fs/buffer.c
>> @@ -3417,7 +3417,7 @@ void __init buffer_init(void)
>>          bh_cachep = kmem_cache_create("buffer_head",
>>                          sizeof(struct buffer_head), 0,
>>                                  (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
>> -                               SLAB_MEM_SPREAD),
>> +                               SLAB_MEM_SPREAD|SLAB_NO_SANITIZE),
>>                                  NULL);
>>
>>          /*
>> diff --git a/fs/dcache.c b/fs/dcache.c
>> index 5c33aeb..470f6be 100644
>> --- a/fs/dcache.c
>> +++ b/fs/dcache.c
>> @@ -3451,7 +3451,7 @@ void __init vfs_caches_init_early(void)
>>   void __init vfs_caches_init(void)
>>   {
>>          names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
>> -                       SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>> +                       SLAB_NO_SANITIZE|SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>>
>>          dcache_init();
>>          inode_init();
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index fce002e..35db9c3 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -1868,7 +1868,7 @@ void __init proc_caches_init(void)
>>          mm_cachep = kmem_cache_create("mm_struct",
>>                          sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
>>                          SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
>> -       vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC);
>> +       vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_NO_SANITIZE);
>>          mmap_init();
>>          nsproxy_cache_init();
>>   }
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index b577fbb..74296d9 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -428,8 +428,8 @@ static void anon_vma_ctor(void *data)
>>   void __init anon_vma_init(void)
>>   {
>>          anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
>> -                       0, SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_ctor);
>> -       anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain, SLAB_PANIC);
>> +               0, SLAB_DESTROY_BY_RCU|SLAB_PANIC|SLAB_NO_SANITIZE, anon_vma_ctor);
>> +       anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain, SLAB_PANIC|SLAB_NO_SANITIZE);
>>   }
>>
>>   /*
>> diff --git a/mm/slab.h b/mm/slab.h
>> index b54b636..6de99da 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -137,7 +137,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>>
>>   /* Legal flag mask for kmem_cache_create(), for various configurations */
>>   #define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | SLAB_PANIC | \
>> -                        SLAB_DESTROY_BY_RCU | SLAB_DEBUG_OBJECTS )
>> +                        SLAB_DESTROY_BY_RCU | SLAB_DEBUG_OBJECTS | SLAB_NO_SANITIZE)
>>
>>   #if defined(CONFIG_DEBUG_SLAB)
>>   #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index b2df375..1d499ea 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3316,15 +3316,15 @@ done:
>>   void __init skb_init(void)
>>   {
>>          skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
>> -                                             sizeof(struct sk_buff),
>> -                                             0,
>> -                                             SLAB_HWCACHE_ALIGN|SLAB_PANIC,
>> -                                             NULL);
>> +                               sizeof(struct sk_buff),
>> +                               0,
>> +                               SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NO_SANITIZE,
>> +                               NULL);
>>          skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
>> -                                               sizeof(struct sk_buff_fclones),
>> -                                               0,
>> -                                               SLAB_HWCACHE_ALIGN|SLAB_PANIC,
>> -                                               NULL);
>> +                               sizeof(struct sk_buff_fclones),
>> +                               0,
>> +                               SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NO_SANITIZE,
>> +                               NULL);
>>   }
>>
>>   /**
>> --
>> 2.5.0
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
