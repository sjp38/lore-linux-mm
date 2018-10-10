Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC3F26B0270
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 04:26:04 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id m7-v6so3968290iop.9
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 01:26:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s190-v6sor43757995jaa.13.2018.10.10.01.26.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 01:26:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com> <20181005163018.icbknlzymwjhdehi@linutronix.de>
 <20181005163320.zkacovxvlih6blpp@linutronix.de> <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
 <20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 10 Oct 2018 10:25:42 +0200
Message-ID: <CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
Subject: Re: [PATCH] kasan: convert kasan/quarantine_lock to raw_spinlock
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Oct 9, 2018 at 4:27 PM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> On 2018-10-08 11:15:57 [+0200], Dmitry Vyukov wrote:
>> Hi Sebastian,
> Hi Dmitry,
>
>> This seems to beak quarantine_remove_cache( ) in the sense that some
>> object from the cache may still be in quarantine when
>> quarantine_remove_cache() returns. When quarantine_remove_cache()
>> returns all objects from the cache must be purged from quarantine.
>> That srcu and irq trickery is there for a reason.
>
> That loop should behave like your on_each_cpu() except it does not
> involve the remote CPU.


The problem is that it can squeeze in between:

+               spin_unlock(&q->lock);

                spin_lock(&quarantine_lock);

as far as I see. And then some objects can be left in the quarantine.


>> This code is also on hot path of kmallock/kfree, an additional
>> lock/unlock per operation is expensive. Adding 2 locked RMW per
>> kmalloc is not something that should be done only out of refactoring
>> reasons.
> But this is debug code anyway, right? And it is highly complex imho.
> Well, maybe only for me after I looked at it for the first time=E2=80=A6

It is debug code - yes.
Nothing about its performance matters - no.

That's the way to produce unusable debug tools.
With too much overhead timeouts start to fire and code behaves not the
way it behaves in production.
The tool is used in continuous integration and developers wait for
test results before merging code.
The tool is used on canary devices and directly contributes to usage experi=
ence.

We of course don't want to trade a page of assembly code for cutting
few cycles here (something that could make sense for some networking
code maybe). But otherwise let's not introduce spinlocks on fast paths
just for refactoring reasons.


>> The original message from Clark mentions that the problem can be fixed
>> by just changing type of spinlock. This looks like a better and
>> simpler way to resolve the problem to me.
>
> I usually prefer to avoid adding raw_locks everywhere if it can be
> avoided. However given that this is debug code and a few additional us
> shouldn't matter here, I have no problem with Clark's initial patch
> (also the mem-free in irq-off region works in this scenario).
> Can you take it as-is or should I repost it with an acked-by?

Perhaps it's the problem with the way RT kernel changes things then?
This is not specific to quarantine, right? Should that mutex detect
that IRQs are disabled and not try to schedule? If this would happen
in some networking code, what would we do?
