Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 192156B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 19:56:59 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 43-v6so10692939ple.19
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 16:56:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 144-v6si2855479pgh.282.2018.10.12.16.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 16:56:57 -0700 (PDT)
Date: Fri, 12 Oct 2018 16:56:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/kasan: make quarantine_lock a raw_spinlock_t
Message-Id: <20181012165655.f067886428a394dc7fbae7af@linux-foundation.org>
In-Reply-To: <20181010214945.5owshc3mlrh74z4b@linutronix.de>
References: <20180918152931.17322-1-williams@redhat.com>
	<20181005163018.icbknlzymwjhdehi@linutronix.de>
	<20181005163320.zkacovxvlih6blpp@linutronix.de>
	<CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
	<20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
	<CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
	<20181010092929.a5gd3fkkw6swco4c@linutronix.de>
	<CACT4Y+agGPSTZ-8A8r8haSeRM8UpRYMAF8BC4A87yeM9nvpP6w@mail.gmail.com>
	<20181010095343.6qxved3owi6yokoa@linutronix.de>
	<CACT4Y+ZpMjYBPS0GHP0AsEJZZmDjwV9DJBiVUzYKBnD+r9W4+A@mail.gmail.com>
	<20181010214945.5owshc3mlrh74z4b@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dmitry Vyukov <dvyukov@google.com>, Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On Wed, 10 Oct 2018 23:49:45 +0200 Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> On 2018-10-10 11:57:41 [+0200], Dmitry Vyukov wrote:
> > Yes. Clark's patch looks good to me. Probably would be useful to add a
> > comment as to why raw spinlock is used (otherwise somebody may
> > refactor it back later).
> 
> If you really insist, I could add something but this didn't happen so
> far. git's changelog should provide enough information why to why it was
> changed.

Requiring code readers to look up changelogs in git is rather user-hostile.
There are several reasons for using raw_*, so an explanatory comment at
each site is called for.

However it would be smarter to stop "using raw_* for several reasons". 
Instead, create a differently named variant for each such reason.  ie, do

/*
 * Nice comment goes here.  It explains all the possible reasons why -rt
 * might use a raw_spin_lock when a spin_lock could otherwise be used.
 */
#define raw_spin_lock_for_rt	raw_spinlock

Then use raw_spin_lock_for_rt() at all such sites.
