Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B9888828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:48:56 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so36878819wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:48:56 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id hz10si11837249wjb.190.2016.02.18.09.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 09:48:55 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id g62so36878219wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:48:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1602181131320.24647@east.gentwo.org>
References: <cover.1455811491.git.glider@google.com>
	<alpine.DEB.2.20.1602181131320.24647@east.gentwo.org>
Date: Thu, 18 Feb 2016 18:48:54 +0100
Message-ID: <CAG_fn=WnLoM8SGDxa8Dvz62drPsh9_Mi_G_c2X-OENF_Oy8nFw@mail.gmail.com>
Subject: Re: [PATCH v2 0/7] SLAB support for KASAN
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Indeed, CONFIG_SLUB_DEBUG is not an issue by itself.

The biggest problem is the stack trace bookkeeping which currently
(with SLUB) requires 128 bytes for each allocation and deallocation
stack, bloating each memory object by 256 bytes.
If we make KASAN use the stack depot with SLUB we'll save a lot of memory.

On Thu, Feb 18, 2016 at 6:32 PM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 18 Feb 2016, Alexander Potapenko wrote:
>
>> Unlike SLUB, SLAB doesn't store allocation/deallocation stacks for heap
>> objects, therefore we reimplement this feature in mm/kasan/stackdepot.c.
>> The intention is to ultimately switch SLUB to use this implementation as
>> well, which will remove the dependency on SLUB_DEBUG.
>
> This needs to be clarified a bit. CONFIG_SLUB_DEBUG is on by default. So
> the dependency does not matter much. I think you depend on the slowpath
> debug processing right? The issue is that you want to do these things in
> the fastpath?
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
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
