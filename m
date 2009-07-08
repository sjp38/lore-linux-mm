Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D88FD6B004D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 23:13:49 -0400 (EDT)
Date: Wed, 8 Jul 2009 11:19:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH 1/2] vmscan don't isolate too many pages
Message-ID: <20090708031901.GA9924@localhost>
References: <20090707182947.0C6D.A69D9226@jp.fujitsu.com> <20090707184034.0C70.A69D9226@jp.fujitsu.com> <4A539B11.5020803@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A539B11.5020803@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 02:59:29AM +0800, Rik van Riel wrote:
> KOSAKI Motohiro wrote:
> 
> > FAQ
> > -------
> > Q: Why do you compared zone accumulate pages, not individual zone pages?
> > A: If we check individual zone, #-of-reclaimer is restricted by smallest zone.
> >    it mean decreasing the performance of the system having small dma zone.
> 
> That is a clever solution!  I was playing around a bit with
> doing it on a per-zone basis.  Your idea is much nicer.
> 
> However, I can see one potential problem with your patch:
> 
> +		nr_inactive += zone_page_state(zone, NR_INACTIVE_ANON);
> +		nr_inactive += zone_page_state(zone, NR_INACTIVE_FILE);
> +		nr_isolated += zone_page_state(zone, NR_ISOLATED_ANON);
> +		nr_isolated += zone_page_state(zone, NR_ISOLATED_FILE);
> +	}
> +
> +	return nr_isolated > nr_inactive;
> 
> What if we ran out of swap space, or are not scanning the
> anon list at all for some reason?
> 
> It is possible that there are no inactive_file pages left,
> with all file pages already isolated, and your function
> still letting reclaimers through.

Good catch!

If swap is always off, NR_ISOLATED_ANON = 0. So it becomes

        NR_ISOLATED_FILE > NR_INACTIVE_FILE + NR_INACTIVE_ANON

which will never be true if there are more anon pages than file pages.

If swap is on but goes full at some time, comparing *ANON is
also meaningless because the anon list won't be scanned.

> This means you could still get a spurious OOM.
> 
> I guess I should mail out my (ugly) approach, so we can
> compare the two :)

And it helps to be aware of all the alternatives, now and future :)

KOSAKI, I tested this updated patch. The OOM seems to be gone, but
now the process could sleep for too long time.

