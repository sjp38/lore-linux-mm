Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4A96B2CFB
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 14:57:09 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b26so6988312qtq.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:57:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w9si2086245qkg.175.2018.11.22.11.57.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 11:57:08 -0800 (PST)
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
 <20181122020422.GA3441@jagdpanzerIV>
From: Waiman Long <longman@redhat.com>
Message-ID: <c8c29a58-f356-d379-2bf4-cea09b03dc3e@redhat.com>
Date: Thu, 22 Nov 2018 14:57:02 -0500
MIME-Version: 1.0
In-Reply-To: <20181122020422.GA3441@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/21/2018 09:04 PM, Sergey Senozhatsky wrote:
> On (11/21/18 11:49), Waiman Long wrote:
> [..]
>>>  	case ODEBUG_STATE_ACTIVE:
>>> -		debug_print_object(obj, "init");
>>>  		state =3D obj->state;
>>>  		raw_spin_unlock_irqrestore(&db->lock, flags);
>>> +		debug_print_object(obj, "init");
>>>  		debug_object_fixup(descr->fixup_init, addr, state);
>>>  		return;
>>> =20
>>>  	case ODEBUG_STATE_DESTROYED:
>>> -		debug_print_object(obj, "init");
>>> +		debug_printobj =3D true;
>>>  		break;
>>>  	default:
>>>  		break;
>>>  	}
>>> =20
>>>  	raw_spin_unlock_irqrestore(&db->lock, flags);
>>> +	if (debug_chkstack)
>>> +		debug_object_is_on_stack(addr, onstack);
>>> +	if (debug_printobj)
>>> +		debug_print_object(obj, "init");
>>>
> [..]
>> As a side note, one of the test systems that I used generated a
>> debugobjects splat in the bootup process and the system hanged
>> afterward. Applying this patch alone fix the hanging problem and the
>> system booted up successfully. So it is not really a good idea to call=

>> printk() while holding a raw spinlock.
> Right, I like this patch.
> And I think that we, maybe, can go even further.
>
> Some serial consoles call mod_timer(). So what we could have with the
> debug objects enabled was
>
> 	mod_timer()
> 	 lock_timer_base()
> 	  debug_activate()
> 	   printk()
> 	    call_console_drivers()
> 	     foo_console()
> 	      mod_timer()
> 	       lock_timer_base()       << deadlock
>
> That's one possible scenario. The other one can involve console's
> IRQ handler, uart port spinlock, mod_timer, debug objects, printk,
> and an eventual deadlock on the uart port spinlock. This one can
> be mitigated with printk_safe. But mod_timer() deadlock will require
> a different fix.
>
> So maybe we need to switch debug objects print-outs to _always_
> printk_deferred(). Debug objects can be used in code which cannot
> do direct printk() - timekeeping is just one example.
>
> 	-ss

Actually, I don't think that was the cause of the hang. The debugobjects
splat was caused by debug_object_is_on_stack(), below was the output:

[=C2=A0=C2=A0=C2=A0 6.890048] ODEBUG: object (____ptrval____) is NOT on s=
tack
(____ptrval____), but annotated.
[=C2=A0=C2=A0=C2=A0 6.891000] WARNING: CPU: 28 PID: 1 at lib/debugobjects=
=2Ec:369
__debug_object_init.cold.11+0x51/0x2d6
[=C2=A0=C2=A0=C2=A0 6.891000] Modules linked in:
[=C2=A0=C2=A0=C2=A0 6.891000] CPU: 28 PID: 1 Comm: swapper/0 Not tainted
4.18.0-41.el8.bz1651764_cgroup_debug.x86_64+debug #1
[=C2=A0=C2=A0=C2=A0 6.891000] Hardware name: HPE ProLiant DL120 Gen10/Pro=
Liant DL120
Gen10, BIOS U36 11/14/2017
[=C2=A0=C2=A0=C2=A0 6.891000] RIP: 0010:__debug_object_init.cold.11+0x51/=
0x2d6
[=C2=A0=C2=A0=C2=A0 6.891000] Code: ea 03 80 3c 02 00 0f 85 85 02 00 00 4=
9 8b 54 24 18
48 89 de 4c 89 44 24 10 48 c7 c7 00 ce 22 94 e8 73 18 62 ff 4c 8b 44 24
10 <0f> 0b e9 60 db ff ff 41 83 c4 01 b8 ff ff 37 00 44 89 25 ce 46 f9
[=C2=A0=C2=A0=C2=A0 6.891000] RSP: 0000:ffff880104187960 EFLAGS: 00010086=

[=C2=A0=C2=A0=C2=A0 6.891000] RAX: 0000000000000050 RBX: ffffffff9764c570=
 RCX:
0000000000000000
[=C2=A0=C2=A0=C2=A0 6.891000] RDX: 0000000000000000 RSI: 0000000000000000=
 RDI:
ffff880104178ca8
[=C2=A0=C2=A0=C2=A0 6.891000] RBP: 1ffff10020830f34 R08: ffff8807ce68a1d0=
 R09:
