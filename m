Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA9036B2B02
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:07:24 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n95so5789594qte.16
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:07:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c19si8557331qkh.43.2018.11.22.02.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:07:23 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 7/8] PM / Hibernate: use pfn_to_online_page()
Date: Thu, 22 Nov 2018 11:06:26 +0100
Message-Id: <20181122100627.5189-8-david@redhat.com>
In-Reply-To: <20181122100627.5189-1-david@redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
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
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Pavel Machek <pavel@ucw.cz>
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
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
