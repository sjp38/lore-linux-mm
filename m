Received: by rv-out-0910.google.com with SMTP id l15so2156038rvb
        for <linux-mm@kvack.org>; Sun, 02 Dec 2007 03:59:44 -0800 (PST)
From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] mm/backing-dev.c: fix percpu_counter_destroy call bug in bdi_init
Date: Sun,  2 Dec 2007 19:59:07 +0800
Message-Id: <1196596747-5932-1-git-send-email-crquan@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>
Cc: stable@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

this call should use the array index j, not i:

	--- mm/backing-dev.c.orig	2007-12-02 19:42:57.000000000 +0800
	+++ mm/backing-dev.c	2007-12-02 19:43:14.000000000 +0800
	@@ -22,7 +22,7 @@ int bdi_init(struct backing_dev_info *bd
		if (err) {
	 err:
			for (j = 0; j < i; j++)
	-			percpu_counter_destroy(&bdi->bdi_stat[i]);
	+			percpu_counter_destroy(&bdi->bdi_stat[j]);
		}

		return err;

but with this approach, just one int i is enough, int j is not needed.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 mm/backing-dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index b0ceb29..e8644b1 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -7,7 +7,7 @@
 
 int bdi_init(struct backing_dev_info *bdi)
 {
-	int i, j;
+	int i;
 	int err;
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
@@ -21,7 +21,7 @@ int bdi_init(struct backing_dev_info *bdi)
 
 	if (err) {
 err:
-		for (j = 0; j < i; j++)
+		while (i--)
 			percpu_counter_destroy(&bdi->bdi_stat[i]);
 	}
 
-- 
1.5.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
