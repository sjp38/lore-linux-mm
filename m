Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E894BC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:45:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B930C208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:45:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B930C208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E52F8E0003; Thu, 18 Jul 2019 16:45:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 394EF8E0001; Thu, 18 Jul 2019 16:45:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 282EE8E0003; Thu, 18 Jul 2019 16:45:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0784D8E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:45:53 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id l186so13051440vke.19
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:45:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition;
        bh=FjFH/N8W3Qj/YnCgjEqUkRE16KwoN6p/8QsZ72tJ0N4=;
        b=sk9/J7/fx1w8bJ/Xpl0RqhpD6ILDvMLJ+8jmU/YnOSPG4n+t1bqFEDreyfC9Z3RcC9
         /WAKjSVcWBdu/ArYtAp3EqkPr8txcOyjZKqn3o+J0UDnRys1S14woztr+eBODr3PNr+0
         c3iaUpcVtk5c6XCyDR7ZbbM2H3n6KNHjNGTwDLUtbmqJAeENOsXtDwqoobaVC2kjYnNF
         fJ/Fp5OJmTBsspubhJLP32TOxoJFSUw+5WNh5psrxU7ltHpoFJ4ziscrzdssQ4jjZUok
         Zr7trCgdLteCrU/9VN8VadaQJf33u58WE8pYwZOePRfCGeCK0dxL82qmvYYc4Q8DyD8u
         ZeMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVN/geSpkCz+REGjuSY67SDlJSe19Ph3Rn8Dnf/Q2suHRyys0/m
	SuQ7VUT+angCHYB3uVUR/QKMwELMKg7gWI9r9/n/KS9bkCuY8nVmi9N1wXyVmIpmAhymQkzkUG6
	1iKD4oCA+oCXd1ToTzgpaNQbKB0aseoj4cIyZga669PzGhsOWV/wR8oFjmSsMHLPeYA==
X-Received: by 2002:a67:c403:: with SMTP id c3mr30972196vsk.234.1563482752658;
        Thu, 18 Jul 2019 13:45:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDcJN8aW6WyX1QHBAvQo17PxjgfNd6+UAsDsJ+CG64Iezzm5YB8hqzAjeFvIR4GPnFdIUx
X-Received: by 2002:a67:c403:: with SMTP id c3mr30972122vsk.234.1563482751917;
        Thu, 18 Jul 2019 13:45:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563482751; cv=none;
        d=google.com; s=arc-20160816;
        b=YYX+LYxFlv53fpXVe64CT/VIjiMYmsL1urksJJJJPxyEMPM9z8NqOh/xXekCV8TXQn
         oleZjbC1JHf77lzRNWQ1a04D0IGOWEgDxpho9z7pzy7KX0wnOzwX6gabB2tm5Tp0GgIo
         Hyrc5p0LkUeM2lyGZrz8l8rfbuOe1IlisiYdBNByS3ZhCFxGgH554/+kf5V65lnPf7JK
         m1nUxK+6fJ3juIls5ftCjPFjbhuy5Rkr1r9bvEi0IvPzEfj3/0qHE4xpWKvvy+wHAf9H
         +BQZEuuzxWy15iOjEPFjtsiJ8R1D6zVTDSWqwr7jK7GwaTXqKH5PB3E9GWYk/JjVN8NC
         9H4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date;
        bh=FjFH/N8W3Qj/YnCgjEqUkRE16KwoN6p/8QsZ72tJ0N4=;
        b=kcVObHJ8bNkh8C84EEWKQrpjnw4c0MgQJNl7T+Uf4P6/dBnxsNt/C0VfGtsH3N1KeS
         6RZTeF/M9BO2gCJ1cH17Dl7V9wna7pVulK5SROsUqt+20BRqKaUv8HtGdJW840c9R8ZK
         QXko6Bb9mJp6rRQU0FXOpYaTAIEHHB71zRmNIriLY4JU5/Iv3J19flUscWv0XUEht1yl
         /g6JCdzwepz0/JFAzuhBKljryZDpJ12SNdZ/P1+6l72jANNRwa7zlRKcZfY1bTbUDFX3
         FeeqS1EqBlq0i4H0F+jP0HM7KIrxtrX3bvePXExqLPJczdMuVezT96bA7AyWnJ/zLSHk
         w78w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q16si2554066vsn.44.2019.07.18.13.45.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:45:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2EF0030BD1AF;
	Thu, 18 Jul 2019 20:45:50 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 0327860E39;
	Thu, 18 Jul 2019 20:45:47 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:45:46 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Subject: [PATCH v5 1/2] mm/balloon_compaction: avoid duplicate page removal
Message-ID: <20190718204333.26030-1-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mutt-Fcc: =sent
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 18 Jul 2019 20:45:50 +0000 (UTC)
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

Note: no need for CC stable since 418a3ab1e778 is new since 5.2

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

