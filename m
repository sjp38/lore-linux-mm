Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E23F6B027E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:44:50 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k200so48170109lfg.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:44:50 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id kq8si45658345wjc.2.2016.04.14.07.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 07:44:48 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id n3so23552373wmn.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:44:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160414134926.GD19990@nuc-i3427.alporthouse.com>
References: <1460444239-22475-1-git-send-email-chris@chris-wilson.co.uk>
	<CACZ9PQV+H+i11E-GEfFeMD3cXWXOF1yPGJH8j7BLXQVqFB3oGw@mail.gmail.com>
	<20160414134926.GD19990@nuc-i3427.alporthouse.com>
Date: Thu, 14 Apr 2016 16:44:48 +0200
Message-ID: <CACZ9PQXCHRC5bFqQKmtOv+GyuEmEaXDVPJdQhBt0sXPfomFTNw@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: Keep a separate lazy-free list
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Roman Peniaev <r.peniaev@gmail.com>, intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Toshi Kani <toshi.kani@hp.com>, Shawn Lin <shawn.lin@rock-chips.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Apr 14, 2016 at 3:49 PM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> On Thu, Apr 14, 2016 at 03:13:26PM +0200, Roman Peniaev wrote:
>> Hi, Chris.
>>
>> Is it made on purpose not to drop VM_LAZY_FREE flag in
>> __purge_vmap_area_lazy()?  With your patch va->flags
>> will have two bits set: VM_LAZY_FREE | VM_LAZY_FREEING.
>> Seems it is not that bad, because all other code paths
>> do not care, but still the change is not clear.
>
> Oh, that was just a bad deletion.
>
>> Also, did you consider to avoid taking static purge_lock
>> in __purge_vmap_area_lazy() ? Because, with your change
>> it seems that you can avoid taking this lock at all.
>> Just be careful when you observe llist as empty, i.e.
>> nr == 0.
>
> I admit I only briefly looked at the lock. I will be honest and say I
> do not fully understand the requirements of the sync/force_flush
> parameters.

if sync:
   o I can wait for other purge in progress
      (do not care if purge_lock is dropped)

   o purge fragmented blocks

if force_flush:
   o even nothing to purge, flush TLB, which is costly.
    (again sync-like is implied)

> purge_fragmented_blocks() manages per-cpu lists, so that looks safe
> under its own rcu_read_lock.
>
> Yes, it looks feasible to remove the purge_lock if we can relax sync.

what is still left is waiting on vmap_area_lock for !sync mode.
but probably is not that bad.

>
>> > @@ -706,6 +703,8 @@ static void purge_vmap_area_lazy(void)
>> >  static void free_vmap_area_noflush(struct vmap_area *va)
>> >  {
>> >         va->flags |= VM_LAZY_FREE;
>> > +       llist_add(&va->purge_list, &vmap_purge_list);
>> > +
>> >         atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
>>
>> it seems to me that this a very long-standing problem: when you mark
>> va->flags as VM_LAZY_FREE, va can be immediately freed from another CPU.
>> If so, the line:
>>
>>     atomic_add((va->va_end - va->va_start)....
>>
>>  does use-after-free access.
>>
>> So I would also fix it with careful line reordering with barrier:
>> (probably barrier is excess here, because llist_add implies cmpxchg,
>>  but I simply want to be explicit here, showing that marking va as
>>  VM_LAZY_FREE and adding it to the list should be at the end)
>>
>> -       va->flags |= VM_LAZY_FREE;
>>         atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
>> +       smp_mb__after_atomic();
>> +       va->flags |= VM_LAZY_FREE;
>> +       llist_add(&va->purge_list, &vmap_purge_list);
>>
>> What do you think?
>
> Yup, it is racy. We can drop the modification of LAZY_FREE/LAZY_FREEING
> to ease one headache, since those bits are not inspected anywhere afaict.

Yes, those flags can be completely dropped.

> Would not using atomic_add_return() be even clearer with respect to
> ordering:
>
>         nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
>                                     &vmap_lazy_nr);
>         llist_add(&va->purge_list, &vmap_purge_list);
>
>         if (unlikely(nr_lazy > lazy_max_pages()))
>                 try_purge_vmap_area_lazy();
>
> Since it doesn't matter that much if we make an extra call to
> try_purge_vmap_area_lazy() when we are on the boundary.

Nice.

--
Roman

> -Chris
>
> --
> Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
