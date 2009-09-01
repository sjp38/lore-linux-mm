Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D4E286B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 05:34:06 -0400 (EDT)
Date: Tue, 1 Sep 2009 10:33:31 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [mmotm][BUG] free is bigger than presnet Re: mmotm 2009-08-27-16-51
 uploaded
In-Reply-To: <20090901180032.55f7b8ca.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0909011031140.13740@sister.anvils>
References: <200908272355.n7RNtghC019990@imap1.linux-foundation.org>
 <20090901180032.55f7b8ca.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009, KAMEZAWA Hiroyuki wrote:
> 
> I'm not digggin so much but /proc/meminfo corrupted.
> 
> [kamezawa@bluextal cgroup]$ cat /proc/meminfo
> MemTotal:       24421124 kB
> MemFree:        38314388 kB

If that's without my fix to shrink_active_list(), I'd try again with.
Hugh

[PATCH mmotm] vmscan move pgdeactivate modification to shrink_active_list fix

mmotm 2009-08-27-16-51 lets the OOM killer loose on my loads even
quicker than last time: one bug fixed but another bug introduced.
vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
forgot to add NR_LRU_BASE to lru index to make zone_page_state index.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/vmscan.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- mmotm/mm/vmscan.c	2009-08-28 10:07:57.000000000 +0100
+++ linux/mm/vmscan.c	2009-08-28 18:30:33.000000000 +0100
@@ -1381,8 +1381,10 @@ static void shrink_active_list(unsigned
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 	__count_vm_events(PGDEACTIVATE, nr_deactivated);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	__mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
-	__mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
+	__mod_zone_page_state(zone, NR_ACTIVE_ANON + file * LRU_FILE,
+							nr_rotated);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON + file * LRU_FILE,
+							nr_deactivated);
 	spin_unlock_irq(&zone->lru_lock);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
