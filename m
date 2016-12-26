Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB116B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 06:34:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so641364949pgc.0
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 03:34:28 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id k187si42853622pgc.41.2016.12.26.03.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 03:34:27 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id b1so9063055pgc.1
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 03:34:26 -0800 (PST)
Date: Mon, 26 Dec 2016 20:34:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161226113407.GA515@tigerII.localdomain>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky@gmail.com, mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

Cc Greg, Jiri,

On (12/26/16 19:54), Tetsuo Handa wrote:
[..]
> 
> (3) I got below warning. (Though not reproducible.)
>     If fb_flashcursor() called console_trylock(), console_may_schedule is set to 1?

hmmm... it takes an atomic/spin `printing_lock' lock in vt_console_print(),
then call console_conditional_schedule() from lf(), being under spin_lock.
`console_may_schedule' in console_conditional_schedule() still keeps the
value from console_trylock(), which was ok (console_may_schedule permits
rescheduling). but preemption got changed under console_trylock(), by
that spin_lock.

console_trylock() used to always forbid rescheduling; but it got changed
like a yaer ago.

the other thing is... do we really need to console_conditional_schedule()
from fbcon_*()? console_unlock() does cond_resched() after every line it
prints. wouldn't that be enough?

so may be we can drop some of console_conditional_schedule()
call sites in fbcon. or update console_conditional_schedule()
function to always return the current preemption value, not the
one we saw in console_trylock().

(not tested)

---

 kernel/printk/printk.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 8b2696420abb..ad4a02cf9f15 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -2075,6 +2075,24 @@ static int console_cpu_notify(unsigned int cpu)
 	return 0;
 }
 
+static int get_console_may_schedule(void)
+{
+	/*
+	 * When PREEMPT_COUNT disabled we can't reliably detect if it's
+	 * safe to schedule (e.g. calling printk while holding a spin_lock),
+	 * because preempt_disable()/preempt_enable() are just barriers there
+	 * and preempt_count() is always 0.
+	 *
+	 * RCU read sections have a separate preemption counter when
+	 * PREEMPT_RCU enabled thus we must take extra care and check
+	 * rcu_preempt_depth(), otherwise RCU read sections modify
+	 * preempt_count().
+	 */
+	return !oops_in_progress &&
+		preemptible() &&
+		!rcu_preempt_depth();
+}
+
 /**
  * console_lock - lock the console system for exclusive use.
  *
@@ -2112,20 +2130,7 @@ int console_trylock(void)
 		return 0;
 	}
 	console_locked = 1;
-	/*
-	 * When PREEMPT_COUNT disabled we can't reliably detect if it's
-	 * safe to schedule (e.g. calling printk while holding a spin_lock),
-	 * because preempt_disable()/preempt_enable() are just barriers there
-	 * and preempt_count() is always 0.
-	 *
-	 * RCU read sections have a separate preemption counter when
-	 * PREEMPT_RCU enabled thus we must take extra care and check
-	 * rcu_preempt_depth(), otherwise RCU read sections modify
-	 * preempt_count().
-	 */
-	console_may_schedule = !oops_in_progress &&
-			preemptible() &&
-			!rcu_preempt_depth();
+	console_may_schedule = get_console_may_schedule();
 	return 1;
 }
 EXPORT_SYMBOL(console_trylock);
@@ -2316,7 +2321,7 @@ EXPORT_SYMBOL(console_unlock);
  */
 void __sched console_conditional_schedule(void)
 {
-	if (console_may_schedule)
+	if (get_console_may_schedule())
 		cond_resched();
 }
 EXPORT_SYMBOL(console_conditional_schedule);


---


	-ss

