Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B99DDC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:45:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D45A208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:45:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D45A208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 088B78E0005; Thu, 18 Jul 2019 16:45:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 039FE8E0001; Thu, 18 Jul 2019 16:45:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E46578E0005; Thu, 18 Jul 2019 16:45:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id C11658E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:45:57 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id p193so13023647vkd.7
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:45:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=9S0xb5z5fR3mjUHu6CoYssrB1TCkTl2mEiTbCUl8WWc=;
        b=bmT8U84sfiryCwFg6IioUNjxw0pBoSxkhDvewwIV3pJ11BvoXRKCdJjXIj1p4YnfmP
         005IchtmmiLtkpGuzurVJjSsNxlWj5h32L0oZzkS69VAg/CUtwdeluGNcIGgLLO3hV/w
         W29KyJP3Bv03Yd/cZky2hjnWXesOgj/VjGbBOcdO5K6q3LNOaJhS1Vy5Z+6zrqNJtBWD
         evIIw7q3DgvnoVnkeEjwce9g6EqSeHTcalHmOw+oiY9ZTUku2yIpZNwhBYOS2Oa5C/8E
         Sb+9dw4k5EjL6IzLKd4A8HQ/X8ELVANW8HUUPZMbyJKP26pDIRfuSbLrbAT/hjsMf9GL
         ozpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVMXWB8fppBe9jWCjXwibK5xZQu45hjQeCdmkKfx1EGgZPXv7jj
	o8mMyOw7d5Y52YZkJehPwMro+k0Cxjr5K5bHhTQOhG4K/bDg+W4c9CQnkkRbFFtMWDhENQ9/SnB
	4qmvGPfBQNiRneg2+4oCiRfmmu/aTQTWuqowJHxxm9V4Uw3fnrJsWvJQahbseBUA/Hw==
X-Received: by 2002:a67:6c83:: with SMTP id h125mr32540884vsc.16.1563482757541;
        Thu, 18 Jul 2019 13:45:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYJW+opwyS644OZcV7sFF0woSIz4epE4C1eUyP7UwdZljUOcKhKv6eWgFflBlN3z7iFJQL
X-Received: by 2002:a67:6c83:: with SMTP id h125mr32540759vsc.16.1563482756212;
        Thu, 18 Jul 2019 13:45:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563482756; cv=none;
        d=google.com; s=arc-20160816;
        b=DQxBo8hDILCP91AjF1RstflhqlLnhvB5h52DDBDL+M0/uhu0cq0VgrC/7Fo3O5OZkS
         QMWo21OBcqfQUN/NXtVYY4y4tJiyKboMAAE/Rgmmbu7hNpxGoEHHyFuyau8PPedOfQww
         2U+bAdoEfopbmC9D0AlqLTxooNeybBCafW/PSsWpgX4KBflyBm3cwA6EVSTRkn8ogMTW
         k1WL7pEqqt66x3a5KlUGhqlN9W238v649Yoy1grzrF4C+KMDgViNUewbNyT0ZG48uMkA
         imETsf+Kgs+mproqQfO+bdwKBcAn8YDA0y2YTp0LTd/ezp5gMZZQePt1WO2UBKi8/5tC
         Zg/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=9S0xb5z5fR3mjUHu6CoYssrB1TCkTl2mEiTbCUl8WWc=;
        b=s3goukLBG05QS6fX0OxR/PZdcpnHE9DCRLbrkvOhQL100jK4AWXL2CsUaMId+CaRde
         dbb7rjPlnJBbslLmLv8npHl1XMKh4NqVTbCkDRKKn7FMs+Q/+CgE3wurzZ/783VkMQhz
         201Oe5wdZn4qEhO+xL0zQ3TczbSqCf1RBN32+yRIa3Xy+W/295vUhLHXuuW31EupAbuB
         dqfjy7JVGtQhbmazggQjeQueJ9NfOJgtK/W3ydQ2F2vPbgBaHyaf4fhT0K5LPBpAudz9
         LpYzGSG+nPQsGBU/nWsa36+nmzwIURyACRsQv7iu1O9HSM7w0NH3l/CkxIwROcmitJRA
         MHhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si7096843vsw.190.2019.07.18.13.45.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:45:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 66E613082E10;
	Thu, 18 Jul 2019 20:45:55 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 4C0DE5D71A;
	Thu, 18 Jul 2019 20:45:52 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:45:50 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 2/2] balloon: fix up comments
Message-ID: <20190718204333.26030-2-mst@redhat.com>
References: <20190718204333.26030-1-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718204333.26030-1-mst@redhat.com>
X-Mutt-Fcc: =sent
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 18 Jul 2019 20:45:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Lots of comments bitrotted. Fix them up.

Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
Reviewed-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Acked-by: Nadav Amit <namit@vmware.com>
---
 mm/balloon_compaction.c | 67 +++++++++++++++++++++++------------------
 1 file changed, 37 insertions(+), 30 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index d25664e1857b..798275a51887 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -32,8 +32,8 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
  * @b_dev_info: balloon device descriptor where we will insert a new page to
  * @pages: pages to enqueue - allocated using balloon_page_alloc.
  *
