Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 354796B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 08:58:00 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id x1so156625152lbj.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:58:00 -0800 (PST)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id qv8si4318000lbb.163.2016.03.11.05.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 05:57:58 -0800 (PST)
Received: by mail-lb0-x22e.google.com with SMTP id xr8so151682406lbb.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:57:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UFB3UYg0-uw4TUJvuvu9ZkqqTKG4enMFMXyWC-q65SeA@mail.gmail.com>
References: <cover.1457519440.git.glider@google.com>
	<14d02da417b3941fd871566e16a164ca4d4ccabc.1457519440.git.glider@google.com>
	<CAPAsAGy3goFXhFZiAarYV3NFZHQOYQxaF324UOJrMCbaZWV7CQ@mail.gmail.com>
	<CAG_fn=UFB3UYg0-uw4TUJvuvu9ZkqqTKG4enMFMXyWC-q65SeA@mail.gmail.com>
Date: Fri, 11 Mar 2016 16:57:58 +0300
Message-ID: <CAPAsAGxM+D9c_VCoL77D9DwZa5gzeO3nRW3tNpwKnuo7fzgJVg@mail.gmail.com>
Subject: Re: [PATCH v5 2/7] mm, kasan: SLAB support
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-11 16:05 GMT+03:00 Alexander Potapenko <glider@google.com>:
> On Fri, Mar 11, 2016 at 12:47 PM, Andrey Ryabinin
> <ryabinin.a.a@gmail.com> wrote:
>> 2016-03-09 14:05 GMT+03:00 Alexander Potapenko <glider@google.com>:
>>
>>> +struct kasan_track {
>>> +       u64 cpu : 6;                    /* for NR_CPUS =3D 64 */
>>
>> What about NR_CPUS > 64 ?
> After a discussion with Dmitry we've decided to drop |cpu| and |when|
> at all, as they do not actually help debugging.
> This way we'll make kasan_track only 8 bytes (4 bytes for PID, 4 bytes
> for stack handle).
> Then the meta structures will be smaller and have nice alignment:
>

Sounds good.

> struct kasan_track {
>         u32 pid;
>         depot_stack_handle_t stack;
> };
>
> struct kasan_alloc_meta {
>         struct kasan_track track;
>         u32 state : 2;  /* enum kasan_state */
>         u32 alloc_size : 30;
>         u32 reserved;  /* we can use it to store an additional stack
> handle, e.g. for debugging RCU */
> };
>
> struct kasan_free_meta {
>         /* This field is used while the object is in the quarantine.
>          * Otherwise it might be used for the allocator freelist.
>          */
>         void **quarantine_link;
>         struct kasan_track track;
> };
>
>
>>> +       u64 pid : 16;                   /* 65536 processes */
>>> +       u64 when : 42;                  /* ~140 years */
>>> +};
>>> +
>
>
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
