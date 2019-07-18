Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF406C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:24:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4F7D20873
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:24:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4F7D20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 361AE6B0003; Thu, 18 Jul 2019 08:24:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EAFB8E0001; Thu, 18 Jul 2019 08:24:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D8C56B0007; Thu, 18 Jul 2019 08:24:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED49F6B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:24:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l9so24085196qtu.12
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition;
        bh=H+TymQOnmdcKuZk9ttK0AqeJXUX/JIzSLYz7mBRh16k=;
        b=b91eUYrwJJeeGfpnI3fmyL01bhSvEkyZC24ZPJmcS44vNG5hNZjWWYRoV8ToHLEvT2
         9Z/64029z82pOqQ7ZlOMwPrTSRvehF+79/LEeiGzSKT1V2Oz7Oumjf5jDOTl8d8/HI6+
         0z+h7+6osfZLnuApIEXqBi0KcgRUJ/zgEaKYG6YIiiagj2DsxumSOqVOSqM2Tfx1o01O
         HzBxrnAjV1K/TTZ3YxYXGc9r/iNChIJKyvEnGUeskar1xoBANoYYZNxM4ZKvUqqg2s9p
         pCo09mSL657K2xkA+H6H9MjdSkA+tcyajrc8mwvYQuR1eAfuGvMdpqax3eECjg6fjSDM
         dEAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU0bCmMF+rsdhDqriFYA51R+nQAayG3N32BIcsjyTsGEBQ0u6I5
	2e6H0e6oSmJOyS4aTfEQKqefS7SFREesfoMXlBUDvxaLelyOWTYqEzZ8huRxQJJ1dG8uAymvI/7
	nrSPsNiGZPtrIwS87YR9n+261jRUDIB5E+ylsJ7wzRGk9SxIkzmMmCGhQjg0UUPlNug==
X-Received: by 2002:ac8:7104:: with SMTP id z4mr31690705qto.52.1563452665692;
        Thu, 18 Jul 2019 05:24:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy4GAC3zMfmPnbSjIaCjJ0jmLwcne9FBdInOgNHxT1PGWxW39D2vLIelt9Vixy9uU8Jj60
X-Received: by 2002:ac8:7104:: with SMTP id z4mr31690663qto.52.1563452665044;
        Thu, 18 Jul 2019 05:24:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563452665; cv=none;
        d=google.com; s=arc-20160816;
        b=uIN8hPq6oZAH1qzqniJLAaBpepMrx4n310Zd4OjyKLsognqXS9WlhDqw3sNQcof0yL
         yrcYHydnOj6CecqGh7NwpqYESl1NVyRDEcHN+RNRBuYxQ/X0qTr9XqrYZIiLLJd/N98Z
         tWrovyYUyhjz9xpS8zMYA8v0NjnFAgiSHyeVPxku8fMGjydzDaU1T/5MYAM1FPsphBYC
         GZ1i07KdbZ4dh7r7nKqbGuAShGtuN4XQ2g6CYcq8qHgaJcKZUkZMCRw/8ohMISMLgyld
         W8pQPfvkyQTKJr86wKDD9tAFC0/3b/4DaifJ1ZD1Hxgxy7H/0X7Gh9htFtZMphSlCh0w
         baLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date;
        bh=H+TymQOnmdcKuZk9ttK0AqeJXUX/JIzSLYz7mBRh16k=;
        b=Mbua720DFYOF0whidJ6iHOmm2bDgeQqSx6LhSmd7v2rxhQNjqpbW60tvbX5crXXnaO
         kJza6ccqhlA0KexQjM8wAR07Rv8mQysyVRHfXWX6mlGWpcYw2qz2U1YJre7Re1lJT74E
         2MiqvUZHKNZNWzlg/wCHGV8DfzHMPHJI0BIa9bpfG0dsAH/1wfvKcxfq1gSgrcy+IY9F
         WRPIPdlbvyLI++qMYqJMgRegUAFcxq9yg71ITphNcT+rlVPs4wm7SLs8m8aO+RXr0HLl
         AtImjWBrWZvJP6uBYcFGVdQ5SZ7sgbpn8NUHBdKuwkoZyf5tW/KQbmJWezmBo9jKo7om
         HJvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q31si1919187qta.349.2019.07.18.05.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 05:24:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3A909309264C;
	Thu, 18 Jul 2019 12:24:24 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 8FA4E60A35;
	Thu, 18 Jul 2019 12:24:19 +0000 (UTC)
Date: Thu, 18 Jul 2019 08:24:11 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Subject: [PATCH v3 1/2] mm/balloon_compaction: avoid duplicate page removal
Message-ID: <20190718122324.10552-1-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mutt-Fcc: =sent
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 18 Jul 2019 12:24:24 +0000 (UTC)
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

