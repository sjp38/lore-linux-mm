Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 348F86B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 04:18:18 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id nq2so6911986lbc.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 01:18:18 -0700 (PDT)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id d81si10100548lfb.59.2016.06.21.01.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 01:18:16 -0700 (PDT)
Received: by mail-lf0-x236.google.com with SMTP id f6so11673809lfg.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 01:18:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5768490E.6050808@oracle.com>
References: <1466173664-118413-1-git-send-email-glider@google.com>
 <5765699E.6000508@oracle.com> <CAG_fn=WP3HBLBarYz6u8UfEKwS3Cw58+2VcrzV_asiuQid_oxw@mail.gmail.com>
 <5766D902.7080007@oracle.com> <CAG_fn=XbNQAzRKMH71og4k1Dv=1vHMcc6sG-Dx7zwxS18LmYMg@mail.gmail.com>
 <5768490E.6050808@oracle.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 21 Jun 2016 10:18:14 +0200
Message-ID: <CAG_fn=UNmmoBAoau+yx-orq7u9r12aNjf-Xiiem3+Nqo8-SSQw@mail.gmail.com>
Subject: Re: [PATCH v4] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 20, 2016 at 9:50 PM, Sasha Levin <sasha.levin@oracle.com> wrote=
:
> On 06/20/2016 08:53 AM, Alexander Potapenko wrote:
>> On Sun, Jun 19, 2016 at 7:40 PM, Sasha Levin <sasha.levin@oracle.com> wr=
ote:
>>> > On 06/19/2016 03:24 AM, Alexander Potapenko wrote:
>>>> >> Hi Sasha,
>>>> >>
>>>> >> This commit delays the reuse of memory after it has been freed, so
>>>> >> it's intended to help people find more use-after-free errors.
>>> >
>>> > Is there a way to tell if the use-after-free access was to a memory
>>> > that is quarantined?
>>> >
>>>> >> But I'm puzzled why the stacks are missing.
>>> >
>>> > I looked at the logs, it looks like stackdepot ran out of room pretty
>>> > early during boot.
>> This is quite strange, as there's room for ~80k stacks in the depot,
>> and usually the number of unique stacks is lower than 30k.
>> I wonder if this is specific to your config, can you please share it
>> (assuming you're using ToT kernel)?
>> Attached is the patch that you can try out to dump the new stacks
>> after 30k - it's really interesting where do they come from (note the
>> patch is not for submission).
>
> Attached a log file generated with that patch, and my kernel config.
I haven't looked close yet, but your log contains 1455 unique
'DRIVERNAME_driver_init' function names, for which it's quite likely
that 80k allocation stacks are generated.
Can you remove the dump_stack() call from my patch, fuzz for a while
and see to which number does |alloc_cnt| converge on your machine?
Maybe our estimate was just too optimistic, and we need to increase
the memory limit for the stack depot.
>
> Thanks,
> Sasha
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
