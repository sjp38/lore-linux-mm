Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B08E06B0256
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 08:05:46 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so16842780wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:05:46 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id cu9si10956868wjc.53.2016.03.11.05.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 05:05:45 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id p65so17272122wmp.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:05:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGy3goFXhFZiAarYV3NFZHQOYQxaF324UOJrMCbaZWV7CQ@mail.gmail.com>
References: <cover.1457519440.git.glider@google.com>
	<14d02da417b3941fd871566e16a164ca4d4ccabc.1457519440.git.glider@google.com>
	<CAPAsAGy3goFXhFZiAarYV3NFZHQOYQxaF324UOJrMCbaZWV7CQ@mail.gmail.com>
Date: Fri, 11 Mar 2016 14:05:45 +0100
Message-ID: <CAG_fn=UFB3UYg0-uw4TUJvuvu9ZkqqTKG4enMFMXyWC-q65SeA@mail.gmail.com>
Subject: Re: [PATCH v5 2/7] mm, kasan: SLAB support
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 11, 2016 at 12:47 PM, Andrey Ryabinin
<ryabinin.a.a@gmail.com> wrote:
> 2016-03-09 14:05 GMT+03:00 Alexander Potapenko <glider@google.com>:
>
>> +struct kasan_track {
>> +       u64 cpu : 6;                    /* for NR_CPUS =3D 64 */
>
> What about NR_CPUS > 64 ?
After a discussion with Dmitry we've decided to drop |cpu| and |when|
at all, as they do not actually help debugging.
This way we'll make kasan_track only 8 bytes (4 bytes for PID, 4 bytes
for stack handle).
Then the meta structures will be smaller and have nice alignment:

struct kasan_track {
        u32 pid;
        depot_stack_handle_t stack;
};

struct kasan_alloc_meta {
        struct kasan_track track;
        u32 state : 2;  /* enum kasan_state */
        u32 alloc_size : 30;
        u32 reserved;  /* we can use it to store an additional stack
handle, e.g. for debugging RCU */
};

struct kasan_free_meta {
        /* This field is used while the object is in the quarantine.
         * Otherwise it might be used for the allocator freelist.
         */
        void **quarantine_link;
        struct kasan_track track;
};


>> +       u64 pid : 16;                   /* 65536 processes */
>> +       u64 when : 42;                  /* ~140 years */
>> +};
>> +



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
