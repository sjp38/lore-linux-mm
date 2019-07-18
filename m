Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 466E9C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:24:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2009217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:24:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2009217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81BF86B0005; Thu, 18 Jul 2019 08:24:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CC0A6B0007; Thu, 18 Jul 2019 08:24:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66D1C8E0001; Thu, 18 Jul 2019 08:24:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 438866B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:24:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c79so23086157qkg.13
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:24:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=9e4f5Wm+7v+5gnl2N8Qt2KV0IZg5PpiXlQeQJbRykCw=;
        b=RSif91bisJ9N7i6JgMg8pzehdD6Ek3OcTXjrZJv9iBC4MXwNbFjZ2v4NgXDUoPBgBa
         aHg8ZSaE/7c0yplHerQcgyj4Yytf4OQxLE+Iw3M49jzv9ISCLrYxIezQHfdtLCJk7MMn
         O3DX/Ci9PrGAqs8+OHjM4O4oBd+ouoPgzNdkDyds/g2u7ihJMIg+gATZnMXGGnzWSdfc
         T8nFXlrBWfeUxIq9rnYfZnPeTwIComVVxdD8PkYv6lpbxE4n9VRwFaFC0A0MQSs0bWLa
         wpEWDClmsb5lgqgWIHkamaElpJ7KUL3pVXW1bsGG1us3kNa8vm1HdDlT1bJgGFt7ba0g
         /14w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXF9MBEuGq4WbtoH1zuJUajmcZoWTFQ5jTX+SgchKgobwj18b4D
	/cd7dTsaTvHmo5pbz0EYdx5MriaNcuYVn/3KA7Zn/yYN3xStC4eEOFo4ereYo/fPVzHEs1JuXmz
	nNQ9Wq1B0CO01UCKJ7YzLcDEYPtj2TiVyyOuYYPLn4m+mjdBbHCuj4CajHASEnQ6EHw==
X-Received: by 2002:ae9:d606:: with SMTP id r6mr29882727qkk.364.1563452670024;
        Thu, 18 Jul 2019 05:24:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqkH57gNDAASV9JwHI8GM3aDVT5dCSwKCjE7l/whGI+Fwnz8t6lJr+LdBFyoRHuW3hyGi0
X-Received: by 2002:ae9:d606:: with SMTP id r6mr29882652qkk.364.1563452668845;
        Thu, 18 Jul 2019 05:24:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563452668; cv=none;
        d=google.com; s=arc-20160816;
        b=EUtkfrCe9xHV1HxzuBy9R0F0RW4BmCuDu9P33VrlaTbKr2SkimcF/LCQg1Xj7In7sX
         RK4O2FBter59LFPBpScP9EpfKNfL+P3pIKEm2ZEtH0IKxl6y5wesjkhq+scPetAjjg/I
         9KnZ/6rFcVBnitkFsZP5Z++nJAJK3o3W2oeG+8nzb0QdPHXRQIWNN9XjLjJ+oh61YNXE
         X2whLNeD8pD1mEG8G3ALaxawYTHJDkACDbsV6JAaORfCujQ/fG/c89IOVdmiyTu0ZQ3A
         Ei/lZ8HBFlllb8R8c/SvS3SxlDgtJRUZCWn6zxB8wj7L4Kgi5pd+QucWrIzCnQ5r6apJ
         n3Sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=9e4f5Wm+7v+5gnl2N8Qt2KV0IZg5PpiXlQeQJbRykCw=;
        b=YSUVFAIuGgell1Xj6S/BL9b1nzUsHEU6WfzKGP5bec/wNK2Tqxq8QvfKkUWYbs101D
         VnnAca954l34WHjuvoknw5uJhuJ/vgQ1NXIiwUHIAkiNaqrhWJ8nMas6SdQpXtp9PqyN
         lZBHDJlvhm1Quu7Nl8MfKINnXURKH6iFXl1RUPx5rRFZ+8xPbEau82CAolsfc8KZdLXV
         WPF7NP7hFVT/UToVq2fBIqnX0mQqsDTWo8UsMg9ZCQa4rrEj4IIcqxdMIRRfhAg8/Gnx
         vYTFCeP1Dd8mILD9Q45K6oRdakbsqJfEl1Ye9x+Q70U+u2/0pb8bD4VbonnP9ktq/T02
         SCWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f44si18291754qtk.148.2019.07.18.05.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 05:24:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1F9AC30C543E;
	Thu, 18 Jul 2019 12:24:28 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 2EE4F5C21A;
	Thu, 18 Jul 2019 12:24:25 +0000 (UTC)
