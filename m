Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id D74496B0254
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 10:20:15 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so158973916wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 07:20:15 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id o5si4912527wib.43.2015.09.09.07.20.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 07:20:14 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so23799500wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 07:20:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org>
References: <CACT4Y+Yfz3XvT+w6a3WjcZuATb1b9JdQHHf637zdT=6QZ-hjKg@mail.gmail.com>
 <alpine.DEB.2.11.1509080902190.24606@east.gentwo.org> <CACT4Y+Z9Mggp_iyJbd03yLNRak-ErSyZanEhxb9DS16QCgZNRA@mail.gmail.com>
 <alpine.DEB.2.11.1509081008400.25292@east.gentwo.org> <CACT4Y+Z0xoKGmTMyZVf-jhbDQvcH7aErRBULwXHq3GnAudwO-w@mail.gmail.com>
 <alpine.DEB.2.11.1509081031100.25526@east.gentwo.org> <CACT4Y+bt4mBzQZDTjJDQFtOs463QFUt7-OJWEABCocNzork8Ww@mail.gmail.com>
 <alpine.DEB.2.11.1509081205120.25526@east.gentwo.org> <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
 <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 9 Sep 2015 16:19:54 +0200
Message-ID: <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Wed, Sep 9, 2015 at 4:02 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 8 Sep 2015, Dmitry Vyukov wrote:
>
>> > There is no access to p in the first thread. If there are such accesse=
s
>> > then they are illegal. A user of slab allocators must ensure that ther=
e
>> > are no accesses after freeing the object. And since there is a thread
>> > that  at random checks p and frees it when not NULL then no other thre=
ad
>> > would be allowed to touch the object.
>>
>>
>> But the memory allocator itself (kmalloc/kfree) generally reads and
>> writes the object (e.g. storing object size in header before object,
>> writing redzone in debug mode, reading and checking redzone in debug
>> mode, building freelist using first word of the object, etc). There is
>> no different between user accesses and memory allocator accesses just
>> before returning the object from kmalloc and right after accepting the
>> object in kfree.
>
> There is a difference. The object is not accessible to any code before
> kmalloc() returns. And it must not be accessible anymore when kfree() is =
called.
> Thus the object is under exclusive control of the allocators when it is
> handled.


Yes, the object should not be accessible to other threads when kfree
is called. But in all examples above it is accessible.
For example, in the last example it is still being accessed by
kmalloc. Since there are no memory barriers, kmalloc does not
happen-before kfree, it happens concurrently with kfree, thus memory
accesses from kmalloc and kfree can be intermixed.
It would not be the case on a sequentially consistent
machine/language, but most machines and the implementation language do
not give sequential consistency guarantees.



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
