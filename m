Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7966B026D
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:40:22 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r6so12774233pfj.14
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:40:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor18500pgf.428.2017.11.06.17.40.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 17:40:20 -0800 (PST)
Date: Tue, 7 Nov 2017 10:40:15 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171107014015.GA1822@jagdpanzerIV>
References: <20171102134515.6eef16de@gandalf.local.home>
 <201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

On (11/06/17 21:06), Tetsuo Handa wrote:
> I tried your patch with warn_alloc() torture. It did not cause lockups.
> But I felt that possibility of failing to flush last second messages (such
> as SysRq-c or SysRq-b) to consoles has increased. Is this psychological?

do I understand it correctly that there are "lost messages"?

sysrq-b does an immediate emergency reboot. "normally" it's not expected
to flush any pending logbuf messages because it's an emergency-reboot...
but in fact it does. and this is why sysrq-b is not 100% reliable:

	__handle_sysrq()
	{
	  pr_info("SysRq : ");

	  op_p = __sysrq_get_key_op(key);
	  pr_cont("%s\n", op_p->action_msg);

	    op_p->handler(key);

	  pr_cont("\n");
	}

those pr_info()/pr_cont() calls can spoil sysrq-b, depending on how
badly the system is screwed. if pr_info() deadlocks, then we never
go to op_p->handler(key)->emergency_restart(). even if you suppress
printing of info loglevel messages, pr_info() still goes to
console_unlock() and prints [console_seq, log_next_seq] messages,
if there any.

there is, however, a subtle behaviour change, I think.

previously, in some cases [?], pr_info("SysRq : ") from __handle_sysrq()
would flush logbuf messages. now we have that "break out of console_unlock()
loop even though there are pending messages, there is another CPU doing
printk()". so sysrb-b instead of looping in console_unlock() goes directly
to emergency_restart(). without the change it would have continued looping
in console_unlock() and would have called emergency_restart() only when
"console_seq == log_next_seq".

now... the "subtle" part here is that we had that thing:
	- *IF* __handle_sysrq() grabs the console_sem then it will not
	  return from console_unlock() until logbuf is empty. so
	  concurrent printk() messages won't get lost.

what we have now is:
	- if there are concurrent printk() then __handle_sysrq() does not
	  fully flush the logbuf *even* if it grabbed the console_sem.

> ---------- vmcore-dmesg start ----------
> [  169.016198] postgres cpuset=
> [  169.032544]  filemap_fault+0x311/0x790
> [  169.047745] /
> [  169.047780]  mems_allowed=0
> [  169.050577]  ? xfs_ilock+0x126/0x1a0 [xfs]
> [  169.062769]  mems_allowed=0
> [  169.065754]  ? down_read_nested+0x3a/0x60
> [  169.065783]  ? xfs_ilock+0x126/0x1a0 [xfs]
> [  189.700206] sysrq: SysRq :
> [  189.700639]  __xfs_filemap_fault.isra.19+0x3f/0xe0 [xfs]
> [  189.700799]  xfs_filemap_fault+0xb/0x10 [xfs]
> [  189.703981] Trigger a crash
> [  189.707032]  __do_fault+0x19/0xa0
> [  189.710008] BUG: unable to handle kernel
> [  189.713387]  __handle_mm_fault+0xbb3/0xda0
> [  189.716473] NULL pointer dereference
> [  189.719674]  handle_mm_fault+0x14f/0x300
> [  189.722969]  at           (null)
> [  189.722974] IP: sysrq_handle_crash+0x3b/0x70
> [  189.726156]  ? handle_mm_fault+0x39/0x300
> [  189.729537] PGD 1170dc067
> [  189.732841]  __do_page_fault+0x23e/0x4f0
> [  189.735876] P4D 1170dc067
> [  189.739171]  do_page_fault+0x30/0x80
> [  189.742323] PUD 1170dd067
> [  189.745437]  page_fault+0x22/0x30
> [  189.748329] PMD 0
> [  189.751106] RIP: 0033:0x650390
> [  189.756583] RSP: 002b:00007fffef6b1568 EFLAGS: 00010246
> [  189.759574] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
> [  189.762607] RAX: 0000000000000000 RBX: 00007fffef6b1594 RCX: 00007fae949caa20
> [  189.765665] Modules linked in:
> [  189.768423] RDX: 0000000000000008 RSI: 0000000000000000 RDI: 0000000000000000
> [  189.768425] RBP: 00007fffef6b1590 R08: 0000000000000002 R09: 0000000000000010
> [  189.771478]  ip6t_rpfilter
> [  189.774297] R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000000
> [  189.777016]  ipt_REJECT
> [  189.779366] R13: 0000000000000000 R14: 00007fae969787e0 R15: 0000000000000004
> [  189.782114]  nf_reject_ipv4
> [  189.784839] CPU: 7 PID: 6959 Comm: sleep Not tainted 4.14.0-rc8+ #302
> [  189.785113] Mem-Info:
> ---------- vmcore-dmesg end ----------

hm... wondering if this is a regression.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
