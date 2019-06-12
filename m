Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49CA7C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02B9D20B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="JWAuNS78"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02B9D20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 760176B0269; Wed, 12 Jun 2019 18:06:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 710D66B026A; Wed, 12 Jun 2019 18:06:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53CE36B026B; Wed, 12 Jun 2019 18:06:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC646B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:06:25 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id z124so16713240ybz.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
        b=feg0WBsqPfOAXgaXs/KYz5TwWeivQAfrRSvplYqhfrtxtz5F6lmfnG4sysgpXYI6bM
         thbyidXN/LIbxIkG6wse6kaUOaKkvJHzqEkmFKXlaabY5MBhhrEWpRhNGLWt2h5b3l7M
         zGIMSuwRmtJU8qv7AC4U9CBzP2cBerajMptWdwLbn8C07DXL8/ig0tyP6HJjukcD/VGY
         TQ1OvksO42Ok5MYbj9VSnF04OTLYXRfxEtF8l0qWqz9eAQQdLMX4+mF86WJ3pUxo6yL/
         QP7CdIuRdDGfHIKCw/QgSpeHCIzDG4M3IcT0QNohykb5hNsUU5qjDuqyh5j7kD9k+1hd
         4lug==
X-Gm-Message-State: APjAAAX45ts/Fz7Z0h5S9OWYEeHI4z60QdUI9/282HeFGPPbb1M5hWrs
	QOJwrRSXlrZ/bPNAuaUGeFTLzPhiuW00ZSLgmY6K1QERZ1ZwZLisB5+9y+UpurJuykwH8c795CT
	0+OQzrg3K0j6jcy6gRhItS+2TMpqUrZ3z2BM9FK8YVTwR3/wAFxDVjjSJnTEKdmXsyg==
X-Received: by 2002:a25:ef0d:: with SMTP id g13mr2674660ybd.425.1560377184934;
        Wed, 12 Jun 2019 15:06:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvlDoF3KbcG1xH8SaeR5xxjOorrO76ti0VovoWta08+UOFVafKCVP4n5+YVXRNj/pisLHV
X-Received: by 2002:a25:ef0d:: with SMTP id g13mr2674628ybd.425.1560377184268;
        Wed, 12 Jun 2019 15:06:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560377184; cv=none;
        d=google.com; s=arc-20160816;
        b=u4mXOgiSmhBWXF7dAg/9PBTscjTQhOpz7Ytb8/v2EtTDrVHAMOUWGPnslJsK56OIty
         v0yMQMseHPmI0xCMHdT/d5ft7XPxsRn/CZ1jgvGAap4wlO1j+BBggT4oshMCEYo3VX+m
         jY7L3+s0YPF/xHUlD9OhQriN9yWakGsG+fcxiv5UL9qVScbE9HvxLZLu/YdVSyJxUy55
         ewKJi5Htds2LOXoN44VlO2O49csC/pulrE61atTHGEClKErcOGq7Jy7D/j/7lc+dFm9V
         mWYoqDgi18lmGkarXLD5COY/zVD+ZQ+qWIFgjvwFfVJeZ+X9J9QWVCxVnvXXy4bfLTVV
         5nfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
        b=fNtMW155CKHtYUB04WI5J1vottETzTksuLEl1tUFWmEqxBjFMqId0RSQlXdM+ZN8hS
         nheuq0pDBGYmBPusN7+lqLEfYheoI4Pvcg+mNO4Ar0ot+u+bASVAB/aHDthn21WtnLeZ
         A34uLHnkUmGltgO8vO9ipF8W5OGgwIzhjFuCH1P11Z6VaFtPyeJ50NanDxv933x3V0IW
         USpnRFsFWrPqHBX4TskSIoo5hqyoDHVd16+olWcM5dZ718wHf6yiaA6Ui0B3R7isl5fC
         qBzXMTKHfJXIXp/dV8ZVyiNAuGsIvTIcUxBb45ec5Hlh896BWNLnVGc72icUB8VvAKej
         zxow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=JWAuNS78;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z199si287754ywa.83.2019.06.12.15.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:06:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=JWAuNS78;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5CM2iuL014732
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:24 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
 b=JWAuNS789fcNPxnofRvQvtkoJwvLIrNhL2jvavikaTKn60o5iKcg8PEGbEhX69QfO0Q0
 M3KtRcs/HlxJn+Tk34Pq9dKYLOTfwpNSbBk+SU0CPWIfSI6Yc18Z1bO8XLNAGOq2cEMn
 H4LeEqV95Y/j+iGEYsT58hInBnNXoDdiZ+g= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t37b0gj76-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:23 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 12 Jun 2019 15:06:15 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id EA96962E2CA8; Wed, 12 Jun 2019 15:03:26 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 1/5] mm: move memcmp_pages() and pages_identical()
Date: Wed, 12 Jun 2019 15:03:15 -0700
Message-ID: <20190612220320.2223898-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190612220320.2223898-1-songliubraving@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-12_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=940 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906120153
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch moves memcmp_pages() to mm/util.c and pages_identical() to
mm.h, so that we can use them in other files.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/mm.h |  7 +++++++
 mm/ksm.c           | 18 ------------------
 mm/util.c          | 13 +++++++++++++
 3 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dd0b5f4e1e45..0ab8c7d84cd0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2891,5 +2891,12 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern int memcmp_pages(struct page *page1, struct page *page2);
+
+static inline int pages_identical(struct page *page1, struct page *page2)
+{
+	return !memcmp_pages(page1, page2);
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/ksm.c b/mm/ksm.c
index 81c20ed57bf6..6f153f976c4c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1030,24 +1030,6 @@ static u32 calc_checksum(struct page *page)
 	return checksum;
 }
 
-static int memcmp_pages(struct page *page1, struct page *page2)
-{
-	char *addr1, *addr2;
-	int ret;
-
-	addr1 = kmap_atomic(page1);
-	addr2 = kmap_atomic(page2);
-	ret = memcmp(addr1, addr2, PAGE_SIZE);
-	kunmap_atomic(addr2);
-	kunmap_atomic(addr1);
-	return ret;
-}
-
-static inline int pages_identical(struct page *page1, struct page *page2)
-{
-	return !memcmp_pages(page1, page2);
-}
-
 static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 			      pte_t *orig_pte)
 {
diff --git a/mm/util.c b/mm/util.c
index 9834c4ab7d8e..750e586d50bc 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -755,3 +755,16 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 out:
 	return res;
 }
+
+int memcmp_pages(struct page *page1, struct page *page2)
+{
+	char *addr1, *addr2;
+	int ret;
+
+	addr1 = kmap_atomic(page1);
+	addr2 = kmap_atomic(page2);
+	ret = memcmp(addr1, addr2, PAGE_SIZE);
+	kunmap_atomic(addr2);
+	kunmap_atomic(addr1);
+	return ret;
+}
-- 
2.17.1

