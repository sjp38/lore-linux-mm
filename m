Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id C2AE86B0031
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 12:30:07 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so2793496pdj.28
        for <linux-mm@kvack.org>; Mon, 01 Jul 2013 09:30:07 -0700 (PDT)
Message-ID: <51D1AE84.8010404@gmail.com>
Date: Tue, 02 Jul 2013 00:29:56 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm, slab: Drop unnecessary slabp->inuse < cachep->num test
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org, cl@linux-foundation.org, mpm@selenic.com
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

In function cache_alloc_refill, we have used BUG_ON to ensure
that slabp->inuse is less than cachep->num before the while
test. And in the while body, we do not change the value of
slabp->inuse and cachep->num, so it is not necessary to test
if slabp->inuse < cachep->num test for every loop.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/slab.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 8ccd296..c2076c2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3004,7 +3004,7 @@ retry:
 		 */
 		BUG_ON(slabp->inuse >= cachep->num);
 
-		while (slabp->inuse < cachep->num && batchcount--) {
+		while (batchcount--) {
 			STATS_INC_ALLOCED(cachep);
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
