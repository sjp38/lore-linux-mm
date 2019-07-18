Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EC95C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E96C217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:01:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E96C217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D04716B0007; Thu, 18 Jul 2019 10:01:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB4F46B0008; Thu, 18 Jul 2019 10:01:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCAAB8E0001; Thu, 18 Jul 2019 10:01:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 97A6E6B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:01:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x17so23269706qkf.14
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:01:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition;
        bh=Vtp7Edj/Vc/aYf70zuYOaKgF5H5Sxtu19VIwmazsSB0=;
        b=oCoDqFHpJ4xFXCxHxvvAIuO51/yLEBpetSRGV9WPbvcrIG4t3D/NVoENx8RVq102xl
         rr8OClJuQPaLojKMuIqrowVWzudgmk/Evicg/H01pvSbtP14xS77frrZPQJU14qd0Rfu
         +qOfliMoOsFfoavUrIDuT4qG8Q62RFAH9hqooVplzcAjnNsHdZkY5edtsqsEwYEWqFN+
         8K9+1GgUtwEdc3paLjV9D9sa1lZwbrtkAiC/YzeZkRetyNh4l3/ad1yDUJMlwomyZWU8
         v8qkd/ReO/6WzxppaStBQ9Q9WDxYCzmXo0vhD30x8+UkmQfz6XwsWgCj9liK3lY5/wEO
         fiuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXQLmxRqCsTbkvUchoyQIruJrPF6/DdC97sNo8tHdmm2IPMHa+R
	rTocNHEtjN7uHR/vpD88o0Is7wBIxGst29sIoLOqF4jItpzX4tGiFkJwDGHInYb4FDU0JPBSkJ3
	le9U69Pluvoly6OySAfpsIDvB1tIckPTVT6z2z2zGXKAAWvwqPEjavCKX4GdA4fttgA==
X-Received: by 2002:ac8:6c59:: with SMTP id z25mr34159377qtu.43.1563458466357;
        Thu, 18 Jul 2019 07:01:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxtz7vvyfuZ5L+2rv2fY9SWHCP7XoeN93YzgUaVDTRI17rcbePEdJEa0+RRlbg8Ca8Ec/p
X-Received: by 2002:ac8:6c59:: with SMTP id z25mr34159279qtu.43.1563458465581;
        Thu, 18 Jul 2019 07:01:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563458465; cv=none;
        d=google.com; s=arc-20160816;
        b=kzvWB44zyQfTO7+S2hn34B3kvF3jo2i1ht4h1H4klPbhDt5zqPbNzvbMupiysarCtz
         tNgnSOWCT4UACpyFC7itEvrR1GD2d6K+0VsMtraPyes1KFSxq6cU5TE59v7DPgRyVAYt
         8alHfK/qRFjsUJAqBXWppbNDj93WkwysBuUFAFCGUaseeOP+Sy6+8IMujo60hkqYcX+T
         vM2ID6r/N+ZKb2Nch516lqJWd092DLIaTD+oBUPwBfgqbRSUZ+U5JT8HDWFvstpBrFXw
         mzV+RNMq0xgGsxsBVg/cwimdwH7mg8XWscZXVg6GxalmbWavow9dJvgXRXtDmP7LyoYf
         I2rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date;
        bh=Vtp7Edj/Vc/aYf70zuYOaKgF5H5Sxtu19VIwmazsSB0=;
        b=TD8FK1A6oOh0IlZWH3ba4MLD3QvRXFGRxCaKS78huis0jo818jdT4xlt29C+XbUd/m
         kLdXRuHiWxlXU1WpDoKDHC5qAWg8EjcA4IVL17x24CPjQJ3GGruz8AQMr3dCFsTy7eKd
         oZv/NYRDv/R636inLjVP/4zfCfW2ss0WSpm40tCjwmYGybpdn4HbxKoPFciZhXsSCfYl
         Irrk6WA472iaG+eWhQ+QQlFbRuY8I+WSX0iGzDuBk6TTVc39etNIzoT0ihEVdQ0HRT4w
         +sGhgsGnh/omdELEO6l0P+gV0igthNkDR4fxE5AKz6jBFOEM9UxVN+7KypmKMZUVXk8g
         myVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h47si19219079qtc.37.2019.07.18.07.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 07:01:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C8EBD821C1;
	Thu, 18 Jul 2019 14:01:04 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 409086064C;
	Thu, 18 Jul 2019 14:01:01 +0000 (UTC)
Date: Thu, 18 Jul 2019 10:00:53 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Subject: [PATCH v4 1/2] mm/balloon_compaction: avoid duplicate page removal
Message-ID: <20190718140006.15052-1-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mutt-Fcc: =sent
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 18 Jul 2019 14:01:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Wei Wang <wei.w.wang@intel.com>

A #GP is reported in the guest when requesting balloon inflation via
virtio-balloon. The reason is that the virtio-balloon driver has
removed the page from its internal page list (via balloon_page_pop),
but balloon_page_enqueue_one also calls "list_del"  to do the removal.
This is necessary when it's used from balloon_page_enqueue_list, but
not from balloon_page_enqueue.

Move list_del to balloon_page_enqueue, and update comments accordingly.

Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This patch is same as v3.

 mm/balloon_compaction.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 83a7b614061f..d25664e1857b 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -21,7 +21,6 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
 	 * memory corruption is possible and we should stop execution.
 	 */
 	BUG_ON(!trylock_page(page));
-	list_del(&page->lru);
 	balloon_page_insert(b_dev_info, page);
 	unlock_page(page);
 	__count_vm_event(BALLOON_INFLATE);
@@ -47,6 +46,7 @@ size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
 
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 	list_for_each_entry_safe(page, tmp, pages, lru) {
+		list_del(&page->lru);
 		balloon_page_enqueue_one(b_dev_info, page);
 		n_pages++;
 	}
@@ -128,13 +128,19 @@ struct page *balloon_page_alloc(void)
 EXPORT_SYMBOL_GPL(balloon_page_alloc);
 
 /*
- * balloon_page_enqueue - allocates a new page and inserts it into the balloon
- *			  page list.
+ * balloon_page_enqueue - inserts a new page into the balloon page list.
+ *
  * @b_dev_info: balloon device descriptor where we will insert a new page to
  * @page: new page to enqueue - allocated using balloon_page_alloc.
  *
  * Driver must call it to properly enqueue a new allocated balloon page
  * before definitively removing it from the guest system.
+ *
+ * Drivers must not call balloon_page_enqueue on pages that have been
+ * pushed to a list with balloon_page_push before removing them with
+ * balloon_page_pop. To all pages on a list, use balloon_page_list_enqueue
+ * instead.
+ *
  * This function returns the page address for the recently enqueued page or
  * NULL in the case we fail to allocate a new page this turn.
  */
-- 
MST

