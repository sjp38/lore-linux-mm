Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3916B025F
	for <linux-mm@kvack.org>; Sun, 29 May 2016 10:57:00 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h68so39705130lfh.2
        for <linux-mm@kvack.org>; Sun, 29 May 2016 07:57:00 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id e11si1047100lji.43.2016.05.29.07.56.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 May 2016 07:56:58 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id k98so63152796lfi.1
        for <linux-mm@kvack.org>; Sun, 29 May 2016 07:56:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20E775CA4D599049A25800DE5799F6DD1F635901@G9W0759.americas.hpqcorp.net>
References: <20160524183018.GA4769@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+ZBSEpqi+aUFdKZk9ncRzAxPpBRLV8DGrEuSWSBNbdpAQ@mail.gmail.com> <20E775CA4D599049A25800DE5799F6DD1F635901@G9W0759.americas.hpqcorp.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 29 May 2016 16:56:38 +0200
Message-ID: <CACT4Y+Yd4kvqg90NsOWPpAc7ijGLfFn2Bn6CTVVDSm07k8eX9w@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm, kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Yury Norov <ynorov@caviumnetworks.com>

On Sun, May 29, 2016 at 4:45 PM, Luruo, Kuthonuzo
<kuthonuzo.luruo@hpe.com> wrote:
>> > +/* flags shadow for object header if it has been overwritten. */
>> > +void kasan_mark_bad_meta(struct kasan_alloc_meta *alloc_info,
>> > +               struct kasan_access_info *info)
>> > +{
>> > +       u8 *datap = (u8 *)&alloc_info->data;
>> > +
>> > +       if ((((u8 *)info->access_addr + info->access_size) > datap) &&
>> > +                       ((u8 *)info->first_bad_addr <= datap) &&
>> > +                       info->is_write)
>> > +               kasan_poison_shadow((void *)datap, KASAN_SHADOW_SCALE_SIZE,
>> > +                               KASAN_KMALLOC_BAD_META);
>>
>>
>> Is it only to prevent deadlocks in kasan_meta_lock?
>>
>> If so, it is still unrelable because an OOB write can happen in
>> non-instrumented code. Or, kasan_meta_lock can successfully lock
>> overwritten garbage before noticing KASAN_KMALLOC_BAD_META. Or, two
>> threads can assume lock ownership after noticing
>> KASAN_KMALLOC_BAD_META.
>>
>> After the first report we continue working in kind of best effort
>> mode: we can try to mitigate some things, but generally all bets are
>> off. Because of that there is no need to build something complex,
>> global (and still unrelable). I would just wait for at most, say, 10
>> seconds in kasan_meta_lock, if we can't get the lock -- print an error
>> and return. That's simple, local and won't deadlock under any
>> circumstances.
>> The error message will be helpful, because there are chances we will
>> report a double-free on free of the corrupted object.
>>  e
>> Tests can be arranged so that they write 0 (unlocked) into the meta
>> (if necessary).
>
> Dmitry,
>
> Thanks very much for review & comments. Yes, the locking scheme in v3
> is flawed in the presence of OOB writes on header, safety valve
> notwithstanding. The core issue is that when thread finds lock held, it is
> difficult to tell whether a legit lock holder exists or lock bit got flipped
> from OOB. Earlier, I did consider a lock timeout but felt it to be a bit ugly...
>
> However, I believe I've found a solution and was about to push out v4
> when your comments came in. It takes concept from v3 - exploiting
> shadow memory - to make lock much more reliable/resilient even in the
> presence of OOB writes. I'll push out v4 within the hour...


Locking shadow will probably work. Need to think more.


>> > +       switch (alloc_info->state) {
>> >                 case KASAN_STATE_QUARANTINE:
>> >                 case KASAN_STATE_FREE:
>> > -                       pr_err("Double free");
>> > -                       dump_stack();
>> > -                       break;
>> > +                       kasan_report((unsigned long)object, 0, false, caller);
>> > +                       kasan_meta_unlock(alloc_info);
>> > +                       return true;
>> >                 default:
>>
>> Please at least print some here (it is not meant to happen, right?).
>
> ok.
>
>> >  struct kasan_alloc_meta {
>> > +       union {
>> > +               u64 data;
>> > +               struct {
>> > +                       u32 lock : 1;           /* lock bit */
>>
>>
>> Add a comment that kasan_meta_lock expects this to be the first bit.
>
> Not required in v4...
>
> Thank you, once again.
>
> Kuthonuzo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
