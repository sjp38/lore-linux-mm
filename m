Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9915D6B1A3E
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:17:16 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id k203so68580361qke.2
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 02:17:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f9si2302847qtq.274.2018.11.19.02.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 02:17:15 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 7/8] PM / Hibernate: use pfn_to_online_page()
Date: Mon, 19 Nov 2018 11:16:15 +0100
Message-Id: <20181119101616.8901-8-david@redhat.com>
In-Reply-To: <20181119101616.8901-1-david@redhat.com>
References: <20181119101616.8901-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, David Hildenbrand <david@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

Let's use pfn_to_online_page() instead of pfn_to_page() when checking
for saveable pages to not save/restore offline memory sections.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Len Brown <len.brown@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 kernel/power/snapshot.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 640b2034edd6..87e6dd57819f 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1215,8 +1215,8 @@ static struct page *saveable_highmem_page(struct zone *zone, unsigned long pfn)
 	if (!pfn_valid(pfn))
 		return NULL;
 
-	page = pfn_to_page(pfn);
-	if (page_zone(page) != zone)
+	page = pfn_to_online_page(pfn);
+	if (!page || page_zone(page) != zone)
 		return NULL;
 
 	BUG_ON(!PageHighMem(page));
@@ -1277,8 +1277,8 @@ static struct page *saveable_page(struct zone *zone, unsigned long pfn)
 	if (!pfn_valid(pfn))
 		return NULL;
 
-	page = pfn_to_page(pfn);
-	if (page_zone(page) != zone)
+	page = pfn_to_online_page(pfn);
+	if (!page || page_zone(page) != zone)
 		return NULL;
 
 	BUG_ON(PageHighMem(page));
-- 
2.17.2
