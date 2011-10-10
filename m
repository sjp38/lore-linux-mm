Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 517B86B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 07:11:48 -0400 (EDT)
From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 1/9] mm: add a "struct subpage" type containing a page, offset and length
Date: Mon, 10 Oct 2011 12:11:33 +0100
Message-ID: <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: Ian Campbell <ian.campbell@citrix.com>, linux-mm@kvack.org

A few network drivers currently use skb_frag_struct for this purpose but I have
patches which add additional fields and semantics there which these other uses
do not want.

A structure for reference sub-page regions seems like a generally useful thing
so do so instead of adding a network subsystem specific structure.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: linux-mm@kvack.org
---
 include/linux/mm_types.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 774b895..dc1d103 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -135,6 +135,17 @@ struct page {
 #endif
 ;
 
+struct subpage {
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
