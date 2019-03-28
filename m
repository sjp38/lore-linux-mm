Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DE67C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:47:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 412872173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:47:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iMJb67+f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 412872173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B25076B000A; Thu, 28 Mar 2019 19:47:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA6D36B0008; Thu, 28 Mar 2019 19:47:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94A036B000A; Thu, 28 Mar 2019 19:47:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF4A6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:47:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i23so180051pfa.0
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:47:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DCoXfwtDoQElNXOEfosWBeE/6jSxU0DiQdqtsDNUNdE=;
        b=LY93nJfmxww1ZV/7J/9gaxsh9GhKxLzvNX47JzaRNIAYjLw51UNs3Rj5R4j1HFWRLC
         KpUWUdaFmqDzDcJ7iH5YtHs5TJcFsmxyZUNI3zNW4ajGlE/tepqzD7Qv5UPzsQOyg8NV
         wnWIGadh/3ajEBVP9IcKbplh79c+FDwYpDRnMJpwbNS28nO4FkZBuiHgZywNPPEGEXNC
         9a+ehXnzsnDwmKTwxEX7LqZd1Ggv2qdQrVlrtEeuP0Vf4W2A4lqDyK43ZbPtl4oXSgDh
         xNtt9GlN9OuBxOtslMj0H9yatljSLOwfBPulVkxgRAQCG0YtBPCQs2KYwWbm91k+xIn7
         SgbA==
X-Gm-Message-State: APjAAAVZ7/PEaLe49zx46WhJUEHyLoXQP3BnHkBje+ot6AdSz2FFZSM0
	m/9bXsIXXAqywtaR/FSf7vnflMc5Bva234xwvD7iSW8CuMUREt3IIK+KeTr2kYWuViHQgmvS9ns
	m6elM4uFE1YLPIYXfRKQeWueTlboVzA1y9+f+ZsgJ3/G14BCl+60O4FS8fRjf0Ra9/Q==
X-Received: by 2002:a62:59cb:: with SMTP id k72mr45095710pfj.111.1553816845005;
        Thu, 28 Mar 2019 16:47:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtU6o59ILazl76RHgQiIZFcJ8auzqsDN7Y70DU35TBt+C+u/R2eB6b9LUV2C6yfFc05xRs
X-Received: by 2002:a62:59cb:: with SMTP id k72mr45095674pfj.111.1553816844140;
        Thu, 28 Mar 2019 16:47:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553816844; cv=none;
        d=google.com; s=arc-20160816;
        b=Pf36gJQTUDV0rVRHbmjSwnQZ9cSi1grHaff4uc69iVUyTpMhXGWDScLULf0biyN6Ob
         TF1kxYwcSu8+waFCtE3RPOj63EgKb5LNNnpG33IyXC/9NndTDITFN3kTxAv88XxSBFR9
         b/K+q92k/v6196iupi97ph52jq0/sbdfFEiGMqA79lUqoYK0oig6XqZ6+tGTrvD6wySA
         r7FI95juS14jwFSMwhZF/SePLHqBQv+xzJrxfECpSY9RtCavOKgcc95GfvcYo0dn7pEu
         lpNMNzUNgUhfSdW5LPlWfDlha8Vsv4BtaTBRswLIM6Jj4sBjl+WMp7hJ7ecC7OCtnpvQ
         tIEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=DCoXfwtDoQElNXOEfosWBeE/6jSxU0DiQdqtsDNUNdE=;
        b=e7Q9CKtiZO1hyKPc+cjX1W0Jq3QPPaqA8ik2N38JMaMcBagoIlpwvE9Q1pAYRWufwC
         D836QVuHIUhwQabeqS+bK6EV8M0x2zkeuKK4dxPZbKpZz5UPa/4YVzgarfbZq6igpl6Q
         5Iahs8vsamWhQ82UtDrYNMMFK84p+sqYYCNFB5SHzrCO6uuCW0On1VLN36IhXa65IHLm
         PjH6BpzVzhCs62XvsUTj9AY85JhrqWO4QmhQ8irOeNHT8BQazzqjOVDerKNbY/fZ7RJK
         X9Dz+EEb+W89LN+CJF7w8ywFI0pyR4VaKy8TVUAUt62hBUz7p673vxOeiICRB4WLYa2f
         GWgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iMJb67+f;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r198si490907pgr.153.2019.03.28.16.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:47:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iMJb67+f;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SNiDr2124232;
	Thu, 28 Mar 2019 23:47:19 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=DCoXfwtDoQElNXOEfosWBeE/6jSxU0DiQdqtsDNUNdE=;
 b=iMJb67+fuQVNpdvgaj3dV0A+AKOE1Ws5y9ti9ugYJXb0jmPwNHSMgBZLJ2ghZf1RxYfY
 ZVKJxyvwPsX4deBz06LETu0pe7dW+HHRhb4ldKbzdy+iWE1HaofJhO5X844P+IoIoh+u
 Dtip/rPUMHoKAxeR27Ne9UR+hNrUE0LIZyBnbDtDoTsAC7ezawApX7XkHGYeqxMfaVWg
 9FIm6sMgoRPA+9cvxQ8mhAb7vR4ooIc/eSMBx/KNKYRDphJTwW2kNOy2YkvbXN6S9BUd
 57hmuqYfb6DRD/cpCBUo4ENRRvVTD9Xz8pBvgk+URNjn0o35llqnPu8I6C73cWuyAbMd vw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2re6g1hj1n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 23:47:19 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2SNlJSq008392
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 23:47:19 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2SNlIn5018631;
	Thu, 28 Mar 2019 23:47:18 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 16:47:18 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 1/2] huegtlbfs: on restore reserve error path retain subpool reservation
