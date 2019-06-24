Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25FAEC4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:13:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D53EF2166E
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:13:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WST0UPSx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D53EF2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BC896B0003; Mon, 24 Jun 2019 00:13:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66CD28E0002; Mon, 24 Jun 2019 00:13:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5845F8E0001; Mon, 24 Jun 2019 00:13:00 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0B96B0003
	for <Linux-mm@kvack.org>; Mon, 24 Jun 2019 00:13:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x13so4560680pgk.23
        for <Linux-mm@kvack.org>; Sun, 23 Jun 2019 21:13:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=liAXSrzZADosAkb1YtXWhzyzZ/3HP+JE3hlQPzLjKmY=;
        b=KfF5QLcuqAHBJKA8Wlsmzk+8Vy1WrbqJtl4gCBe+xTS0k0FuWrOvWdUHt7S8mGdQVk
         wiNCz9+K4Z6PhjCMj5/BADOCP6yn4JBzH8Y5Cmk0rf/MOxP6qFInBfz37SE1cQOlDeX4
         bkOlUrrivGl3A9IgyDgymNkA7bFzg6WxfVKgZSa4QQ4xk1PUMCOt1h4skxSRWjCjYLS1
         4mxiUW/O6ifOC5pnYt+rBXzcgBwKFo/w4bfWp42rDomh7xRUrYZjq3On+PDw/ihjpiVD
         /F+LLJpw3iOIOpRVfaYyYHDDAqtwb0V+EIKLqiQGnE0R21oijQJMwc8eknAUfqKCY0wW
         NBkA==
X-Gm-Message-State: APjAAAUQBYguurK0phMRxIDhzrC8o6sMzDn3CyLWx9yHgsk8BZiQD6Cx
	YtZ+MLw5/iSr0TntQlGUgC2PCbPwx+LdNH/4fItdyXxR+9aBHUMeIbZ7ZGRQUL80ieJo5DOKbtE
	MrhEGtf58ptN923GfkpIqxEmRHTVvesdKrenK6ChbmZGLpXluIt8tLcqr+cx5SwyKcQ==
X-Received: by 2002:a17:902:8696:: with SMTP id g22mr118626624plo.249.1561349579593;
        Sun, 23 Jun 2019 21:12:59 -0700 (PDT)
X-Received: by 2002:a17:902:8696:: with SMTP id g22mr118626578plo.249.1561349578780;
        Sun, 23 Jun 2019 21:12:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561349578; cv=none;
        d=google.com; s=arc-20160816;
        b=na9PPf58e8k0bPIMdu1m+pcMkqfg6BHexhPYvvXU69aib3vH8Di4MPez5UA1FWe4VZ
         lr5ibJN7PHWS4+wIX0gTVzWF+ZNhGU4GGRcuRd/Ac3W74L+mM4M12N6DanzZc1vRdOGz
         IkezPw+sbLudYCOuAnMWoO+1oknYxqYhIj76jro8scXL1b7L0Y1RnyuhId/xAoMxUnck
         Q5BXe9SIkw/v9LhZF7j/d1UK6yXV85HSvfFTnJgrobP7jbKhimMt40PXucSc2e/on/N2
         DY69EiAVPAvKdQ+B7XntZfEIuftlIoKfiwF2gsLr1g80hdsgC1M/Kj4ED2vC/ntLeAzW
         ARBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=liAXSrzZADosAkb1YtXWhzyzZ/3HP+JE3hlQPzLjKmY=;
        b=AJSjZaj6SwVP8wdNTeEpsZuKacxo7WJ/XeA3hrYd66jPYzbyC6q5rSStGaYdqv8BWT
         m6HmDwJ7SNP0amLW1dQtd8mIUUylzQ+q5qJbiSP7wH7E3UyY04/H2eYu9pT+7pHmvGR8
         uiKdty0qFrL83LZcbGnJWR+DLnO0vgLlvxUWyHckb7mrCdROrajKTgq3qC30WZLNRMkQ
         uPBLm/i24SHtemfajPSduD/8IJqt+AiNyTh3YxUBNU6FK7Yd8JGxrsU+25AUWX66DivK
         xyVUoqNC6rtn8J9dIcVHpRggf5TAZvSYo0XcvEerTNGAeN1vlGVFju2tOH9Q2JKvVoxH
         9f8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WST0UPSx;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k135sor5521939pgc.23.2019.06.23.21.12.58
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 21:12:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WST0UPSx;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=liAXSrzZADosAkb1YtXWhzyzZ/3HP+JE3hlQPzLjKmY=;
        b=WST0UPSxHFggzVaicksTgzQyGB6/nIpepqasB5OKMlpX3rsja1TvHJxR4lrdMAUVAP
         2H9C11DwrkI0aHug/+cSUmz9S0HXv+3TALy9ePTW3w4BIR2m8KAqaE7oQ9zYzmzvTGJN
         /eyeYAHj0LXDLaL4hOA0vL2otu3b4cvecV0skqxcIydsgvCsXQqRTz71Vpb5lCGneuxN
         v/XTodbFVZtWYeQQKMdLhBgY9oZTSxyiprXdlKmDs/LDHGGs6p7AfvyzGCGcjNKukKd6
         vLeZRkn8/rwhQWtIZkFh8o+7vJ3P/tbhv3PpWdVAxL2lNhqM062UInNj02QkdxLCt6gx
         /v9A==
