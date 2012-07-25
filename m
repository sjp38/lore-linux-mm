Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 1DC836B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 14:53:16 -0400 (EDT)
Date: Wed, 25 Jul 2012 14:51:19 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] remove __GFP_NO_KSWAPD fixes
Message-ID: <20120725145119.75be021d@cuia.bos.redhat.com>
In-Reply-To: <20120724111222.2c5e6b30@annuminas.surriel.com>
References: <20120724111222.2c5e6b30@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Artem Bityutskiy <artem.bityutskiy@linux.intel.com>, David Woodhouse <David.Woodhouse@intel.com>, Minchan Kim <minchan.kim@gmail.com>

Turns out I missed two spots where __GFP_NO_KSWAPD is used.

The removal from the trace code is obvious, since the flag
got removed there is no need to print it.

For mtdcore.c, now that memory compaction has been fixed,
we should no longer see large swap storms from an attempt
to allocate a large buffer, removing the need to specify
__GFP_NO_KSWAPD.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 drivers/mtd/mtdcore.c           |    3 +--
 include/trace/events/gfpflags.h |    1 -
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/mtd/mtdcore.c b/drivers/mtd/mtdcore.c
index 9a9ce71..af1e932 100644
--- a/drivers/mtd/mtdcore.c
+++ b/drivers/mtd/mtdcore.c
@@ -761,8 +761,7 @@ EXPORT_SYMBOL_GPL(mtd_writev);
  */
 void *mtd_kmalloc_up_to(const struct mtd_info *mtd, size_t *size)
 {
-	gfp_t flags = __GFP_NOWARN | __GFP_WAIT |
-		       __GFP_NORETRY | __GFP_NO_KSWAPD;
+	gfp_t flags = __GFP_NOWARN | __GFP_WAIT | __GFP_NORETRY;
 	size_t min_alloc = max_t(size_t, mtd->writesize, PAGE_SIZE);
 	void *kbuf;
 
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
index 9fe3a36..8ffc050 100644
--- a/include/trace/events/gfpflags.h
+++ b/include/trace/events/gfpflags.h
@@ -35,7 +35,6 @@
 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
 	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
 	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
-	{(unsigned long)__GFP_NO_KSWAPD,	"GFP_NO_KSWAPD"},	\
 	{(unsigned long)__GFP_OTHER_NODE,	"GFP_OTHER_NODE"}	\
 	) : "GFP_NOWAIT"
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
