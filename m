Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B86606B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 02:48:01 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so4660442pdj.6
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 23:48:01 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id pt10si3057728pac.96.2014.12.07.23.47.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 23:48:00 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 8 Dec 2014 15:47:47 +0800
Subject: [PATCH] mm:add VM_BUG_ON() for page_mapcount()
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313F5@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E688B313F1@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313F1@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'riel@redhat.com'" <riel@redhat.com>, "'nasa4836@gmail.com'" <nasa4836@gmail.com>, "'sasha.levin@oracle.com'" <sasha.levin@oracle.com>

This patch add VM_BUG_ON() for slab page,
because _mapcount is an union with slab struct in struct page,
avoid access _mapcount if this page is a slab page.
Also remove the unneeded bracket.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 include/linux/mm.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 11b65cf..34124c4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -373,7 +373,8 @@ static inline void reset_page_mapcount(struct page *pag=
e)
=20
 static inline int page_mapcount(struct page *page)
 {
-	return atomic_read(&(page)->_mapcount) + 1;
+	VM_BUG_ON(PageSlab(page));
+	return atomic_read(&page->_mapcount) + 1;
 }
=20
 static inline int page_count(struct page *page)
--=20
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
