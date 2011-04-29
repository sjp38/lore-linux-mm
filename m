Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EBC62900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 12:44:30 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2934129pzk.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 09:44:27 -0700 (PDT)
Date: Sat, 30 Apr 2011 01:44:15 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 0/2] memcg: add the soft_limit reclaim in global direct
 reclaim
Message-ID: <20110429164415.GA2006@barrios-desktop>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1304030226-19332-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

Hi Ying,

On Thu, Apr 28, 2011 at 03:37:04PM -0700, Ying Han wrote:
> We recently added the change in global background reclaim which counts the
> return value of soft_limit reclaim. Now this patch adds the similar logic
> on global direct reclaim.
> 
> We should skip scanning global LRU on shrink_zone if soft_limit reclaim does
> enough work. This is the first step where we start with counting the nr_scanned
> and nr_reclaimed from soft_limit reclaim into global scan_control.
> 
> The patch is based on mmotm-04-14 and i triggered kernel BUG at mm/vmscan.c:1058!

Could you tell me exact patches?
mmtom-04-14 + just 2 patch of this? or + something?

These day, You and Kame produces many patches.
Do I have to apply something of them?

> 
> [  938.242033] kernel BUG at mm/vmscan.c:1058!
> [  938.242033] invalid opcode: 0000 [#1] SMP.
> [  938.242033] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/device
> [  938.242033] Pid: 546, comm: kswapd0 Tainted: G        W   2.6.39-smp-direct_reclaim
> [  938.242033] RIP: 0010:[<ffffffff810ed174>]  [<ffffffff810ed174>] isolate_pages_global+0x18c/0x34f
> [  938.242033] RSP: 0018:ffff88082f83bb50  EFLAGS: 00010082
> [  938.242033] RAX: 00000000ffffffea RBX: ffff88082f83bc90 RCX: 0000000000000401
> [  938.242033] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffea001ca653e8
> [  938.242033] RBP: ffff88082f83bc20 R08: 0000000000000000 R09: ffff88085ffb6e00
> [  938.242033] R10: ffff88085ffb73d0 R11: ffff88085ffb6e00 R12: ffff88085ffb6e00
> [  938.242033] R13: ffffea001ca65410 R14: 0000000000000001 R15: ffffea001ca653e8
> [  938.242033] FS:  0000000000000000(0000) GS:ffff88085fd00000(0000) knlGS:0000000000000000
> [  938.242033] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  938.242033] CR2: 00007f5c3405c320 CR3: 0000000001803000 CR4: 00000000000006e0
> [  938.242033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  938.242033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  938.242033] Process kswapd0 (pid: 546, threadinfo ffff88082f83a000, task ffff88082fe52080)
> [  938.242033] Stack:
> [  938.242033]  ffff88085ffb6e00 ffffea0000000002 0000000000000021 0000000000000000
> [  938.242033]  0000000000000000 ffff88082f83bcb8 ffffea00108eec80 ffffea00108eecb8
> [  938.242033]  ffffea00108eecf0 0000000000000004 fffffffffffffffc 0000000000000020
> [  938.242033] Call Trace:
> [  938.242033]  [<ffffffff810ee8a5>] shrink_inactive_list+0x185/0x418
> [  938.242033]  [<ffffffff810366cc>] ? __switch_to+0xea/0x212
> [  938.242033]  [<ffffffff810e8b35>] ? determine_dirtyable_memory+0x1a/0x2c
> [  938.242033]  [<ffffffff810ef19b>] shrink_zone+0x380/0x44d
> [  938.242033]  [<ffffffff810e5188>] ? zone_watermark_ok_safe+0xa1/0xae
> [  938.242033]  [<ffffffff810efbd8>] kswapd+0x41b/0x76b
> [  938.242033]  [<ffffffff810ef7bd>] ? zone_reclaim+0x2fb/0x2fb
> [  938.242033]  [<ffffffff81088569>] kthread+0x82/0x8a
> [  938.242033]  [<ffffffff8141b0d4>] kernel_thread_helper+0x4/0x10
> [  938.242033]  [<ffffffff810884e7>] ? kthread_worker_fn+0x112/0x112
> [  938.242033]  [<ffffffff8141b0d0>] ? gs_change+0xb/0xb
> 

It seems there is active page in inactive list.
As I look deactivate_page, lru_deactivate_fn clears PageActive before
add_page_to_lru_list and it should be protected by zone->lru_lock.
In addiion, PageLRU would protect with race with isolation functions.

Hmm, I don't have any clue now.
Is it reproducible easily?

Could you apply below debugging patch and report the result?

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 8f7d247..f39b53a 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -25,6 +25,8 @@ static inline void
 __add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
 		       struct list_head *head)
 {
+	VM_BUG_ON(PageActive(page) && (
+			l == LRU_INACTIVE_ANON || l == LRU_INACTIVE_FILE));
 	list_add(&page->lru, head);
 	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
 	mem_cgroup_add_lru_list(page, l);
diff --git a/mm/swap.c b/mm/swap.c
index a83ec5a..5f7c3c8 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -454,6 +454,8 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
+		VM_BUG_ON(PageActive(page) && (
+			lru == LRU_INACTIVE_ANON || lru == LRU_INACTIVE_FILE));
 		list_move_tail(&page->lru, &zone->lru[lru].list);
 		mem_cgroup_rotate_reclaimable_page(page);
 		__count_vm_event(PGROTATED);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b3a569f..3415896 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -963,7 +963,7 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 
 	/* Only take pages on the LRU. */
 	if (!PageLRU(page))
-		return ret;
+		return 1;
 
 	/*
 	 * When checking the active state, we need to be sure we are
@@ -971,10 +971,10 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	 * of each.
 	 */
 	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
-		return ret;
+		return 2;
 
 	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
-		return ret;
+		return 3;
 
 	/*
 	 * When this function is being called for lumpy reclaim, we
@@ -982,7 +982,7 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	 * unevictable; only give shrink_page_list evictable pages.
 	 */
 	if (PageUnevictable(page))
-		return ret;
+		return 4;
 
 	ret = -EBUSY;
 
@@ -1035,13 +1035,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		unsigned long end_pfn;
 		unsigned long page_pfn;
 		int zone_id;
+		int ret;
 
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, mode, file)) {
+		switch (ret = __isolate_lru_page(page, mode, file)) {
 		case 0:
 			list_move(&page->lru, dst);
 			mem_cgroup_del_lru(page);
@@ -1055,6 +1056,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			continue;
 
 		default:
+			printk(KERN_ERR "ret %d\n", ret);
 			BUG();
 		}
 
> Thank you Minchan for the pointer. I reverted the following commit and I
> haven't seen the problem with the same operation. I haven't looked deeply
> on the patch yet, but figured it would be a good idea to post the dump.
> The dump looks not directly related to this patchset, but ppl can use it to
> reproduce the problem.

I tested the patch with rsync + fadvise several times
in my machine(2P, 2G DRAM) but I didn't have ever seen the BUG.
But I didn't test it in memcg. As I look dump, it seems not related to memcg.
Anyway, I tried it to reproduce it in my machine.
Maybe I will start testing after next week. Sorry.

I hope my debugging patch givse some clues.
Thanks for the reporting, Ying. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
