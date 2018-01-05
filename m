Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D98DC280276
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 08:02:36 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r63so497305wmb.9
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 05:02:36 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id j134si3567162wmj.210.2018.01.05.05.02.35
        for <linux-mm@kvack.org>;
        Fri, 05 Jan 2018 05:02:35 -0800 (PST)
Date: Fri, 5 Jan 2018 14:02:35 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm/page_ext.c: Make page_ext_init a noop when
 CONFIG_PAGE_EXTENSION but nothing uses it
Message-ID: <20180105130235.GA21241@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, jaewon31.kim@samsung.com

static struct page_ext_operations *page_ext_ops[] always contains debug_guardpage_ops,

static struct page_ext_operations *page_ext_ops[] = {
        &debug_guardpage_ops,
 #ifdef CONFIG_PAGE_OWNER
        &page_owner_ops,
 #endif
...
}

but for it to work, CONFIG_DEBUG_PAGEALLOC must be enabled first.
If someone has CONFIG_PAGE_EXTENSION, but has none of its users,
eg: (CONFIG_PAGE_OWNER, CONFIG_DEBUG_PAGEALLOC, CONFIG_IDLE_PAGE_TRACKING), we can shrink page_ext_init()
to a simple retq.

$ size vmlinux  (before patch)
   text	   data	    bss	    dec	    hex	filename
14356698	5681582	1687748	21726028	14b834c	vmlinux

$ size vmlinux  (after patch)
   text	   data	    bss	    dec	    hex	filename
14356008	5681538	1687748	21725294	14b806e	vmlinux

On the other hand, it might does not even make sense, since if someone
enables CONFIG_PAGE_EXTENSION, I would expect him to enable also at least
one of its users, but I wanted to see what you guys think.

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/page_ext.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 2c16216c29b6..5295ef331165 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -59,7 +59,9 @@
  */
 
 static struct page_ext_operations *page_ext_ops[] = {
+#ifdef CONFIG_DEBUG_PAGEALLOC
 	&debug_guardpage_ops,
+#endif
 #ifdef CONFIG_PAGE_OWNER
 	&page_owner_ops,
 #endif
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
