Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67EA0C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:36:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 349402184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:36:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 349402184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD7336B0006; Wed, 20 Mar 2019 03:35:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D93E76B0007; Wed, 20 Mar 2019 03:35:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C76276B0008; Wed, 20 Mar 2019 03:35:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCB66B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:35:59 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e1so1480938qth.23
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:35:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=w9cFJm+HEeCHcX9JqiAPkwlfm2xd5GqjMiIlH+9+Qg0=;
        b=o+pp9NGNKeQgICH5SZFTgptCUA2AacjhdtLYrA67CjmT7V4vrUNoRSjlne5/zD4Mn0
         mZEUoioJc3Exrca5foS3DgY+UlQloab/Hvn7zSTY4PW+oakv7nVtzQIJIpY8gbcqkOwO
         jHM4WK3LDDE+VpfHDsOaWAX0FW/04octvmjf9ZqgNd0Ib63Kj8eMwZV7NCenEuTrIoV3
         rWXtV3bB9exijQfrLywbLP1O4bKkwLkr0+itEyhYeXzIXiMITzWupclm7VckpHYnugcF
         ITx625gYBOjPsA8CMsCE9bNc/30TIMIO2HCuwfnj4wsx+ok44dycCMFrpp8bSzGM214T
         xJag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWBxeloQbNd6fdEgRE0ZrtEAzpU/AdbeD4LUNf7v4XJCZSgGTy5
	fFnZVgR7dn2LU2xG7PsEUMysRvUr4WGpYse0ENlTHqNPG8fiECLgvrQRTysiW3Id5AMMK+KDOf5
	QBWZ4YdAA76Gl+yAYn+oEBUmoUKNpzzTZ0JAvmZuh2rlMnehoNKVIE2dt1K+2dch/Hw==
X-Received: by 2002:a0c:b756:: with SMTP id q22mr5323707qve.29.1553067359454;
        Wed, 20 Mar 2019 00:35:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1y47ZmSYVi1vB1k/kERkKHwoDTlClk0FG8sM1b8KI91zqyFzmT2YnZwWjBJQ2+aZGX+AD
X-Received: by 2002:a0c:b756:: with SMTP id q22mr5323666qve.29.1553067358418;
        Wed, 20 Mar 2019 00:35:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553067358; cv=none;
        d=google.com; s=arc-20160816;
        b=ucmJox63D5fruFocblvCiLebkKMmVB+o8PmgKN+gB3GI0rFY9cQhV6fJTpBzK24/Xs
         zMjlQcJo5AYo91EE/fMeu3Gq1mJWM1OC9/kz2hnArEYFW0+8XSZde+I8zV+tQ6GIJzJp
         O5mh4b3956QvkPCv6Xyjy3ShlMxRuR31cqOgeweMSo3p8duSFlrDBqH2jGqHxXWxYZYi
         Fk3u3Wv9Fwqz3VwSXevoT+0gdqMiCiBPq+XWuL2xHAWNuHuMKcLEzNU3IGfBuBrNcUZQ
         WKqOy5J4pneokKjDrUIAxR151ABGza2p0jPVU7vEKJyQuOJab1w40Q9mPgckls8MuRbp
         4LWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=w9cFJm+HEeCHcX9JqiAPkwlfm2xd5GqjMiIlH+9+Qg0=;
        b=LRUi5K+wUvxzJNQsBnEGHvTEVsI+4484XachMlRJklGNrrvb0Ni27tfvW0IIJY4b4a
         UHub1RUzOscraQrCydJx9Y3L6gEcorUEGwzwzmNo8ano7wU6x+Wf7ZSz1qwJWmWfMsW4
         81QTU1YpPt8QKvIcCd19OGRGU2uX0TvsLZVd1m5xX4q5ZLBYp+k5nym9QGERmcA77gMr
         Aua6SHSv4PBkQxlh+FdyyQQWYlqvF0nap+sgKARTmCOpWGb04f5Cd1NiBiLc+lhOmuML
         EyrlvfQO+fdjYhUQ/0murD95h8QDmzb3Vm1B7zxhMmY205DzFdRWbWpWu/6Fnv0Rzs8z
         fF2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l37si733250qte.317.2019.03.20.00.35.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:35:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9578D31688EB;
	Wed, 20 Mar 2019 07:35:57 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C8C4F60CD3;
	Wed, 20 Mar 2019 07:35:54 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	pasha.tatashin@oracle.com,
	mhocko@suse.com,
	rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com,
	linux-mm@kvack.org,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH 2/3] mm/sparse: Optimize sparse_add_one_section()
Date: Wed, 20 Mar 2019 15:35:39 +0800
Message-Id: <20190320073540.12866-2-bhe@redhat.com>
In-Reply-To: <20190320073540.12866-1-bhe@redhat.com>
References: <20190320073540.12866-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 20 Mar 2019 07:35:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Reorder the allocation of usemap and memmap since usemap allocation
is much smaller and simpler. Otherwise hard work is done to make
memmap ready, then have to rollback just because of usemap allocation
failure.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 0a0f82c5d969..054b99f74181 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -697,16 +697,17 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	ret = sparse_index_init(section_nr, nid);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	ret = 0;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
-	if (!memmap)
-		return -ENOMEM;
+
 	usemap = __kmalloc_section_usemap();
-	if (!usemap) {
-		__kfree_section_memmap(memmap, altmap);
+	if (!usemap)
+		return -ENOMEM;
+	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	if (!memmap) {
+		kfree(usemap);
 		return -ENOMEM;
 	}
 
+	ret = 0;
 	ms = __pfn_to_section(start_pfn);
 	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
 		ret = -EEXIST;
-- 
2.17.2

