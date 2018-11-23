Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7376B3102
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:20:43 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w2so5210400edc.13
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:20:43 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si527326edn.298.2018.11.23.03.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:20:41 -0800 (PST)
Date: Fri, 23 Nov 2018 12:20:39 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181123112039.omeup3be4kw6qxxc@pathway.suse.cz>
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
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 2018-11-22 14:57:02, Waiman Long wrote:
> On 11/21/2018 09:04 PM, Sergey Senozhatsky wrote:
> > On (11/21/18 11:49), Waiman Long wrote:
> > [..]
> >>>  	case ODEBUG_STATE_ACTIVE:
> >>> -		debug_print_object(obj, "init");
> >>>  		state = obj->state;
> >>>  		raw_spin_unlock_irqrestore(&db->lock, flags);
> >>> +		debug_print_object(obj, "init");
> >>>  		debug_object_fixup(descr->fixup_init, addr, state);
> >>>  		return;
> >>>  
> >>>  	case ODEBUG_STATE_DESTROYED:
> >>> -		debug_print_object(obj, "init");
> >>> +		debug_printobj = true;
> >>>  		break;
> >>>  	default:
> >>>  		break;
> >>>  	}
> >>>  
> >>>  	raw_spin_unlock_irqrestore(&db->lock, flags);
> >>> +	if (debug_chkstack)
> >>> +		debug_object_is_on_stack(addr, onstack);
> >>> +	if (debug_printobj)
> >>> +		debug_print_object(obj, "init");
> >>>
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
> >
> > 	-ss
> 
> Actually, I don't think that was the cause of the hang. The debugobjects
> splat was caused by debug_object_is_on_stack(), below was the output:
> 
> [��� 6.890048] ODEBUG: object (____ptrval____) is NOT on stack
> (____ptrval____), but annotated.
> [��� 6.891000] WARNING: CPU: 28 PID: 1 at lib/debugobjects.c:369
> __debug_object_init.cold.11+0x51/0x2d6
> [��� 6.891000] Modules linked in:
> [��� 6.891000] CPU: 28 PID: 1 Comm: swapper/0 Not tainted
> 4.18.0-41.el8.bz1651764_cgroup_debug.x86_64+debug #1
> [��� 6.891000] Hardware name: HPE ProLiant DL120 Gen10/ProLiant DL120
> Gen10, BIOS U36 11/14/2017
> [��� 6.891000] RIP: 0010:__debug_object_init.cold.11+0x51/0x2d6
> [��� 6.891000] Code: ea 03 80 3c 02 00 0f 85 85 02 00 00 49 8b 54 24 18
> 48 89 de 4c 89 44 24 10 48 c7 c7 00 ce 22 94 e8 73 18 62 ff 4c 8b 44 24
> 10 <0f> 0b e9 60 db ff ff 41 83 c4 01 b8 ff ff 37 00 44 89 25 ce 46 f9
> [��� 6.891000] RSP: 0000:ffff880104187960 EFLAGS: 00010086
> [��� 6.891000] RAX: 0000000000000050 RBX: ffffffff9764c570 RCX:
> 0000000000000000
> [��� 6.891000] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> ffff880104178ca8
> [��� 6.891000] RBP: 1ffff10020830f34 R08: ffff8807ce68a1d0 R09:
> fffffbfff2923554
> [��� 6.891000] R10: fffffbfff2923554 R11: ffffffff9491aaa3 R12:
> ffff880104178000
> [��� 6.891000] R13: ffffffff96c809b8 R14: 000000000000a370 R15:
> ffff8807ce68a1c0
> [��� 6.891000] FS:� 0000000000000000(0000) GS:ffff8807d4200000(0000)
> knlGS:0000000000000000
> [��� 6.891000] CS:� 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [��� 6.891000] CR2: 0000000000000000 CR3: 000000028de16001 CR4:
> 00000000007606e0
> [��� 6.891000] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [��� 6.891000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
> 0000000000000400
> [��� 6.891000] PKRU: 00000000
> [��� 6.891000] Call Trace:
> [��� 6.891000]� ? debug_object_fixup+0x30/0x30
> [��� 6.891000]� ? _raw_spin_unlock_irqrestore+0x4b/0x60
> [��� 6.891000]� ? __lockdep_init_map+0x12f/0x510
> [��� 6.891000]� ? __lockdep_init_map+0x12f/0x510
> [��� 6.891000]� virt_efi_get_next_variable+0xa2/0x160
> [��� 6.891000]� efivar_init+0x1c4/0x6d7
> [��� 6.891000]� ? efivar_ssdt_setup+0x3b/0x3b
> [��� 6.891000]� ? efivar_entry_iter+0x120/0x120
> [��� 6.891000]� ? find_held_lock+0x3a/0x1c0
> [��� 6.891000]� ? lock_downgrade+0x5e0/0x5e0
> [��� 6.891000]� ? kmsg_dump_rewind_nolock+0xd9/0xd9
> [��� 6.891000]� ? _raw_spin_unlock_irqrestore+0x4b/0x60
> [��� 6.891000]� ? trace_hardirqs_on_caller+0x381/0x570
> [��� 6.891000]� ? efivar_ssdt_iter+0x1f4/0x1f4
> [��� 6.891000]� efisubsys_init+0x1be/0x4ae
> [��� 6.891000]� ? kernfs_get.part.8+0x4c/0x60
> [��� 6.891000]� ? efivar_ssdt_iter+0x1f4/0x1f4
> [��� 6.891000]� ? __kernfs_create_file+0x235/0x2e0
> [��� 6.891000]� ? efivar_ssdt_iter+0x1f4/0x1f4
> [��� 6.891000]� do_one_initcall+0xe9/0x5fd
> [��� 6.891000]� ? perf_trace_initcall_level+0x450/0x450
> [��� 6.891000]� ? __wake_up_common+0x5a0/0x5a0
> [��� 6.891000]� ? lock_downgrade+0x5e0/0x5e0
> [��� 6.891000]� kernel_init_freeable+0x51a/0x5f2
> [��� 6.891000]� ? start_kernel+0x7b8/0x7b8
> [��� 6.891000]� ? finish_task_switch+0x19a/0x690
> [��� 6.891000]� ? __switch_to_asm+0x40/0x70
> [��� 6.891000]� ? __switch_to_asm+0x34/0x70
> [��� 6.891000]� ? rest_init+0xe9/0xe9
> [��� 6.891000]� kernel_init+0xc/0x110
> [��� 6.891000]� ? rest_init+0xe9/0xe9
> [��� 6.891000]� ret_from_fork+0x24/0x50
> [��� 6.891000] irq event stamp: 1081352
> [��� 6.891000] hardirqs last� enabled at (1081351): [<ffffffff93af7dab>]
> _raw_spin_unlock_irqrestore+0x4b/0x60
> [��� 6.891000] hardirqs last disabled at (1081352): [<ffffffff93af85c2>]
> _raw_spin_lock_irqsave+0x22/0x81
> [��� 6.891000] softirqs last� enabled at (1081334): [<ffffffff93e006f9>]
> __do_softirq+0x6f9/0xaa0
> [��� 6.891000] softirqs last disabled at (1081325): [<ffffffff921b993f>]
> irq_exit+0x27f/0x2d0
> [��� 6.891000] ---[ end trace 15e1083fc009a526 ]---
> 
> All the messages above were printed while holding a raw spinlock with
> IRQ disabled. Further down the bootup sequence, the system appeared to hang:
> 
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
> I am not totally sure what caused this. Maybe it was caused by disabling
> IRQ for too long leading to some kind of corruption. Anyway, moving
> debug_object_is_on_stack() outside of the IRQ disabled lock critical
> section seemed to fix the hang problem.

It is hard to say why printing the above with disabled interrupts
would break anything. efivar_init() itself should get delayed
the same way with and without the patch.

Some clue might be in the rest of the log. It would be interesting
to compare full logs of non-patched and patched system.

Best Regards,
Petr
