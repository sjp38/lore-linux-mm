Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0A806B0496
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 05:19:57 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id o19so37212091vkd.7
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 02:19:57 -0700 (PDT)
Received: from mail-vk0-x231.google.com (mail-vk0-x231.google.com. [2607:f8b0:400c:c05::231])
        by mx.google.com with ESMTPS id a73si1055631vke.157.2017.07.10.02.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 02:19:57 -0700 (PDT)
Received: by mail-vk0-x231.google.com with SMTP id 191so43599976vko.2
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 02:19:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1707071816560.20454@east.gentwo.org>
References: <20170707083408.40410-1-glider@google.com> <20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org>
 <alpine.DEB.2.20.1707071816560.20454@east.gentwo.org>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 10 Jul 2017 11:19:55 +0200
Message-ID: <CAG_fn=XGns6jtiD253jMaTH8vLpuYNN=son-4+jDRRvc79ky4Q@mail.gmail.com>
Subject: Re: [PATCH] slub: make sure struct kmem_cache_node is initialized
 before publication
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Sat, Jul 8, 2017 at 1:18 AM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 7 Jul 2017, Andrew Morton wrote:
>
>> On Fri,  7 Jul 2017 10:34:08 +0200 Alexander Potapenko <glider@google.co=
m> wrote:
>>
>> > --- a/mm/slub.c
>> > +++ b/mm/slub.c
>> > @@ -3389,8 +3389,8 @@ static int init_kmem_cache_nodes(struct kmem_cac=
he *s)
>> >                     return 0;
>> >             }
>> >
>> > -           s->node[node] =3D n;
>> >             init_kmem_cache_node(n);
>> > +           s->node[node] =3D n;
>> >     }
>> >     return 1;
>> >  }
>>
>> If this matters then I have bad feelings about free_kmem_cache_nodes():
>
> At creation time the kmem_cache structure is private and no one can run a
> free operation.
>
>> Inviting a use-after-free?  I guess not, as there should be no way
>> to look up these items at this stage.
>
> Right.
>
>> Could the slab maintainers please take a look at these and also have a
>> think about Alexander's READ_ONCE/WRITE_ONCE question?
>
> Was I cced on these?
I've asked Andrew about READ_ONCE privately.
My concern is as follows.
Since unfreeze_partials() sees uninitialized value of n->list_lock, I
was suspecting there's a data race between unfreeze_partials() and
init_kmem_cache_nodes().
If so, reads and writes to s->node[node] must be acquire/release
atomics (not actually READ_ONCE/WRITE_ONCE, but
smp_load_acquire/smp_store_release).




--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
