Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DC95C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:01:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B46F4217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:01:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B46F4217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5639D6B0008; Thu, 18 Jul 2019 10:01:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51C808E0003; Thu, 18 Jul 2019 10:01:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 429B28E0001; Thu, 18 Jul 2019 10:01:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2057C6B0008
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:01:34 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q26so24478031qtr.3
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:01:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=TKHlaMkr53YU/WtZnK3SILipGxvOfIufitQJRU2Ckmc=;
        b=DEcMCaDqPQGj9A8yqERzpYQA6tnABmkaQXKD/T7BunbhaJdq/bcNyJ2t7ugfB0GwMP
         iHGGwa+jZTblmswkAHaJAy7mFuGBrArIwAv4fDvVfqGZM3I5pPQ4HGbp3ZyX2OsjBosa
         zUaaiwOIXpsFGZK33Q1oCgs7aDoCLbYZ8zsgNzaP96ch1QGj51TCKnTUl3FTozML94aR
         y+2W1IGnKKmN5U0L+qV0VWZg6F4i4daPGkAi26Aw1YtHnUSf/VPSASEl/kxZkjd+Jlnz
         pTIafHzJOjrjiGV2Dk48LCapRuOugjgZ4HmnCp7yMWJvHZ4QAJTSS8YY4V1OPMPM+RTQ
         BM7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXwiAOQqiRcdBftmHsODDuTeyy6hYGFqu0jNuc4XYiTZEeXCkG4
	zTk2HaSBpSFXq0q5I7iIL7bkOg85H4zRr44Ased70zLsitiPCaKCjgWolc/c6wfxUuUj0w5CkSt
	xmx6q9DkI9I3D6CLX1Tq2BC4FjPIhhUb4/edQOmdJLSSRKhhDkqXeOl+KplVJsWr6ZQ==
X-Received: by 2002:ac8:7941:: with SMTP id r1mr27562693qtt.82.1563458493803;
        Thu, 18 Jul 2019 07:01:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRj2RERJI9U30SwBiCGXKLvZLDoS1M0vQzoK9cS1AHerxlPGSpwdgEk/82IALiflUYCO1u
X-Received: by 2002:ac8:7941:: with SMTP id r1mr27562289qtt.82.1563458490070;
        Thu, 18 Jul 2019 07:01:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563458490; cv=none;
        d=google.com; s=arc-20160816;
        b=kLZAuu8tXgh+yEI1fhR7XlFRWsGgLeS5iIGzTMSdJaGEKYdHjBNrqxchVwAZiN32Qu
         G7SKgjPAuPX2dBnmKlqIWERLA4GFmN37DpNC5sFdFYkV+hdXAEg8/QS85GWzBdE9CQkx
         P6m9+8gLeQ2wY0vH9BhS6znB1oOJo9+G8MfDU7my5t6L5V5PxE2xSuHirJ1IWfrwDAk8
         2vCoKjdn7TxPu+2qVbN/ofklecxQsgy3/HCVHZB2CUTJ0VirYhInNcafjonpgkRScq1h
         g9HTPD3pSS5lfBg1YcWog0kMM0jz9yT7q/phia/sghxSgGhGH0NUDVPVYtZaP3GBMD7s
         zS8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=TKHlaMkr53YU/WtZnK3SILipGxvOfIufitQJRU2Ckmc=;
        b=U3Qd30IvTvNF67dyiBeX3JWKIGkiP/0oBVtbzl6giZ86eheo/neklii3hF9eMEP8pI
         DtLoX+z4t6lscggEmsqLR453mT4u61ssZsQRLRe+nVHvmgSBYpksOrEwKGIYzLkQjTVx
         UD/DYLqpSFtFvcJka9qioQCdKiUwpK9L6/WP8U2Jife1DtT9+KTgOFYcDndG7TNI5tRr
         djljdTtd8d1vodtXxC/nZU8sPTVClGXLm+D3lW/VdDvoJbN7zoXBdEL3clc31N6JUMhl
         fcMLYbKWaJErMsRvn2b08pO21hcCNsM1D/VI/+oeH6Odfg/o9vNamAeuNUQ0tgdmDHBy
         Aeug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c20si16351845qkc.183.2019.07.18.07.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 07:01:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4064781E0A;
	Thu, 18 Jul 2019 14:01:29 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id D86F419C67;
	Thu, 18 Jul 2019 14:01:06 +0000 (UTC)
Date: Thu, 18 Jul 2019 10:01:05 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Subject: [PATCH v4 2/2] balloon: fix up comments
Message-ID: <20190718140006.15052-2-mst@redhat.com>
References: <20190718140006.15052-1-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718140006.15052-1-mst@redhat.com>
X-Mutt-Fcc: =sent
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 18 Jul 2019 14:01:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Lots of comments bitrotted. Fix them up.

Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
Reviewed-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

fixes since v3:
	teaks suggested by Wei

 mm/balloon_compaction.c | 71 ++++++++++++++++++++++-------------------
 1 file changed, 39 insertions(+), 32 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index d25664e1857b..7e95d2cd185a 100644
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
+ * Returns: struct page for the allocated page or NULL on allocation failure.
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
+ * Returns: struct page for the dequeued page, or NULL if no page was dequeued.
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

