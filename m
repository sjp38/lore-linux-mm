Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA6DC6B0267
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 03:35:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so157638397pgd.3
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 00:35:28 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d85si43639320pfb.163.2016.11.25.00.35.27
        for <linux-mm@kvack.org>;
        Fri, 25 Nov 2016 00:35:27 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 1/3] mm: support anonymous stable page
Date: Fri, 25 Nov 2016 17:35:12 +0900
Message-Id: <1480062914-25556-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1480062914-25556-1-git-send-email-minchan@kernel.org>
References: <1480062914-25556-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "Darrick J . Wong" <darrick.wong@oracle.com>, stable@vger.kernel.org

During developemnt for zram-swap asynchronous writeback, I found strange
corruption of compressed page.

Modules linked in: zram(E)
CPU: 3 PID: 1520 Comm: zramd-1 Tainted: G            E   4.8.0-mm1-00320-ge0d4894c9c38-dirty #3274
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
task: ffff88007620b840 task.stack: ffff880078090000
RIP: 0010:[<ffffffff811d6f3d>]  [<ffffffff811d6f3d>] set_freeobj.part.43+0x1c/0x1f
RSP: 0018:ffff880078093ca8  EFLAGS: 00010246
RAX: 0000000000000018 RBX: ffff880076798d88 RCX: ffffffff81c408c8
RDX: 0000000000000018 RSI: 0000000000000000 RDI: 0000000000000246
RBP: ffff880078093cb0 R08: 0000000000000000 R09: 0000000000000000
R10: ffff88005bc43030 R11: 0000000000001df3 R12: ffff880076798d88
R13: 000000000005bc43 R14: ffff88007819d1b8 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff88007e380000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fc934048f20 CR3: 0000000077b01000 CR4: 00000000000406e0
Stack:
 ffffea00016f10c0 ffff880078093d08 ffffffff811d43cb ffff88005bc43030
 ffff88005bc43030 0000000000000001 ffff88007aa17f68 ffff88007819d1b8
 000000000200020a 0000000002000200 ffff880076798d88 ffff88007aa17f68
Call Trace:
 [<ffffffff811d43cb>] obj_malloc+0x22b/0x260
 [<ffffffff811d4be4>] zs_malloc+0x1e4/0x580
 [<ffffffff81355490>] ? lz4_compress_crypto+0x30/0x50
 [<ffffffffa000269d>] zram_bvec_rw+0x4cd/0x830 [zram]
 [<ffffffffa000356c>] page_requests_rw+0x9c/0x130 [zram]
 [<ffffffffa0003600>] ? page_requests_rw+0x130/0x130 [zram]
 [<ffffffffa00036e6>] zram_thread+0xe6/0x173 [zram]
 [<ffffffff810b67e0>] ? wake_atomic_t_function+0x60/0x60
 [<ffffffff81094cfa>] kthread+0xca/0xe0
 [<ffffffff81094c30>] ? kthread_park+0x60/0x60
 [<ffffffff817ae775>] ret_from_fork+0x25/0x30

With investigation, it reveals currently stable page doesn't support
anonymous page.  IOW, reuse_swap_page can reuse the page without waiting
writeback completion so it can overwrite page zram is compressing.

Unfortunately, zram has used per-cpu stream feature from v4.7.
It aims for increasing cache hit ratio of scratch buffer for
compressing. Downside of that approach is that zram should ask
memory space for compressed page in per-cpu context which requires
stricted gfp flag which could be failed. If so, it retries to
allocate memory space out of per-cpu context so it could get memory
this time and compress the data again, copies it to the memory space.

In this scenario, zram assumes the data should never be changed
but it is not true unless stable page supports. So, If the data is
changed under us, zram can make buffer overrun because second
compression size could be bigger than one we got in previous trial
and blindly, copy bigger size object to smaller buffer which is
buffer overrun. The overrun breaks zsmalloc free object chaining
so system goes crash like above.

I think below is same problem.
https://bugzilla.suse.com/show_bug.cgi?id=997574

Unfortunately, reuse_swap_page should be atomic so that we cannot wait on
writeback in there so the approach in this patch is simply return false if
we found it needs stable page.  Although it increases memory footprint
temporarily, it happens rarely and it should be reclaimed easily althoug
it happened.  Also, It would be better than waiting of IO completion,
which is critial path for application latency.

Fixes: da9556a2367c ("zram: user per-cpu compression streams")
Link: http://lkml.kernel.org/r/20161120233015.GA14113@bbox
Signed-off-by: Minchan Kim <minchan@kernel.org>
Acked-by: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: stable@vger.kernel.org
---
 include/linux/swap.h |  3 ++-
 mm/swapfile.c        | 20 +++++++++++++++++++-
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 09f4be179ff3..7f47b7098b1b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -150,8 +150,9 @@ enum {
 	SWP_FILE	= (1 << 7),	/* set after swap_activate success */
 	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
 	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
+	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 10),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 11),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f30438970cd1..d76b2a18f044 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -943,11 +943,25 @@ bool reuse_swap_page(struct page *page, int *total_mapcount)
 	count = page_trans_huge_mapcount(page, total_mapcount);
 	if (count <= 1 && PageSwapCache(page)) {
 		count += page_swapcount(page);
-		if (count == 1 && !PageWriteback(page)) {
+		if (count != 1)
+			goto out;
+		if (!PageWriteback(page)) {
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
+		} else {
+			swp_entry_t entry;
+			struct swap_info_struct *p;
+
+			entry.val = page_private(page);
+			p = swap_info_get(entry);
+			if (p->flags & SWP_STABLE_WRITES) {
+				spin_unlock(&p->lock);
+				return false;
+			}
+			spin_unlock(&p->lock);
 		}
 	}
+out:
 	return count <= 1;
 }
 
@@ -2449,6 +2463,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		error = -ENOMEM;
 		goto bad_swap;
 	}
+
+	if (bdi_cap_stable_pages_required(inode_to_bdi(inode)))
+		p->flags |= SWP_STABLE_WRITES;
+
 	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 		int cpu;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
