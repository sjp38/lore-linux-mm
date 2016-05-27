Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id B46C46B0253
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:15:18 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id rs7so57362977lbb.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:15:18 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com. [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id f22si4361359lji.23.2016.05.27.10.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:15:17 -0700 (PDT)
Received: by mail-lb0-x233.google.com with SMTP id k7so33226627lbm.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:15:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UYn=0BBNhqS_O97WF64Dwv2jpuV-bt_CEgWdq_vje25A@mail.gmail.com>
References: <CAG_fn=UYn=0BBNhqS_O97WF64Dwv2jpuV-bt_CEgWdq_vje25A@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 27 May 2016 19:15:16 +0200
Message-ID: <CAG_fn=UpmYka1w_TW=OYknDkqAx2eiXGmFuNdPzzQy97exAQjw@mail.gmail.com>
Subject: Re: Value of page->slab_cache in objects allocated from a cache?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

On Fri, May 27, 2016 at 12:04 PM, Alexander Potapenko <glider@google.com> w=
rote:
> Hi everyone,
>
> I'm debugging some crashes in the KASAN quarantine, and I've noticed
> that for certain objects something which I assumed to be invariant
> does not hold.
>
> In particular, my understanding was that for an object returned by
> kmem_cache_zalloc(cache, gfp_flags) the value of
> virt_to_page(object)->slab_cache must be always equal to |cache|.

Sent out a patch for this ("[mm] Set page->slab_cache for every page
allocated for a kmem_cache.")

> However this isn't true for at least idr_free_cache in lib/idr.c
> If I apply the attached patch, build a x86_64 kernel with defconfig,
> and run the resulting kernel in QEMU, I get the following log:
>
> [    0.007022] HERE: lib/idr.c:198 allocated ffff88001ddc8008 from
> idr_layer_cache
> [    0.007478] idr_layer_cache: ffff88001dc0b6c0, slab_cache: ffff88001dc=
0b6c0
> [    0.007920] HERE: lib/idr.c:198 allocated ffff88001ddcf1a8 from
> idr_layer_cache
> [    0.008002] idr_layer_cache: ffff88001dc0b6c0, slab_cache:           (=
null)
> [    0.008445] ------------[ cut here ]------------
> [    0.008791] kernel BUG at lib/idr.c:200!
>
> Am I misunderstanding the purpose of slab_cache in struct page, or is
> there really a bug in initializing it?
>
> Thanks,
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



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
