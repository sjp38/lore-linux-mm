Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id E995B6B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 16:03:10 -0400 (EDT)
Received: by igui7 with SMTP id i7so19332057igu.0
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 13:03:10 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id d63si4546335ioe.56.2015.08.14.13.03.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Aug 2015 13:03:09 -0700 (PDT)
Received: by igfj19 with SMTP id j19so20188281igf.0
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 13:03:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150810004912.GB645@swordfish>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-3-git-send-email-ddstreet@ieee.org> <20150807063056.GG1891@swordfish>
 <CALZtONATwf7EbWo1RhoNzeYnacCk6A__9Jrtr4UZvV9W-seX7g@mail.gmail.com> <20150810004912.GB645@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 14 Aug 2015 16:02:29 -0400
Message-ID: <CALZtONBwcYXfUx1uw2cWm0wLwFEXm3dEdNytvvwmCtyamHOSnw@mail.gmail.com>
Subject: Re: [PATCH 2/3] zswap: dynamic pool creation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sun, Aug 9, 2015 at 8:49 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> On (08/07/15 10:24), Dan Streetman wrote:
>> > On (08/05/15 09:46), Dan Streetman wrote:
>> > [..]
>> >> -enum comp_op {
>> >> -     ZSWAP_COMPOP_COMPRESS,
>> >> -     ZSWAP_COMPOP_DECOMPRESS
>> >> +struct zswap_pool {
>> >> +     struct zpool *zpool;
>> >> +     struct kref kref;
>> >> +     struct list_head list;
>> >> +     struct rcu_head rcu_head;
>> >> +     struct notifier_block notifier;
>> >> +     char tfm_name[CRYPTO_MAX_ALG_NAME];
>> >
>> > do you need to keep a second CRYPTO_MAX_ALG_NAME copy? shouldn't it
>> > be `tfm->__crt_alg->cra_name`, which is what
>> >         crypto_tfm_alg_name(struct crypto_tfm *tfm)
>> > does?
>>
>> well, we don't absolutely have to keep a copy of tfm_name.  However,
>> ->tfm is a __percpu variable, so each time we want to check the pool's
>> tfm name, we would need to do:
>> crypto_comp_name(this_cpu_ptr(pool->tfm))
>>
>> nothing wrong with that really, just adds a bit more code each time we
>> want to check the tfm name.  I'll send a patch to change it.
>>
>> >
>> >> +     struct crypto_comp * __percpu *tfm;
>> >>  };
>> >
>> > ->tfm will be access pretty often, right? did you intentionally put it
>> > at the bottom offset of `struct zswap_pool'?
>>
>> no it wasn't intentional; does moving it up provide a benefit?
>
> well, I just prefer to keep 'read mostly' pointers together. all
> those cache lines, etc.
>
> gcc 5.1, x86_64
>
>  struct zswap_pool {
>         struct zpool *zpool;
> +       struct crypto_comp * __percpu *tfm;
>         struct kref kref;
>         struct list_head list;
>         struct rcu_head rcu_head;
>         struct notifier_block notifier;
>         char tfm_name[CRYPTO_MAX_ALG_NAME];
> -       struct crypto_comp * __percpu *tfm;
>  };
>
> ../scripts/bloat-o-meter zswap.o.old zswap.o
> add/remove: 0/0 grow/shrink: 0/6 up/down: 0/-27 (-27)
> function                                     old     new   delta
> zswap_writeback_entry                        659     656      -3
> zswap_frontswap_store                       1445    1442      -3
> zswap_frontswap_load                         417     414      -3
> zswap_pool_create                            438     432      -6
> __zswap_cpu_comp_notifier.part               152     146      -6
> __zswap_cpu_comp_notifier                    122     116      -6
>
>
> you know it better ;-)

Ah, well sure that looks better, I'll send a patch (or roll it into a
patch set resend).

Thanks!

>
>
> [..]
>> > this one seems to be used only once. do you want to replace
>> > that single usage (well, if it's really needed)
>>
>> it's actually used twice, in __zswap_pool_empty() and
>> __zswap_param_set().  The next patch adds __zswap_param_set().
>
> Aha, sorry, didn't read the next patch in advance.
>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
