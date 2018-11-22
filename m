Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF7646B2B04
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:07:31 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w15so5840107qtk.19
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:07:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o5si5751555qkh.112.2018.11.22.02.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:07:31 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 8/8] PM / Hibernate: exclude all PageOffline() pages
Date: Thu, 22 Nov 2018 11:06:27 +0100
Message-Id: <20181122100627.5189-9-david@redhat.com>
In-Reply-To: <20181122100627.5189-1-david@redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, David Hildenbrand <david@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

The content of pages that are marked PG_offline is not of interest
(e.g. inflated by a balloon driver), let's skip these pages.

In saveable_highmem_page(), move the PageReserved() check to a new
check along with the PageOffline() check to separate it from the
swsusp checks.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Len Brown <len.brown@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Acked-by: Pavel Machek <pavel@ucw.cz>
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 kernel/power/snapshot.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 87e6dd57819f..4802b039b89f 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1221,8 +1221,10 @@ static struct page *saveable_highmem_page(struct zone *zone, unsigned long pfn)
 
 	BUG_ON(!PageHighMem(page));
 
-	if (swsusp_page_is_forbidden(page) ||  swsusp_page_is_free(page) ||
-	    PageReserved(page))
+	if (swsusp_page_is_forbidden(page) ||  swsusp_page_is_free(page))
+		return NULL;
+
+	if (PageReserved(page) || PageOffline(page))
 		return NULL;
 
 	if (page_is_guard(page))
@@ -1286,6 +1288,9 @@ static struct page *saveable_page(struct zone *zone, unsigned long pfn)
 	if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page))
 		return NULL;
 
+	if (PageOffline(page))
+		return NULL;
+
 	if (PageReserved(page)
 	    && (!kernel_page_present(page) || pfn_is_nosave(pfn)))
 		return NULL;
-- 
2.17.2
