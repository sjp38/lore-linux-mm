Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D6D266B0253
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 07:39:02 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j8so62070524lfd.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:39:02 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id h198si4677621lfe.211.2016.04.28.04.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 04:39:01 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id u64so80782509lff.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:39:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160422143259.b2d2c253da7ea6fa4b425269@linux-foundation.org>
References: <2126fe9ca8c3a4698c0ad7aae652dce28e261182.1460545373.git.glider@google.com>
	<20160422143259.b2d2c253da7ea6fa4b425269@linux-foundation.org>
Date: Thu, 28 Apr 2016 13:31:14 +0200
Message-ID: <CAG_fn=XTeQ5TgxWRKSnAt3b+rkw4H6c=h3h36UGMeBben4TMsA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm, kasan: don't call kasan_krealloc() from ksize().
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Apr 22, 2016 at 11:32 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 13 Apr 2016 13:20:09 +0200 Alexander Potapenko <glider@google.com=
> wrote:
>
>> Instead of calling kasan_krealloc(), which replaces the memory allocatio=
n
>> stack ID (if stack depot is used), just unpoison the whole memory chunk.
>
> I don't understand why these two patches exist.  Bugfix?  Cleanup?
> Optimization?
It's incorrect to call kasan_krealloc() from ksize(), because the
former may touch the allocation metadata (it does so for the SLAB
allocator).
Yes, this is a bugfix.
>
> I had to change kmalloc_tests_init() a bit due to
> mm-kasan-initial-memory-quarantine-implementation.patch:
>
>         kasan_stack_oob();
>         kasan_global_oob();
>  #ifdef CONFIG_SLAB
>         kasan_quarantine_cache();
>  #endif
> +       ksize_unpoisons_memory();
>         return -EAGAIN;
>  }
>
> Please check.
Ack.



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
