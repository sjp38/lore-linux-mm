Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 432986B2AFA
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:07:10 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id v74so8811381qkb.21
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:07:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o61si5363344qte.74.2018.11.22.02.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:07:09 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 4/8] xen/balloon: mark inflated pages PG_offline
Date: Thu, 22 Nov 2018 11:06:23 +0100
Message-Id: <20181122100627.5189-5-david@redhat.com>
In-Reply-To: <20181122100627.5189-1-david@redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, David Hildenbrand <david@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

Mark inflated and never onlined pages PG_offline, to tell the world that
the content is stale and should not be dumped.

Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Stefano Stabellini <sstabellini@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/xen/balloon.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 12148289debd..14dd6b814db3 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -425,6 +425,7 @@ static int xen_bring_pgs_online(struct page *pg, unsigned int order)
 	for (i = 0; i < size; i++) {
 		p = pfn_to_page(start_pfn + i);
 		__online_page_set_limits(p);
+		__SetPageOffline(p);
 		__balloon_append(p);
 	}
 	mutex_unlock(&balloon_mutex);
@@ -493,6 +494,7 @@ static enum bp_state increase_reservation(unsigned long nr_pages)
 		xenmem_reservation_va_mapping_update(1, &page, &frame_list[i]);
 
 		/* Relinquish the page back to the allocator. */
+		__ClearPageOffline(page);
 		free_reserved_page(page);
 	}
 
@@ -519,6 +521,7 @@ static enum bp_state decrease_reservation(unsigned long nr_pages, gfp_t gfp)
 			state = BP_EAGAIN;
 			break;
 		}
+		__SetPageOffline(page);
 		adjust_managed_page_count(page, -1);
 		xenmem_reservation_scrub_page(page);
 		list_add(&page->lru, &pages);
-- 
2.17.2
