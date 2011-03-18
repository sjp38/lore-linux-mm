Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31C2F8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 08:54:38 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 13so5447379iyf.14
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 05:54:37 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 2/3] memcg: fix off-by-one when calculating swap cgroup map length
Date: Fri, 18 Mar 2011 21:54:14 +0900
Message-Id: <1300452855-10194-2-git-send-email-namhyung@gmail.com>
In-Reply-To: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

It allocated one more page than necessary if @max_pages was
a multiple of SC_PER_PAGE.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 2d1a0fa01d7b..29951abc852e 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -446,7 +446,7 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
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
