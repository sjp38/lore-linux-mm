Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 501E5C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:53:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6C8121925
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:53:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hXK6gWJS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6C8121925
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 990736B02E6; Wed, 18 Sep 2019 13:53:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F0CE6B02E7; Wed, 18 Sep 2019 13:53:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7944D6B02E8; Wed, 18 Sep 2019 13:53:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0084.hostedemail.com [216.40.44.84])
	by kanga.kvack.org (Postfix) with ESMTP id 482096B02E6
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:53:02 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 02C04181AC9BF
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:53:02 +0000 (UTC)
X-FDA: 75948787404.16.drain76_1a645a12eda4f
X-HE-Tag: drain76_1a645a12eda4f
X-Filterd-Recvd-Size: 20445
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:53:01 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id k20so393488oih.3
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:53:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=AhRgakU0MKQRR6cibd3J7rx7XiKVe3yFDUh+nL02+OU=;
        b=hXK6gWJSwJAbm43T7vAw0Lk5NiQNKKHOKVPzjtVAII4vLjAzb/FsL6WBNI70+e/Bxg
         MbApfP31XVX46SKEWHLvQmUANP1BgvMIfjjjk+jgs6ZfbQjrvc9Dyl+5iYVBGpm6WO4d
         yiFgPCy3JWFrkgoHX81/tacMzaTYGXwAzx0sBmB9C2riFZNi5C+ZwdI1R7LKHr3FTddL
         BeEpGAiKin6u0z5B3LMWUdhZID+aJVfzSQqNGlJQ6gNAssJu5vjs6DKpn2GwTH/8VdzR
         L95CDpMHMbud+UEn4Zl4Xbv+x7fPVob+VeBEj2EUYUafwgqXj9kYTSm2E1e/eUZ5Qdol
         AVpw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=AhRgakU0MKQRR6cibd3J7rx7XiKVe3yFDUh+nL02+OU=;
        b=AkKp35g1CPPye8O0rkWYHancHAIeuwpbuS3VVDtkaZCmlEXybhRokcj+JcxmvEM/Ss
         0IOzOAivS73LyDp2NfVJQTKvTQw8M4gm+FAW9QUdUfCF4DVUHHpsyqG2eVMvAa4oDq5a
         E4EcMvnAZodjr1lp9FFk034HRXDVojQOeoRmciYAucs7WGwJLw+QEfXNR1ZJFxX1kv0S
         zXtxHKuJWqNk+9VpL0Pwo/yh7a3sx52q9Yq5C/5r9rdCIBLqDm0/BaXucymEc8cASo2E
         iopsD4C3d9ccmf68Gou3CSPfK3hsbnMHwitpAOAAdQzt2Z6fY+65a8wyplb4KrEdEcY2
         W5kw==
X-Gm-Message-State: APjAAAUa+iFqbFJKJ3ROwZp9Wiv3KrTueZyPOboMYa/ug1JB1yOyc4mJ
	J5dCXwGfXqtA+gBRAzZH200=
X-Google-Smtp-Source: APXvYqzE2EGl7PiThZPVTqLhVx5ehyPxdcY4JGRIHF9S8G2ToMQjPgx935E65AXQrj45hWOTteTNaA==
X-Received: by 2002:aca:5856:: with SMTP id m83mr2955719oib.90.1568829180351;
        Wed, 18 Sep 2019 10:53:00 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id v12sm1848407oiv.58.2019.09.18.10.52.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 10:52:59 -0700 (PDT)
Subject: [PATCH v10 4/6] mm: Add device side and notifier for unused page
 reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
 david@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org,
 willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org, vbabka@suse.cz,
 akpm@linux-foundation.org, mgorman@techsingularity.net,
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 18 Sep 2019 10:52:57 -0700
Message-ID: <20190918175257.23474.73638.stgit@localhost.localdomain>
In-Reply-To: <20190918175109.23474.67039.stgit@localhost.localdomain>
References: <20190918175109.23474.67039.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

With this patch we are adding the pieces needed to enable the reporting of
pages to a specific device. That device needs to register a page reporting
device that can be used to handle notifications that that pages are unused.

Registering the device will in turn enable the notifications and allow page
reporting to be active. When the the device is unregistered it will disable
page reporting notifications. For now we only allow one page reporting
device to be registered at a time.

