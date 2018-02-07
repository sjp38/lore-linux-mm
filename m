Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA376B02D1
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 02:13:36 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f4so3131150plr.14
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 23:13:36 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n9si570805pgr.552.2018.02.06.23.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 23:13:35 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v27 3/4] mm/page_poison: expose page_poisoning_enabled to kernel modules
Date: Wed,  7 Feb 2018 14:54:30 +0800
Message-Id: <1517986471-15185-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1517986471-15185-1-git-send-email-wei.w.wang@intel.com>
References: <1517986471-15185-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

In some usages, e.g. virtio-balloon, a kernel module needs to know if
page poisoning is in use. This patch exposes the page_poisoning_enabled
function to kernel modules.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 mm/page_poison.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/page_poison.c b/mm/page_poison.c
index e83fd44..c08d02a 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -30,6 +30,11 @@ bool page_poisoning_enabled(void)
 		debug_pagealloc_enabled()));
 }
 
+/**
+ * page_poisoning_enabled - check if page poisoning is enabled
+ *
+ * Return true if page poisoning is enabled, or false if not.
+ */
 static void poison_page(struct page *page)
 {
 	void *addr = kmap_atomic(page);
@@ -37,6 +42,7 @@ static void poison_page(struct page *page)
 	memset(addr, PAGE_POISON, PAGE_SIZE);
 	kunmap_atomic(addr);
 }
+EXPORT_SYMBOL_GPL(page_poisoning_enabled);
 
 static void poison_pages(struct page *page, int n)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
