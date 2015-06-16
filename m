Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9386B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 04:48:27 -0400 (EDT)
Received: by qkdm188 with SMTP id m188so5330217qkd.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:48:27 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g34si277323qge.65.2015.06.16.01.48.23
        for <linux-mm@kvack.org>;
        Tue, 16 Jun 2015 01:48:26 -0700 (PDT)
Date: Tue, 16 Jun 2015 09:48:18 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC NEXT] mm: Fix suspicious RCU usage at
 kernel/sched/core.c:7318
Message-ID: <20150616084818.GF21229@e104818-lin.cambridge.arm.com>
References: <1434403518-5308-1-git-send-email-Larry.Finger@lwfinger.net>
 <20150616084424.GE21229@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150616084424.GE21229@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Tejun Heo <tj@kernel.org>, Martin KaFai Lau <kafai@fb.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jun 16, 2015 at 09:44:24AM +0100, Catalin Marinas wrote:
> On Mon, Jun 15, 2015 at 10:25:18PM +0100, Larry Finger wrote:
> > Beginning at commit d52d399, the following INFO splat is logged:
> > 
> > [    2.816564] ===============================
> > [    2.816986] [ INFO: suspicious RCU usage. ]
> > [    2.817402] 4.1.0-rc7-next-20150612 #1 Not tainted
> > [    2.817881] -------------------------------
> > [    2.818297] kernel/sched/core.c:7318 Illegal context switch in RCU-bh read-side critical section!
> > [    2.819180]
> > other info that might help us debug this:
> > 
> > [    2.819947]
> > rcu_scheduler_active = 1, debug_locks = 0
> > [    2.820578] 3 locks held by systemd/1:
> > [    2.820954]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff815f0c8f>] rtnetlink_rcv+0x1f/0x40
> > [    2.821855]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff816a34e2>] ipv6_add_addr+0x62/0x540
> > [    2.822808]  #2:  (addrconf_hash_lock){+...+.}, at: [<ffffffff816a3604>] ipv6_add_addr+0x184/0x540
> > [    2.823790]
> > stack backtrace:
> > [    2.824212] CPU: 0 PID: 1 Comm: systemd Not tainted 4.1.0-rc7-next-20150612 #1
> > [    2.824932] Hardware name: TOSHIBA TECRA A50-A/TECRA A50-A, BIOS Version 4.20   04/17/2014
> > [    2.825751]  0000000000000001 ffff880224e07838 ffffffff817263a4 ffffffff810ccf2a
> > [    2.826560]  ffff880224e08000 ffff880224e07868 ffffffff810b6827 0000000000000000
> > [    2.827368]  ffffffff81a445d3 00000000000004f4 ffff88022682e100 ffff880224e07898
> > [    2.828177] Call Trace:
> > [    2.828422]  [<ffffffff817263a4>] dump_stack+0x4c/0x6e
> > [    2.828937]  [<ffffffff810ccf2a>] ? console_unlock+0x1ca/0x510
> > [    2.829514]  [<ffffffff810b6827>] lockdep_rcu_suspicious+0xe7/0x120
> > [    2.830139]  [<ffffffff8108cf05>] ___might_sleep+0x1d5/0x1f0
> > [    2.830699]  [<ffffffff8108cf6d>] __might_sleep+0x4d/0x90
> > [    2.831239]  [<ffffffff811f3789>] ? create_object+0x39/0x2e0
> > [    2.831800]  [<ffffffff811da427>] kmem_cache_alloc+0x47/0x250
> > [    2.832375]  [<ffffffff813c19ae>] ? find_next_zero_bit+0x1e/0x20
> > [    2.832973]  [<ffffffff811f3789>] create_object+0x39/0x2e0
> > [    2.833515]  [<ffffffff810b7eb6>] ? mark_held_locks+0x66/0x90
> > [    2.834089]  [<ffffffff8172efab>] ? _raw_spin_unlock_irqrestore+0x4b/0x60
> > [    2.834761]  [<ffffffff817193c1>] kmemleak_alloc_percpu+0x61/0xe0
> > [    2.835369]  [<ffffffff811a26f0>] pcpu_alloc+0x370/0x630
> > 
> > Additional backtrace lines are truncated. In addition, the above splat is
> > followed by several "BUG: sleeping function called from invalid context
> > at mm/slub.c:1268" outputs. As suggested by Martin KaFai Lau, these are the
> > clue to the fix. Routine kmemleak_alloc_percpu() always uses GFP_KERNEL
> > for its allocations, whereas it should use the value input to pcpu_alloc().
> > 
> > Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> > Cc: Martin KaFai Lau <kafai@fb.com>
> > Cc: Catalin Marinas <catalin.marinas@arm.com>
> > To: Tejun Heo <tj@kernel.org>
> > Cc: Christoph Lameter <cl@linux-foundation.org>
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
[...]
> Apart from the minor comment above (and the kmemleak.c.rej file):
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

BTW, it's worth adding:

Cc: <stable@vger.kernel.org> # v3.18+

(or Fixes: 5835d96e9ce4 percpu: implement [__]alloc_percpu_gfp())

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
