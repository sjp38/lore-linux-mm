Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2EC6B7B18
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 12:26:29 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 12so679285plb.18
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 09:26:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor1542922pls.72.2018.12.06.09.26.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 09:26:28 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: Number of arguments in vmalloc.c
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181206102559.GG13538@hirez.programming.kicks-ass.net>
Date: Thu, 6 Dec 2018 09:26:24 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <55B665E1-3F64-4D87-B779-D1B4AFE719A9@gmail.com>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
 <20181203161352.GP10377@bombadil.infradead.org>
 <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
 <20181203224920.GQ10377@bombadil.infradead.org>
 <C377D9EF-A0F4-4142-8145-6942DC29A353@gmail.com>
 <EB579DAE-B25F-4869-8529-8586DF4AECFF@gmail.com>
 <20181206102559.GG13538@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>

> On Dec 6, 2018, at 2:25 AM, Peter Zijlstra <peterz@infradead.org> =
wrote:
>=20
> On Thu, Dec 06, 2018 at 12:28:26AM -0800, Nadav Amit wrote:
>> [ +Peter ]
>>=20
>> So I dug some more (I=E2=80=99m still not done), and found various =
trivial things
>> (e.g., storing zero extending u32 immediate is shorter for registers,
>> inlining already takes place).
>>=20
>> *But* there is one thing that may require some attention - patch
>> b59167ac7bafd ("x86/percpu: Fix this_cpu_read()=E2=80=9D) set =
ordering constraints
>> on the VM_ARGS() evaluation. And this patch also imposes, it appears,
>> (unnecessary) constraints on other pieces of code.
>>=20
>> These constraints are due to the addition of the volatile keyword for
>> this_cpu_read() by the patch. This affects at least 68 functions in =
my
>> kernel build, some of which are hot (I think), e.g., =
finish_task_switch(),
>> smp_x86_platform_ipi() and select_idle_sibling().
>>=20
>> Peter, perhaps the solution was too big of a hammer? Is it possible =
instead
>> to create a separate "this_cpu_read_once()=E2=80=9D with the volatile =
keyword? Such
>> a function can be used for native_sched_clock() and other seqlocks, =
etc.
>=20
> No. like the commit writes this_cpu_read() _must_ imply READ_ONCE(). =
If
> you want something else, use something else, there's plenty other
> options available.
>=20
> There's this_cpu_op_stable(), but also __this_cpu_read() and
> raw_this_cpu_read() (which currently don't differ from this_cpu_read()
> but could).

Would setting the inline assembly memory operand both as input and =
output be
better than using the =E2=80=9Cvolatile=E2=80=9D?

I think that If you do that, the compiler would should the =
this_cpu_read()
as something that changes the per-cpu-variable, which would make it =
invalid
to re-read the value. At the same time, it would not prevent reordering =
the
read with other stuff.
