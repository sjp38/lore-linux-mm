Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8BA6B308B
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:53:23 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id a9so9418748wrs.6
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 01:53:23 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m2si5497604wme.142.2018.11.23.01.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 23 Nov 2018 01:53:21 -0800 (PST)
Date: Fri, 23 Nov 2018 10:53:14 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181123095314.hervxkxtqoixovro@linutronix.de>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhe.he@windriver.com
Cc: catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org

On 2018-11-22 17:04:19 [+0800], zhe.he@windriver.com wrote:
> From: He Zhe <zhe.he@windriver.com>
>=20
> kmemleak_lock, as a rwlock on RT, can possibly be held in atomic context =
and
> causes the follow BUG.
>=20
> BUG: scheduling while atomic: migration/15/132/0x00000002
=E2=80=A6
> Preemption disabled at:
> [<ffffffff8c927c11>] cpu_stopper_thread+0x71/0x100
> CPU: 15 PID: 132 Comm: migration/15 Not tainted 4.19.0-rt1-preempt-rt #1
> Hardware name: Intel Corp. Harcuvar/Server, BIOS HAVLCRB1.X64.0015.D62.17=
08310404 08/31/2017
> Call Trace:
>  dump_stack+0x4f/0x6a
>  ? cpu_stopper_thread+0x71/0x100
>  __schedule_bug.cold.16+0x38/0x55
>  __schedule+0x484/0x6c0
>  schedule+0x3d/0xe0
>  rt_spin_lock_slowlock_locked+0x118/0x2a0
>  rt_spin_lock_slowlock+0x57/0x90
>  __rt_spin_lock+0x26/0x30
>  __write_rt_lock+0x23/0x1a0
>  ? intel_pmu_cpu_dying+0x67/0x70
>  rt_write_lock+0x2a/0x30
>  find_and_remove_object+0x1e/0x80
>  delete_object_full+0x10/0x20
>  kmemleak_free+0x32/0x50
>  kfree+0x104/0x1f0
>  ? x86_pmu_starting_cpu+0x30/0x30
>  intel_pmu_cpu_dying+0x67/0x70
>  x86_pmu_dying_cpu+0x1a/0x30
>  cpuhp_invoke_callback+0x92/0x700
>  take_cpu_down+0x70/0xa0
>  multi_cpu_stop+0x62/0xc0
>  ? cpu_stop_queue_work+0x130/0x130
>  cpu_stopper_thread+0x79/0x100
>  smpboot_thread_fn+0x20f/0x2d0
>  kthread+0x121/0x140
>  ? sort_range+0x30/0x30
>  ? kthread_park+0x90/0x90
>  ret_from_fork+0x35/0x40

If this is the only problem? kfree() from a preempt-disabled section
should cause a warning even without kmemleak.

> And on v4.18 stable tree the following call trace, caused by grabbing
> kmemleak_lock again, is also observed.
>=20
> kernel BUG at kernel/locking/rtmutex.c:1048!=20
> invalid opcode: 0000 [#1] PREEMPT SMP PTI=20
> CPU: 5 PID: 689 Comm: mkfs.ext4 Not tainted 4.18.16-rt9-preempt-rt #1=20
=E2=80=A6
> Call Trace:=20
>  ? preempt_count_add+0x74/0xc0=20
>  rt_spin_lock_slowlock+0x57/0x90=20
>  ? __kernel_text_address+0x12/0x40=20
>  ? __save_stack_trace+0x75/0x100=20
>  __rt_spin_lock+0x26/0x30=20
>  __write_rt_lock+0x23/0x1a0=20
>  rt_write_lock+0x2a/0x30=20
>  create_object+0x17d/0x2b0=20
=E2=80=A6

is this an RT-only problem? Because mainline should not allow read->read
locking or read->write locking for reader-writer locks. If this only
happens on v4.18 and not on v4.19 then something must have fixed it.
=20

Sebastian
