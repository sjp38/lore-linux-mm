Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BA45C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26DFB208C3
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ShkJ0gVd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26DFB208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AAE76B0008; Sun, 23 Jun 2019 01:48:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46CB48E0007; Sun, 23 Jun 2019 01:48:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30CDB8E0006; Sun, 23 Jun 2019 01:48:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7B9E6B0008
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so6870005pgo.14
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
        b=qtRN1mmH79ABi2FyJBgqg5NeeFv8sb36n30i4zAYEaDr3528/vt06RvXecRrea+Czn
         BRJ3i8Es/xO00Dmz0EP0nrXGMyCNocb9E7lu1P3h6uCtYXi2uROTLdhbreNNsKMX1PTW
         NzniD3EwP4EwlqnwY5fnDX4E+GH34QWH7sNs3PKi+iEcbcKqo0YnS+MVu0KhHO0UIdaG
         qQLZxi+2iHmW+fXebX8tiT087SB52Uf4F/ueO8gr3pREb8yFHkBiw+ErYPFR+S9TaPyl
         6pzBWFp8S3bi6t1B6YfPcB/aBk4IRVEoGXQwbiVCu0Tb9wPMJ2JBNcGp4Yvkge8neTCQ
         iVbQ==
X-Gm-Message-State: APjAAAWTszeUoWH+YG3PsjJmt3tb+rYWCv9LG0wiVvR3jFGDyf9Hiiyj
	dNbUzKzY7TRArsXuG6p+llTdpa+7xqPjDScxQ+NbUv+A2/fW8ewZ0F2kkeUX6yw39zrY46EyCAK
	qvG1IdGwmrJ/TJl641S68ezuSo6s2ot5Ardr5yNfE3a7Zdsk11VzeawfJWaEqAY7FWQ==
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr16950861pjz.117.1561268927570;
        Sat, 22 Jun 2019 22:48:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn32nZcEB7LvN4ab9Ud0nrcUO00tauphRGMPJRUouCb8OmWZVCC9sGFzGfXJdY1Y+LhehH
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr16950821pjz.117.1561268926885;
        Sat, 22 Jun 2019 22:48:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268926; cv=none;
        d=google.com; s=arc-20160816;
        b=hxuyzN8P5lbFweApAx5RQeYvDffOIrRHN5oE3d4U6MI8PRq1pES6fdgoFRpzgi+wiq
         EWlE7BY7poGd5tGTBMBipGRJ6JwrBiqKoVGokn/Ez8ajkt5BX5HXXrQQnMas5I7dcFWd
         uwWQPxNIWHwjpyZjaGiOdGsRNnGYFC3kocDqlTxznNcRXoZTXDTMer7FH7EjmNRj2eYQ
         jYRaMh1V9PrNzDEx/ghk4CBJ7w54Q7tDjCKJytqbEGP3Fn7IAT+qTMXTvh5gsCXamGxf
         KD/akt0FGuOwjCs0oTVyo9XGElT7hLHPH6h0+RIHGXih+Rc8I9DjPmDL/y0aFsuhb2+4
         hzgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
        b=YeDcWWDee4zi6WEfN7osEfeSLMvbvvR1BmvQnazv7r+VThzyX8pHJXaUywi7qdOU1x
         ckw59UPzPevhxWX27jsf9IibzAfElQpSfklAcALFxtNkm1SLdSpqv9X/u1xQHkK/fG/g
         MbX53xaCqK5e1cGjzWLiyzq0MK+Gp8WQMidIe8t0La0Z8PqkZFcnx5rFuJCQHbktO/fU
         SwH9u5+2TuWREkFjUEEWwRSIMbXP9KyT59kYNHQ3iNg/ykIlk6tqsArkHtMCTtg9GUr4
         55o5gqz8QwkOhmt91+UDNpoQFU0vVewJyf3g5C2DVQ+5DFxWLxKskFXCNR1YmGxYegOb
         ENuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ShkJ0gVd;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e21si6974817pgh.571.2019.06.22.22.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ShkJ0gVd;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5j2fI008151
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:46 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
 b=ShkJ0gVdzE4CAaYKqcPhWAwugyakkRFNJ5zY9jje2zQZ2BWgEtwAANNbymtMaifRBTV6
 LrLlUA+hWOc8UUIQ5a+T5WRnDRgNHuyLN5FuE2d5CsexniYeGzPNaQyNalYJbQ/Fcq20
 qMIWDslH9lg3i+DpmWYbnRpovxOiQjNNRl4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9fn2agbk-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:46 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:48:45 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id E4FD862E2CFB; Sat, 22 Jun 2019 22:48:44 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 1/6] mm: move memcmp_pages() and pages_identical()
Date: Sat, 22 Jun 2019 22:48:24 -0700
Message-ID: <20190623054829.4018117-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054829.4018117-1-songliubraving@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=948 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
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

