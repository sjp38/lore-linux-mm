Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 11D556B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 22:49:17 -0400 (EDT)
Message-ID: <5091E485.7090409@cn.fujitsu.com>
Date: Thu, 01 Nov 2012 10:55:01 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memory-hotplug: fix NR_FREE_PAGES mismatch's fix
References: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com> <1351682594-17347-4-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351682594-17347-4-git-send-email-wency@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rjw@sisk.pl, Lai Jiangshan <laijs@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Jianguo wu <wujianguo@huawei.com>

When a page is freed and put into pcp list, get_freepage_migratetype()
doesn't return MIGRATE_ISOLATE even if this pageblock is isolated.
So we should use get_pageblock_migratetype() instead of mt to check
whether it is isolated.

Cc: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Len Brown <len.brown@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Jianguo Wu <wujianguo@huawei.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 027afd0..e9c19d2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -667,7 +667,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
-			if (likely(mt != MIGRATE_ISOLATE)) {
+			if (likely(mt != get_pageblock_migratetype(page))) {
 				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
 				if (is_migrate_cma(mt))
 					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
