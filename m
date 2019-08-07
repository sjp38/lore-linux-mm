Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C8B8C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB98B20880
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Gv5UZLvI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB98B20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70DD46B0003; Wed,  7 Aug 2019 19:37:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BE466B0006; Wed,  7 Aug 2019 19:37:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5ADF46B0007; Wed,  7 Aug 2019 19:37:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B10B6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 19:37:37 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id z7so14098914ybp.9
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
        b=ReKtS/hr1IVqDbEI01Oqwys2MmH3zUEm5pAp3pa1jyHiZCYFqq0Km0qYrXj265q2LD
         B6jWBo26WEqexWRN2evmpz9VwRHlNIsv00hfyXRYLIYNu36h9rRKX9PAsrB4yE8KqbB3
         9q1346gvCxPoSOaONPo1VcgneupoO831CZ3OQdnGjO0zf8CQr6vsJ5pYMpoW1NgnxgZd
         R0MUDS/JBtxC9hwkThmO72+O+VBgyIJ+XZqtCdeV14aLo969WxZQ6DeV3FZOR/qCFGWs
         j8sVjWNCFw9Kov6wAiSg6K468eYFUZLVGqtuTxHRvcSiBmSspQvfV5TPWxiM4CWC8Gf6
         tdnQ==
X-Gm-Message-State: APjAAAUHCEe2igusuTXwasJsXfHXKAn4n75fQPzO72E6GN6fzJqvz/73
	pODtFD7mHWe02+2UjHzJiuRKnsCA/3ASmt7pDjYShRwSC25y/SNzCnaUWdhsEzf7nNqQodc0cCD
	lz6ZpHpODnx8GQOV4aLEAmrU7PUkC681YEKSinApeS6ODpr7168q+0MIeOtMpLIjx8w==
X-Received: by 2002:a25:818d:: with SMTP id p13mr3686282ybk.322.1565221056975;
        Wed, 07 Aug 2019 16:37:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzO9NoEy5hi/xfSn3EET5jLIHHxnlKMBcYYXrfadI2mpq+MDMQ7kZCC8KKWH4LHxRRYgxi9
X-Received: by 2002:a25:818d:: with SMTP id p13mr3686269ybk.322.1565221056417;
        Wed, 07 Aug 2019 16:37:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565221056; cv=none;
        d=google.com; s=arc-20160816;
        b=gbjOPa/1Rk3zwE7o5cg6NiIDXnwL9Xg2CQN7EbwEaJ/AkwXJJGU3RfWUzW3BJ2deMG
         uOMKq/kyY72ewubzWmcfP3JWDlJMOI5h2o1Lsh+IuWaw9SqVBjzhQQR03ViAl1mjxMNz
         CT1IGdEfLbbNV7yfgBvaZgnOOGx7fJQZvmIMiGhwK9UrMA4+aFhjaooBkYvZmoKouqz2
         Q3hZbyWMOHkrqQDYf5/29tHLqfpbc+zR/TfZo0S+J0D0zecNPFw/Rnnh5xwcrAI4mO9e
         kx4bWyDUXPD7WQ3oDCP5ukTM2XWpSEYvzovWOKKcCyfkyaQ1MjfNh7CG5zKesQ+NqEtb
         SG6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
        b=NWxC4eM1MyDhSXbJ0Mlq0YxZzYs3NQie6BvI22SF6rj1/H7+C8Wj4FvkbxIpLK5vp+
         GKIbs0SwmGimQrYAGg2xEaE/IZWe35TZNqt1E5Ih+2F7Fqnpp0qfvBuN0kDsCK1YMFwI
         bN/CNRCZu+vd9E4gnU8rUVw82Qttgt23Matev06pTBb7WJ3Hrjt4Hyv3i7ZiWrrvBbs2
         wtYIFDtNcgkjN2UkgwOCwvkMdcbQVZAn5j7yztYKR/LRh+1mBherEhQANeYhXfiMF7s3
         J+JJjUjxxf8QC6gdxLENVB4kI0+F5GfQTlNxIz8psiC6b5hf7emf4jHPDxmr2qO+0SJ8
         OlPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Gv5UZLvI;
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y4si30415567ybp.210.2019.08.07.16.37.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 16:37:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Gv5UZLvI;
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x77NXfmb023061
	for <linux-mm@kvack.org>; Wed, 7 Aug 2019 16:37:36 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
 b=Gv5UZLvIQpk3H5o9jYYsuAFPeT+5OaaAH9R4uN6i5nQ3Gskfy9CClU5zuv5DP2v/byKQ
 4v5SRjemSgck2QGK6iKRQWBviTZExsycZqi7esWLI27m2y6lE2oCe7Sg9/t57O0TNa59
 0xG5IKVQ8t0sxSRPn9CNiAZeuedzqIT2L8w= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u87ue83xw-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:36 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 7 Aug 2019 16:37:35 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id F006D62E2D9E; Wed,  7 Aug 2019 16:37:34 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v12 1/6] mm: move memcmp_pages() and pages_identical()
Date: Wed, 7 Aug 2019 16:37:24 -0700
Message-ID: <20190807233729.3899352-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190807233729.3899352-1-songliubraving@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-07_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=973 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908070208
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch moves memcmp_pages() to mm/util.c and pages_identical() to
mm.h, so that we can use them in other files.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/mm.h |  7 +++++++
 mm/ksm.c           | 18 ------------------
 mm/util.c          | 13 +++++++++++++
 3 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..f189176dabed 100644
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
index 3dc4346411e4..dbee2eb4dd05 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1029,24 +1029,6 @@ static u32 calc_checksum(struct page *page)
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
index e6351a80f248..0d5e2f425612 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -783,3 +783,16 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
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

