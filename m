Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 843616B0007
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 05:14:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r2-v6so2875720edo.10
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 02:14:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m64-v6si833119ede.52.2018.10.03.02.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 02:14:04 -0700 (PDT)
Date: Wed, 3 Oct 2018 11:14:00 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
References: <20180927194601.207765-1-wonderfly@google.com>
 <20181001152324.72a20bea@gandalf.local.home>
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
 <20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
 <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002212327.7aab0b79@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Daniel Wang <wonderfly@google.com>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Tue 2018-10-02 21:23:27, Steven Rostedt wrote:
> On Tue, 2 Oct 2018 17:15:17 -0700
> Daniel Wang <wonderfly@google.com> wrote:
> 
> > On Tue, Oct 2, 2018 at 1:42 AM Petr Mladek <pmladek@suse.com> wrote:
> > >
> > > Well, I still wonder why it helped and why you do not see it with 4.4.
> > > I have a feeling that the console owner switch helped only by chance.
> > > In fact, you might be affected by a race in
> > > printk_safe_flush_on_panic() that was fixed by the commit:
> > >
> > > 554755be08fba31c7 printk: drop in_nmi check from printk_safe_flush_on_panic()
> > >
> > > The above one commit might be enough. Well, there was one more
> > > NMI-related race that was fixed by:
> > >
> > > ba552399954dde1b printk: Split the code for storing a message into the log buffer
> > > a338f84dc196f44b printk: Create helper function to queue deferred console handling
> > > 03fc7f9c99c1e7ae printk/nmi: Prevent deadlock when accessing the main log buffer in NMI  
> > 
> > All of these commits already exist in 4.14 stable, since 4.14.68. The deadlock
> > still exists even when built from 4.14.73 (latest tag) though. And cherrypicking
> > dbdda842fe96 fixes it.
> > 
> 
> I don't see the big deal of backporting this. The biggest complaints
> about backports are from fixes that were added to late -rc releases
> where the fixes didn't get much testing. This commit was added in 4.16,
> and hasn't had any issues due to the design. Although a fix has been
> added:
> 
> c14376de3a1 ("printk: Wake klogd when passing console_lock owner")

As I said, I am fine with backporting the console_lock owner stuff
into the stable release.

I just wonder (like Sergey) what the real problem is. The console_lock
owner handshake is not fully reliable. It is might be good enough
to prevent softlockup. But we should not relay on it to prevent
a deadlock.

My new theory ;-)

printk_safe_flush() is called in nmi_trigger_cpumask_backtrace().
=> watchdog_timer_fn() is blocked until all backtraces are printed.

Now, the original report complained that the system rebooted before
all backtraces were printed. It means that panic() was called
on another CPU. My guess is that it is from the hardlockup detector.
And the panic() was not able to flush the console because it was
not able to take console_lock.

IMHO, there was not a real deadlock. The console_lock owner
handshake jsut helped to get console_lock in panic() and
flush all messages before reboot => it is reasonable
and acceptable fix.

Just to be sure. Daniel, could you please send a log with
the console_lock owner stuff backported? There we would see
who called the panic() and why it rebooted early.

Best Regards,
Petr
