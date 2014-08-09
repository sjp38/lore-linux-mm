Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id D5A746B0036
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 21:47:01 -0400 (EDT)
Received: by mail-yh0-f49.google.com with SMTP id b6so4643801yha.22
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 18:47:01 -0700 (PDT)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id k58si15430941yho.43.2014.08.08.18.47.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 18:47:01 -0700 (PDT)
Received: by mail-yh0-f44.google.com with SMTP id f73so4747089yha.17
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 18:47:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL3GjrqsixS6U+GYD1pxAOOcXsXbt5XOVC8KhZB+naXAA@mail.gmail.com>
References: <20140808075316.GA21919@www.outflux.net> <CALZtONBNEg7kzUtwKihQuAU48MNh5NjhZcWoOxe-1-vgWqSLiw@mail.gmail.com>
 <CAGXu5jL3GjrqsixS6U+GYD1pxAOOcXsXbt5XOVC8KhZB+naXAA@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 8 Aug 2014 21:46:40 -0400
Message-ID: <CALZtONC5w2Ys5cX3dZQGLvhd8wkSgHoJhY_1cK3jqObhUz3e5w@mail.gmail.com>
Subject: Re: [PATCH] mm/zpool: use prefixed module loading
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Linux-MM <linux-mm@kvack.org>, Vasiliy Kulikov <segoon@openwall.com>

On Fri, Aug 8, 2014 at 8:06 PM, Kees Cook <keescook@chromium.org> wrote:
> On Fri, Aug 8, 2014 at 10:11 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> On Fri, Aug 8, 2014 at 3:53 AM, Kees Cook <keescook@chromium.org> wrote:
>>> To avoid potential format string expansion via module parameters,
>>> do not use the zpool type directly in request_module() without a
>>> format string. Additionally, to avoid arbitrary modules being loaded
>>> via zpool API (e.g. via the zswap_zpool_type module parameter) add a
>>> "zpool-" prefix to the requested module, as well as module aliases for
>>> the existing zpool types (zbud and zsmalloc).
>>>
>>> Signed-off-by: Kees Cook <keescook@chromium.org>
>>> ---
>>>  mm/zbud.c     | 1 +
>>>  mm/zpool.c    | 2 +-
>>>  mm/zsmalloc.c | 1 +
>>>  3 files changed, 3 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/zbud.c b/mm/zbud.c
>>> index a05790b1915e..aa74f7addab1 100644
>>> --- a/mm/zbud.c
>>> +++ b/mm/zbud.c
>>> @@ -619,3 +619,4 @@ module_exit(exit_zbud);
>>>  MODULE_LICENSE("GPL");
>>>  MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
>>>  MODULE_DESCRIPTION("Buddy Allocator for Compressed Pages");
>>> +MODULE_ALIAS("zpool-zbud");
>>
>> If we keep this, I'd recommend putting this inside the #ifdef
>> CONFIG_ZPOOL section, to keep all the zpool stuff together in zbud and
>> zsmalloc.
>>
>>> diff --git a/mm/zpool.c b/mm/zpool.c
>>> index e40612a1df00..739cdf0d183a 100644
>>> --- a/mm/zpool.c
>>> +++ b/mm/zpool.c
>>> @@ -150,7 +150,7 @@ struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops)
>>>         driver = zpool_get_driver(type);
>>>
>>>         if (!driver) {
>>> -               request_module(type);
>>> +               request_module("zpool-%s", type);
>>
>> I agree with a change of (type) to ("%s", type), but what's the need
>> to prefix "zpool-"?  Anyone who has access to modify the
>> zswap_zpool_type parameter is already root and can just as easily load
>> any module they want.  Additionally, the zswap_compressor parameter
>> also runs through request_module() (in crypto/api.c) and could be used
>> to load any kernel module.
>
> Yeah, the "%s" should be the absolute minimum. :)
>
>> I'd prefer to leave out the "zpool-" prefix unless there is a specific
>> reason to include it.
>
> The reason is that the CAP_SYS_MODULE capability is supposed to be
> what controls the loading of arbitrary modules, and that's separate
> permission than changing module parameters via sysfs
> (/sys/modules/...). Which begs the question: maybe those parameters
> shouldn't be writable without CAP_SYS_MODULE? Greg, any thoughts here?
> kobjects don't seem to carry any capabilities checks.

For the current implementation in zswap, those parameters are only
settable at boot time - zswap isn't buildable (currently) as a module,
and those parameters are only processed during zswap init.

So I don't think there's currently any issue, as far as the zswap
module params, with any user being able to loading arbitrary modules.
Besides a user modifying the bootloader configuration, of course.

Even when/if zswap gets updated to be buildable as a module, passing
those parameters during zswap module load would, in itself, require
CAP_SYS_MODULE, since the params are only processed during module
init.

> This is certainly much less serious than letting a non-root user load
> an arbitrary module, but it would be great if we could have a clear
> path to making sure that arbitrary module loading isn't the default
> case here (given this new ability). In the past (netdev module
> loading), a CVE was assigned for a CAP_NET_ADMIN privilege being able
> to load arbitrary modules, so I don't see this as much different.
>
> Ugh, yes, I didn't see the call to crypto_has_comp. Other users of
> this routine use const char arrays, so there wasn't any danger here.
> This would be the first user of the crypto API to expose this via a
> userspace-controlled arbitrary string.
>
> Herbert, what do you think here? I'm concerned we're going to get into
> a situation like we had to deal with for netdev:
>
> http://git.kernel.org/linus/8909c9ad8ff03611c9c96c9a92656213e4bb495b
>
> I think we need to fix zswap now before it gets too far, and likely
> adjust the crypto API to use a module prefix as well. Perhaps we need
> a "crypto-" prefix?

Since (I think) this would only become a problem if/when zswap is
modified to process either zswap_compressor or zswap_zpool_type
outside of module init, maybe a comment would be enough clarifying
that restriction?  To just check CAP_SYS_MODULE if processing either
param outside of module init, if their value doesn't match the
default?


>
> -Kees
>
>>
>>>                 driver = zpool_get_driver(type);
>>>         }
>>>
>>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>>> index 4e2fc83cb394..36af729eb3f6 100644
>>> --- a/mm/zsmalloc.c
>>> +++ b/mm/zsmalloc.c
>>> @@ -1199,3 +1199,4 @@ module_exit(zs_exit);
>>>
>>>  MODULE_LICENSE("Dual BSD/GPL");
>>>  MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
>>> +MODULE_ALIAS("zpool-zsmalloc");
>>> --
>>> 1.9.1
>>>
>>>
>>> --
>>> Kees Cook
>>> Chrome OS Security
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>
>
> --
> Kees Cook
> Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