fffffbfff2923554
[=C2=A0=C2=A0=C2=A0 6.891000] R10: fffffbfff2923554 R11: ffffffff9491aaa3=
 R12:
ffff880104178000
[=C2=A0=C2=A0=C2=A0 6.891000] R13: ffffffff96c809b8 R14: 000000000000a370=
 R15:
ffff8807ce68a1c0
[=C2=A0=C2=A0=C2=A0 6.891000] FS:=C2=A0 0000000000000000(0000) GS:ffff880=
7d4200000(0000)
knlGS:0000000000000000
[=C2=A0=C2=A0=C2=A0 6.891000] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 00000=
00080050033
[=C2=A0=C2=A0=C2=A0 6.891000] CR2: 0000000000000000 CR3: 000000028de16001=
 CR4:
00000000007606e0
[=C2=A0=C2=A0=C2=A0 6.891000] DR0: 0000000000000000 DR1: 0000000000000000=
 DR2:
0000000000000000
[=C2=A0=C2=A0=C2=A0 6.891000] DR3: 0000000000000000 DR6: 00000000fffe0ff0=
 DR7:
0000000000000400
[=C2=A0=C2=A0=C2=A0 6.891000] PKRU: 00000000
[=C2=A0=C2=A0=C2=A0 6.891000] Call Trace:
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? debug_object_fixup+0x30/0x30
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? _raw_spin_unlock_irqrestore+0x4b/0x=
60
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? __lockdep_init_map+0x12f/0x510
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? __lockdep_init_map+0x12f/0x510
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 virt_efi_get_next_variable+0xa2/0x160=

[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 efivar_init+0x1c4/0x6d7
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? efivar_ssdt_setup+0x3b/0x3b
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? efivar_entry_iter+0x120/0x120
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? find_held_lock+0x3a/0x1c0
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? lock_downgrade+0x5e0/0x5e0
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? kmsg_dump_rewind_nolock+0xd9/0xd9
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? _raw_spin_unlock_irqrestore+0x4b/0x=
60
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? trace_hardirqs_on_caller+0x381/0x57=
0
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? efivar_ssdt_iter+0x1f4/0x1f4
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 efisubsys_init+0x1be/0x4ae
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? kernfs_get.part.8+0x4c/0x60
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? efivar_ssdt_iter+0x1f4/0x1f4
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? __kernfs_create_file+0x235/0x2e0
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? efivar_ssdt_iter+0x1f4/0x1f4
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 do_one_initcall+0xe9/0x5fd
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? perf_trace_initcall_level+0x450/0x4=
50
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? __wake_up_common+0x5a0/0x5a0
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? lock_downgrade+0x5e0/0x5e0
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 kernel_init_freeable+0x51a/0x5f2
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? start_kernel+0x7b8/0x7b8
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? finish_task_switch+0x19a/0x690
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? __switch_to_asm+0x40/0x70
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? __switch_to_asm+0x34/0x70
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? rest_init+0xe9/0xe9
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 kernel_init+0xc/0x110
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ? rest_init+0xe9/0xe9
[=C2=A0=C2=A0=C2=A0 6.891000]=C2=A0 ret_from_fork+0x24/0x50
[=C2=A0=C2=A0=C2=A0 6.891000] irq event stamp: 1081352
[=C2=A0=C2=A0=C2=A0 6.891000] hardirqs last=C2=A0 enabled at (1081351): [=
<ffffffff93af7dab>]
_raw_spin_unlock_irqrestore+0x4b/0x60
[=C2=A0=C2=A0=C2=A0 6.891000] hardirqs last disabled at (1081352): [<ffff=
ffff93af85c2>]
_raw_spin_lock_irqsave+0x22/0x81
[=C2=A0=C2=A0=C2=A0 6.891000] softirqs last=C2=A0 enabled at (1081334): [=
<ffffffff93e006f9>]
__do_softirq+0x6f9/0xaa0
[=C2=A0=C2=A0=C2=A0 6.891000] softirqs last disabled at (1081325): [<ffff=
ffff921b993f>]
irq_exit+0x27f/0x2d0
[=C2=A0=C2=A0=C2=A0 6.891000] ---[ end trace 15e1083fc009a526 ]---

All the messages above were printed while holding a raw spinlock with
IRQ disabled. Further down the bootup sequence, the system appeared to ha=
ng:

=C2=A0=C2=A0 11.270654] systemd[1]: systemd 239 running in system mode. (=
+PAM
+AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP
+GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN
+PCRE2 default-hierarchy=3Dlegacy)
[=C2=A0=C2=A0 11.311307] systemd[1]: Detected architecture x86-64.
[=C2=A0=C2=A0 11.316420] systemd[1]: Running in initial RAM disk.

Welcome to

The system is not responsive at this point.

I am not totally sure what caused this. Maybe it was caused by disabling
IRQ for too long leading to some kind of corruption. Anyway, moving
debug_object_is_on_stack() outside of the IRQ disabled lock critical
section seemed to fix the hang problem.

Cheers,
Longman
