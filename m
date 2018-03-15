Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 084536B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:18:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u68so3222012pfk.8
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 06:18:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j82si1224167pfk.248.2018.03.15.06.18.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Mar 2018 06:18:35 -0700 (PDT)
Date: Thu, 15 Mar 2018 06:18:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Improve mutex documentation
Message-ID: <20180315131832.GC9949@bombadil.infradead.org>
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180315115812.GA9949@bombadil.infradead.org>
 <2397831d-71b5-3cc8-9dc4-ce06e2eddfde@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2397831d-71b5-3cc8-9dc4-ce06e2eddfde@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Mauro Carvalho Chehab <mchehab@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>

On Thu, Mar 15, 2018 at 03:12:30PM +0300, Kirill Tkhai wrote:
> > +/**
> > + * mutex_lock_killable() - Acquire the mutex, interruptible by fatal signals.
> 
> Shouldn't we clarify that fatal signals are SIGKILL only?

It's more complicated than it might seem (... welcome to signal handling!)
If you send SIGINT to a task that's waiting on a mutex_killable(), it will
still die.  I *think* that's due to the code in complete_signal():

        if (sig_fatal(p, sig) &&
            !(signal->flags & SIGNAL_GROUP_EXIT) &&
            !sigismember(&t->real_blocked, sig) &&
            (sig == SIGKILL || !p->ptrace)) {
...
                                sigaddset(&t->pending.signal, SIGKILL);

You're correct that this code only checks for SIGKILL, but any fatal
signal will result in the signal group receiving SIGKILL.

Unless I've misunderstood, and it wouldn't be the first time I've
misunderstood signal handling.
