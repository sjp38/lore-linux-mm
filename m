Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8D26B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 11:23:53 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so119780601wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 08:23:52 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id n12si6451305wik.106.2015.09.08.08.23.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 08:23:52 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so124744444wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 08:23:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
 <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com>
 <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Sep 2015 17:23:31 +0200
Message-ID: <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, Sep 8, 2015 at 5:13 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 8 Sep 2015, Dmitry Vyukov wrote:
>
>> >>
>> >> // kernel/pid.c
>> >>          if ((atomic_read(&pid->count) =3D=3D 1) ||
>> >>               atomic_dec_and_test(&pid->count)) {
>> >>                  kmem_cache_free(ns->pid_cachep, pid);
>> >>                  put_pid_ns(ns);
>> >>          }
>> >
>> > It frees when there the refcount is one? Should this not be
>> >
>> >         if (atomic_read(&pid->count) =3D=3D=3D 0) || ...
>>
>> The code is meant to do decrement of pid->count, but since
>> pid->count=3D=3D1 it figures out that it is the only owner of the object=
,
>> so it just skips the "pid->count--" part and proceeds directly to
>> free.
>
> The atomic_dec_and_test will therefore not be executed for count =3D=3D 1=
?
> Strange code. The atomic_dec_and_test suggests there are concurrency
> concerns. The count test with a simple comparison does not share these
> concerns it seems.

Yes, it skips atomic decrement when counter is equal to 1. This is
relatively common optimization for basic-thread-safety reference
counting (when you can acquire a new reference only when you already
have a one). If counter =3D=3D 1, then the only owner is the current
thread, so other threads cannot change counter concurrently. So there
is no point in doing the atomic decrement (we know that the counter
will go to 0).

>> >> The maintainers probably want this sort of code to be allowed:
>> >>         p->a++;
>> >>         if (p->b) {
>> >>                 kfree(p);
>> >>                 p =3D NULL;
>> >>         }
>> >> And the users even more so.
>> >
>> >
>> > Sure. What would be the problem with the above code? The write to the
>> > object (p->a++) results in exclusive access to a cacheline being obtai=
ned.
>> > So one cpu holds that cacheline. Then the object is freed and reused
>> > either
>>
>> I am not sure what cache line states has to do with it...
>> Anyway, another thread can do p->c++ after this thread does p->a++,
>> then this thread loses its ownership. Or p->c can be located on a
>> separate cache line with p->a. And then we still free the object with
>> a pending write.
>
> The subsystem must ensure no other references exist before a call to free=
.
> So this cannot occur. If it does then these are cases of an object being
> used after free which can be caught by a number of diagnostic tools in th=
e
> kernel.


Yes, this is a case of use-after-free bug. But the use-after-free can
happen only due to memory access reordering in a multithreaded
environment.
OK, here is a simpler code snippet:

void *p; // =3D NULL

// thread 1
p =3D kmalloc(8);

// thread 2
void *r =3D READ_ONCE(p);
if (r !=3D NULL)
    kfree(r);

I would expect that this is illegal code. Is my understanding correct?


--=20
Dmitry Vyukov, Software Engineer, dvyukov@google.com
Google Germany GmbH, Dienerstra=C3=9Fe 12, 80331, M=C3=BCnchen
Gesch=C3=A4ftsf=C3=BChrer: Graham Law, Christine Elizabeth Flores
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat
sind, leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
