Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 712696B0006
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 09:51:08 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id v125-v6so16988853ita.7
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 06:51:08 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u67-v6si3537604ith.116.2018.10.13.06.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 13 Oct 2018 06:51:07 -0700 (PDT)
Date: Sat, 13 Oct 2018 15:50:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm/kasan: make quarantine_lock a raw_spinlock_t
Message-ID: <20181013135058.GC4931@worktop.programming.kicks-ass.net>
References: <20181005163320.zkacovxvlih6blpp@linutronix.de>
 <CACT4Y+YoNCm=0C6PZtQR1V1j4QeQ0cFcJzpJF1hn34Oaht=jwg@mail.gmail.com>
 <20181009142742.ikh7xv2dn5skjjbe@linutronix.de>
 <CACT4Y+ZB38pKvT8+BAjDZ1t4ZjXQQKoya+ytXT+ASQxHUkWwnA@mail.gmail.com>
 <20181010092929.a5gd3fkkw6swco4c@linutronix.de>
 <CACT4Y+agGPSTZ-8A8r8haSeRM8UpRYMAF8BC4A87yeM9nvpP6w@mail.gmail.com>
 <20181010095343.6qxved3owi6yokoa@linutronix.de>
 <CACT4Y+ZpMjYBPS0GHP0AsEJZZmDjwV9DJBiVUzYKBnD+r9W4+A@mail.gmail.com>
 <20181010214945.5owshc3mlrh74z4b@linutronix.de>
 <20181012165655.f067886428a394dc7fbae7af@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181012165655.f067886428a394dc7fbae7af@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Clark Williams <williams@redhat.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rt-users@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

On Fri, Oct 12, 2018 at 04:56:55PM -0700, Andrew Morton wrote:
> There are several reasons for using raw_*, so an explanatory comment at
> each site is called for.
> 
> However it would be smarter to stop "using raw_* for several reasons". 
> Instead, create a differently named variant for each such reason.  ie, do
> 
> /*
>  * Nice comment goes here.  It explains all the possible reasons why -rt
>  * might use a raw_spin_lock when a spin_lock could otherwise be used.
>  */
> #define raw_spin_lock_for_rt	raw_spinlock
> 
> Then use raw_spin_lock_for_rt() at all such sites.

The whole raw_spinlock_t is for RT, no other reason. It is the one true
spinlock.

>From this, it naturally follows that:

 - nesting order: raw_spinlock_t < spinlock_t < mutex_t
 - raw_spinlock_t sections must be bounded

The patch under discussion is the result of the nesting order rule; and
is allowed to violate the second rule, by virtue of it being debug code.

There are no other reasons; and I'm somewhat confused by what you
propose.