Date: Thu, 28 Mar 2019 16:47:03 -0700
Message-Id: <20190328234704.27083-2-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328234704.27083-1-mike.kravetz@oracle.com>
References: <20190328234704.27083-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280154
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a huge page is allocated, PagePrivate() is set if the allocation
consumed a reservation.  When freeing a huge page, PagePrivate is checked.
If set, it indicates the reservation should be restored.  PagePrivate
being set at free huge page time mostly happens on error paths.

When huge page reservations are created, a check is made to determine if
the mapping is associated with an explicitly mounted filesystem.  If so,
pages are also reserved within the filesystem.  The default action when
freeing a huge page is to decrement the usage count in any associated
explicitly mounted filesystem.  However, if the reservation is to be
restored the reservation/use count within the filesystem should not be
decrementd.  Otherwise, a subsequent page allocation and free for the same
mapping location will cause the file filesystem usage to go 'negative'.

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G -4.0M  4.1G    - /opt/hugepool

To fix, when freeing a huge page do not adjust filesystem usage if
PagePrivate() is set to indicate the reservation should be restored.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f79ae4e42159..8651d6a602f9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1268,12 +1268,23 @@ void free_huge_page(struct page *page)
 	ClearPagePrivate(page);
 
 	/*
-	 * A return code of zero implies that the subpool will be under its
-	 * minimum size if the reservation is not restored after page is free.
-	 * Therefore, force restore_reserve operation.
+	 * If PagePrivate() was set on page, page allocation consumed a
+	 * reservation.  If the page was associated with a subpool, there
+	 * would have been a page reserved in the subpool before allocation
+	 * via hugepage_subpool_get_pages().  Since we are 'restoring' the
+	 * reservtion, do not call hugepage_subpool_put_pages() as this will
+	 * remove the reserved page from the subpool.
 	 */
-	if (hugepage_subpool_put_pages(spool, 1) == 0)
-		restore_reserve = true;
+	if (!restore_reserve) {
+		/*
+		 * A return code of zero implies that the subpool will be
+		 * under its minimum size if the reservation is not restored
+		 * after page is free.  Therefore, force restore_reserve
+		 * operation.
+		 */
+		if (hugepage_subpool_put_pages(spool, 1) == 0)
+			restore_reserve = true;
+	}
 
 	spin_lock(&hugetlb_lock);
 	clear_page_huge_active(page);
-- 
2.20.1

