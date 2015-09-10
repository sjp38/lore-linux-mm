Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 726526B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 05:55:57 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so21277448wic.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 02:55:56 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id kz6si18557242wjc.27.2015.09.10.02.55.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 02:55:56 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so16474747wic.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 02:55:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
References: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
 <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org> <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
 <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org> <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org> <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 10 Sep 2015 11:55:35 +0200
Message-ID: <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, Sep 10, 2015 at 1:31 AM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 9 Sep 2015, Paul E. McKenney wrote:
>
>> Either way, Dmitry's tool got a hit on real code using the slab
>> allocators.  If that hit is a false positive, then clearly Dmitry
>> needs to fix his tool, however, I am not (yet) convinced that it is a
>> false positive.  If it is not a false positive, we might well need to
>> articulate the rules for use of the slab allocators.
>
> Could I get a clear definiton as to what exactly is positive? Was this
> using SLAB, SLUB or SLOB?
>
>> > This would all use per cpu data. As soon as a handoff is required with=
in
>> > the allocators locks are being used. So I would say no.
>>
>> As in "no, it is not necessary for the caller of kfree() to invoke barri=
er()
>> in this example", right?
>
> Actually SLUB contains a barrier already in kfree(). Has to be there
> because of the way the per cpu pointer is being handled.

The positive was reporting of data races in the following code:

// kernel/pid.c
         if ((atomic_read(&pid->count) =3D=3D 1) ||
              atomic_dec_and_test(&pid->count)) {
                 kmem_cache_free(ns->pid_cachep, pid);
                 put_pid_ns(ns);
         }

//drivers/tty/tty_buffer.c
while ((next =3D buf->head->next) !=3D NULL) {
     tty_buffer_free(port, buf->head);
     buf->head =3D next;
}

Namely, the tool reported data races between usage of the object in
other threads before they released the object and kfree.

I am not sure why we are so concentrated on details like SLAB vs SLUB
vs SLOB or cache coherency protocols. This looks like waste of time to
me. General kernel code should not be safe only when working with SLxB
due to current implementation details of SLxB, it should be safe
according to memory allocator contract. And this contract seem to be:
memory allocator can do arbitrary reads and writes to the object
inside of kmalloc and kfree.
Similarly for memory model. There is officially documented kernel
memory model, which all general kernel code must adhere to. Reasoning
about whether a particular piece of code works on architecture X, or
how exactly it can break on architecture Y in unnecessary in such
context. In the end, there can be memory allocator implementation and
new architectures.

My question is about contracts, not about current implementation
details or specific architectures.

There are memory allocator implementations that do reads and writes of
the object, and there are memory allocator implementations that do not
do any barriers on fast paths. From this follows that objects must be
passed in quiescent state to kfree.
Now, kernel memory model says "A load-load control dependency requires
a full read memory barrier".
>From this follows that the following code is broken:

// kernel/pid.c
         if ((atomic_read(&pid->count) =3D=3D 1) ||
              atomic_dec_and_test(&pid->count)) {
                 kmem_cache_free(ns->pid_cachep, pid);
                 put_pid_ns(ns);
         }

and it should be:

// kernel/pid.c
         if ((smp_load_acquire(&pid->count) =3D=3D 1) ||
              atomic_dec_and_test(&pid->count)) {
                 kmem_cache_free(ns->pid_cachep, pid);
                 put_pid_ns(ns);
         }



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
