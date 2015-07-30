Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id DF52A9003C7
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:15:41 -0400 (EDT)
Received: by ykay190 with SMTP id y190so39297929yka.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:15:41 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id i6si1256352yke.58.2015.07.30.10.15.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:15:41 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 10/10] xen/balloon: pre-allocate p2m entries for ballooned pages
Date: Thu, 30 Jul 2015 18:03:12 +0100
Message-ID: <1438275792-5726-11-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>

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
index 3094f38f..e040cf4 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -593,6 +593,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
 {
 	int pgno = 0;
 	struct page *page;
+	int ret = -ENOMEM;
 
 	mutex_lock(&balloon_mutex);
 
@@ -602,6 +603,11 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
 		page = balloon_retrieve(true);
 		if (page) {
 			pages[pgno++] = page;
+#ifdef CONFIG_XEN_HAVE_PVMMU
+			ret = xen_alloc_p2m_entry(page_to_pfn(page));
+			if (ret < 0)
+				goto out_undo;
+#endif
 		} else {
 			ret = add_ballooned_pages(nr_pages - pgno);
 			if (ret < 0)
@@ -613,7 +619,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
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
