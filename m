Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2306B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 06:03:03 -0400 (EDT)
From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] mm: add a "struct page_frag" type containing a page, offset and length
Date: Thu, 13 Oct 2011 11:02:56 +0100
Message-ID: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ian Campbell <ian.campbell@citrix.com>, Christoph Hellwig <hch@infradead.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm@kvack.org

A few network drivers currently use skb_frag_struct for this purpose but I have
patches which add additional fields and semantics there which these other uses
do not want.

A structure for reference sub-page regions seems like a generally useful thing
so do so instead of adding a network subsystem specific structure.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <jaxboe@fusionio.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
[since v1: s/struct subpage/struct page_frag/ on advice from Christoph]
---
 include/linux/mm_types.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 774b895..575faaf 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -135,6 +135,17 @@ struct page {
 #endif
 ;
 
+struct page_frag {
+	struct page *page;
+#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
+	__u32 page_offset;
+	__u32 size;
+#else
+	__u16 page_offset;
+	__u16 size;
+#endif
+};
+
 typedef unsigned long __nocast vm_flags_t;
 
 /*
-- 
1.7.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
