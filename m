Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4945D6B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 03:07:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so91202262wme.0
        for <linux-mm@kvack.org>; Mon, 09 May 2016 00:07:51 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id rq2si16283888lbb.141.2016.05.09.00.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 00:07:49 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id y84so190377425lfc.0
        for <linux-mm@kvack.org>; Mon, 09 May 2016 00:07:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20E775CA4D599049A25800DE5799F6DD1F62744C@G4W3225.americas.hpqcorp.net>
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <20160507102505.GA27794@yury-N73SV> <20E775CA4D599049A25800DE5799F6DD1F62744C@G4W3225.americas.hpqcorp.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 9 May 2016 09:07:29 +0200
Message-ID: <CACT4Y+YgGp1XxBqSp=V=2KpkcK2r+9fn4tL-S46=Tmi9EB=geA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Cc: Yury Norov <ynorov@caviumnetworks.com>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "glider@google.com" <glider@google.com>, "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "klimov.linux@gmail.com" <klimov.linux@gmail.com>

On Sat, May 7, 2016 at 5:15 PM, Luruo, Kuthonuzo
<kuthonuzo.luruo@hpe.com> wrote:
> Thank you for the review!
>
>> > +
>> > +/* acquire per-object lock for access to KASAN metadata. */
>>
>> I believe there's strong reason not to use standard spin_lock() or
>> similar. I think it's proper place to explain it.
>>
>
> will do.
>
>> > +void kasan_meta_lock(struct kasan_alloc_meta *alloc_info)
>> > +{
>> > +   union kasan_alloc_data old, new;
>> > +
>> > +   preempt_disable();
>>
>> It's better to disable and enable preemption inside the loop
>> on each iteration, to decrease contention.
>>
>
> ok, makes sense; will do.
>
>> > +   for (;;) {
>> > +           old.packed = READ_ONCE(alloc_info->data);
>> > +           if (unlikely(old.lock)) {
>> > +                   cpu_relax();
>> > +                   continue;
>> > +           }
>> > +           new.packed = old.packed;
>> > +           new.lock = 1;
>> > +           if (likely(cmpxchg(&alloc_info->data, old.packed, new.packed)
>> > +                                   == old.packed))
>> > +                   break;
>> > +   }
>> > +}
>> > +
>> > +/* release lock after a kasan_meta_lock(). */
>> > +void kasan_meta_unlock(struct kasan_alloc_meta *alloc_info)
>> > +{
>> > +   union kasan_alloc_data alloc_data;
>> > +
>> > +   alloc_data.packed = READ_ONCE(alloc_info->data);
>> > +   alloc_data.lock = 0;
>> > +   if (unlikely(xchg(&alloc_info->data, alloc_data.packed) !=
>> > +                           (alloc_data.packed | 0x1U)))
>> > +           WARN_ONCE(1, "%s: lock not held!\n", __func__);
>>
>> Nitpick. It never happens in normal case, correct?. Why don't you place it under
>> some developer config, or even leave at dev branch? The function will
>> be twice shorter without it.
>
> ok, will remove/shorten

My concern here is performance.
We do lock/unlock 3 times per allocated object. Currently that's 6
atomic RMW. The unlock one is not necessary, so that would reduce
number of atomic RMWs to 3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
