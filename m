Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 613586B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 19:07:37 -0500 (EST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 1/4] zram: Fix deadlock bug in partial write
Date: Tue, 22 Jan 2013 09:07:30 +0900
Message-Id: <1358813253-20913-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jerome Marchand <jmarchan@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org

Now zram allocates new page with GFP_KERNEL in zram I/O path
if IO is partial. Unfortunately, It may cuase deadlock with
reclaim path so this patch solves the problem.

Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Jerome Marchand <jmarchan@redhat.com>
Cc: stable@vger.kernel.org
Signed-off-by: Minchan Kim <minchan@kernel.org>
---

We could use GFP_IO instead of GFP_ATOMIC in zram_bvec_read with
some modification related to buffer allocation in case of partial IO.
But it needs more churn and prevent merge this patch into stable
if we should send this to stable so I'd like to keep it as simple
as possbile. GFP_IO usage could be separate patch after we merge it.
Thanks.

 drivers/staging/zram/zram_drv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 61fb8f1..b285b3a 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -220,7 +220,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 	user_mem = kmap_atomic(page);
 	if (is_partial_io(bvec))
 		/* Use  a temporary buffer to decompress the page */
-		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		uncmem = kmalloc(PAGE_SIZE, GFP_ATOMIC);
 	else
 		uncmem = user_mem;
 
@@ -268,7 +268,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		 * This is a partial IO. We need to read the full page
 		 * before to write the changes.
 		 */
-		uncmem = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		uncmem = kmalloc(PAGE_SIZE, GFP_NOIO);
 		if (!uncmem) {
 			pr_info("Error allocating temp memory!\n");
 			ret = -ENOMEM;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
