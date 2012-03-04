Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 923A46B002C
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 00:17:26 -0500 (EST)
Received: by vcbfk14 with SMTP id fk14so3400769vcb.14
        for <linux-mm@kvack.org>; Sat, 03 Mar 2012 21:17:25 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 4 Mar 2012 13:17:25 +0800
Message-ID: <CAJd=RBBYdY1rgoW+0bgKh6Cn8n=guB2_zq2nzaMr8-arqNkr_A@mail.gmail.com>
Subject: [PATCH] mm: shmem: unlock valid page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

In shmem_read_mapping_page_gfp() page is unlocked if no error returned,
so the unlocked page has to valid.

To guarantee that validity, when getting page, success result is feed
back to caller only when page is valid.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/shmem.c	Sun Mar  4 12:17:42 2012
+++ b/mm/shmem.c	Sun Mar  4 12:26:56 2012
@@ -889,13 +889,13 @@ repeat:
 		goto failed;
 	}

-	if (page || (sgp == SGP_READ && !swap.val)) {
+	if (page) {
 		/*
 		 * Once we can get the page lock, it must be uptodate:
 		 * if there were an error in reading back from swap,
 		 * the page would not be inserted into the filecache.
 		 */
-		BUG_ON(page && !PageUptodate(page));
+		BUG_ON(!PageUptodate(page));
 		*pagep = page;
 		return 0;
 	}
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
