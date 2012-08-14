Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id AC7656B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 15:19:40 -0400 (EDT)
Date: Tue, 14 Aug 2012 16:19:27 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [RFC][PATCH -mm 2/3] mm,vmscan: reclaim from highest score
 cgroups
Message-ID: <20120814191927.GB11938@x61.redhat.com>
References: <20120808174549.1b10d51a@cuia.bos.redhat.com>
 <20120808174828.56ffa9e7@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120808174828.56ffa9e7@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, yinghan@google.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On Wed, Aug 08, 2012 at 05:48:28PM -0400, Rik van Riel wrote:
> Instead of doing a round robin reclaim over all the cgroups in a
> zone, we pick the lruvec with the top score and reclaim from that.
> 
> We keep reclaiming from that lruvec until we have reclaimed enough
> pages (common for direct reclaim), or that lruvec's score drops in
> half. We keep reclaiming from the zone until we have reclaimed enough
> pages, or have scanned more than the number of reclaimable pages shifted
> by the reclaim priority.
> 
> As an additional change, targeted cgroup reclaim now reclaims from
> the highest priority lruvec. This is because when a cgroup hierarchy
> hits its limit, the best lruvec to reclaim from may be different than
> whatever lruvec is the first we run into iterating from the hierarchy's
> "root".
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---

After fixing the spinlock lockup at patch 03, I started to see kswapd going on
an infinite loop around shrink_zone() that dumps the following softlockup report

---8<---
BUG: soft lockup - CPU#0 stuck for 22s! [kswapd0:29]
Modules linked in: lockd ip6t_REJECT nf_conntrack_ipv6 nf_conntrack_ipv4
nf_defrag_ipv6 nf_defrag_ipv4 xt_stac
irq event stamp: 16668492 
hardirqs last  enabled at (16668491): [<ffffffff8169d230>]
_raw_spin_unlock_irq+0x30/0x50
hardirqs last disabled at (16668492): [<ffffffff816a6e2a>]
apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (16668258): [<ffffffff8106db4c>]
__do_softirq+0x18c/0x3f0
softirqs last disabled at (16668253): [<ffffffff816a75bc>]
call_softirq+0x1c/0x30
CPU 0
Pid: 29, comm: kswapd0 Not tainted 3.6.0-rc1+ #198 Bochs Bochs
RIP: 0010:[<ffffffff8111168d>]  [<ffffffff8111168d>] rcu_is_cpu_idle+0x2d/0x40
RSP: 0018:ffff880002b99af0  EFLAGS: 00000286
RAX: ffff88003fc0efa0 RBX: 0000000000000001 RCX: 0000000000000000
RDX: ffff880002b98000 RSI: ffffffff81c32420 RDI: 0000000000000246
RBP: ffff880002b99af0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000013 R11: 0000000000000001 R12: 0000000000000013
R13: 0000000000000001 R14: ffffffff8169d630 R15: ffffffff811130ef
FS:  0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fde6b5c2d10 CR3: 0000000001c0b000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kswapd0 (pid: 29, threadinfo ffff880002b98000, task ffff880002a6a040)
 Stack:
 ffff880002b99b80 ffffffff81323fa4 ffff880002a6a6f8 ffff880000000000
 ffff880002b99bac 0000000000000000 ffff88003d9d0938 ffff880002a6a040
 ffff880002b99b60 0000000000000246 0000000000000000 ffff880002a6a040
Call Trace:
 [<ffffffff81323fa4>] idr_get_next+0xd4/0x1a0
 [<ffffffff810eb727>] css_get_next+0x87/0x1b0
 [<ffffffff811b1c56>] mem_cgroup_iter+0x146/0x330
 [<ffffffff811b1bfc>] ? mem_cgroup_iter+0xec/0x330
 [<ffffffff8116865f>] shrink_zone+0x11f/0x2a0
 [<ffffffff8116991b>] kswapd+0x85b/0xf60
 [<ffffffff8108e4f0>] ? wake_up_bit+0x40/0x40
 [<ffffffff811690c0>] ? zone_reclaim+0x420/0x420
 [<ffffffff8108dd8e>] kthread+0xbe/0xd0
 [<ffffffff816a74c4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8169d630>] ? retint_restore_args+0x13/0x13
 [<ffffffff8108dcd0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff816a74c0>] ? gs_change+0x13/0x13
---8<---


I've applied your suggestion fix (below) on top of this patch
and, till now, things are going fine. 
Will keep you tuned on new developments, though :)

---8<---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4f6e124..8cb1bbf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2029,12 +2029,14 @@ restart:
 		score = reclaim_score(memcg, victim, sc);
 	} while (sc->nr_to_reclaim > 0 && score > max_score / 2);
 
+	if (!(sc->nr_scanned - nr_scanned))
+		return;
 	/*
 	 * Do we need to reclaim more pages?
 	 * Did we scan fewer pages than the current priority allows?
 	 */
 	if (sc->nr_to_reclaim > 0 &&
-			sc->nr_scanned + nr_scanned <
+			sc->nr_scanned - nr_scanned <
 			zone_reclaimable_pages(zone) >> sc->priority)
 		goto restart;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
