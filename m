Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 68BC76B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 07:01:04 -0400 (EDT)
Message-ID: <51960DB6.30808@asianux.com>
Date: Fri, 17 May 2013 19:00:06 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/page_alloc.c: add additional checking and return value
 for the 'table->data'
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, minchan@kernel.org, m.szyprowski@samsung.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


If 'table->data' is invalid, also need check its length to know whether
is invalid, firstly.

When __parse_numa_zonelist_order() fails, also need save the related
error code for return.

Beautify code ('char*' --> 'char *') to pass "./scripts/checkpatch.pl"


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/page_alloc.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0a0acfe..48c83e4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3250,18 +3250,25 @@ int numa_zonelist_order_handler(ctl_table *table, int write,
 	static DEFINE_MUTEX(zl_order_mutex);
 
 	mutex_lock(&zl_order_mutex);
-	if (write)
-		strcpy(saved_string, (char*)table->data);
+	if (write) {
+		if (strlen((char *)table->data) >= NUMA_ZONELIST_ORDER_LEN) {
+			ret = -EINVAL;
+			goto out;
+		}
+		strcpy(saved_string, (char *)table->data);
+	}
 	ret = proc_dostring(table, write, buffer, length, ppos);
 	if (ret)
 		goto out;
 	if (write) {
 		int oldval = user_zonelist_order;
-		if (__parse_numa_zonelist_order((char*)table->data)) {
+
+		ret = __parse_numa_zonelist_order((char *)table->data);
+		if (ret) {
 			/*
 			 * bogus value.  restore saved string
 			 */
-			strncpy((char*)table->data, saved_string,
+			strncpy((char *)table->data, saved_string,
 				NUMA_ZONELIST_ORDER_LEN);
 			user_zonelist_order = oldval;
 		} else if (oldval != user_zonelist_order) {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
