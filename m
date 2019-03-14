Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E211EC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:40:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA6CD217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:40:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA6CD217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F1C98E0003; Thu, 14 Mar 2019 11:40:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C8068E0001; Thu, 14 Mar 2019 11:40:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B87F8E0003; Thu, 14 Mar 2019 11:40:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E55E18E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 11:40:32 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y6so5108541qke.1
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 08:40:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=6k8y5owJlIgtXJ/xW4k/7iaMZhqHe82u6BLdUz4Kcic=;
        b=tiOpdqxm+B4xPs3mAmkCorAz/tAv9a8GeakVTeTQbpujPdpjXtyC+3mgnArSoLrw5O
         4Zhd+ZlqfFPfMPM2P9XGO1Udz6jflHsWO9awYsd0lvq5B+rnTbl+NwDwJDuPdAnf7Izm
         O/ZSnAXmxFh6rzEE6fimZa2jXutD/8PikJlo5Q8LxBR3qEWv3ggN1y1EQ48aS5KZZ3Z2
         2yHK5YkIlT0uqoWRSpTj1wGzTNqrI/uQu1NWFxu5TEp3zNg+x98MDzEyi4g5+rXgBSEL
         Ea6rJVFWB082xK0vkp0WWUifICU+Ast39gil9Pb5fcTw1aAC5p2/xvAexS2zqypMi0bg
         MfCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUPJnSiEH1El/gueqdGxrRzOFeEPzdPt54Pdo+qrf2kOSmbuEyQ
	Vb+s0c28ShjsyhCEs10zahmFqK8LSEAeb2Yp310t5bzBHX2qe8jgKRPkMifFkel88mBTx9UleOe
	4Wz9o9r6mK0aEhtQWUQ7Y8XVns+qXdh4vt2kf/sbsE9gooY/Uy/+IuoRjnM8Qx8dG+Q==
X-Received: by 2002:a05:620a:1013:: with SMTP id z19mr9914384qkj.342.1552578032739;
        Thu, 14 Mar 2019 08:40:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0NRV+k6igYzDzgSF4jyRZQLLlDay6ls4SIm2LGJmWQ1vWCUYASvUiS+Zl9qEE9rkJTD0M
X-Received: by 2002:a05:620a:1013:: with SMTP id z19mr9914302qkj.342.1552578031484;
        Thu, 14 Mar 2019 08:40:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552578031; cv=none;
        d=google.com; s=arc-20160816;
        b=S3WP2XyDlHwSR6KeWRg63bN/Uow9ZAnEd06hq2nZuXQUzk7rbJujbNKpwzeFf3NJCi
         eAYt8DqQJ/U6GNbaO2Qg4ytdM7/kb7aVOj3TxijvClHfSdUvI/1Joy4zh/o2q2ModC8q
         kMk+g22qxzMhxNcud1yaloOR0wGfsy0odRzKLuUT5L1be75GO2pma2awJlxvh3UCwrFz
         nwmTHkr7KhScI30EwMOIl9cvHZ6Qgo5xJ7ENBwoBVN+HVHwTZ+BJY+22baakWnpcxfqP
         n2QqEeeObv18m25g+CClloJjUGgmYR5NiFolN50Kmx7ibDIdCItQye3KIDvGqP05kce8
         sElg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=6k8y5owJlIgtXJ/xW4k/7iaMZhqHe82u6BLdUz4Kcic=;
        b=KjUiIPqbSyaMUpjhQ4G15V9AwGuKSoh81oY25z4M+EeWzGtXHeFLpmFGKecMUrpDHz
         jgiiMs/RqrEZq43jaIKG4GxUgZ9CqJUrfi9agR1iKqOVyyYT8o7WupLq5ObCQ1Og+0tp
         hRcKojS6rzb3MmCRpVyEX9eKpEwW2NlsVrIRNJQfd+RNN8Q2m66veoJQ0ge96lPGjjNb
         U0vGSWexavApSQu2UstMQCBL6GQZ3YKSRyWbv+kw2GQuVW30by2f3bAUOfjqYu9B2IFo
         +fMLlx2N1qt33TBA45tBySzcSvryPb164jN6ACZ8RcKXbog4OBrxSI7bSnVIkEwviZH1
         haBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e91si1669465qtb.96.2019.03.14.08.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 08:40:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5BD0880F6B;
	Thu, 14 Mar 2019 15:40:30 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-188.ams2.redhat.com [10.36.117.188])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D93A15D75C;
	Thu, 14 Mar 2019 15:40:25 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: xen-devel@lists.xenproject.org
Cc: linux-kernel@vger.kernel.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Juergen Gross <jgross@suse.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Julien Grall <julien.grall@arm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Nadav Amit <namit@vmware.com>,
	Andrew Cooper <andrew.cooper3@citrix.com>,
	akpm@linux-foundation.org,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH v1] xen/balloon: Fix mapping PG_offline pages to user space
Date: Thu, 14 Mar 2019 16:40:25 +0100
Message-Id: <20190314154025.21128-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 14 Mar 2019 15:40:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The XEN balloon driver - in contrast to other balloon drivers - allows
to map some inflated pages to user space. Such pages are allocated via
alloc_xenballooned_pages() and freed via free_xenballooned_pages().
The pfn space of these allocated pages is used to map other things
by the hypervisor using hypercalls.

Pages marked with PG_offline must never be mapped to user space (as
this page type uses the mapcount field of struct pages).

So what we can do is, clear/set PG_offline when allocating/freeing an
inflated pages. This way, most inflated pages can be excluded by
dumping tools and the "reused for other purpose" balloon pages are
correctly not marked as PG_offline.

Fixes: 77c4adf6a6df (xen/balloon: mark inflated pages PG_offline)
Reported-by: Julien Grall <julien.grall@arm.com>
Tested-by: Julien Grall <julien.grall@arm.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/xen/balloon.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 39b229f9e256..751d32f41f26 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
 	while (pgno < nr_pages) {
 		page = balloon_retrieve(true);
 		if (page) {
+			__ClearPageOffline(page);
 			pages[pgno++] = page;
 #ifdef CONFIG_XEN_HAVE_PVMMU
 			/*
@@ -646,6 +647,7 @@ void free_xenballooned_pages(int nr_pages, struct page **pages)
 
 	for (i = 0; i < nr_pages; i++) {
 		if (pages[i])
+			__SetPageOffline(pages[i]);
 			balloon_append(pages[i]);
 	}
 
-- 
2.17.2

