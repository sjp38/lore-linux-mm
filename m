Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 8E4C06B0033
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 20:52:05 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld11so3785593pab.36
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 17:52:04 -0700 (PDT)
Message-ID: <51E88D6F.3000905@gmail.com>
Date: Fri, 19 Jul 2013 08:50:55 +0800
From: Chen Gang F T <chen.gang.flying.transformer@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: use 'unsigned long' instead of 'int' for variable
 'slub_debug'
References: <51DF5F43.3080408@asianux.com> <0000013fd3283b9c-b5fe217c-fff3-47fd-be0b-31b00faba1f3-000000@email.amazonses.com> <51E33FFE.3010200@asianux.com> <0000013fe2b1bd10-efcc76b5-f75b-4a45-a278-a318e87b2571-000000@email.amazonses.com> <51E49982.30402@asianux.com> <0000013fed18f0f2-cb1afad0-560e-4da5-b865-29e854ce5813-000000@email.amazonses.com> <51E73340.5020703@asianux.com> <0000013ff204c901-636c5864-ec23-4c31-a308-d7fd58016364-000000@email.amazonses.com>
In-Reply-To: <0000013ff204c901-636c5864-ec23-4c31-a308-d7fd58016364-000000@email.amazonses.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Chen Gang <gang.chen@asianux.com>, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org

On 07/18/2013 09:42 PM, Christoph Lameter wrote:
> On Thu, 18 Jul 2013, Chen Gang wrote:
> 
>> On 07/17/2013 10:46 PM, Christoph Lameter wrote:
>>> On Tue, 16 Jul 2013, Chen Gang wrote:
>>>
>>>> If we really use 32-bit as unsigned number, better to use 'U' instead of
>>>> 'UL' (e.g. 0x80000000U instead of 0x80000000UL).
>>>>
>>>> Since it is unsigned 32-bit number, it is better to use 'unsigned int'
>>>> instead of 'int', which can avoid related warnings if "EXTRA_CFLAGS=-W".
>>>
>>> Ok could you go through the kernel source and change that?
>>>
>>
>> Yeah, thanks, I should do it.
>>
>> Hmm... for each case of this issue, it need communicate with (review by)
>> various related maintainers.
>>
>> So, I think one patch for one variable (and related macro contents) is
>> enough.
>>
>> Is it OK ?
> 
> The fundamental issue is that typically ints are used for flags and I
> would like to keep it that way. Changing the constants in slab.h and the
> allocator code to be unsigned int instead of unsigned long wont be that
> much of a deal.
>

At least, we need use 'unsigned' instead of 'signed'.

e.g.
----------------------------diff begin---------------------------------

diff --git a/mm/slub.c b/mm/slub.c
index 2b02d66..7111d7a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -452,9 +452,9 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
  * Debug settings:
  */
 #ifdef CONFIG_SLUB_DEBUG_ON
-static int slub_debug = DEBUG_DEFAULT_FLAGS;
+static unsigned int slub_debug = DEBUG_DEFAULT_FLAGS;
 #else
-static int slub_debug;
+static unsigned int slub_debug;
 #endif
 
 static char *slub_debug_slabs;

----------------------------diff end-----------------------------------
 
> Will the code then be clean enough for you?
> 

Hmm... Things maybe seem more complex, please see bellow:

For 'SLAB_RED_ZONE' (or the other constants), they also can be assigned
to "struct kmem_cache" member variable 'flags'.

But for "struct kmem_cache", it has 2 different definitions, they share
with the 'SLAB_RED_ZONE' (or the other constants).

One defines 'flags' as 'unsigned int' in "include/linux/slab_def.h"

 16 /*
 17  * struct kmem_cache
 18  *
 19  * manages a cache.
 20  */
 21 
 22 struct kmem_cache {
 23 /* 1) Cache tunables. Protected by cache_chain_mutex */
 24         unsigned int batchcount;
 25         unsigned int limit;
 26         unsigned int shared;
 27 
 28         unsigned int size;
 29         u32 reciprocal_buffer_size;
 30 /* 2) touched by every alloc & free from the backend */
 31 
 32         unsigned int flags;             /* constant flags */
 33         unsigned int num;               /* # of objs per slab */
...

The other defines 'flags' as 'unsigned long' in "include/linux/slub_def.h"
(but from its comments, it even says it is for 'Slab' cache management !!)

 65 /*
 66  * Slab cache management.
 67  */
 68 struct kmem_cache {
 69         struct kmem_cache_cpu __percpu *cpu_slab;
 70         /* Used for retriving partial slabs etc */
 71         unsigned long flags;
 72         unsigned long min_partial;
 73         int size;               /* The size of an object including meta data */
 74         int object_size;        /* The size of an object without meta data */
 75         int offset;             /* Free pointer offset. */
 76         int cpu_partial;        /* Number of per cpu partial objects to keep around */
 77         struct kmem_cache_order_objects oo;
...


Maybe it is also related with our discussion ('unsigned int' or 'unsigned long') ?



> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