[  316.756006] BUG: soft lockup - CPU#1 stuck for 61s! [msgctl11:12497]
[  316.756006] Modules linked in: drm snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_seq snd_timer snd_seq_device iwlagn snd iwlcore soundcore snd_page_alloc video
[  316.756006] irq event stamp: 269858
[  316.756006] hardirqs last  enabled at (269857): [<ffffffff8100cc50>] restore_args+0x0/0x30
[  316.756006] hardirqs last disabled at (269858): [<ffffffff8100bf6a>] save_args+0x6a/0x70
[  316.756006] softirqs last  enabled at (269856): [<ffffffff81055d9e>] __do_softirq+0x19e/0x1f0
[  316.756006] softirqs last disabled at (269841): [<ffffffff8100d3cc>] call_softirq+0x1c/0x50
[  316.756006] CPU 1:
[  316.756006] Modules linked in: drm snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_seq snd_timer snd_seq_device iwlagn snd iwlcore soundcore snd_page_alloc video
[  316.756006] Pid: 12497, comm: msgctl11 Not tainted 2.6.31-rc1 #33 HP Compaq 6910p
[  316.756006] RIP: 0010:[<ffffffff810804a9>]  [<ffffffff810804a9>] lock_acquire+0xf9/0x120
[  316.756006] RSP: 0000:ffff880013a9fcd8  EFLAGS: 00000246
[  316.756006] RAX: ffff880013a7c500 RBX: ffff880013a9fd28 RCX: ffffffff81b6c928
[  316.756006] RDX: 0000000000000002 RSI: ffffffff82130ff0 RDI: 0000000000000246
[  316.756006] RBP: ffffffff8100cb8e R08: ffffff18f84dc1fb R09: 0000000000000001
[  316.756006] R10: 00000000000001ce R11: 0000000000000001 R12: 0000000000000002
[  316.756006] R13: ffff880013a7cc90 R14: 000000008107eca9 R15: ffff880013a9fd08
[  316.756006] FS:  00007f91a8bf76f0(0000) GS:ffff88000272f000(0000) knlGS:0000000000000000
[  316.756006] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  316.756006] CR2: 00007f91a8c079a0 CR3: 0000000013a81000 CR4: 00000000000006e0
[  316.756006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  316.756006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  316.756006] Call Trace:
[  316.756006]  [<ffffffff810fade9>] ? __swap_duplicate+0x59/0x1a0
[  316.756006]  [<ffffffff8158e0e6>] ? _spin_lock+0x36/0x70
[  316.756006]  [<ffffffff810fade9>] ? __swap_duplicate+0x59/0x1a0
[  316.756006]  [<ffffffff810fade9>] ? __swap_duplicate+0x59/0x1a0
[  316.756006]  [<ffffffff810faf43>] ? swapcache_prepare+0x13/0x20
[  316.756006]  [<ffffffff810fa423>] ? read_swap_cache_async+0x63/0x120
[  316.756006]  [<ffffffff810fa567>] ? swapin_readahead+0x87/0xc0
[  316.756006]  [<ffffffff810ec9f9>] ? handle_mm_fault+0x719/0x840
[  316.756006]  [<ffffffff815911cb>] ? do_page_fault+0x1cb/0x330
[  316.756006]  [<ffffffff8158e9e5>] ? page_fault+0x25/0x30
[  316.756006] Kernel panic - not syncing: softlockup: hung tasks
[  316.756006] Pid: 12497, comm: msgctl11 Not tainted 2.6.31-rc1 #33
[  316.756006] Call Trace:
[  316.756006]  <IRQ>  [<ffffffff8158a01a>] panic+0xa5/0x173
[  316.756006]  [<ffffffff8100cb8e>] ? common_interrupt+0xe/0x13
[  316.756006]  [<ffffffff81012e69>] ? sched_clock+0x9/0x10
[  316.756006]  [<ffffffff8107b745>] ? lock_release_holdtime+0x35/0x1c0
[  316.756006]  [<ffffffff8158df1b>] ? _spin_unlock+0x2b/0x40
[  316.756006]  [<ffffffff810a733d>] softlockup_tick+0x1ad/0x1e0
[  316.756006]  [<ffffffff8105b91d>] run_local_timers+0x1d/0x30
[  316.756006]  [<ffffffff8105b96c>] update_process_times+0x3c/0x80
[  316.756006]  [<ffffffff810773fc>] tick_periodic+0x2c/0x80
[  316.756006]  [<ffffffff81077476>] tick_handle_periodic+0x26/0x90
[  316.756006]  [<ffffffff81077848>] tick_do_broadcast+0x88/0x90
[  316.756006]  [<ffffffff810779a9>] tick_do_periodic_broadcast+0x39/0x50
[  316.756006]  [<ffffffff81077f34>] tick_handle_periodic_broadcast+0x14/0x50
[  316.756006]  [<ffffffff8100f5ef>] timer_interrupt+0x1f/0x30
[  316.756006]  [<ffffffff810a7e70>] handle_IRQ_event+0x70/0x180
[  316.756006]  [<ffffffff810a9cf1>] handle_edge_irq+0xc1/0x160
[  316.756006]  [<ffffffff8100ee6b>] handle_irq+0x4b/0xb0
[  316.756006]  [<ffffffff8159346f>] do_IRQ+0x6f/0xf0
[  316.756006]  [<ffffffff8100cb93>] ret_from_intr+0x0/0x16
[  316.756006]  <EOI>  [<ffffffff810804a9>] ? lock_acquire+0xf9/0x120
[  316.756006]  [<ffffffff810fade9>] ? __swap_duplicate+0x59/0x1a0
[  316.756006]  [<ffffffff8158e0e6>] ? _spin_lock+0x36/0x70
[  316.756006]  [<ffffffff810fade9>] ? __swap_duplicate+0x59/0x1a0
[  316.756006]  [<ffffffff810fade9>] ? __swap_duplicate+0x59/0x1a0
[  316.756006]  [<ffffffff810faf43>] ? swapcache_prepare+0x13/0x20
[  316.756006]  [<ffffffff810fa423>] ? read_swap_cache_async+0x63/0x120
[  316.756006]  [<ffffffff810fa567>] ? swapin_readahead+0x87/0xc0
[  316.756006]  [<ffffffff810ec9f9>] ? handle_mm_fault+0x719/0x840
[  316.756006]  [<ffffffff815911cb>] ? do_page_fault+0x1cb/0x330
[  316.756006]  [<ffffffff8158e9e5>] ? page_fault+0x25/0x30
[  316.756006] Rebooting in 100 seconds..


---
 mm/page_alloc.c |   29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -1721,6 +1721,30 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	return alloc_flags;
 }
 
+static bool too_many_isolated(struct zonelist *zonelist,
+			      enum zone_type high_zoneidx, nodemask_t *nodemask)
+{
+	unsigned long nr_inactive = 0;
+	unsigned long nr_isolated = 0;
+	struct zoneref *z;
+	struct zone *zone;
+
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+					high_zoneidx, nodemask) {
+		if (!populated_zone(zone))
+			continue;
+
+		nr_inactive += zone_page_state(zone, NR_INACTIVE_FILE);
+		nr_isolated += zone_page_state(zone, NR_ISOLATED_FILE);
+		if (nr_swap_pages) {
+			nr_inactive += zone_page_state(zone, NR_INACTIVE_ANON);
+			nr_isolated += zone_page_state(zone, NR_ISOLATED_ANON);
+		}
+	}
+
+	return nr_isolated > nr_inactive;
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -1789,6 +1813,11 @@ rebalance:
 	if (p->flags & PF_MEMALLOC)
 		goto nopage;
 
+	if (too_many_isolated(zonelist, high_zoneidx, nodemask)) {
+		schedule_timeout_uninterruptible(HZ/10);
+		goto restart;
+	}
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
