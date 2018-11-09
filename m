Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06A166B06A0
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:47 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id x5-v6so747802pfn.22
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w10-v6sor7682518plp.31.2018.11.08.22.47.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:46 -0800 (PST)
Date: Fri, 9 Nov 2018 15:47:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181109064740.GE599@jagdpanzerIV>
References: <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
 <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
 <20181003133704.43a58cf5@gandalf.local.home>
 <CAJmjG291w2ZPRiAevSzxGNcuR6vTuqyk6z4SG3xRsbaQh5U3zQ@mail.gmail.com>
 <20181004074442.GA12879@jagdpanzerIV>
 <20181004083609.kcziz2ynwi2w7lcm@pathway.suse.cz>
 <20181004085515.GC12879@jagdpanzerIV>
 <CAJmjG2-e6f6p=pE5uDECMc=W=81SYyGCmoabrC1ePXwL5DFdSw@mail.gmail.com>
 <20181022100952.GA1147@jagdpanzerIV>
 <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: sergey.senozhatsky.work@gmail.com, Petr Mladek <pmladek@suse.com>, rostedt@goodmis.org, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (11/01/18 09:05), Daniel Wang wrote:
> > Another deadlock scenario could be the following one:
> >
> >         printk()
> >          console_trylock()
> >           down_trylock()
> >            raw_spin_lock_irqsave(&sem->lock, flags)
> >             <NMI>
> >              panic()
> >               console_flush_on_panic()
> >                console_trylock()
> >                 raw_spin_lock_irqsave(&sem->lock, flags)        // deadlock
> >
> > There are no patches addressing this one at the moment. And it's
> > unclear if you are hitting this scenario.
> 
> I am not sure, but Steven's patches did make the deadlock I saw go away...

You certainly can find cases when "busy spin on console_sem owner" logic
can reduce some possibilities.

But spin_lock(&lock); NMI; spin_lock(&lock); code is still in the kernel.

> A little swamped by other things lately but I'll run a test with it.
> If it works, would you recommend taking your patch alone

Let's first figure out if it works.

	-ss