The determination of when to start reporting is based on the tracking of
the number of free pages in a given area versus the number of reported
pages in that area. We keep track of the number of reported pages per
free_area in a separate zone specific area. We do this to avoid modifying
the free_area structure as this can lead to false sharing for the highest
order with the zone lock which leads to a noticeable performance
degradation.

Once reporting has started get_unreported_pages will use the
reported_boundary pointers to track where it should resume processing the
free lists. It will go through and either set the index if it finds a
reported page, or it will attempt to isolate the page so that it can be
reported.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/page_reporting.h |   31 ++++
 mm/Makefile                    |    1 
 mm/page_alloc.c                |   10 +
 mm/page_reporting.c            |  350 ++++++++++++++++++++++++++++++++++++++++
 mm/page_reporting.h            |   46 +++++
 5 files changed, 436 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/page_reporting.h
 create mode 100644 mm/page_reporting.c

diff --git a/include/linux/page_reporting.h b/include/linux/page_reporting.h
new file mode 100644
index 000000000000..afa214f7beaf
--- /dev/null
+++ b/include/linux/page_reporting.h
@@ -0,0 +1,31 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _LINUX_PAGE_REPORTING_H
+#define _LINUX_PAGE_REPORTING_H
+
+#include <linux/mmzone.h>
+
+struct page_reporting_dev_info {
+	/* function that alters pages to make them "reported" */
+	void (*report)(struct page_reporting_dev_info *phdev,
+		       unsigned int nents);
+
+	/* scatterlist containing pages to be processed */
+	struct scatterlist *sg;
+
+	/*
+	 * Upper limit on the number of pages that the react function
+	 * expects to be placed into the batch list to be processed.
+	 */
+	unsigned long capacity;
+
+	/* work struct for processing reports */
+	struct delayed_work work;
+
+	/* The number of zones requesting reporting */
+	atomic_t refcnt;
+};
+
+/* Tear-down and bring-up for page reporting devices */
+void page_reporting_unregister(struct page_reporting_dev_info *phdev);
+int page_reporting_register(struct page_reporting_dev_info *phdev);
+#endif /*_LINUX_PAGE_REPORTING_H */
diff --git a/mm/Makefile b/mm/Makefile
index d996846697ef..fc4fa17b6c83 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -107,3 +107,4 @@ obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_ZONE_DEVICE) += memremap.o
 obj-$(CONFIG_HMM_MIRROR) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
