Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACA96B2AFF
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:07:21 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c84so8926178qkb.13
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:07:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k3si10659676qvo.122.2018.11.22.02.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:07:20 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 6/8] vmw_balloon: mark inflated pages PG_offline
Date: Thu, 22 Nov 2018 11:06:25 +0100
Message-Id: <20181122100627.5189-7-david@redhat.com>
In-Reply-To: <20181122100627.5189-1-david@redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
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
Acked-by: Nadav Amit <namit@vmware.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/misc/vmw_balloon.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/misc/vmw_balloon.c b/drivers/misc/vmw_balloon.c
index e6126a4b95d3..877611b5659b 100644
--- a/drivers/misc/vmw_balloon.c
+++ b/drivers/misc/vmw_balloon.c
@@ -556,6 +556,36 @@ vmballoon_page_in_frames(enum vmballoon_page_size_type page_size)
 	return 1 << vmballoon_page_order(page_size);
 }
 
+/**
+ * vmballoon_mark_page_offline() - mark a page as offline
+ * @page: pointer for the page.
+ * @page_size: the size of the page.
+ */
+static void
+vmballoon_mark_page_offline(struct page *page,
+			    enum vmballoon_page_size_type page_size)
+{
+	int i;
+
+	for (i = 0; i < vmballoon_page_in_frames(page_size); i++)
+		__SetPageOffline(page + i);
+}
+
+/**
+ * vmballoon_mark_page_online() - mark a page as online
+ * @page: pointer for the page.
+ * @page_size: the size of the page.
+ */
+static void
+vmballoon_mark_page_online(struct page *page,
+			   enum vmballoon_page_size_type page_size)
+{
+	int i;
+
+	for (i = 0; i < vmballoon_page_in_frames(page_size); i++)
+		__ClearPageOffline(page + i);
+}
+
 /**
  * vmballoon_send_get_target() - Retrieve desired balloon size from the host.
  *
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
