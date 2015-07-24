Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2C62D6B025B
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 08:15:20 -0400 (EDT)
Received: by ykay190 with SMTP id y190so17816498yka.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 05:15:20 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id b201si5935620ykb.20.2015.07.24.05.15.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 05:15:19 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 10/10] xen/balloon: pre-allocate p2m entries for ballooned pages
Date: Fri, 24 Jul 2015 12:47:48 +0100
Message-ID: <1437738468-24110-11-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

Pages returned by alloc_xenballooned_pages() will be used for grant
mapping which will call set_phys_to_machine() (in PV guests).

Ballooned pages are set as INVALID_P2M_ENTRY in the p2m and thus may
be using the (shared) missing tables and a subsequent
set_phys_to_machine() will need to allocate new tables.

Since the grant mapping may be done from a context that cannot sleep,
the p2m entries must already be allocated.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/xen/balloon.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index fd6970f3..8932d10 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -541,6 +541,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
 {
 	int pgno = 0;
 	struct page *page;
+	int ret = -ENOMEM;
 
 	mutex_lock(&balloon_mutex);
 
@@ -550,6 +551,11 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
 		page = balloon_retrieve(true);
 		if (page) {
 			pages[pgno++] = page;
+#ifdef CONFIG_XEN_HAVE_PVMMU
+			ret = xen_alloc_p2m_entry(page_to_pfn(page));
+			if (ret < 0)
+				goto out_undo;
+#endif
 		} else {
 			enum bp_state st;
 
@@ -576,7 +582,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
  out_undo:
 	mutex_unlock(&balloon_mutex);
 	free_xenballooned_pages(pgno, pages);
-	return -ENOMEM;
+	return ret;
 }
 EXPORT_SYMBOL(alloc_xenballooned_pages);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
