Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E44A6B0007
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:29:34 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z13-v6so2471473wrr.1
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:29:34 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q4-v6si17281947wrr.127.2018.10.10.02.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Oct 2018 02:29:33 -0700 (PDT)
Date: Wed, 10 Oct 2018 11:29:29 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] kasan: convert kasan/quarantine_lock to raw_spinlock
Message-ID: <20181010092929.a5gd3fkkw6swco4c@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com>
 <20181005163018.icbknlzymwjhdehi@linutronix.de>
 <20181005163320.zkacovxvlih6blpp@linutronix.de>
 <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
 <20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
 <CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On 2018-10-10 10:25:42 [+0200], Dmitry Vyukov wrote:
> > That loop should behave like your on_each_cpu() except it does not
> > involve the remote CPU.
>=20
>=20
> The problem is that it can squeeze in between:
>=20
> +               spin_unlock(&q->lock);
>=20
>                 spin_lock(&quarantine_lock);
>=20
> as far as I see. And then some objects can be left in the quarantine.

Okay. But then once you are at CPU10 (in the on_each_cpu() loop) there
can be objects which are added to CPU0, right? So based on that, I
assumed that this would be okay to drop the lock here.=20

> > But this is debug code anyway, right? And it is highly complex imho.
> > Well, maybe only for me after I looked at it for the first time=E2=80=A6
>=20
> It is debug code - yes.
> Nothing about its performance matters - no.
>=20
> That's the way to produce unusable debug tools.
> With too much overhead timeouts start to fire and code behaves not the
> way it behaves in production.
> The tool is used in continuous integration and developers wait for
> test results before merging code.
> The tool is used on canary devices and directly contributes to usage expe=
rience.

Completely understood. What I meant is that debug code in general (from
RT perspective) increases latency to a level where the device can not
operate. Take lockdep for instance. Debug facility which is required
for RT as it spots locking problems early. It increases the latency
(depending on the workload) by 50ms+ and can't be used in production.
Same goes for SLUB debug and most other.

> We of course don't want to trade a page of assembly code for cutting
> few cycles here (something that could make sense for some networking
> code maybe). But otherwise let's not introduce spinlocks on fast paths
> just for refactoring reasons.

Sure. As I said. I'm fine with patch Clark initially proposed. I assumed
the refactoring would make things simpler and avoiding the cross-CPU
call a good thing.

> > Can you take it as-is or should I repost it with an acked-by?
>=20
> Perhaps it's the problem with the way RT kernel changes things then?
> This is not specific to quarantine, right?=20

We got rid of _a lot_ of local_irq_disable/save() + spin_lock() combos
which were there for reasons which are no longer true or due to lack of
the API. And this kasan thing is just something Clark stumbled upon
recently. And I try to negotiate something where everyone can agree on.

> Should that mutex detect
> that IRQs are disabled and not try to schedule? If this would happen
> in some networking code, what would we do?

It is not only that it is supposed not to schedule. Assuming the "mutex"
is not owned you could acquire it right away. No scheduling. However,
you would record current() as the owner of the lock which is wrong and
you get into other trouble later on. The list goes on :)
However, networking. If there is something that breaks then it will be
addressed. It will be forwarded upstream if this something where it
is likely to assume that RT won't change. So networking isn't special.

Should I repost Clark's patch?

Sebastian
