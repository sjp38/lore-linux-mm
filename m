Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 11C3A6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 15:41:06 -0400 (EDT)
Received: by lagg8 with SMTP id g8so112171048lag.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 12:41:05 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id qy3si7675922lbc.117.2015.03.30.12.41.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 12:41:04 -0700 (PDT)
Received: by lbcmq2 with SMTP id mq2so102648689lbc.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 12:41:03 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] mm/mmap.c: use while instead of if+goto
Date: Mon, 30 Mar 2015 21:40:35 +0200
Message-Id: <1427744435-6304-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Roman Gushchin <klamm@yandex-team.ru>
Cc: Hugh Dickins <hughd@google.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The creators of the C language gave us the while keyword. Let's use
that instead of synthesizing it from if+goto.

Made possible by 6597d783397a ("mm/mmap.c: replace find_vma_prepare()
with clearer find_vma_links()").

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 mm/mmap.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index da9990acc08b..e1ae629b1e9c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1553,11 +1553,9 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 
 	/* Clear old maps */
 	error = -ENOMEM;
-munmap_back:
-	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
+	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
-		goto munmap_back;
 	}
 
 	/*
@@ -2741,11 +2739,9 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	/*
 	 * Clear old maps.  this also does some error checking for us
 	 */
- munmap_back:
-	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
+	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
-		goto munmap_back;
 	}
 
 	/* Check against address space limits *after* clearing old maps... */
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
