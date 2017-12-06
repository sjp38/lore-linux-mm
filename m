Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE586B031A
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:25:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j3so1829724pfh.16
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:25:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q127si995274pga.753.2017.12.05.18.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 18:25:22 -0800 (PST)
Received: from willy by bombadil.infradead.org with local (Exim 4.87 #1 (Red Hat Linux))
	id 1eMPOj-0001Ks-Eh
	for linux-mm@kvack.org; Wed, 06 Dec 2017 02:25:21 +0000
Date: Tue, 5 Dec 2017 18:25:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] Get 7% more pages in a pagevec
Message-ID: <20171206022521.GM26021@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


7% sounds so much more impressive than one more, right?

I just noticed that we *could* do this when I was looking at pagevec.h.
I have no idea how much this will affect performance.  Probably minimally,
but I'm hoping to see a report from 0day as a result of posting this
patch ;-)

--- 8< ---

From: Matthew Wilcox <mawilcox@microsoft.com>

We don't have to use an entire 'long' for the number of elements in the
pagevec; we know it's a number between 0 and 14 (now 15).  So we can
store it in a char, and then the bool packs next to it and we still have
two or six bytes of padding for more elements in the header.  That gives
us space to cram in an extra page.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 5fb6580f7f23..6dc456ac6136 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -9,14 +9,14 @@
 #ifndef _LINUX_PAGEVEC_H
 #define _LINUX_PAGEVEC_H
 
-/* 14 pointers + two long's align the pagevec structure to a power of two */
-#define PAGEVEC_SIZE	14
+/* 15 pointers + header align the pagevec structure to a power of two */
+#define PAGEVEC_SIZE	15
 
 struct page;
 struct address_space;
 
 struct pagevec {
-	unsigned long nr;
+	unsigned char nr;
 	bool percpu_pvec_drained;
 	struct page *pages[PAGEVEC_SIZE];
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