+obj-$(CONFIG_PAGE_REPORTING) += page_reporting.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ed0128c65936..b4189d9cc729 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1073,6 +1073,14 @@ static inline void __free_one_page(struct page *page,
 		add_to_free_list_tail(page, zone, order, migratetype);
 	else
 		add_to_free_list(page, zone, order, migratetype);
+
+	/*
+	 * No need to notify on a reported page as the total count of
+	 * unreported pages will not have increased since we have essentially
+	 * merged the reported page with one or more unreported pages.
+	 */
+	if (!reported)
+		page_reporting_notify_free(zone, order);
 }
 
 /*
@@ -2262,8 +2270,6 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 }
 
 #ifdef CONFIG_PAGE_REPORTING
-struct list_head **reported_boundary __read_mostly;
-
 /**
  * free_reported_page - Return a now-reported page back where we got it
  * @page: Page that was reported
diff --git a/mm/page_reporting.c b/mm/page_reporting.c
new file mode 100644
index 000000000000..3e36f250d2d6
--- /dev/null
+++ b/mm/page_reporting.c
@@ -0,0 +1,350 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/page_reporting.h>
+#include <linux/gfp.h>
+#include <linux/export.h>
+#include <linux/delay.h>
+#include <linux/scatterlist.h>
+
+#include "page_reporting.h"
+#include "internal.h"
+
+static struct page_reporting_dev_info __rcu *ph_dev_info __read_mostly;
+struct list_head **reported_boundary __read_mostly;
+
+#define for_each_reporting_migratetype_order(_order, _type) \
+	for (_order = MAX_ORDER; _order-- != PAGE_REPORTING_MIN_ORDER;) \
+		for (_type = MIGRATE_TYPES; _type--;) \
+			if (!is_migrate_isolate(_type))
+
+static void page_reporting_populate_metadata(struct zone *zone)
+{
+	size_t size;
+	int node;
+
+	/*
+	 * We need to make sure we have somewhere to store the tracking
+	 * data for how many reported pages are in the zone. To do that
+	 * we need to make certain zone->reported_pages is populated.
+	 */
+	if (zone->reported_pages)
+		return;
+
+	node = zone_to_nid(zone);
+	size = (MAX_ORDER - PAGE_REPORTING_MIN_ORDER) * sizeof(unsigned long);
+	zone->reported_pages = kzalloc_node(size, GFP_KERNEL, node);
+}
+
+static void page_reporting_reset_all_boundaries(struct zone *zone)
+{
+	unsigned int order, mt;
+
+	/* Update boundary data to reflect the zone we are currently working */
+	for_each_reporting_migratetype_order(order, mt)
+		page_reporting_reset_boundary(zone, order, mt);
+}
+
+static struct page *
+get_unreported_page(struct zone *zone, unsigned int order, int mt)
+{
+	struct list_head *list = &zone->free_area[order].free_list[mt];
+	struct list_head *tail = get_unreported_tail(zone, order, mt);
+	unsigned long index = get_reporting_index(order, mt);
+	struct page *page;
+
+	/* Find a page of the appropriate size in the preferred list */
+	page = list_last_entry(tail, struct page, lru);
+	list_for_each_entry_from_reverse(page, list, lru) {
+		/* If we entered this loop then the "raw" list isn't empty */
+
+		/*
+		 * We are going to skip over the reported pages. Make
+		 * certain that the index of those pages are correct
+		 * as we will later be moving the boundary into place
+		 * above them.
+		 */
+		if (PageReported(page)) {
+			page->index = index;
+			tail = &page->lru;
+			continue;
+		}
+
+		/* Drop reference to page if isolate fails */
+		if (__isolate_free_page(page, order))
+			goto out;
+
+		break;
+	}
+
+	page = NULL;
+out:
+	/* Update the boundary */
+	reported_boundary[index] = tail;
+
+	return page;
+}
+
+static void
+__page_reporting_cancel(struct zone *zone,
+			struct page_reporting_dev_info *phdev)
+{
+	/* processing of the zone is complete, we can disable boundaries */
+	page_reporting_disable_boundaries(zone);
+
+	/*
+	 * If there are no longer enough free pages to fully populate
+	 * the scatterlist, then we can just shut it down for this zone.
+	 */
+	__clear_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags);
+	atomic_dec(&phdev->refcnt);
+}
+
+static unsigned int
+page_reporting_fill(struct zone *zone, struct page_reporting_dev_info *phdev)
+{
+	struct scatterlist *sg = phdev->sg;
+	unsigned int order, mt, count = 0;
+
+	sg_init_table(phdev->sg, phdev->capacity);
+
+	/* Make sure the boundaries are enabled */
+	if (!__test_and_set_bit(ZONE_PAGE_REPORTING_ACTIVE, &zone->flags))
+		page_reporting_reset_all_boundaries(zone);
+
+	for_each_reporting_migratetype_order(order, mt) {
+		struct page *page;
+
+		/*
+		 * Pull pages from free list until we have drained
+		 * it or we have reached capacity.
+		 */
+		while ((page = get_unreported_page(zone, order, mt))) {
+			sg_set_page(&sg[count], page, PAGE_SIZE << order, 0);
+
+			if (++count == phdev->capacity)
+				return phdev->capacity;
+		}
+	}
+
+	/* mark end of scatterlist due to underflow */
+	if (count)
+		sg_mark_end(&sg[count - 1]);
+
+	/* We ran out of pages so we can stop now */
+	__page_reporting_cancel(zone, phdev);
+
+	return count;
+}
+
+static void page_reporting_drain(struct page_reporting_dev_info *phdev)
+{
+	struct scatterlist *sg = phdev->sg;
+
+	/*
+	 * Drain the now reported pages back into their respective
+	 * free lists/areas. We assume at least one page is populated.
+	 */
+	do {
+		free_reported_page(sg_page(sg), get_order(sg->length));
+	} while (!sg_is_last(sg++));
+}
+
+/*
+ * The page reporting cycle consists of 4 stages, fill, report, drain, and
+ * idle. We will cycle through the first 3 stages until we fail to obtain any
+ * pages, in that case we will switch to idle.
+ */
+static void
+page_reporting_cycle(struct zone *zone, struct page_reporting_dev_info *phdev)
+{
+	/*
+	 * Guarantee boundaries and stats are populated before we
+	 * start placing reported pages in the zone.
+	 */
+	page_reporting_populate_metadata(zone);
+
+	spin_lock_irq(&zone->lock);
+
+	/* Cancel the request if we failed to populate zone metadata */
+	if (!zone->reported_pages) {
+		__page_reporting_cancel(zone, phdev);
+		goto zone_not_ready;
+	}
+
+	do {
+		/* Pull pages out of allocator into a scaterlist */
+		unsigned int nents = page_reporting_fill(zone, phdev);
+
+		/* no pages were acquired, give up */
+		if (!nents)
+			break;
+
+		spin_unlock_irq(&zone->lock);
+
+		/* begin processing pages in local list */
+		phdev->report(phdev, nents);
+
+		spin_lock_irq(&zone->lock);
+
+		/*
+		 * We should have a scatterlist of pages that have been
+		 * processed. Return them to their original free lists.
+		 */
+		page_reporting_drain(phdev);
+
+		/* keep pulling pages till there are none to pull */
+	} while (test_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags));
+zone_not_ready:
+	spin_unlock_irq(&zone->lock);
+}
+
+static void page_reporting_process(struct work_struct *work)
+{
+	struct delayed_work *d_work = to_delayed_work(work);
+	struct page_reporting_dev_info *phdev =
+		container_of(d_work, struct page_reporting_dev_info, work);
+	struct zone *zone = first_online_pgdat()->node_zones;
+
+	do {
+		if (test_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags))
+			page_reporting_cycle(zone, phdev);
+
+		/* Move to next zone, if at end of list start over */
+		zone = next_zone(zone) ? : first_online_pgdat()->node_zones;
+
+		/*
+		 * As long as refcnt has not reached zero there are still
+		 * zones to be processed.
+		 */
+	} while (atomic_read(&phdev->refcnt));
+}
+
+/* request page reporting on this zone */
+void __page_reporting_request(struct zone *zone)
+{
+	struct page_reporting_dev_info *phdev;
+
+	rcu_read_lock();
+
+	/*
+	 * We use RCU to protect the ph_dev_info pointer. In almost all
+	 * cases this should be present, however in the unlikely case of
+	 * a shutdown this will be NULL and we should exit.
+	 */
+	phdev = rcu_dereference(ph_dev_info);
+	if (unlikely(!phdev))
+		goto out;
+
+	/*
+	 * We can use separate test and set operations here as there
+	 * is nothing else that can set or clear this bit while we are
+	 * holding the zone lock. The advantage to doing it this way is
+	 * that we don't have to dirty the cacheline unless we are
+	 * changing the value.
+	 */
+	__set_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags);
+
+	/*
+	 * Delay the start of work to allow a sizable queue to
+	 * build. For now we are limiting this to running no more
+	 * than 10 times per second.
+	 */
+	if (!atomic_fetch_inc(&phdev->refcnt))
+		schedule_delayed_work(&phdev->work, HZ / 10);
+out:
+	rcu_read_unlock();
+}
+
+static DEFINE_MUTEX(page_reporting_mutex);
+DEFINE_STATIC_KEY_FALSE(page_reporting_notify_enabled);
+
+void page_reporting_unregister(struct page_reporting_dev_info *phdev)
+{
+	mutex_lock(&page_reporting_mutex);
+
+	if (rcu_access_pointer(ph_dev_info) == phdev) {
+		/* Disable page reporting notification */
+		static_branch_disable(&page_reporting_notify_enabled);
+		RCU_INIT_POINTER(ph_dev_info, NULL);
+		synchronize_rcu();
+
+		/* Flush any existing work, and lock it out */
+		cancel_delayed_work_sync(&phdev->work);
+
+		/* Free scatterlist */
+		kfree(phdev->sg);
+		phdev->sg = NULL;
+
+		/* Free boundaries */
+		kfree(reported_boundary);
+		reported_boundary = NULL;
+	}
+
+	mutex_unlock(&page_reporting_mutex);
+}
+EXPORT_SYMBOL_GPL(page_reporting_unregister);
+
+int page_reporting_register(struct page_reporting_dev_info *phdev)
+{
+	struct zone *zone;
+	int err = 0;
+
+	/* No point in enabling this if it cannot handle any pages */
+	if (WARN_ON(!phdev->capacity))
+		return -EINVAL;
+
+	mutex_lock(&page_reporting_mutex);
+
+	/* nothing to do if already in use */
+	if (rcu_access_pointer(ph_dev_info)) {
+		err = -EBUSY;
+		goto err_out;
+	}
+
+	/*
+	 * Allocate space to store the boundaries for the zone we are
+	 * actively reporting on. We will need to store one boundary
+	 * pointer per migratetype, and then we need to have one of these
+	 * arrays per order for orders greater than or equal to
+	 * PAGE_REPORTING_MIN_ORDER.
+	 */
+	reported_boundary = kcalloc(get_reporting_index(MAX_ORDER, 0),
+				    sizeof(struct list_head *), GFP_KERNEL);
+	if (!reported_boundary) {
+		err = -ENOMEM;
+		goto err_out;
+	}
+
+	/* allocate scatterlist to store pages being reported on */
+	phdev->sg = kcalloc(phdev->capacity, sizeof(*phdev->sg), GFP_KERNEL);
+	if (!phdev->sg) {
+		err = -ENOMEM;
+
+		kfree(reported_boundary);
+		reported_boundary = NULL;
+
+		goto err_out;
+	}
+
+
+	/* initialize refcnt and work structures */
+	atomic_set(&phdev->refcnt, 0);
+	INIT_DELAYED_WORK(&phdev->work, &page_reporting_process);
+
+	/* assign device, and begin initial flush of populated zones */
+	rcu_assign_pointer(ph_dev_info, phdev);
+	for_each_populated_zone(zone) {
+		spin_lock_irq(&zone->lock);
+		__page_reporting_request(zone);
+		spin_unlock_irq(&zone->lock);
+	}
+
+	/* enable page reporting notification */
+	static_branch_enable(&page_reporting_notify_enabled);
+err_out:
+	mutex_unlock(&page_reporting_mutex);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(page_reporting_register);
diff --git a/mm/page_reporting.h b/mm/page_reporting.h
index c5e1bb58ad96..acc6dafc74a1 100644
--- a/mm/page_reporting.h
+++ b/mm/page_reporting.h
@@ -23,6 +23,48 @@ static inline void page_reporting_reset_zone(struct zone *zone)
 	zone->reported_pages = NULL;
 }
 
