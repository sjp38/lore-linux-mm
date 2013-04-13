Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 19FB46B0006
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 11:40:27 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx1so1927990pab.14
        for <linux-mm@kvack.org>; Sat, 13 Apr 2013 08:40:26 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 01/19] mm: introduce accessor function set_max_mapnr()
Date: Sat, 13 Apr 2013 23:36:21 +0800
Message-Id: <1365867399-21323-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Introduce accessor function set_max_mapnr() to set global variable
max_mapnr.

Also unify condition compilation for max_mapnr with
CONFIG_NEED_MULTIPLE_NODES instead of CONFIG_DISCONTIGMEM.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 include/linux/mm.h |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f9f9f3c..497ebaf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -25,8 +25,15 @@ struct file_ra_state;
 struct user_struct;
 struct writeback_control;
 
-#ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
+#ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
+
+static inline void set_max_mapnr(unsigned long limit)
+{
+	max_mapnr = limit;
+}
+#else
+static inline void set_max_mapnr(unsigned long limit) { }
 #endif
 
 extern unsigned long totalram_pages;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
