Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF5AD6B025E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:14:34 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fg3so349089620obb.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:14:34 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id jx3si8555754oeb.82.2016.04.25.14.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 14:14:34 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id r78so190777818oie.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:14:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJcbSZG4wcW=nKSjuzyZpkvTSwYn1eyAok0QtXsgDLyjARz=ig@mail.gmail.com>
References: <1461616763-60246-1-git-send-email-thgarnie@google.com>
	<20160425141046.d14466272ea246dd0374ea43@linux-foundation.org>
	<CAJcbSZG4wcW=nKSjuzyZpkvTSwYn1eyAok0QtXsgDLyjARz=ig@mail.gmail.com>
Date: Mon, 25 Apr 2016 14:14:33 -0700
Message-ID: <CAJcbSZGCywmo_hUCE1DAcPjr0FHcMm0ewAVkCH9jRecmJZBtZQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: SLAB freelist randomization
From: Thomas Garnier <thgarnie@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kees Cook <keescook@chromium.org>, Greg Thelen <gthelen@google.com>, Laura Abbott <labbott@fedoraproject.org>, kernel-hardening@lists.openwall.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Apr 25, 2016 at 2:13 PM, Thomas Garnier <thgarnie@google.com> wrote:
> On Mon, Apr 25, 2016 at 2:10 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Mon, 25 Apr 2016 13:39:23 -0700 Thomas Garnier <thgarnie@google.com> wrote:
>>
>>> Provides an optional config (CONFIG_FREELIST_RANDOM) to randomize the
>>> SLAB freelist. The list is randomized during initialization of a new set
>>> of pages. The order on different freelist sizes is pre-computed at boot
>>> for performance. Each kmem_cache has its own randomized freelist except
>>> early on boot where global lists are used. This security feature reduces
>>> the predictability of the kernel SLAB allocator against heap overflows
>>> rendering attacks much less stable.
>>>
>>> For example this attack against SLUB (also applicable against SLAB)
>>> would be affected:
>>> https://jon.oberheide.org/blog/2010/09/10/linux-kernel-can-slub-overflow/
>>>
>>> Also, since v4.6 the freelist was moved at the end of the SLAB. It means
>>> a controllable heap is opened to new attacks not yet publicly discussed.
>>> A kernel heap overflow can be transformed to multiple use-after-free.
>>> This feature makes this type of attack harder too.
>>>
>>> To generate entropy, we use get_random_bytes_arch because 0 bits of
>>> entropy is available in the boot stage. In the worse case this function
>>> will fallback to the get_random_bytes sub API. We also generate a shift
>>> random number to shift pre-computed freelist for each new set of pages.
>>>
>>> The config option name is not specific to the SLAB as this approach will
>>> be extended to other allocators like SLUB.
>>>
>>> Performance results highlighted no major changes:
>>>
>>> slab_test 1 run on boot. Difference only seen on the 2048 size test
>>> being the worse case scenario covered by freelist randomization. New
>>> slab pages are constantly being created on the 10000 allocations.
>>> Variance should be mainly due to getting new pages every few
>>> allocations.
>>>
>>> ...
>>>
>>> --- a/include/linux/slab_def.h
>>> +++ b/include/linux/slab_def.h
>>> @@ -80,6 +80,10 @@ struct kmem_cache {
>>>       struct kasan_cache kasan_info;
>>>  #endif
>>>
>>> +#ifdef CONFIG_FREELIST_RANDOM
>>
>> CONFIG_FREELIST_RANDOM bugs me a bit - "freelist" is so vague.
>> CONFIG_SLAB_FREELIST_RANDOM would be better.  I mean, what Kconfig
>> identifier could be used for implementing randomisation in
>> slub/slob/etc once CONFIG_FREELIST_RANDOM is used up?
>>
>>> +     void *random_seq;
>>> +#endif
>>> +
>>>       struct kmem_cache_node *node[MAX_NUMNODES];
>>>  };
>>>
>>> diff --git a/init/Kconfig b/init/Kconfig
>>> index 0c66640..73453d0 100644
>>> --- a/init/Kconfig
>>> +++ b/init/Kconfig
>>> @@ -1742,6 +1742,15 @@ config SLOB
>>>
>>>  endchoice
>>>
>>> +config FREELIST_RANDOM
>>> +     default n
>>> +     depends on SLAB
>>> +     bool "SLAB freelist randomization"
>>> +     help
>>> +       Randomizes the freelist order used on creating new SLABs. This
>>> +       security feature reduces the predictability of the kernel slab
>>> +       allocator against heap overflows.
>>> +
>>>  config SLUB_CPU_PARTIAL
>>>       default y
>>>       depends on SLUB && SMP
>>> diff --git a/mm/slab.c b/mm/slab.c
>>> index b82ee6b..89eb617 100644
>>> --- a/mm/slab.c
>>> +++ b/mm/slab.c
>>> @@ -116,6 +116,7 @@
>>>  #include     <linux/kmemcheck.h>
>>>  #include     <linux/memory.h>
>>>  #include     <linux/prefetch.h>
>>> +#include     <linux/log2.h>
>>>
>>>  #include     <net/sock.h>
>>>
>>> @@ -1230,6 +1231,100 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
>>>       }
>>>  }
>>>
>>> +#ifdef CONFIG_FREELIST_RANDOM
>>> +static void freelist_randomize(struct rnd_state *state, freelist_idx_t *list,
>>> +                     size_t count)
>>> +{
>>> +     size_t i;
>>> +     unsigned int rand;
>>> +
>>> +     for (i = 0; i < count; i++)
>>> +             list[i] = i;
>>> +
>>> +     /* Fisher-Yates shuffle */
>>> +     for (i = count - 1; i > 0; i--) {
>>> +             rand = prandom_u32_state(state);
>>> +             rand %= (i + 1);
>>> +             swap(list[i], list[rand]);
>>> +     }
>>> +}
>>> +
>>> +/* Create a random sequence per cache */
>>> +static void cache_random_seq_create(struct kmem_cache *cachep)
>>> +{
>>> +     unsigned int seed, count = cachep->num;
>>> +     struct rnd_state state;
>>> +
>>> +     if (count < 2)
>>> +             return;
>>> +
>>> +     cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), GFP_KERNEL);
>>> +     BUG_ON(cachep->random_seq == NULL);
>
> On your previous email. (trying to stay in one thread). I added a
> comment on this
> version to explain that we need best entropy at this boot stage.
>
>>
>> Yikes, that's a bit rude.  Is there no way of recovering from this?  If
>> the answer to that is really really "no" then I guess we should put a
>> __GFP_NOFAIL in there.  Add a comment explaining why (apologetically -
>> __GFP_NOFAIL is unpopular!) and remove the now-unneeded BUG_ON.
>>
>>
>
> We can always use the static. I will update on next iteration to remove the
> BUG_ON.
>
>>> +     /* Get best entropy at this stage */
>>> +     get_random_bytes_arch(&seed, sizeof(seed));
>>
>> See concerns in other email - isn't this a no-op if CONFIG_ARCH_RANDOM=n?
>>

The arch_* functions will return 0 which will break the loop in
get_random_bytes_arch and make it uses extract_entropy (as does
get_random_bytes).
(cf http://lxr.free-electrons.com/source/drivers/char/random.c#L1335)

I might be missing something.

>
>
>>
>>> +     prandom_seed_state(&state, seed);
>>> +
>>> +     freelist_randomize(&state, cachep->random_seq, count);
>>> +}
>>> +
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
