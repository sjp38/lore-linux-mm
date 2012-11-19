Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id E4E846B005D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 19:53:47 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id ds1so948277wgb.2
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 16:53:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121116151619.aa60acff.akpm@linux-foundation.org>
References: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
	<1352919432-9699-3-git-send-email-konrad.wilk@oracle.com>
	<20121116151619.aa60acff.akpm@linux-foundation.org>
Date: Mon, 19 Nov 2012 08:53:46 +0800
Message-ID: <CAA_GA1crg1ngNx2MAv-fJbgKYqSKmkapZHq=8F4QcNgFja1A-w@mail.gmail.com>
Subject: Re: [PATCH 2/8] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, mgorman@suse.de, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com

On Sat, Nov 17, 2012 at 7:16 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 14 Nov 2012 13:57:06 -0500
> Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:
>
>> From: Dan Magenheimer <dan.magenheimer@oracle.com>
>>
>> With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
>> built/loaded as modules rather than built-in and enabled by a boot parameter,
>> this patch provides "lazy initialization", allowing backends to register to
>> frontswap even after swapon was run. Before a backend registers all calls
>> to init are recorded and the creation of tmem_pools delayed until a backend
>> registers or until a frontswap put is attempted.
>>
>>
>> ...
>>
>> --- a/mm/frontswap.c
>> +++ b/mm/frontswap.c
>> @@ -80,6 +80,18 @@ static inline void inc_frontswap_succ_stores(void) { }
>>  static inline void inc_frontswap_failed_stores(void) { }
>>  static inline void inc_frontswap_invalidates(void) { }
>>  #endif
>> +
>> +/*
>> + * When no backend is registered all calls to init are registered and
>
> What is "init"?  Spell it out fully, please.
>

I think it's frontswap_init().
swapon will call frontswap_init() and in it we need to call init
function of backends with some parameters
like swap_type.

>> + * remembered but fail to create tmem_pools. When a backend registers with
>> + * frontswap the previous calls to init are executed to create tmem_pools
>> + * and set the respective poolids.
>
> Again, seems really hacky.  Why can't we just change callers so they
> call things in the correct order?
>

I don't think so, because it asynchronous.

The original idea was to make backends like zcache/tmem modularization.
So that it's more convenient and flexible to use and testing.

But currently callers like swapon only invoke frontswap_init() once,
it fail if backend not registered.
We have no way to notify swap to call frontswap_init() again when
backend registered in some random time
 in future.

>> + * While no backend is registered all "puts", "gets" and "flushes" are
>> + * ignored or fail.
>> + */
>> +static DECLARE_BITMAP(need_init, MAX_SWAPFILES);
>> +static bool backend_registered __read_mostly;
>> +
>>  /*
>>   * Register operations for frontswap, returning previous thus allowing
>>   * detection of multiple backends and possible nesting.
>> @@ -87,9 +99,19 @@ static inline void inc_frontswap_invalidates(void) { }
>>  struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
>>  {
>>       struct frontswap_ops old = frontswap_ops;
>> +     int i;
>>
>>       frontswap_ops = *ops;
>>       frontswap_enabled = true;
>> +
>> +     for (i = 0; i < MAX_SWAPFILES; i++) {
>> +             if (test_and_clear_bit(i, need_init))
>
> ooh, that wasn't racy ;)
>

Hmm,  i agree.
Seems some lock is needed, actually i think this code only support one
backend at the same.
So it's less risky.

>> +                     (*frontswap_ops.init)(i);
>> +     }
>> +     /* We MUST have backend_registered called _after_ the frontswap_init's
>> +      * have been called. Otherwise __frontswap_store might fail. */
>
> Comment makes no sense - backend_registered is not a function.
>
> Also, let's lay the comments out conventionally please:
>
>         /*
>          * We MUST have backend_registered called _after_ the frontswap_init's
>          * have been called. Otherwise __frontswap_store might fail.
>          */
>
>
>> +     barrier();
>> +     backend_registered = true;
>>       return old;
>>  }
>>  EXPORT_SYMBOL(frontswap_register_ops);
>>
>> ...
>>
>> @@ -226,12 +266,15 @@ void __frontswap_invalidate_area(unsigned type)
>>  {
>>       struct swap_info_struct *sis = swap_info[type];
>>
>> -     BUG_ON(sis == NULL);
>> -     if (sis->frontswap_map == NULL)
>> -             return;
>> -     frontswap_ops.invalidate_area(type);
>> -     atomic_set(&sis->frontswap_pages, 0);
>> -     memset(sis->frontswap_map, 0, sis->max / sizeof(long));
>> +     if (backend_registered) {
>> +             BUG_ON(sis == NULL);
>> +             if (sis->frontswap_map == NULL)
>> +                     return;
>> +             (*frontswap_ops.invalidate_area)(type);
>> +             atomic_set(&sis->frontswap_pages, 0);
>> +             memset(sis->frontswap_map, 0, sis->max / sizeof(long));
>> +     }
>> +     clear_bit(type, need_init);
>>  }
>>  EXPORT_SYMBOL(__frontswap_invalidate_area);
>>
>> @@ -364,6 +407,9 @@ static int __init init_frontswap(void)
>>       debugfs_create_u64("invalidates", S_IRUGO,
>>                               root, &frontswap_invalidates);
>>  #endif
>> +     bitmap_zero(need_init, MAX_SWAPFILES);
>
> unneeded?
>
>> +     frontswap_enabled = 1;
>>       return 0;
>>  }
>>
>> ...
>>

-- 
Thanks,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
