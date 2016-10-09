Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC9BC6B0069
	for <linux-mm@kvack.org>; Sat,  8 Oct 2016 23:43:54 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x23so20156065lfi.0
        for <linux-mm@kvack.org>; Sat, 08 Oct 2016 20:43:54 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id s192si13468350lfe.215.2016.10.08.20.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Oct 2016 20:43:52 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id l131so4635755lfl.0
        for <linux-mm@kvack.org>; Sat, 08 Oct 2016 20:43:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160929081818.GE28107@nuc-i3427.alporthouse.com>
References: <20160929073411.3154-1-jszhang@marvell.com> <20160929081818.GE28107@nuc-i3427.alporthouse.com>
From: Joel Fernandes <agnel.joel@gmail.com>
Date: Sat, 8 Oct 2016 20:43:51 -0700
Message-ID: <CAD=GYpYKL9=uY=Fks2xO6oK3bJ772yo4EiJ1tJkVU9PheSD+Cw@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: reduce the number of lazy_max_pages to reduce latency
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Jisheng Zhang <jszhang@marvell.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, rientjes@google.com, iamjoonsoo.kim@lge.com, npiggin@kernel.dk, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM Kernel List <linux-arm-kernel@lists.infradead.org>

On Thu, Sep 29, 2016 at 1:18 AM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> On Thu, Sep 29, 2016 at 03:34:11PM +0800, Jisheng Zhang wrote:
>> On Marvell berlin arm64 platforms, I see the preemptoff tracer report
>> a max 26543 us latency at __purge_vmap_area_lazy, this latency is an
>> awfully bad for STB. And the ftrace log also shows __free_vmap_area
>> contributes most latency now. I noticed that Joel mentioned the same
>> issue[1] on x86 platform and gave two solutions, but it seems no patch
>> is sent out for this purpose.
>>
>> This patch adopts Joel's first solution, but I use 16MB per core
>> rather than 8MB per core for the number of lazy_max_pages. After this
>> patch, the preemptoff tracer reports a max 6455us latency, reduced to
>> 1/4 of original result.
>
> My understanding is that
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 91f44e78c516..3f7c6d6969ac 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -626,7 +626,6 @@ void set_iounmap_nonlazy(void)
>  static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>                                         int sync, int force_flush)
>  {
> -       static DEFINE_SPINLOCK(purge_lock);
>         struct llist_node *valist;
>         struct vmap_area *va;
>         struct vmap_area *n_va;
> @@ -637,12 +636,6 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>          * should not expect such behaviour. This just simplifies locking for
>          * the case that isn't actually used at the moment anyway.
>          */
> -       if (!sync && !force_flush) {
> -               if (!spin_trylock(&purge_lock))
> -                       return;
> -       } else
> -               spin_lock(&purge_lock);
> -
>         if (sync)
>                 purge_fragmented_blocks_allcpus();
>
> @@ -667,7 +660,6 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
>                         __free_vmap_area(va);
>                 spin_unlock(&vmap_area_lock);
>         }
> -       spin_unlock(&purge_lock);
>  }
>
[..]
> should now be safe. That should significantly reduce the preempt-disabled
> section, I think.

I believe that the purge_lock is supposed to prevent concurrent purges
from happening.

For the case where if you have another concurrent overflow happen in
alloc_vmap_area() between the spin_unlock and purge :

spin_unlock(&vmap_area_lock);
if (!purged)
   purge_vmap_area_lazy();

Then the 2 purges would happen at the same time and could subtract
vmap_lazy_nr twice.

I had proposed to change it to mutex in [1]. How do you feel about
that? Let me know your suggestions, thanks. I am also Ok with reducing
the lazy_max_pages value.

[1] http://lkml.iu.edu/hypermail/linux/kernel/1603.2/04803.html

Regards,
Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
