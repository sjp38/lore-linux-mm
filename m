Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 581A96B4130
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:40:50 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so21059591plk.12
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 00:40:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d12si54244578pln.340.2018.11.26.00.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Nov 2018 00:40:48 -0800 (PST)
Date: Mon, 26 Nov 2018 09:40:42 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181126084042.GK2113@hirez.programming.kicks-ass.net>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
 <20181123095314.hervxkxtqoixovro@linutronix.de>
 <20181123110226.GA5125@andrea>
 <20181123110611.s2gmd237j7docrxt@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123110611.s2gmd237j7docrxt@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>, zhe.he@windriver.com, catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, boqun.feng@gmail.com

On Fri, Nov 23, 2018 at 12:06:11PM +0100, Sebastian Andrzej Siewior wrote:
> On 2018-11-23 12:02:55 [+0100], Andrea Parri wrote:
> > > is this an RT-only problem? Because mainline should not allow read->read
> > > locking or read->write locking for reader-writer locks. If this only
> > > happens on v4.18 and not on v4.19 then something must have fixed it.
> > 
> > Probably misunderstanding, but I'd say that read->read locking is "the
> > norm"...?
> > 
> > If you don't use qrwlock, readers are also "recursive", in part.,
> > 
> >   P0			P1
> >   read_lock(l)
> > 			write_lock(l)
> >   read_lock(l)
> > 
> > won't block P0 on the second read_lock().  (qrwlock somehow complicate
> > the analysis; IIUC, they are recursive if and only if in_interrupt().).
> 
> ehm, peterz, is that true? My memory on that is that all readers will
> block if there is a writer pending.

Since qrwlock is the more strict, all users should use its semantics.
Just like we cannot 'rely' on the unfairness of some lock
implementations.
