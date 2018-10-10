Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0060B6B0007
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:58:03 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y6-v6so4092738ioc.10
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:58:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r14-v6sor11038854ioa.72.2018.10.10.02.58.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 02:58:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181010095343.6qxved3owi6yokoa@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com> <20181005163018.icbknlzymwjhdehi@linutronix.de>
 <20181005163320.zkacovxvlih6blpp@linutronix.de> <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
 <20181009142742.ikh7xv2dn5skjjbe@linutronix.de> <CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
 <20181010092929.a5gd3fkkw6swco4c@linutronix.de> <CACT4Y+agGPSTZ-8A8r8haSeRM8UpRYMAF8BC4A87yeM9nvpP6w@mail.gmail.com>
 <20181010095343.6qxved3owi6yokoa@linutronix.de>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 10 Oct 2018 11:57:41 +0200
Message-ID: <CACT4Y+ZpMjYBPS0GHP0AsEJZZmDjwV9DJBiVUzYKBnD+r9W4+A@mail.gmail.com>
Subject: Re: [PATCH] kasan: convert kasan/quarantine_lock to raw_spinlock
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Oct 10, 2018 at 11:53 AM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> On 2018-10-10 11:45:32 [+0200], Dmitry Vyukov wrote:
>> > Should I repost Clark's patch?
>>
>>
>> I am much more comfortable with just changing the type of the lock.
>
> Yes, that is what Clark's patch does. Should I resent it?


Yes. Clark's patch looks good to me. Probably would be useful to add a
comment as to why raw spinlock is used (otherwise somebody may
refactor it back later).


>> What are the bad implications of using the raw spinlock? Will it help
>> to do something along the following lines:
>>
>> // Because of ...
>> #if CONFIG_RT
>> #define quarantine_spinlock_t raw_spinlock_t
>> #else
>> #define quarantine_spinlock_t spinlock_t
>> #endif
>
> no. For !RT spinlock_t and raw_spinlock_t are the same. For RT
> spinlock_t does not disable interrupts or preemption while
> raw_spinlock_t does.
> Therefore holding a raw_spinlock_t might increase your latency.

Ack.
