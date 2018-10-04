Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1842C6B0275
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:49:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m45-v6so4727098edc.2
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:49:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d33-v6si1394157edd.393.2018.10.04.00.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:49:36 -0700 (PDT)
Date: Thu, 4 Oct 2018 09:49:33 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181004074933.5pzqnjzl4pwuutoj@pathway.suse.cz>
References: <20180927194601.207765-1-wonderfly@google.com>
 <20181001152324.72a20bea@gandalf.local.home>
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
 <20181002084225.6z2b74qem3mywukx@pathway.suse.cz>
 <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home>
 <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
 <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
 <20181003133704.43a58cf5@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181003133704.43a58cf5@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Daniel Wang <wonderfly@google.com>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Wed 2018-10-03 13:37:04, Steven Rostedt wrote:
> On Wed, 3 Oct 2018 10:16:08 -0700
> Daniel Wang <wonderfly@google.com> wrote:
> 
> > On Wed, Oct 3, 2018 at 2:14 AM Petr Mladek <pmladek@suse.com> wrote:
> > >
> > > On Tue 2018-10-02 21:23:27, Steven Rostedt wrote:  
> > > > I don't see the big deal of backporting this. The biggest complaints
> > > > about backports are from fixes that were added to late -rc releases
> > > > where the fixes didn't get much testing. This commit was added in 4.16,
> > > > and hasn't had any issues due to the design. Although a fix has been
> > > > added:
> > > >
> > > > c14376de3a1 ("printk: Wake klogd when passing console_lock owner")  
> > >
> > > As I said, I am fine with backporting the console_lock owner stuff
> > > into the stable release.
> > >
> > > I just wonder (like Sergey) what the real problem is. The console_lock
> > > owner handshake is not fully reliable. It is might be good enough
> 
> I'm not sure what you mean by 'not fully reliable'

I mean that it is not guaranteed that the very first printk() takes over
the console. It will happen only when the other printk() calls
console_trylock_spinning() while the current console owner does
the code between:

   console_lock_spinning_enable();
   console_lock_spinning_disable_and_check();


> > > Just to be sure. Daniel, could you please send a log with
> > > the console_lock owner stuff backported? There we would see
> > > who called the panic() and why it rebooted early.  
> > 
> > Sure. Here is one. It's a bit long but complete. I attached another log
> > snippet below it which is what I got when `softlockup_panic` was turned
> > off. The log was from the IRQ task that was flushing the printk buffer. I
> > will be taking a closer look at it too but in case you'll find it helpful.
> 
> Just so I understand correctly. Does the panic hit with and without the
> suggested backport patch? The only difference is that you get the full
> output with the patch and limited output without it?

Sigh, the other mail suggest that there was a real deadlock. It means
that the console owner logic might help but it would not prevent
the deadlock completely.

Best Regards,
Petr
