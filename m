Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 12EC26B011C
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:45:17 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id kp6so9313022pab.21
        for <linux-mm@kvack.org>; Wed, 29 May 2013 07:45:17 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH, v2 01/13] mm: introduce helper function set_max_mapnr()
Date: Wed, 29 May 2013 22:44:40 +0800
Message-Id: <1369838692-26860-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
References: <1369838692-26860-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mauro Carvalho Chehab <mchehab@redhat.com>, "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@opensource.wolfsonmicro.com>

Introduce an helper function set_max_mapnr() to set global variable
max_mapnr.

Also unify condition compilation for max_mapnr with
CONFIG_NEED_MULTIPLE_NODES instead of CONFIG_DISCONTIGMEM.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/mm.h | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7e39aa1..bde812e 100644
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
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
