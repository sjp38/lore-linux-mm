Subject: Re: [RFC][PATCH 0/6] per device dirty throttling
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1174383938.16478.22.camel@twins>
References: <20070319155737.653325176@programming.kicks-ass.net>
	 <20070320074751.GP32602149@melbourne.sgi.com>
	 <1174378104.16478.17.camel@twins>
	 <20070320093845.GQ32602149@melbourne.sgi.com>
	 <1174383938.16478.22.camel@twins>
Content-Type: text/plain
Date: Tue, 20 Mar 2007 16:38:43 +0100
Message-Id: <1174405123.16478.28.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

This seems to fix the worst of it, I'll run with it for a few days and
respin the patches and repost when nothing weird happens.

---
Found missing bdi_stat_init() sites for NFS and Fuse

Optimize bdi_writeout_norm(), break out of the loop when we hit zero. This will
allow 'new' BDIs to catch up without triggering NMI/softlockup msgs.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/fuse/inode.c     |    1 +
 fs/nfs/client.c     |    1 +
 mm/page-writeback.c |   25 +++++++++++++++++++------
 3 files changed, 21 insertions(+), 6 deletions(-)

Index: linux-2.6/fs/nfs/client.c
===================================================================
--- linux-2.6.orig/fs/nfs/client.c
+++ linux-2.6/fs/nfs/client.c
@@ -657,6 +657,7 @@ static void nfs_server_set_fsinfo(struct
 		server->rsize = NFS_MAX_FILE_IO_SIZE;
 	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
+	bdi_stat_init(&server->backing_dev_info);
 
 	if (server->wsize > max_rpc_payload)
 		server->wsize = max_rpc_payload;
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -114,6 +114,13 @@ static void background_writeout(unsigned
  *
  * Furthermore, when we choose thresh to be 2^n it can be written in terms of
  * binary operations and wraparound artifacts disappear.
+ *
+ * Also note that this yields a natural counter of the elapsed periods:
+ *
+ *   i / thresh
+ *
+ * Its monotonous increasing property can be applied to mitigate the wrap-
+ * around issue.
  */
 static int vm_cycle_shift __read_mostly;
 
@@ -125,19 +132,25 @@ static void bdi_writeout_norm(struct bac
 	int bits = vm_cycle_shift;
 	unsigned long cycle = 1UL << bits;
 	unsigned long mask = ~(cycle - 1);
-	unsigned long total = __global_bdi_stat(BDI_WRITEOUT_TOTAL) << 1;
+	unsigned long global_cycle =
+		(__global_bdi_stat(BDI_WRITEOUT_TOTAL) << 1) & mask;
 	unsigned long flags;
 
-	if ((bdi->cycles & mask) == (total & mask))
+	if ((bdi->cycles & mask) == global_cycle)
 		return;
 
 	spin_lock_irqsave(&bdi->lock, flags);
-	while ((bdi->cycles & mask) != (total & mask)) {
-		unsigned long half = __bdi_stat(bdi, BDI_WRITEOUT) / 2;
+	while ((bdi->cycles & mask) != global_cycle) {
+		unsigned long val = __bdi_stat(bdi, BDI_WRITEOUT);
+		unsigned long half = (val + 1) / 2;
+
+		if (!val)
+			break;
 
 		mod_bdi_stat(bdi, BDI_WRITEOUT, -half);
 		bdi->cycles += cycle;
 	}
+	bdi->cycles = global_cycle;
 	spin_unlock_irqrestore(&bdi->lock, flags);
 }
 
@@ -146,10 +159,10 @@ static void bdi_writeout_inc(struct back
 	if (!bdi_cap_writeback_dirty(bdi))
 		return;
 
+	bdi_writeout_norm(bdi);
+
 	__inc_bdi_stat(bdi, BDI_WRITEOUT);
 	__inc_bdi_stat(bdi, BDI_WRITEOUT_TOTAL);
-
-	bdi_writeout_norm(bdi);
 }
 
 void get_writeout_scale(struct backing_dev_info *bdi, int *scale, int *div)
Index: linux-2.6/fs/fuse/inode.c
===================================================================
--- linux-2.6.orig/fs/fuse/inode.c
+++ linux-2.6/fs/fuse/inode.c
@@ -413,6 +413,7 @@ static struct fuse_conn *new_conn(void)
 		atomic_set(&fc->num_waiting, 0);
 		fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 		fc->bdi.unplug_io_fn = default_unplug_io_fn;
+		bdi_stat_init(&fc->bdi);
 		fc->reqctr = 0;
 		fc->blocked = 1;
 		get_random_bytes(&fc->scramble_key, sizeof(fc->scramble_key));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