Date: Thu, 18 Jul 2019 08:24:24 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Subject: [PATCH v3 2/2] balloon: fix up comments
Message-ID: <20190718122324.10552-2-mst@redhat.com>
References: <20190718122324.10552-1-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718122324.10552-1-mst@redhat.com>
X-Mutt-Fcc: =sent
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 18 Jul 2019 12:24:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Lots of comments bitrotted. Fix them up.

Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 mm/balloon_compaction.c | 73 +++++++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 32 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index d25664e1857b..9cb03da5bcea 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -32,10 +32,10 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
  * @b_dev_info: balloon device descriptor where we will insert a new page to
  * @pages: pages to enqueue - allocated using balloon_page_alloc.
  *
- * Driver must call it to properly enqueue a balloon pages before definitively
- * removing it from the guest system.
+ * Driver must call this function to properly enqueue balloon pages before
+ * definitively removing them from the guest system.
  *
- * Return: number of pages that were enqueued.
+ * Returns: number of pages that were enqueued.
  */
 size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
 				 struct list_head *pages)
@@ -63,14 +63,15 @@ EXPORT_SYMBOL_GPL(balloon_page_list_enqueue);
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
- * Return: number of pages that were added to the @pages list.
+ * Returns: number of pages that were added to the @pages list.
  */
 size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
 				 struct list_head *pages, size_t n_req_pages)
@@ -112,12 +113,14 @@ EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
 
 /*
  * balloon_page_alloc - allocates a new page for insertion into the balloon
- *			  page list.
+ *			page list.
  *
- * Driver must call it to properly allocate a new enlisted balloon page.
- * Driver must call balloon_page_enqueue before definitively removing it from
- * the guest system.  This function returns the page address for the recently
- * allocated page or NULL in the case we fail to allocate a new page this turn.
+ * Driver must call this function to properly allocate a new enlisted balloon page.
+ * Driver must call balloon_page_enqueue before definitively removing the page
+ * from the guest system.
+ *
+ * Returns: struct page address for the allocated page or NULL in case it fails
+ * 			to allocate a new page.
  */
 struct page *balloon_page_alloc(void)
 {
@@ -130,19 +133,15 @@ EXPORT_SYMBOL_GPL(balloon_page_alloc);
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
+ * enqueue all pages on a list, use balloon_page_list_enqueue instead.
  */
 void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
 			  struct page *page)
@@ -157,14 +156,24 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
 
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
+ * Driver must call this to properly dequeue a previously enqueued page
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
+ * Returns: struct page address for the dequeued page, or NULL if it fails to
+ * 			dequeue any pages.
  */
 struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 {
@@ -177,9 +186,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
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
@@ -230,8 +239,8 @@ int balloon_page_migrate(struct address_space *mapping,
 
 	/*
 	 * We can not easily support the no copy case here so ignore it as it
-	 * is unlikely to be use with ballon pages. See include/linux/hmm.h for
-	 * user of the MIGRATE_SYNC_NO_COPY mode.
+	 * is unlikely to be used with ballon pages. See include/linux/hmm.h for
+	 * a user of the MIGRATE_SYNC_NO_COPY mode.
 	 */
 	if (mode == MIGRATE_SYNC_NO_COPY)
 		return -EINVAL;
-- 
MST

