Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC31D6B0283
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 10:27:47 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id y27-v6so1023036wrd.10
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 07:27:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s3-v6si15659574wru.343.2018.10.09.07.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 09 Oct 2018 07:27:46 -0700 (PDT)
Date: Tue, 9 Oct 2018 16:27:42 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] kasan: convert kasan/quarantine_lock to raw_spinlock
Message-ID: <20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com>
 <20181005163018.icbknlzymwjhdehi@linutronix.de>
 <20181005163320.zkacovxvlih6blpp@linutronix.de>
 <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On 2018-10-08 11:15:57 [+0200], Dmitry Vyukov wrote:
> Hi Sebastian,
Hi Dmitry,

> This seems to beak quarantine_remove_cache( ) in the sense that some
> object from the cache may still be in quarantine when
> quarantine_remove_cache() returns. When quarantine_remove_cache()
> returns all objects from the cache must be purged from quarantine.
> That srcu and irq trickery is there for a reason.

That loop should behave like your on_each_cpu() except it does not
involve the remote CPU.

> This code is also on hot path of kmallock/kfree, an additional
> lock/unlock per operation is expensive. Adding 2 locked RMW per
> kmalloc is not something that should be done only out of refactoring
> reasons.
But this is debug code anyway, right? And it is highly complex imho.
Well, maybe only for me after I looked at it for the first time=E2=80=A6

> The original message from Clark mentions that the problem can be fixed
> by just changing type of spinlock. This looks like a better and
> simpler way to resolve the problem to me.

I usually prefer to avoid adding raw_locks everywhere if it can be
avoided. However given that this is debug code and a few additional us
shouldn't matter here, I have no problem with Clark's initial patch
(also the mem-free in irq-off region works in this scenario).
Can you take it as-is or should I repost it with an acked-by?

Sebastian
