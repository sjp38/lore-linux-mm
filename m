Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5EFAD6B00E6
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 12:44:42 -0400 (EDT)
Received: by bwz24 with SMTP id 24so844773bwz.38
        for <linux-mm@kvack.org>; Fri, 18 Sep 2009 09:44:45 -0700 (PDT)
Message-ID: <4AB3B8BF.1060302@vflare.org>
Date: Fri, 18 Sep 2009 22:13:43 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: [PATCH] ramzswap prefix for swap free callback
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
In-Reply-To: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

Swap free callback is used to inform the underlying block
device that a swap page has been freed. Currently, ramzswap
is the only user of this callback. So, rename swap notify
interface to reflect this.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>

---
 drivers/staging/ramzswap/ramzswap_drv.c |    4 ++--
 include/linux/swap.h                    |    7 ++++---
 mm/swapfile.c                           |   14 +++++++-------
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/ramzswap/ramzswap_drv.c b/drivers/staging/ramzswap/ramzswap_drv.c
index 46c387a..1a7167f 100644
--- a/drivers/staging/ramzswap/ramzswap_drv.c
+++ b/drivers/staging/ramzswap/ramzswap_drv.c
@@ -761,7 +761,7 @@ static int ramzswap_read(struct ramzswap *rzs, struct bio *bio)
 	index = bio->bi_sector >> SECTORS_PER_PAGE_SHIFT;

 	if (unlikely(!rzs->init_notify_callback) && PageSwapCache(page)) {
-		set_swap_free_notify(bio->bi_bdev, ramzswap_free_notify);
+		set_ramzswap_free_notify(bio->bi_bdev, ramzswap_free_notify);
 		rzs->init_notify_callback = 1;
 	}

@@ -1323,7 +1323,7 @@ static int ramzswap_ioctl(struct block_device *bdev, fmode_t mode,
 		 * can happen if another swapon is done before this reset.
 		 * TODO: A callback from swapoff() will solve this problem.
 		 */
-		set_swap_free_notify(bdev, NULL);
+		set_ramzswap_free_notify(bdev, NULL);
 		rzs->init_notify_callback = 0;
 		break;

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 64796fc..ace7900 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -21,7 +21,7 @@ struct bio;
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0

-typedef void (swap_free_notify_fn) (struct block_device *, unsigned long);
+typedef void (ramzswap_free_notify_fn) (struct block_device *, unsigned long);

 static inline int current_is_kswapd(void)
 {
@@ -158,7 +158,7 @@ struct swap_info_struct {
 	unsigned int max;
 	unsigned int inuse_pages;
 	unsigned int old_block_size;
-	swap_free_notify_fn *swap_free_notify_fn;
+	ramzswap_free_notify_fn *ramzswap_free_notify_fn;
 };

 struct swap_list_t {
@@ -299,7 +299,8 @@ extern sector_t swapdev_block(int, pgoff_t);
 extern struct swap_info_struct *get_swap_info_struct(unsigned);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
-extern void set_swap_free_notify(struct block_device *, swap_free_notify_fn *);
+extern void set_ramzswap_free_notify(struct block_device *,
+				ramzswap_free_notify_fn *);
 struct backing_dev_info;

 /* linux/mm/thrash.c */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index b165db0..0cc9c9c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -558,8 +558,8 @@ out:
  * Sets callback for event when swap_map[offset] == 0
  * i.e. page at this swap offset is no longer used.
  */
-void set_swap_free_notify(struct block_device *bdev,
-			swap_free_notify_fn *notify_fn)
+void set_ramzswap_free_notify(struct block_device *bdev,
+			ramzswap_free_notify_fn *notify_fn)
 {
 	unsigned int i;
 	struct swap_info_struct *sis;
@@ -579,12 +579,12 @@ void set_swap_free_notify(struct block_device *bdev,
 		return;
 	}

-	BUG_ON(!sis || sis->swap_free_notify_fn);
-	sis->swap_free_notify_fn = notify_fn;
+	BUG_ON(!sis || sis->ramzswap_free_notify_fn);
+	sis->ramzswap_free_notify_fn = notify_fn;
 	spin_unlock(&swap_lock);
 	return;
 }
-EXPORT_SYMBOL_GPL(set_swap_free_notify);
+EXPORT_SYMBOL_GPL(set_ramzswap_free_notify);

 static int swap_entry_free(struct swap_info_struct *p,
 			   swp_entry_t ent, int cache)
@@ -617,8 +617,8 @@ static int swap_entry_free(struct swap_info_struct *p,
 			swap_list.next = p - swap_info;
 		nr_swap_pages++;
 		p->inuse_pages--;
-		if (p->swap_free_notify_fn)
-			p->swap_free_notify_fn(p->bdev, offset);
+		if (p->ramzswap_free_notify_fn)
+			p->ramzswap_free_notify_fn(p->bdev, offset);
 	}
 	if (!swap_count(count))
 		mem_cgroup_uncharge_swap(ent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