> ----------------------------------------
> [  OK  [  255.862188] audit: type=1131 audit(1482733112.662:148): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=systemd-tmpfiles-setup-dev comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
> ] Stopped Create Static Device Nodes in /dev.
> 
> [  255.871468] BUG: sleeping function called from invalid context at kernel/printk/printk.c:2325
> [  255.871469] in_atomic(): 1, irqs_disabled(): 1, pid: 10079, name: plymouthd
> [  255.871469] 6 locks held by plymouthd/10079:
> [  255.871470]  #0:  (&tty->ldisc_sem){++++.+}, at: [<ffffffff817413e2>] ldsem_down_read+0x32/0x40
> [  255.871472]  #1:  (&tty->atomic_write_lock){+.+.+.}, at: [<ffffffff81424309>] tty_write_lock+0x19/0x50
> [  255.871474]  #2:  (&tty->termios_rwsem){++++..}, at: [<ffffffff81429d59>] n_tty_write+0x99/0x470
> [  255.871475]  #3:  (&ldata->output_lock){+.+...}, at: [<ffffffff81429df0>] n_tty_write+0x130/0x470
> [  255.871477]  #4:  (console_lock){+.+.+.}, at: [<ffffffff8110616e>] console_unlock+0x33e/0x6b0
> [  255.871479]  #5:  (printing_lock){......}, at: [<ffffffff8143baf5>] vt_console_print+0x75/0x3d0
> [  255.871481] irq event stamp: 15244
> [  255.871481] hardirqs last  enabled at (15243): [<ffffffff81105011>] __down_trylock_console_sem+0x91/0xa0
> [  255.871482] hardirqs last disabled at (15244): [<ffffffff81105ea4>] console_unlock+0x74/0x6b0
> [  255.871482] softirqs last  enabled at (14968): [<ffffffff81096394>] __do_softirq+0x344/0x580
> [  255.871482] softirqs last disabled at (14963): [<ffffffff810968d3>] irq_exit+0xe3/0x120
> [  255.871483] CPU: 0 PID: 10079 Comm: plymouthd Not tainted 4.9.0-next-20161224+ #12
> [  255.871483] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  255.871484] Call Trace:
> [  255.871484]  dump_stack+0x85/0xc9
> [  255.871485]  ___might_sleep+0x14a/0x250
> [  255.871485]  console_conditional_schedule+0x22/0x30
> [  255.871485]  fbcon_redraw.isra.24+0xa3/0x1d0
> [  255.871486]  ? fbcon_cursor+0x151/0x1c0
> [  255.871486]  fbcon_scroll+0x11d/0xcb0
> [  255.871487]  con_scroll+0x160/0x170
> [  255.871487]  lf+0x9c/0xb0
> [  255.871487]  vt_console_print+0x2b7/0x3d0
> [  255.871488]  console_unlock+0x457/0x6b0
> [  255.871488]  do_con_write.part.19+0x737/0x9e0
> [  255.871489]  ? mark_held_locks+0x71/0x90
> [  255.871489]  con_write+0x57/0x60
> [  255.871489]  n_tty_write+0x1bf/0x470
> [  255.871490]  ? prepare_to_wait_event+0x110/0x110
> [  255.871490]  tty_write+0x157/0x2d0
> [  255.871491]  ? n_tty_open+0xd0/0xd0
> [  255.871491]  __vfs_write+0x32/0x140
> [  255.871491]  ? trace_hardirqs_on+0xd/0x10
> [  255.871492]  ? __audit_syscall_entry+0xaa/0xf0
> [  255.871492]  vfs_write+0xc2/0x1f0
> [  255.871493]  ? syscall_trace_enter+0x1cb/0x3e0
> [  255.871493]  SyS_write+0x53/0xc0
> [  255.871493]  do_syscall_64+0x67/0x1f0
> [  255.871494]  entry_SYSCALL64_slow_path+0x25/0x25
> [  255.871494] RIP: 0033:0x7fb74cf8fc60
> [  255.871495] RSP: 002b:00007ffcaab3fe88 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> [  255.871495] RAX: ffffffffffffffda RBX: 000055d3acaf7160 RCX: 00007fb74cf8fc60
> [  255.871496] RDX: 000000000000003f RSI: 000055d3acafd090 RDI: 0000000000000009
> [  255.871496] RBP: 000055d3acafc440 R08: 0000000000000070 R09: 0000000000000000
> [  255.871497] R10: 000000000000003f R11: 0000000000000246 R12: 000055d3acafc330
> [  255.871497] R13: 000000000000003f R14: 00007ffcaab3ffb0 R15: 0000000000000000
>          Stopping Create Static Device Nodes in /dev...
> 
> ----------------------------------------
> 
> # ./scripts/faddr2line vmlinux console_unlock+0x74/0x6b0
> console_unlock+0x74/0x6b0:
> console_unlock at kernel/printk/printk.c:2228
> # ./scripts/faddr2line vmlinux console_unlock+0x457/0x6b0
> console_unlock+0x457/0x6b0:
> call_console_drivers at kernel/printk/printk.c:1613
>  (inlined by) console_unlock at kernel/printk/printk.c:2277
> # ./scripts/faddr2line vmlinux vt_console_print+0x2b7/0x3d0
> vt_console_print+0x2b7/0x3d0:
> cr at drivers/tty/vt/vt.c:1137
>  (inlined by) vt_console_print at drivers/tty/vt/vt.c:2598
> # ./scripts/faddr2line vmlinux lf+0x9c/0xb0
> lf+0x9c/0xb0:
> lf at drivers/tty/vt/vt.c:1112
> # ./scripts/faddr2line vmlinux con_scroll+0x160/0x170
> con_scroll+0x160/0x170:
> con_scroll at drivers/tty/vt/vt.c:327 (discriminator 1)
> # ./scripts/faddr2line vmlinux fbcon_scroll+0x11d/0xcb0
> fbcon_scroll+0x11d/0xcb0:
> fbcon_scroll at drivers/video/console/fbcon.c:1898
> # ./scripts/faddr2line vmlinux fbcon_cursor+0x151/0x1c0
> fbcon_cursor+0x151/0x1c0:
> fbcon_cursor at drivers/video/console/fbcon.c:1331
> # ./scripts/faddr2line vmlinux fbcon_redraw.isra.24+0xa3/0x1d0
> fbcon_redraw.isra.24+0xa3/0x1d0:
> fbcon_redraw at drivers/video/console/fbcon.c:1756
> # ./scripts/faddr2line vmlinux console_conditional_schedule+0x22/0x30
> console_conditional_schedule+0x22/0x30:
> console_conditional_schedule at kernel/printk/printk.c:2325
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
