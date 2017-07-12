Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id B957F440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 10:11:30 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id g40so8890443uaa.4
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 07:11:30 -0700 (PDT)
Received: from mail-ua0-x231.google.com (mail-ua0-x231.google.com. [2607:f8b0:400c:c08::231])
        by mx.google.com with ESMTPS id v64si866622vkb.146.2017.07.12.07.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 07:11:29 -0700 (PDT)
Received: by mail-ua0-x231.google.com with SMTP id z22so15059184uah.1
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 07:11:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170710133238.2afcda57ea28e020ca03c4f0@linux-foundation.org>
References: <20170707083408.40410-1-glider@google.com> <20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org>
 <alpine.DEB.2.20.1707071816560.20454@east.gentwo.org> <20170710133238.2afcda57ea28e020ca03c4f0@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 12 Jul 2017 16:11:28 +0200
Message-ID: <CAG_fn=WKtQhGfcTxvRgDYnAkOp1acGUmnLyoJRf6syvEL-Yysg@mail.gmail.com>
Subject: Re: [PATCH] slub: make sure struct kmem_cache_node is initialized
 before publication
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi everyone,

On Mon, Jul 10, 2017 at 10:32 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 7 Jul 2017 18:18:31 -0500 (CDT) Christoph Lameter <cl@linux.com> =
wrote:
>
>> On Fri, 7 Jul 2017, Andrew Morton wrote:
>>
>> > On Fri,  7 Jul 2017 10:34:08 +0200 Alexander Potapenko <glider@google.=
com> wrote:
>> >
>> > > --- a/mm/slub.c
>> > > +++ b/mm/slub.c
>> > > @@ -3389,8 +3389,8 @@ static int init_kmem_cache_nodes(struct kmem_c=
ache *s)
>> > >                   return 0;
>> > >           }
>> > >
>> > > -         s->node[node] =3D n;
>> > >           init_kmem_cache_node(n);
>> > > +         s->node[node] =3D n;
>> > >   }
>> > >   return 1;
>> > >  }
>> >
>> > If this matters then I have bad feelings about free_kmem_cache_nodes()=
:
>>
>> At creation time the kmem_cache structure is private and no one can run =
a
>> free operation.
I've double-checked the code path and this turned out to be a false
positive caused by KMSAN not instrumenting the contents of mm/slub.c
(i.e. the initialization of the spinlock remained unnoticed).
Christoph is indeed right that kmem_cache_structure is private, so a
race is not possible here.
I am sorry for the false alarm.
>> > Inviting a use-after-free?  I guess not, as there should be no way
>> > to look up these items at this stage.
>>
>> Right.
>
> Still.   It looks bad, and other sites do these things in the other order=
.
If the maintainers agree the initialization order needs to be fixed,
we'll need to remove the (irrelevant) KMSAN report from the patch
description.
>> > Could the slab maintainers please take a look at these and also have a
>> > think about Alexander's READ_ONCE/WRITE_ONCE question?
>>
>> Was I cced on these?
>
> It's all on linux-mm.



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
