Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A542F6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 13:49:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f75so47723191wmf.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 10:49:47 -0700 (PDT)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id mu6si24882461lbb.123.2016.05.31.10.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 10:49:46 -0700 (PDT)
Received: by mail-lf0-x232.google.com with SMTP id s64so72031551lfe.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 10:49:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <574D7B11.8090709@virtuozzo.com>
References: <1464691466-59010-1-git-send-email-glider@google.com> <574D7B11.8090709@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 31 May 2016 19:49:45 +0200
Message-ID: <CAG_fn=UuSs=aUst5Ww3RGF-SvOprUYPs2Y3-dD=w1b80-D_R-A@mail.gmail.com>
Subject: Re: [PATCH] mm, kasan: introduce a special shadow value for allocator metadata
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 31, 2016 at 1:52 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 05/31/2016 01:44 PM, Alexander Potapenko wrote:
>> Add a special shadow value to distinguish accesses to KASAN-specific
>> allocator metadata.
>>
>> Unlike AddressSanitizer in the userspace, KASAN lets the kernel proceed
>> after a memory error. However a write to the kmalloc metadata may cause
>> memory corruptions that will make the tool itself unreliable and induce
>> crashes later on. Warning about such corruptions will ease the
>> debugging.
>
> It will not. Whether out-of-bounds hits metadata or not is absolutely irr=
elevant
> to the bug itself. This information doesn't help to understand, analyze o=
r fix the bug.
>
Here's the example that made me think the opposite.

I've been reworking KASAN hooks for mempool and added a test that did
a write-after-free to an object allocated from a mempool.
This resulted in flaky kernel crashes somewhere in quarantine
shrinking after several attempts to `insmod test_kasan.ko`.
Because there already were numerous KASAN errors in the test, it
wasn't evident that the crashes were related to the new test, so I
thought the problem was in the buggy quarantine implementation.
However the problem was indeed in the new test, which corrupted the
quarantine pointer in the object and caused a crash while traversing
the quarantine list.

My previous experience with userspace ASan shows that crashes in the
tool code itself puzzle the developers.
As a result, the users think that the tool is broken and don't believe
its reports.

I first thought about hardening the quarantine list by checksumming
the pointers and validating them on each traversal.
This prevents the crashes, but doesn't give the users any idea about
what went wrong.
On the other hand, reporting the pointer corruption right when it happens d=
oes.
Distinguishing between a regular UAF and a quarantine corruption
(which is what the patch in question is about) helps to prioritize the
KASAN reports and give the developers better understanding of the
consequences.



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
