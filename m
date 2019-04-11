Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C2ABC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:49:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3F6F2083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:49:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3F6F2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 104B56B0005; Wed, 10 Apr 2019 23:49:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 062716B0006; Wed, 10 Apr 2019 23:49:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1FAE6B0007; Wed, 10 Apr 2019 23:49:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id BAC206B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:49:24 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id i21so2248035otf.4
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:49:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=C+DweHRt2Ar/FxB1sq7sHDiVqzSl0QFu+YK0v7VYk04=;
        b=BV8GJZK63b4nsBBzW+0Q5ybiKXEg3/jgqBpJsH3PmjI4Vme49VcAEp08CdCxzFdmcX
         Gscf0Av2F3sewxMePzmpBCBUlNikXWA/LLHsEz7mAzXj57y8xhFIsA8B/4ZAQOlJqzmU
         qoF98EnB0qsWt1nz3qZxT1f+qI1CaD1pJSUh2fOAENZDA39Zh9S2YmCc433bto59ldZa
         pwGdSxONRkmuTTxZmj1+xMT7WnPrBBs/uXL16FtguAOn/dlnMZmcAR/zVxpevwS6CnWR
         xzFwPJvqiLd78rLwnTTlvAko98Hvj2fo3tkjIoy7p6hJWLCuYL1Idc3dDHEe7USJH+ET
         qGAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAV0IQmzXfZLHAPsGP5Vf6iJNrszqldmKEiSUpf8rOp5eFVDJwOO
	mLnTSgsKwl1N4N/HQXxhln0yE4VxqcQCo7SVH0/uTzqDeXWMPbWkFV+0kCsrwAfiEYYLXwFTZan
	kJyM/xqRLEVXFl3Dy9dHg7ll+9mDSAX/PKZdx9gDOKdihf4IHp5n28GrCGgnyttC5aQ==
X-Received: by 2002:a9d:61c5:: with SMTP id h5mr27739369otk.330.1554954564480;
        Wed, 10 Apr 2019 20:49:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgelPEhoLX1I0BMsWD6JfWFB/ipyEjD+2rdaOpQ/zV6PJ1/FU4ET1nBNKwA7BzIjSdDon2
X-Received: by 2002:a9d:61c5:: with SMTP id h5mr27739347otk.330.1554954563880;
        Wed, 10 Apr 2019 20:49:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554954563; cv=none;
        d=google.com; s=arc-20160816;
        b=iDNKUJvLcWyxP0gxW1cIo9YBsUAyzO4ZP5d7n6oTVbQRb46HPg+mbYzj3pCv5sno0/
         gY0e5f3lyuAI1k5xZnJhhojMsyeV+89V5NtD97mUcrKalF5GDhogtBFyMldbmcqPqjg+
         RutK/GyuMlup+2ii9NmgqxaXb37rJW+2Yl4OSth0MuXGbEe26paVDww8D1VMen2SF1Pd
         PFP9F47xNkjxRxAZB1ToWZECs7SakgJOX9jVAEB1LFA6eO6HsjnhCX0hLsyTD2iuIH0c
         QNtMOUGTTEuDDtc602J4vrLyvQXLiAk+tR0q9dsEyysNfWpHmiIPEVWJlKO7eyAgSW5p
         Rtog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=C+DweHRt2Ar/FxB1sq7sHDiVqzSl0QFu+YK0v7VYk04=;
        b=IDnwgQGUk2wQgrHKZNZ8nUw5WEMEZzb9o/90uSNdUOw3X4Ef1OhbObu2bkeYoWZrR/
         s+qfOJhHTS1dwvU8xEIYKNhhporAeCAGjXWd5pbvtuNF8mCV/VnP8b1HG6tIlCOrryQ6
         MjScjButxcGpfE60kGJDzWLr2G4jbCFLGAAzX6MnIz0j2ZqdWWvxg6AMW++Pr9ooq4BJ
         9QpDHHC1yJ49ZEgfSmNqqNR7pVYQpyq2M70Wep8GKITok6mjL0EHCNpwwpLdQKc0qUKk
         IndWswF31wkZBa5wqBBhfQJFnei+VPXNzSLx24JqSf7MqQGcqpAzQoMiXdu3BFv4z1r8
         UZKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id b186si17521217oih.158.2019.04.10.20.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:49:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 78970CC7F424CB41748D;
	Thu, 11 Apr 2019 11:49:18 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.408.0; Thu, 11 Apr 2019
 11:49:12 +0800
From: Yufen Yu <yuyufen@huawei.com>
To: <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
CC: <kirill.shutemov@linux.intel.com>, <n-horiguchi@ah.jp.nec.com>,
	<mhocko@kernel.org>, <yuyufen@huawei.com>
Subject: [PATCH v2] hugetlbfs: fix protential null pointer dereference
Date: Thu, 11 Apr 2019 11:53:18 +0800
Message-ID: <20190411035318.32976-1-yuyufen@huawei.com>
X-Mailer: git-send-email 2.16.2.dirty
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch can avoid protential null pointer dereference for resv_map.

As Mike Kravetz say:
    Even if we can not hit this condition today, I still believe it
    would be a good idea to make this type of change.  It would
    prevent a possible NULL dereference in case the structure of code
    changes in the future.

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@kernel.org>
Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Yufen Yu <yuyufen@huawei.com>
---
 mm/hugetlb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 97b1e0290c66..fe74f94e5327 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4465,6 +4465,8 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
 		resv_map = inode_resv_map(inode);
+		if (!resv_map)
+			return -EACCES;
 
 		chg = region_chg(resv_map, from, to);
 
-- 
2.16.2.dirty