+DECLARE_STATIC_KEY_FALSE(page_reporting_notify_enabled);
+void __page_reporting_request(struct zone *zone);
+
+/**
+ * page_reporting_notify_free - Free page notification to start page processing
+ * @zone: Pointer to current zone of last page processed
+ * @order: Order of last page added to zone
+ *
+ * This function is meant to act as a screener for __page_reporting_request
+ * which will determine if a give zone has crossed over the high-water mark
+ * that will justify us beginning page treatment. If we have crossed that
+ * threshold then it will start the process of pulling some pages and
+ * placing them in the batch list for treatment.
+ */
+static inline void page_reporting_notify_free(struct zone *zone, int order)
+{
+	unsigned long nr_reported;
+
+	/* Called from hot path in __free_one_page() */
+	if (!static_branch_unlikely(&page_reporting_notify_enabled))
+		return;
+
+	/* Limit notifications only to higher order pages */
+	if (order < PAGE_REPORTING_MIN_ORDER)
+		return;
+
+	/* Do not bother with tests if we have already requested reporting */
+	if (test_bit(ZONE_PAGE_REPORTING_REQUESTED, &zone->flags))
+		return;
+
+	/* If reported_pages is not populated, assume 0 */
+	nr_reported = zone->reported_pages ?
+		    zone->reported_pages[order - PAGE_REPORTING_MIN_ORDER] : 0;
+
+	/* Only request it if we have enough to begin the page reporting */
+	if (zone->free_area[order].nr_free < nr_reported + PAGE_REPORTING_HWM)
+		return;
+
+	/* This is slow, but should be called very rarely */
+	__page_reporting_request(zone);
+}
+
 /* Boundary functions */
 static inline pgoff_t
 get_reporting_index(unsigned int order, unsigned int migratetype)
@@ -142,6 +184,10 @@ static inline void page_reporting_reset_zone(struct zone *zone)
 {
 }
 
+static inline void page_reporting_notify_free(struct zone *zone, int order)
+{
+}
+
 static inline void
 page_reporting_free_area_release(struct zone *zone, unsigned int order, int mt)
 {


