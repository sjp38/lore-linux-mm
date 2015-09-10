Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCCB6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:17:47 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so24783180wic.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 06:17:46 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id a16si11568103wiv.112.2015.09.10.06.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 06:17:46 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so24782508wic.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 06:17:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55F17BFE.8080008@suse.cz>
References: <CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
 <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org> <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
 <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org> <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org> <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org> <20150909184415.GJ4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org> <20150909203642.GO4029@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org> <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
 <55F17BFE.8080008@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 10 Sep 2015 15:17:25 +0200
Message-ID: <CACT4Y+bMLZu7uRLESPGPwD3wY2M02xKZgE33TQAkSyW81mF_Xw@mail.gmail.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, Sep 10, 2015 at 2:47 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 09/10/2015 11:55 AM, Dmitry Vyukov wrote:
>> On Thu, Sep 10, 2015 at 1:31 AM, Christoph Lameter <cl@linux.com> wrote:
>>> On Wed, 9 Sep 2015, Paul E. McKenney wrote:
>>>
>>>> Either way, Dmitry's tool got a hit on real code using the slab
>>>> allocators.  If that hit is a false positive, then clearly Dmitry
>>>> needs to fix his tool, however, I am not (yet) convinced that it is a
>>>> false positive.  If it is not a false positive, we might well need to
>>>> articulate the rules for use of the slab allocators.
>>>
>>> Could I get a clear definiton as to what exactly is positive? Was this
>>> using SLAB, SLUB or SLOB?
>>>
>>>> > This would all use per cpu data. As soon as a handoff is required wi=
thin
>>>> > the allocators locks are being used. So I would say no.
>>>>
>>>> As in "no, it is not necessary for the caller of kfree() to invoke bar=
rier()
>>>> in this example", right?
>>>
>>> Actually SLUB contains a barrier already in kfree(). Has to be there
>>> because of the way the per cpu pointer is being handled.
>>
>> The positive was reporting of data races in the following code:
>>
>> // kernel/pid.c
>>          if ((atomic_read(&pid->count) =3D=3D 1) ||
>>               atomic_dec_and_test(&pid->count)) {
>>                  kmem_cache_free(ns->pid_cachep, pid);
>>                  put_pid_ns(ns);
>>          }
>>
>> //drivers/tty/tty_buffer.c
>> while ((next =3D buf->head->next) !=3D NULL) {
>>      tty_buffer_free(port, buf->head);
>>      buf->head =3D next;
>> }
>>
>> Namely, the tool reported data races between usage of the object in
>> other threads before they released the object and kfree.
>>
>
> [...]
>
>> There are memory allocator implementations that do reads and writes of
>> the object, and there are memory allocator implementations that do not
>> do any barriers on fast paths. From this follows that objects must be
>> passed in quiescent state to kfree.
>> Now, kernel memory model says "A load-load control dependency requires
>> a full read memory barrier".
>
> But a load-load dependency is something different than writes from
> kmem_cache_free() being visible before the atomic_read(), right?

Right.
As of now, the code has problem with both reads and writes from kfree
hoisting above the pid->count=3D=3D1 check.
I've just demonstrated the problem for reads.

> So the problem you are seeing is a different one, that some other cpu's a=
re
> still writing to the object after they decrese the count to 1?.

I don't see any actual manifestation of the issue.  Our tool works on
x86, so chances of actual manifestation are pretty low. But the tool
verifies code according to abstract memory model and thus can detect
potential manifestations on ARM, POWER, Alpha or whatever.


>> From this follows that the following code is broken:
>>
>> // kernel/pid.c
>>          if ((atomic_read(&pid->count) =3D=3D 1) ||
>>               atomic_dec_and_test(&pid->count)) {
>>                  kmem_cache_free(ns->pid_cachep, pid);
>>                  put_pid_ns(ns);
>>          }
>>
>> and it should be:
>>
>> // kernel/pid.c
>>          if ((smp_load_acquire(&pid->count) =3D=3D 1) ||
>
> Is that enough? Doesn't it need a pairing smp_store_release?
>
>>               atomic_dec_and_test(&pid->count)) {
>
> A prior release from another thread (that sets the counter to 1) would be=
 done
> by this atomic_dec_and_test() (this all is put_pid() function).
> Does that act as a release? memory-barriers.txt seems to say it does.

Yes, release is required and it is provided by atomic_dec_and_test.


> So yeah your patch seems to be needed and I don't think it should be the =
sl*b
> providing the necessary barrier here. It should be on the refcounting IMH=
O. That
> has the knowledge of correct ordering depending on the pid->count, sl*b h=
as no
> such knowledge.

Thanks for confirmation!
Yes, I completely agree that code that calls kfree must provide
necessary synchronization. It would just massive pessimization if
kfree do barrier.


>>                  kmem_cache_free(ns->pid_cachep, pid);
>>                  put_pid_ns(ns);
>>          }


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
