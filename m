Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 266A66B0269
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:53:48 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id n13-v6so2490004wrt.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:53:48 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 64-v6si18863194wre.304.2018.10.10.02.53.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Oct 2018 02:53:47 -0700 (PDT)
Date: Wed, 10 Oct 2018 11:53:43 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] kasan: convert kasan/quarantine_lock to raw_spinlock
Message-ID: <20181010095343.6qxved3owi6yokoa@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com>
 <20181005163018.icbknlzymwjhdehi@linutronix.de>
 <20181005163320.zkacovxvlih6blpp@linutronix.de>
 <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
 <20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
 <CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
 <20181010092929.a5gd3fkkw6swco4c@linutronix.de>
 <CACT4Y+agGPSTZ-8A8r8haSeRM8UpRYMAF8BC4A87yeM9nvpP6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CACT4Y+agGPSTZ-8A8r8haSeRM8UpRYMAF8BC4A87yeM9nvpP6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On 2018-10-10 11:45:32 [+0200], Dmitry Vyukov wrote:
> > Should I repost Clark's patch?
> 
> 
> I am much more comfortable with just changing the type of the lock.

Yes, that is what Clark's patch does. Should I resent it?

> What are the bad implications of using the raw spinlock? Will it help
> to do something along the following lines:
> 
> // Because of ...
> #if CONFIG_RT
> #define quarantine_spinlock_t raw_spinlock_t
> #else
> #define quarantine_spinlock_t spinlock_t
> #endif

no. For !RT spinlock_t and raw_spinlock_t are the same. For RT
spinlock_t does not disable interrupts or preemption while
raw_spinlock_t does.
Therefore holding a raw_spinlock_t might increase your latency.

Sebastian
