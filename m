Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3D36B319F
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:51:37 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e89so5229286pfb.17
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:51:37 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f4-v6si47145516plo.111.2018.11.23.07.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 07:51:35 -0800 (PST)
Date: Fri, 23 Nov 2018 10:51:32 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181123105132.47ee57ad@vmware.local.home>
In-Reply-To: <20181123113130.GA3360@arrakis.emea.arm.com>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
	<20181123095314.hervxkxtqoixovro@linutronix.de>
	<20181123110226.GA5125@andrea>
	<20181123110611.s2gmd237j7docrxt@linutronix.de>
	<20181123113130.GA3360@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrea Parri <andrea.parri@amarulasolutions.com>, Peter Zijlstra <peterz@infradead.org>, zhe.he@windriver.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, boqun.feng@gmail.com

On Fri, 23 Nov 2018 11:31:31 +0000
Catalin Marinas <catalin.marinas@arm.com> wrote:

> With qwrlocks, the readers will normally block if there is a pending
> writer (to avoid starving the writer), unless in_interrupt() when the
> readers are allowed to starve a pending writer.
> 
> TLA+/PlusCal model here:  ;)
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/kernel-tla.git/tree/qrwlock.tla
> 


And the code appears to confirm it too:

void queued_read_lock_slowpath(struct qrwlock *lock)
{
	/*
	 * Readers come here when they cannot get the lock without waiting
	 */
	if (unlikely(in_interrupt())) {
		/*
		 * Readers in interrupt context will get the lock immediately
		 * if the writer is just waiting (not holding the lock yet),
		 * so spin with ACQUIRE semantics until the lock is available
		 * without waiting in the queue.
		 */
		atomic_cond_read_acquire(&lock->cnts, !(VAL & _QW_LOCKED));
		return;
	}
	atomic_sub(_QR_BIAS, &lock->cnts);

	/*
	 * Put the reader into the wait queue
	 */
	arch_spin_lock(&lock->wait_lock);
	atomic_add(_QR_BIAS, &lock->cnts);



-- Steve
