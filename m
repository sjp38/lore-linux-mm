Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 31E296B015A
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 17:53:24 -0400 (EDT)
Date: Sat, 30 Oct 2010 23:43:05 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] kmemleak: remove memset by using kzalloc
Message-ID: <alpine.LNX.2.00.1010302340260.1572@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>
List-ID: <linux-mm.kvack.org>

We don't need to memset if we just use kzalloc() rather than kmalloc() in 
kmemleak_test_init().

(please CC on replies)


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 kmemleak-test.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/kmemleak-test.c b/mm/kmemleak-test.c
index 177a516..ff0d977 100644
--- a/mm/kmemleak-test.c
+++ b/mm/kmemleak-test.c
@@ -75,13 +75,11 @@ static int __init kmemleak_test_init(void)
 	 * after the module is removed.
 	 */
 	for (i = 0; i < 10; i++) {
-		elem = kmalloc(sizeof(*elem), GFP_KERNEL);
-		pr_info("kmemleak: kmalloc(sizeof(*elem)) = %p\n", elem);
+		elem = kzalloc(sizeof(*elem), GFP_KERNEL);
+		pr_info("kmemleak: kzalloc(sizeof(*elem)) = %p\n", elem);
 		if (!elem)
 			return -ENOMEM;
-		memset(elem, 0, sizeof(*elem));
 		INIT_LIST_HEAD(&elem->list);
-
 		list_add_tail(&elem->list, &test_list);
 	}
 


-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
