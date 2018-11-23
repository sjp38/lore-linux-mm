Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 454446B2EAD
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 21:35:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i3so2006570pfj.4
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 18:35:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w2sor59239711pgo.65.2018.11.22.18.35.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 18:35:20 -0800 (PST)
Date: Fri, 23 Nov 2018 11:35:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181123023514.GC1582@jagdpanzerIV>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
 <20181122020422.GA3441@jagdpanzerIV>
 <c8c29a58-f356-d379-2bf4-cea09b03dc3e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c8c29a58-f356-d379-2bf4-cea09b03dc3e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On (11/22/18 14:57), Waiman Long wrote:
> > [..]
> >> As a side note, one of the test systems that I used generated a
> >> debugobjects splat in the bootup process and the system hanged
> >> afterward. Applying this patch alone fix the hanging problem and the
> >> system booted up successfully. So it is not really a good idea to call
> >> printk() while holding a raw spinlock.
> > Right, I like this patch.
> > And I think that we, maybe, can go even further.
> >
> > Some serial consoles call mod_timer(). So what we could have with the
> > debug objects enabled was
> >
> > 	mod_timer()
> > 	 lock_timer_base()
> > 	  debug_activate()
> > 	   printk()
> > 	    call_console_drivers()
> > 	     foo_console()
> > 	      mod_timer()
> > 	       lock_timer_base()       << deadlock
> >
> > That's one possible scenario. The other one can involve console's
> > IRQ handler, uart port spinlock, mod_timer, debug objects, printk,
> > and an eventual deadlock on the uart port spinlock. This one can
> > be mitigated with printk_safe. But mod_timer() deadlock will require
> > a different fix.
> >
> > So maybe we need to switch debug objects print-outs to _always_
> > printk_deferred(). Debug objects can be used in code which cannot
> > do direct printk() - timekeeping is just one example.
> 
> Actually, I don't think that was the cause of the hang.

Oh, I didn't suggest that this was the case. Just talked about more
problems with printk in debug objects. Serial consoles call mod_time,
mod_timer calls debug objects, debug objects call printk and end up
in serial console again. Serial consoles are not re-entrant at this
point.

> The debugobjects splat was caused by debug_object_is_on_stack(), below
> was the output:
>
> [��� 6.890048] ODEBUG: object (____ptrval____) is NOT on stack
> (____ptrval____), but annotated.
> [��� 6.891000] WARNING: CPU: 28 PID: 1 at lib/debugobjects.c:369
> __debug_object_init.cold.11+0x51/0x2d6
[..]
> �� 11.270654] systemd[1]: systemd 239 running in system mode. (+PAM
> +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP
> +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN
> +PCRE2 default-hierarchy=legacy)
> [�� 11.311307] systemd[1]: Detected architecture x86-64.
> [�� 11.316420] systemd[1]: Running in initial RAM disk.
> 
> Welcome to
> 
> The system is not responsive at this point.
> 
> I am not totally sure what caused this.

Hmm, me neither.

	-ss
