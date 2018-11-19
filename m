Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB4E46B1A3B
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:17:10 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id j125so1655168qke.12
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 02:17:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d12si1592659qtc.207.2018.11.19.02.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 02:17:09 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 6/8] vmw_balloon: mark inflated pages PG_offline
Date: Mon, 19 Nov 2018 11:16:14 +0100
Message-Id: <20181119101616.8901-7-david@redhat.com>
In-Reply-To: <20181119101616.8901-1-david@redhat.com>
References: <20181119101616.8901-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, David Hildenbrand <david@redhat.com>, Xavier Deguillard <xdeguillard@vmware.com>, Nadav Amit <namit@vmware.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Julien Freche <jfreche@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

Mark inflated and never onlined pages PG_offline, to tell the world that
the content is stale and should not be dumped.

Cc: Xavier Deguillard <xdeguillard@vmware.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Julien Freche <jfreche@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/misc/vmw_balloon.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/misc/vmw_balloon.c b/drivers/misc/vmw_balloon.c
index e6126a4b95d3..8cc8bd9a4e32 100644
--- a/drivers/misc/vmw_balloon.c
+++ b/drivers/misc/vmw_balloon.c
@@ -544,6 +544,36 @@ unsigned int vmballoon_page_order(enum vmballoon_page_size_type page_size)
 	return page_size == VMW_BALLOON_2M_PAGE ? VMW_BALLOON_2M_ORDER : 0;
 }
 
+/**
+ * vmballoon_mark_page_offline() - mark a page as offline
+ * @page: pointer for the page
+ * @page_size: the size of the page.
+ */
+static void
+vmballoon_mark_page_offline(struct page *page,
+			    enum vmballoon_page_size_type page_size)
+{
+	int i;
+
+	for (i = 0; i < 1ULL << vmballoon_page_order(page_size); i++)
+		__SetPageOffline(page + i);
+}
+
+/**
+ * vmballoon_mark_page_online() - mark a page as online
+ * @page: pointer for the page
+ * @page_size: the size of the page.
+ */
+static void
+vmballoon_mark_page_online(struct page *page,
+			   enum vmballoon_page_size_type page_size)
+{
+	int i;
+
+	for (i = 0; i < 1ULL << vmballoon_page_order(page_size); i++)
+		__ClearPageOffline(page + i);
+}
+
 /**
  * vmballoon_page_in_frames() - returns the number of frames in a page.
  * @page_size: the size of the page.
@@ -612,6 +642,7 @@ static int vmballoon_alloc_page_list(struct vmballoon *b,
 					 ctl->page_size);
 
 		if (page) {
+			vmballoon_mark_page_offline(page, ctl->page_size);
 			/* Success. Add the page to the list and continue. */
 			list_add(&page->lru, &ctl->pages);
 			continue;
@@ -850,6 +881,7 @@ static void vmballoon_release_page_list(struct list_head *page_list,
 
 	list_for_each_entry_safe(page, tmp, page_list, lru) {
 		list_del(&page->lru);
+		vmballoon_mark_page_online(page, page_size);
 		__free_pages(page, vmballoon_page_order(page_size));
 	}
 
-- 
2.17.2
