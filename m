Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 474E48D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 22:36:00 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 42so724778iyh.14
        for <linux-mm@kvack.org>; Mon, 11 Apr 2011 19:35:59 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH RESEND 2/4] memcg: fix off-by-one when calculating swap cgroup map length
Date: Tue, 12 Apr 2011 11:35:35 +0900
Message-Id: <1302575737-6401-2-git-send-email-namhyung@gmail.com>
In-Reply-To: <1302575737-6401-1-git-send-email-namhyung@gmail.com>
References: <1302575737-6401-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

It allocated one more page than necessary if @max_pages was
a multiple of SC_PER_PAGE.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 mm/page_cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 81205c52735c..e7208105203c 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -475,7 +475,7 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 	if (!do_swap_account)
 		return 0;
 
-	length = ((max_pages/SC_PER_PAGE) + 1);
+	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
 	array_size = length * sizeof(void *);
 
 	array = vmalloc(array_size);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
