Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A0CCC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:51:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12C4523CF3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:51:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="a9iZtmop"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12C4523CF3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A00216B0271; Tue,  4 Jun 2019 12:51:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AFF76B0272; Tue,  4 Jun 2019 12:51:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89FFB6B0273; Tue,  4 Jun 2019 12:51:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5457A6B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:51:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b24so5744649plz.20
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=czGyebjwq6q9H91dvt642bzkXDyJo2km23TAp5AUCEw=;
        b=kIGPIqrhRftx/kiys0JlVjh6yXVZlfKW40g1BzeXiTLP6l1icXSsPyxjPRz9Llo8go
         GQhwxve4Gqudmsp+0iaCh4PA4JJBJPkT3zaMxubA77B/BWfysK8kPGZEz5YyEvPjn4/+
         9s13pS0eCvioz+t6bsLpE8943LteZwQkFXyB0nCxqdjIj01QPh0RIGOBdb4EOmyIDz/N
         8aI0N4NOdIRA11hhU38qZDu+pHcEJLoj4miRDhl4S1oFzctHzHPf5mBTHSkpNAlbrE28
         v7ZFKH7T3hZJGqNBiWN2auer6k9N0FHtz6LA5/1hFHvNx/e9ITAiDM7kH+TdrZ5AJT0u
         7r6Q==
X-Gm-Message-State: APjAAAV5UDfgQSI7pfabF62L3MnwDKRlU+wInKDF/L0ckh5wME0m+GGs
	Hjg3QaXW3Q62RC+zTUsE9iH2Cb8M0zF6VQIqoRW1ckpqN0mCPZ6XF6Asz4T2OC9xIeyVPt6YgUq
	WlMQFs6N4CAxo9neJ4/Ne7LEEbsBGFW/P9RdLrNEVMViPuxYaj0wb+yh3VztoSRZ0Ig==
X-Received: by 2002:a62:2e46:: with SMTP id u67mr39752514pfu.206.1559667108847;
        Tue, 04 Jun 2019 09:51:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn7kj3jK9vSY/netUuqIBeZPd8F6Tm0RxmBKQcOBj6ITbmhHMEoyd8ustK/11oAwfxMNJ3
X-Received: by 2002:a62:2e46:: with SMTP id u67mr39752465pfu.206.1559667108056;
        Tue, 04 Jun 2019 09:51:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559667108; cv=none;
        d=google.com; s=arc-20160816;
        b=KmHyS0Zhpc9HhCWljE+TBngI+RqwFd8OBVmgr894sEpex4n7kxOmZqr5drjsIk4obq
         qXEMlISAShw8NoeFuu+aI7KyIoghCO1D5rvRoU5Bfs7rlNYXOXtRzJgzsyRTpM/xEeTT
         29eTxJfh8+0a8t63Ud30YrwRtVx80UgeEtxnb+QftoqgERV6/JwSNpWTbL2GlceqhSUr
         YB4HSoHiTdA7ALelI0eVKlpNG48+qOitc1n6j24ARYe/W+WrMou1jF3/9vqS/yLwEXaT
         CEIEsbxZImKHIA9hWkZ9DBEutoZQURuFIme70uHeRw5zvvC9l/hymsz4URIBT4NBAbI4
         Fhyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=czGyebjwq6q9H91dvt642bzkXDyJo2km23TAp5AUCEw=;
        b=MHQb0WABYZZF2mcbMlIe/elZk3Ov9riQUTRTxD0NG9zVbC1BkEFZqgmpaOregZj7Hl
         uz3KXRmwPIWTsdyvfoaGSsdyZyi0La116HSURkXbr8F3ur9Bn//3Iws8vjJgXDwgaBU4
         Lvx1cJpGDFlMOLosb2uuHeY5nRKrDOryj21u3TFsSDoQb0qTyDbhbNKvPDY2jki8b/WY
         3PhKU1CdKgUYlcOewP33vw6Shc8kFdfnDKapPSTtV2M3pG0vTdMVzCu6Dl/TqB2Q9eJB
         5GbQIo//sVkx2EJ25aJAywmVZV8GXBRJ7mUoQtSwejNVZeos+tgpgfpuu0nxO7eTtF3s
         hBaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=a9iZtmop;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h1si18769228plr.116.2019.06.04.09.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:51:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=a9iZtmop;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x54Gb3QU011365
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 09:51:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=czGyebjwq6q9H91dvt642bzkXDyJo2km23TAp5AUCEw=;
 b=a9iZtmopl4uqheVbwFpn4pF0Qr+XnQZnYd2PUYmWPNhzu0lDAppIVjySlV/uavoqwpd+
 U0FrM/2BkeXNzvMXIv/vF4RrYssMJVHrUDtMPHYl+BqeLgOHOElVF+pPvqoOVdXrF48L
 NC6l5PQN3d8/BRekSLh8XzTm9OG6BDl1KY4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2swr7a9061-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:47 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 4 Jun 2019 09:51:46 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id BC20762E1EE3; Tue,  4 Jun 2019 09:51:44 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <mhiramat@kernel.org>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH uprobe, thp v2 1/5] mm: move memcmp_pages() and pages_identical()
Date: Tue, 4 Jun 2019 09:51:34 -0700
Message-ID: <20190604165138.1520916-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190604165138.1520916-1-songliubraving@fb.com>
References: <20190604165138.1520916-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=938 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040106
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
index 0f57b5dfb331..1bdaf1872492 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2881,5 +2881,12 @@ void __init setup_nr_node_ids(void);
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
index c2fb8fd807df..c122718de550 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -801,3 +801,16 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
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