X-Google-Smtp-Source: APXvYqz73zX9Cj8GqKXGuUimsv0v8MW6gNnWWORYAHs3K7IDVHnrZrBvSf0VxXsWmAA5jNXiyXaccg==
X-Received: by 2002:a63:5a4b:: with SMTP id k11mr13446294pgm.143.1561349578165;
        Sun, 23 Jun 2019 21:12:58 -0700 (PDT)
Received: from mylaptop.nay.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j14sm10202116pfn.120.2019.06.23.21.12.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 21:12:57 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: Linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>,
	Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Linux-kernel@vger.kernel.org
Subject: [PATCHv2] mm/gup: speed up check_and_migrate_cma_pages() on huge page
Date: Mon, 24 Jun 2019 12:12:41 +0800
Message-Id: <1561349561-8302-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Both hugetlb and thp locate on the same migration type of pageblock, since
they are allocated from a free_list[]. Based on this fact, it is enough to
check on a single subpage to decide the migration type of the whole huge
page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
similar on other archs.

Furthermore, when executing isolate_huge_page(), it avoid taking global
hugetlb_lock many times, and meanless remove/add to the local link list
cma_page_list.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Linux-kernel@vger.kernel.org
---
 mm/gup.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097..544f5de 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 	LIST_HEAD(cma_page_list);
 
 check_again:
-	for (i = 0; i < nr_pages; i++) {
+	for (i = 0; i < nr_pages;) {
+
+		struct page *head = compound_head(pages[i]);
+		long step = 1;
+
+		if (PageCompound(head))
+			step = compound_order(head) - (pages[i] - head);
 		/*
 		 * If we get a page from the CMA zone, since we are going to
 		 * be pinning these entries, we might as well move them out
 		 * of the CMA zone if possible.
 		 */
-		if (is_migrate_cma_page(pages[i])) {
-
-			struct page *head = compound_head(pages[i]);
-
-			if (PageHuge(head)) {
+		if (is_migrate_cma_page(head)) {
+			if (PageHuge(head))
 				isolate_huge_page(head, &cma_page_list);
-			} else {
+			else {
 				if (!PageLRU(head) && drain_allow) {
 					lru_add_drain_all();
 					drain_allow = false;
@@ -1369,6 +1372,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 				}
 			}
 		}
+
+		i += step;
 	}
 
 	if (!list_empty(&cma_page_list)) {
-- 
2.7.5

