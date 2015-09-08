Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A06316B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 11:38:02 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so125235912wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 08:38:02 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id dq1si7407044wid.88.2015.09.08.08.38.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 08:38:01 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so120259687wic.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 08:38:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
 <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com>
 <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org> <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com>
 <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Sep 2015 17:37:39 +0200
Message-ID: <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, Sep 8, 2015 at 5:33 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 8 Sep 2015, Dmitry Vyukov wrote:
>
>> Yes, this is a case of use-after-free bug. But the use-after-free can
>> happen only due to memory access reordering in a multithreaded
>> environment.
>> OK, here is a simpler code snippet:
>>
>> void *p; // =3D NULL
>>
>> // thread 1
>> p =3D kmalloc(8);
>>
>> // thread 2
>> void *r =3D READ_ONCE(p);
>> if (r !=3D NULL)
>>     kfree(r);
>>
>> I would expect that this is illegal code. Is my understanding correct?
>
> This should work. It could be a problem if thread 1 is touching
> the object.

What does make it work?
There are clearly memory barriers missing when passing the object
between threads. The typical correct pattern is:

// thread 1
smp_store_release(&p, kmalloc(8));

// thread 2
void *r =3D smp_load_acquire(&p); // or READ_ONCE_CTRL
if (r)
  kfree(r);

Otherwise stores into the object in kmalloc can reach the object when
it is already freed, which is a use-after-free.

What does prevent the use-after-free?



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
