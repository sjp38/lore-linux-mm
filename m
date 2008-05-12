Received: by rv-out-0708.google.com with SMTP id f25so2585802rvb.26
        for <linux-mm@kvack.org>; Mon, 12 May 2008 03:32:09 -0700 (PDT)
From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/4] [mm] buddy page allocator: add tunable big order allocation
Date: Mon, 12 May 2008 18:32:02 +0800
Message-Id: <1210588325-11027-2-git-send-email-cooloney@kernel.org>
In-Reply-To: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
References: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
Sender: owner-linux-mm@kvack.org
From: Michael Hennerich <michael.hennerich@analog.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dwmw2@infradead.org
Cc: Michael Hennerich <michael.hennerich@analog.com>, Bryan Wu <cooloney@kernel.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 init/Kconfig    |    9 +++++++++
 mm/page_alloc.c |    2 +-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 6135d07..b6ff75b 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -742,6 +742,15 @@ config SLUB_DEBUG
 	  SLUB sysfs support. /sys/slab will not exist and there will be
 	  no support for cache validation etc.
 
+config BIG_ORDER_ALLOC_NOFAIL_MAGIC
+	int "Big Order Allocation No FAIL Magic"
+	depends on EMBEDDED
+	range 3 10
+	default 3
+	help
+	  Let big-order allocations loop until memory gets free. Specified Value
+	  expresses the order.
+
 choice
 	prompt "Choose SLAB allocator"
 	default SLUB
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bdd5c43..71b09b4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1631,7 +1631,7 @@ nofail_alloc:
 	pages_reclaimed += did_some_progress;
 	do_retry = 0;
 	if (!(gfp_mask & __GFP_NORETRY)) {
-		if (order <= PAGE_ALLOC_COSTLY_ORDER) {
+		if (order <= CONFIG_BIG_ORDER_ALLOC_NOFAIL_MAGIC) {
 			do_retry = 1;
 		} else {
 			if (gfp_mask & __GFP_REPEAT &&
-- 
1.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
