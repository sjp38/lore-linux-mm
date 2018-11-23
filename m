Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 394D16B310F
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:31:38 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id q11so187265otl.23
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:31:38 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 32si19978233otw.207.2018.11.23.03.31.36
        for <linux-mm@kvack.org>;
        Fri, 23 Nov 2018 03:31:37 -0800 (PST)
Date: Fri, 23 Nov 2018 11:31:31 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181123113130.GA3360@arrakis.emea.arm.com>
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
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>, Peter Zijlstra <peterz@infradead.org>, zhe.he@windriver.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, boqun.feng@gmail.com

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

With qwrlocks, the readers will normally block if there is a pending
writer (to avoid starving the writer), unless in_interrupt() when the
readers are allowed to starve a pending writer.

TLA+/PlusCal model here:  ;)

https://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/kernel-tla.git/tree/qrwlock.tla

-- 
Catalin
