Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 313146B026B
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 13:37:10 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 17-v6so2473827pgs.18
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 10:37:10 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v191-v6si1936414pgd.157.2018.10.03.10.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 10:37:08 -0700 (PDT)
Date: Wed, 3 Oct 2018 13:37:04 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181003133704.43a58cf5@gandalf.local.home>
In-Reply-To: <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
References: <20180927194601.207765-1-wonderfly@google.com>
	<20181001152324.72a20bea@gandalf.local.home>
	<CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
	<20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
	<CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
	<20181002212327.7aab0b79@vmware.local.home>
	<20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
	<CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: Petr Mladek <pmladek@suse.com>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Wed, 3 Oct 2018 10:16:08 -0700
Daniel Wang <wonderfly@google.com> wrote:

> On Wed, Oct 3, 2018 at 2:14 AM Petr Mladek <pmladek@suse.com> wrote:
> >
> > On Tue 2018-10-02 21:23:27, Steven Rostedt wrote:  
> > > I don't see the big deal of backporting this. The biggest complaints
> > > about backports are from fixes that were added to late -rc releases
> > > where the fixes didn't get much testing. This commit was added in 4.16,
> > > and hasn't had any issues due to the design. Although a fix has been
> > > added:
> > >
> > > c14376de3a1 ("printk: Wake klogd when passing console_lock owner")  
> >
> > As I said, I am fine with backporting the console_lock owner stuff
> > into the stable release.
> >
> > I just wonder (like Sergey) what the real problem is. The console_lock
> > owner handshake is not fully reliable. It is might be good enough

I'm not sure what you mean by 'not fully reliable'

> > to prevent softlockup. But we should not relay on it to prevent
> > a deadlock.  
> 
> Yes. I myself was curious too. :)
> 
> >
> > My new theory ;-)
> >
> > printk_safe_flush() is called in nmi_trigger_cpumask_backtrace().  
> > => watchdog_timer_fn() is blocked until all backtraces are printed.  
> >
> > Now, the original report complained that the system rebooted before
> > all backtraces were printed. It means that panic() was called
> > on another CPU. My guess is that it is from the hardlockup detector.
> > And the panic() was not able to flush the console because it was
> > not able to take console_lock.
> >
> > IMHO, there was not a real deadlock. The console_lock owner
> > handshake jsut helped to get console_lock in panic() and
> > flush all messages before reboot => it is reasonable
> > and acceptable fix.  

Agreed.


> 
> I had the same speculation. Tried to capture a lockdep snippet with
> CONFIG_PROVE_LOCKING turned on but didn't get anything. But
> maybe I was doing it wrong.
> 
> >
> > Just to be sure. Daniel, could you please send a log with
> > the console_lock owner stuff backported? There we would see
> > who called the panic() and why it rebooted early.  
> 
> Sure. Here is one. It's a bit long but complete. I attached another log
> snippet below it which is what I got when `softlockup_panic` was turned
> off. The log was from the IRQ task that was flushing the printk buffer. I
> will be taking a closer look at it too but in case you'll find it helpful.

Just so I understand correctly. Does the panic hit with and without the
suggested backport patch? The only difference is that you get the full
output with the patch and limited output without it?

-- Steve
