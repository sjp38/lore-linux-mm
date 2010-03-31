Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B45EC6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 20:01:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3101Wjg000807
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 1 Apr 2010 09:01:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 288C545DE59
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 09:01:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F187E45DE56
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 09:01:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4E191DB803B
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 09:01:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 52960EF8005
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 09:01:31 +0900 (JST)
Date: Thu, 1 Apr 2010 08:57:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
 PageSwapCache pages
Message-Id: <20100401085718.d091eda6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100331112730.GB27389@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	<1269940489-5776-15-git-send-email-mel@csn.ul.ie>
	<20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
	<20100331112730.GB27389@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010 12:27:30 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, Mar 31, 2010 at 02:26:23PM +0900, KAMEZAWA Hiroyuki wrote:

> > Then, PageSwapCache is cleared only when swap is freeable even if mapped.
> > 
> > rmap_walk_anon() should be called and the check is not necessary.
> > 
> 
> I follow your reasoning. What caught me is the following comment;
> 
>          * Corner case handling:
>          * 1. When a new swap-cache page is read into, it is added to the LRU
>          * and treated as swapcache but it has no rmap yet.
>          * Calling try_to_unmap() against a page->mapping==NULL page will
>          * trigger a BUG.  So handle it here.
> 
> and the fact that without the check the following bug is triggered;
> 
> [  476.541321] BUG: unable to handle kernel NULL pointer dereference at (null)
> [  476.590328] IP: [<ffffffff81072162>] __bfs+0x1a1/0x1d7
> [  476.590328] PGD 3781c067 PUD 371b2067 PMD 0 
> [  476.590328] Oops: 0000 [#1] PREEMPT SMP 
> [  476.590328] last sysfs file: /sys/block/sr0/capability
> [  476.590328] CPU 0 
> [  476.590328] Modules linked in: highalloc trace_allocmap buddyinfo vmregress_core oprofile dm_crypt loop i2c_piix4 evdev i2c_core processor serio_raw tpm_tis tpm tpm_bios shpchp pci_hotplug button ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sg sr_mod cdrom sd_mod ata_generic ahci libahci ide_pci_generic libata ide_core scsi_mod ohci_hcd r8169 mii ehci_hcd floppy thermal fan thermal_sys
> [  477.296405] 
> [  477.296405] Pid: 4343, comm: bench-stresshig Not tainted 2.6.34-rc2-mm1-compaction-v7r3 #1 GA-MA790GP-UD4H/GA-MA790GP-UD4H
> [  477.296405] RIP: 0010:[<ffffffff81072162>]  [<ffffffff81072162>] __bfs+0x1a1/0x1d7
> [  477.296405] RSP: 0000:ffff88007817d4c8  EFLAGS: 00010046
> [  477.296405] RAX: ffffffff81c80170 RBX: ffff88007817d528 RCX: 0000000000000000
> [  477.296405] RDX: ffff88007817d528 RSI: 0000000000000000 RDI: ffff88007817d528
> [  477.296405] RBP: ffff88007817d518 R08: 0000000000000000 R09: 0000000000000000
> [  477.296405] R10: ffffffff816a1d08 R11: 0000000000000046 R12: 0000000000000000
> [  477.922839] R13: ffffffff81513887 R14: ffffffff81c80170 R15: 0000000000000000
> [  477.922839] FS:  00007f8d853d26e0(0000) GS:ffff880002200000(0000) knlGS:0000000000000000
> [  478.123091] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  478.123091] CR2: 0000000000000000 CR3: 0000000037a0e000 CR4: 00000000000006f0
> [  478.123091] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  478.123091] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  478.123091] Process bench-stresshig (pid: 4343, threadinfo ffff88007817c000, task ffff88007ebea000)
> [  478.566030] Stack:
> [  478.566030]  ffff88007817d570 ffffffff81070f92 0000000000000000 0000000000000002
> [  478.566030] <0> ffff88007817d528 ffff88007817d528 ffff88007ebea668 ffffffff81513887
> [  478.566030] <0> ffff88007ebea000 ffff88007ebea000 ffff88007817d598 ffffffff81074201
> [  478.566030] Call Trace:
> [  478.566030]  [<ffffffff81070f92>] ? usage_match+0x0/0x17
> [  478.566030]  [<ffffffff81074201>] check_usage_backwards+0x93/0xca
> [  478.566030]  [<ffffffff8107416e>] ? check_usage_backwards+0x0/0xca
> [  478.566030]  [<ffffffff81073544>] mark_lock+0x31d/0x52f
> [  478.566030]  [<ffffffff8107515a>] __lock_acquire+0x801/0x1776
> [  478.566030]  [<ffffffff810761c5>] lock_acquire+0xf6/0x122
> [  478.566030]  [<ffffffff810ef121>] ? rmap_walk+0x5c/0x16d
> [  478.566030]  [<ffffffff812fcfeb>] _raw_spin_lock+0x3b/0x47
> [  478.566030]  [<ffffffff810ef121>] ? rmap_walk+0x5c/0x16d
> [  478.566030]  [<ffffffff810ef121>] rmap_walk+0x5c/0x16d
> [  478.566030]  [<ffffffff81106396>] ? remove_migration_pte+0x0/0x234
> [  478.566030]  [<ffffffff81300dc1>] ? sub_preempt_count+0x9/0x83
> [  478.566030]  [<ffffffff81106914>] ? migrate_page_copy+0xa0/0x1ed
> [  478.566030]  [<ffffffff81106ea4>] migrate_pages+0x3fc/0x5d3
> [  478.566030]  [<ffffffff81106c56>] ? migrate_pages+0x1ae/0x5d3
> [  478.566030]  [<ffffffff81073a24>] ? trace_hardirqs_on_caller+0x110/0x134
> [  478.566030]  [<ffffffff81107e11>] ? compaction_alloc+0x0/0x283
> [  478.566030]  [<ffffffff811079b0>] ? compact_zone+0x14e/0x4bd
> 
> Granted, what I should have spotted was that a more relevant check was for
> the specific corner case like in the revised patch below. Please note that
> if I put a WARN_ON in the check in rmap.c, it can and does trigger. If this
> situation really is never meant to occur, there is a race that needs to be
> closed before PageSwapCache can be migrated.
> 
> ==== CUT HERE ====
> 
> mm,migration: Allow the migration of PageSwapCache pages
> 
> PageAnon pages that are unmapped may or may not have an anon_vma so
> are not currently migrated. However, a swap cache page can be migrated
> and fits this description. This patch identifies page swap caches and
> allows them to be migrated.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/migrate.c |   12 +++++++-----
>  mm/rmap.c    |    7 +++++--
>  2 files changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 35aad2a..2284d79 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -607,11 +607,13 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  		 * the page was isolated and when we reached here while
>  		 * the RCU lock was not held
>  		 */
> -		if (!page_mapped(page))
> -			goto rcu_unlock;
> -
> -		anon_vma = page_anon_vma(page);
> -		atomic_inc(&anon_vma->external_refcount);
> +		if (!page_mapped(page)) {
> +			if (!PageSwapCache(page))
> +				goto rcu_unlock;
> +		} else {
> +			anon_vma = page_anon_vma(page);
> +			atomic_inc(&anon_vma->external_refcount);
> +		}
>  	}
>  
>  	/*
> diff --git a/mm/rmap.c b/mm/rmap.c
> index af35b75..7d63c68 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1394,9 +1394,12 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
>  
>  	if (unlikely(PageKsm(page)))
>  		return rmap_walk_ksm(page, rmap_one, arg);
> -	else if (PageAnon(page))
> +	else if (PageAnon(page)) {
> +		/* See comment on corner case handling in mm/migrate.c */
> +		if (PageSwapCache(page) && !page_mapped(page))
> +			return SWAP_AGAIN;
>  		return rmap_walk_anon(page, rmap_one, arg);

rmap_walk_anon() is called against unmapped pages.
Then, !page_mapped() is always true. So, the behavior will not be different from
the last one.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
