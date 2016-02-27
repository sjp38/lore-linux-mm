Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3943E6B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 06:42:50 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id bc4so58897525lbc.2
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 03:42:50 -0800 (PST)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id d66si8108825lfd.149.2016.02.27.03.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Feb 2016 03:42:48 -0800 (PST)
Received: by mail-lf0-x234.google.com with SMTP id l143so67362520lfe.2
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 03:42:48 -0800 (PST)
Subject: [PATCH 1/3] radix-tree: fix bug in radix_tree_iter_next() for
 tagged iteration
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Feb 2016 14:42:44 +0300
Message-ID: <145657336413.9016.2011291702664991604.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org

Helper radix_tree_iter_next reset slot to NULL and next_index to index + 1,
for tagger iteraction it also must reset cached tags in iterator to abort
next radix_tree_next_slot and go to slow-path into radix_tree_next_chunk.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/radix-tree.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index a59f940a54f5..51a97ac8bfbf 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -414,6 +414,7 @@ static inline __must_check
 void **radix_tree_iter_next(struct radix_tree_iter *iter)
 {
 	iter->next_index = iter->index + 1;
+	iter->tags = 0;
 	return NULL;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
