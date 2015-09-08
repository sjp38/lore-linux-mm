Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id EF0826B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 10:41:26 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so122992276wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 07:41:26 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id cv10si1031217wib.81.2015.09.08.07.41.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 07:41:25 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so119607895wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 07:41:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
 <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Sep 2015 16:41:05 +0200
Message-ID: <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, Sep 8, 2015 at 4:13 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 8 Sep 2015, Dmitry Vyukov wrote:
>
>> The question arose during work on KernelThreadSanitizer, a kernel data
>> race, and in particular caused by the following existing code:
>>
>> // kernel/pid.c
>>          if ((atomic_read(&pid->count) =3D=3D 1) ||
>>               atomic_dec_and_test(&pid->count)) {
>>                  kmem_cache_free(ns->pid_cachep, pid);
>>                  put_pid_ns(ns);
>>          }
>
> It frees when there the refcount is one? Should this not be
>
>         if (atomic_read(&pid->count) =3D=3D=3D 0) || ...

The code is meant to do decrement of pid->count, but since
pid->count=3D=3D1 it figures out that it is the only owner of the object,
so it just skips the "pid->count--" part and proceeds directly to
free.

>> //drivers/tty/tty_buffer.c
>> while ((next =3D buf->head->next) !=3D NULL) {
>>      tty_buffer_free(port, buf->head);
>>      buf->head =3D next;
>> }
>> // Here another thread can concurrently append to the buffer list, and
>> tty_buffer_free eventually calls kfree.
>>
>> Both these cases don't contain proper memory barrier before handing
>> off the object to kfree. In my opinion the code should use
>> smp_load_acquire or READ_ONCE_CTRL ("control-dependnecy-acquire").
>> Otherwise there can be pending memory accesses to the object in other
>> threads that can interfere with slab code or the next usage of the
>> object after reuse.
>
> There can be pending reads maybe? But a write would require exclusive
> acccess to the cachelines.
>
>
>> Paul McKenney suggested that:
>>
>> "
>> The maintainers probably want this sort of code to be allowed:
>>         p->a++;
>>         if (p->b) {
>>                 kfree(p);
>>                 p =3D NULL;
>>         }
>> And the users even more so.
>
>
> Sure. What would be the problem with the above code? The write to the
> object (p->a++) results in exclusive access to a cacheline being obtained=
.
> So one cpu holds that cacheline. Then the object is freed and reused
> either

I am not sure what cache line states has to do with it...
Anyway, another thread can do p->c++ after this thread does p->a++,
then this thread loses its ownership. Or p->c can be located on a
separate cache line with p->a. And then we still free the object with
a pending write.

> 1. On the same cpu -> No problem.
>
> 2. On another cpu. This means that a hand off of the pointer to the objec=
t
> occurs in the slab allocators. The hand off involves a spinlock and thus
> implicit barriers. The other processor will acquire exclusive access to
> the cacheline when it initializes the object. At that point the cacheline
> ownership will transfer between the processors.
>



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
