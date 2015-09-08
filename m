Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 54A556B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 15:25:08 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so126990917wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 12:25:08 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id b8si7794523wiz.119.2015.09.08.12.25.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 12:25:07 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so128977188wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 12:25:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
 <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com>
 <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org> <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com>
 <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org> <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com>
 <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Sep 2015 21:24:46 +0200
Message-ID: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, Sep 8, 2015 at 7:09 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 8 Sep 2015, Dmitry Vyukov wrote:
>
>> >> I would expect that this is illegal code. Is my understanding correct=
?
>> >
>> > This should work. It could be a problem if thread 1 is touching
>> > the object.
>>
>> What does make it work?
>
> The 2nd thread gets the pointer that the first allocated and frees it.
> If there is no more processing then fine.
>
>> There are clearly memory barriers missing when passing the object
>> between threads. The typical correct pattern is:
>
> Why? If thread 2 gets the pointer it frees it. Thats ok.
>
>> // thread 1
>> smp_store_release(&p, kmalloc(8));
>>
>> // thread 2
>> void *r =3D smp_load_acquire(&p); // or READ_ONCE_CTRL
>> if (r)
>>   kfree(r);
>>
>> Otherwise stores into the object in kmalloc can reach the object when
>> it is already freed, which is a use-after-free.
>
> Ok so there is more code executing in thread #1. That changes things.
>>
>> What does prevent the use-after-free?
>
> There is no access to p in the first thread. If there are such accesses
> then they are illegal. A user of slab allocators must ensure that there
> are no accesses after freeing the object. And since there is a thread
> that  at random checks p and frees it when not NULL then no other thread
> would be allowed to touch the object.


But the memory allocator itself (kmalloc/kfree) generally reads and
writes the object (e.g. storing object size in header before object,
writing redzone in debug mode, reading and checking redzone in debug
mode, building freelist using first word of the object, etc). There is
no different between user accesses and memory allocator accesses just
before returning the object from kmalloc and right after accepting the
object in kfree.


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
