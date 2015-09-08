Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B28646B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 03:52:03 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so105595499wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 00:52:03 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id kz6si4441461wjc.27.2015.09.08.00.52.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 00:52:02 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so104700755wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 00:52:01 -0700 (PDT)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Sep 2015 09:51:41 +0200
Message-ID: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
Subject: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

Hello mm-maintainers,

I have a question about kfree semantics, I can't find answer in docs
and opinions I hear differ.
Namely, is it OK to pass non-acquired objects to
kfree/kmem_cache_free? By non-acquired mean objects unsafely passed
between threads without using proper release/acquire (wmb/rmb) memory
barriers.

The question arose during work on KernelThreadSanitizer, a kernel data
race, and in particular caused by the following existing code:

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
// Here another thread can concurrently append to the buffer list, and
tty_buffer_free eventually calls kfree.

Both these cases don't contain proper memory barrier before handing
off the object to kfree. In my opinion the code should use
smp_load_acquire or READ_ONCE_CTRL ("control-dependnecy-acquire").
Otherwise there can be pending memory accesses to the object in other
threads that can interfere with slab code or the next usage of the
object after reuse.

Paul McKenney suggested that:

"
The maintainers probably want this sort of code to be allowed:
        p->a++;
        if (p->b) {
                kfree(p);
                p =3D NULL;
        }
And the users even more so.
So if the compiler really is free to reorder any scribbling/checking
by the caller with any scribbling/checking by kfree(), that should
be fixed in kfree() rather than in all the callers.
"

This does not look reasonable to me for 2 reasons:
- this incurs unnecessary cost for all kfree users, kfree would have
to execute a memory barrier always while most callers already have the
object acquired (either single-threaded use, or mutex protected, or
the object was properly handed off to the freeing thread)
- as far as I understand if an object is unsafely passed between a
chain of threads A->B->C->D and then the last does kfree, then kfree
can't acquire visibility over the object by executing a memory
barrier. All threads in the chain must play by the rules to properly
hand off the object to kfree.

As far as I understand, that's why atomic_dec_and_test used for
reference counting contains full memory barrier; and also kfree does
not seem to contain any memory barriers on fast path.

Can you please clarify the rules here?

Thank you



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
