Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7FCBC6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 10:39:10 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id n3so107678991wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:39:10 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id i69si18705487wmc.104.2016.04.11.07.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 07:39:09 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id l6so148940670wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:39:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160411074452.GC26116@js1304-P5Q-DELUXE>
References: <cover.1457949315.git.glider@google.com>
	<4f6880ee0c1545b3ae9c25cfe86a879d724c4e7b.1457949315.git.glider@google.com>
	<20160411074452.GC26116@js1304-P5Q-DELUXE>
Date: Mon, 11 Apr 2016 16:39:08 +0200
Message-ID: <CAG_fn=W_zM0u_NjSzJNi9KiNRY=rtQSYWTVfOQ2nGedApWMBdg@mail.gmail.com>
Subject: Re: [PATCH v7 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Apr 11, 2016 at 9:44 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote=
:
> On Mon, Mar 14, 2016 at 11:43:43AM +0100, Alexander Potapenko wrote:
>> +depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
>> +                                 gfp_t alloc_flags)
>> +{
>> +     u32 hash;
>> +     depot_stack_handle_t retval =3D 0;
>> +     struct stack_record *found =3D NULL, **bucket;
>> +     unsigned long flags;
>> +     struct page *page =3D NULL;
>> +     void *prealloc =3D NULL;
>> +     bool *rec;
>> +
>> +     if (unlikely(trace->nr_entries =3D=3D 0))
>> +             goto fast_exit;
>> +
>> +     rec =3D this_cpu_ptr(&depot_recursion);
>> +     /* Don't store the stack if we've been called recursively. */
>> +     if (unlikely(*rec))
>> +             goto fast_exit;
>> +     *rec =3D true;
>> +
>> +     hash =3D hash_stack(trace->entries, trace->nr_entries);
>> +     /* Bad luck, we won't store this stack. */
>> +     if (hash =3D=3D 0)
>> +             goto exit;
>
> Hello,
>
> why is hash =3D=3D 0 skipped?
>
> Thanks.
We have to keep a special value to distinguish allocations for which
we don't have the stack trace for some reason.
Making 0 such a value seems natural.


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