- * Driver must call it to properly enqueue a balloon pages before definitively
- * removing it from the guest system.
+ * Driver must call this function to properly enqueue balloon pages before
+ * definitively removing them from the guest system.
  *
  * Return: number of pages that were enqueued.
  */
@@ -63,12 +63,13 @@ EXPORT_SYMBOL_GPL(balloon_page_list_enqueue);
  * @n_req_pages: number of requested pages.
  *
  * Driver must call this function to properly de-allocate a previous enlisted
- * balloon pages before definetively releasing it back to the guest system.
+ * balloon pages before definitively releasing it back to the guest system.
  * This function tries to remove @n_req_pages from the ballooned pages and
  * return them to the caller in the @pages list.
  *
- * Note that this function may fail to dequeue some pages temporarily empty due
- * to compaction isolated pages.
+ * Note that this function may fail to dequeue some pages even if the balloon
+ * isn't empty - since the page list can be temporarily empty due to compaction
+ * of isolated pages.
  *
  * Return: number of pages that were added to the @pages list.
  */
@@ -112,12 +113,13 @@ EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
 
 /*
  * balloon_page_alloc - allocates a new page for insertion into the balloon
- *			  page list.
+ *			page list.
  *
- * Driver must call it to properly allocate a new enlisted balloon page.
- * Driver must call balloon_page_enqueue before definitively removing it from
- * the guest system.  This function returns the page address for the recently
- * allocated page or NULL in the case we fail to allocate a new page this turn.
+ * Driver must call this function to properly allocate a new balloon page.
+ * Driver must call balloon_page_enqueue before definitively removing the page
+ * from the guest system.
+ *
+ * Return: struct page for the allocated page or NULL on allocation failure.
  */
 struct page *balloon_page_alloc(void)
 {
@@ -130,19 +132,15 @@ EXPORT_SYMBOL_GPL(balloon_page_alloc);
 /*
  * balloon_page_enqueue - inserts a new page into the balloon page list.
  *
- * @b_dev_info: balloon device descriptor where we will insert a new page to
+ * @b_dev_info: balloon device descriptor where we will insert a new page
  * @page: new page to enqueue - allocated using balloon_page_alloc.
  *
- * Driver must call it to properly enqueue a new allocated balloon page
- * before definitively removing it from the guest system.
+ * Drivers must call this function to properly enqueue a new allocated balloon
+ * page before definitively removing the page from the guest system.
  *
- * Drivers must not call balloon_page_enqueue on pages that have been
- * pushed to a list with balloon_page_push before removing them with
- * balloon_page_pop. To all pages on a list, use balloon_page_list_enqueue
- * instead.
- *
- * This function returns the page address for the recently enqueued page or
- * NULL in the case we fail to allocate a new page this turn.
+ * Drivers must not call balloon_page_enqueue on pages that have been pushed to
+ * a list with balloon_page_push before removing them with balloon_page_pop. To
+ * enqueue a list of pages, use balloon_page_list_enqueue instead.
  */
 void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
 			  struct page *page)
@@ -157,14 +155,23 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
 
 /*
  * balloon_page_dequeue - removes a page from balloon's page list and returns
- *			  the its address to allow the driver release the page.
+ *			  its address to allow the driver to release the page.
  * @b_dev_info: balloon device decriptor where we will grab a page from.
  *
- * Driver must call it to properly de-allocate a previous enlisted balloon page
- * before definetively releasing it back to the guest system.
- * This function returns the page address for the recently dequeued page or
- * NULL in the case we find balloon's page list temporarily empty due to
- * compaction isolated pages.
+ * Driver must call this function to properly dequeue a previously enqueued page
+ * before definitively releasing it back to the guest system.
+ *
+ * Caller must perform its own accounting to ensure that this
+ * function is called only if some pages are actually enqueued.
+ *
+ * Note that this function may fail to dequeue some pages even if there are
+ * some enqueued pages - since the page list can be temporarily empty due to
+ * the compaction of isolated pages.
+ *
+ * TODO: remove the caller accounting requirements, and allow caller to wait
+ * until all pages can be dequeued.
+ *
+ * Return: struct page for the dequeued page, or NULL if no page was dequeued.
  */
 struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 {
@@ -177,9 +184,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 	if (n_pages != 1) {
 		/*
 		 * If we are unable to dequeue a balloon page because the page
-		 * list is empty and there is no isolated pages, then something
+		 * list is empty and there are no isolated pages, then something
 		 * went out of track and some balloon pages are lost.
-		 * BUG() here, otherwise the balloon driver may get stuck into
+		 * BUG() here, otherwise the balloon driver may get stuck in
 		 * an infinite loop while attempting to release all its pages.
 		 */
 		spin_lock_irqsave(&b_dev_info->pages_lock, flags);
@@ -230,8 +237,8 @@ int balloon_page_migrate(struct address_space *mapping,
 
 	/*
 	 * We can not easily support the no copy case here so ignore it as it
-	 * is unlikely to be use with ballon pages. See include/linux/hmm.h for
-	 * user of the MIGRATE_SYNC_NO_COPY mode.
+	 * is unlikely to be used with balloon pages. See include/linux/hmm.h
+	 * for a user of the MIGRATE_SYNC_NO_COPY mode.
 	 */
 	if (mode == MIGRATE_SYNC_NO_COPY)
 		return -EINVAL;
-- 
MST

