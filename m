Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 013E6C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A03C320821
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="L6sdhAib"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A03C320821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 512248E0003; Fri, 21 Jun 2019 20:01:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C3748E0001; Fri, 21 Jun 2019 20:01:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 363A28E0003; Fri, 21 Jun 2019 20:01:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2ECE8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:01:22 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s22so4481939plp.5
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
        b=ZF2iUOsSBpCocdF4ex+m/5Ueve+O5Y3bfgdMBrl0Ys230bxQgFuUT/cNpGt6P8XRGZ
         lSr+vESyBRWBMFKl9kqTWo+/naykY4AJFrOjhqPAgQNSUocVQlN+qdGGWSTiRedgR+oh
         9gmODP7WjyWBmI5xkwnWmE2Y3NLbi0kv02WLSzDO12/d4gK7HpPycvdvL4hTBJVOBTaC
         3tDvdrIfVkqsXfMVkhnUWcT3B8Ce8ka0ifA3qNBjEkWjdqRvBrQsYkpedJC4KoyZl1U2
         bK9UfOXlYjCQtHfUC8uG2aM60vv+EoeNm0xEXSMiiw6ok6eP+4awzUvSgL0sEEX19t+f
         y/yg==
X-Gm-Message-State: APjAAAUvMHb9Zon8BKm72F5LFL3iZlHFJ0ICiA14Eo9qVThqePOba6To
	iyGqH+GL39SHEXNWPhs3FqIxFj8hKm58+OpgRh9pnp7chDwJrWdPAhhoFOGOkZhDblqapqrAyW4
	djj18OvrLtRMSjcNAqRZV8NmLZ48kGtzhIWu/Ysp/fsuNmLT4tpYq8WskiEQKDySsmw==
X-Received: by 2002:a63:6c4a:: with SMTP id h71mr20731378pgc.331.1561161682544;
        Fri, 21 Jun 2019 17:01:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoSUGHq+xTN1eU+mPBIkOnPezNWkQ85HR2gyH9d0JdIyax08levNiLDngbNDBIvM8feuxL
X-Received: by 2002:a63:6c4a:: with SMTP id h71mr20731321pgc.331.1561161681836;
        Fri, 21 Jun 2019 17:01:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161681; cv=none;
        d=google.com; s=arc-20160816;
        b=CiZszBAkhVJOkWoMYMrAY1dZAKYyxMR1z2GfwXirf97JT/wqK0ZfhAw0vaDryQP+Sc
         H4zcpR5bmZj0l3gQ71EUJf6ELBj9hQ47ODkKX9yEHFynSFjoB6OznOoyfcayPQsfYGw2
         zWqLDGDpdV7e5bE7ns8fkFivFZCdIJwAwvV1KGbmgVS/2Bj3lb2uhiXX5WO1hKLp/wci
         8GzooJtd//s7pPmjGuWKV+H70ecZuxi7Nep7GUv+HRdjD5TATnCBVApQjLX9kCSY3oeU
         kpftLs2oBkYUz3C1sMco6OdZGEG0xX96nQ7VLMYCGuc+xDKIPr2kIspmhujZ8u+5yelF
         sl1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
        b=00YTvQxPwfgk+ikZgsX0NeAN166Sq9XkDh6Z4pVsAjh3SjiL7oK9M3er6qxhblAJKu
         qVH27BAYFGrUHI7hbj6iY2Y74PAjWR86WToWyIVtZZPAKxtMSwJBkg51Rr3ytn23dDDh
         Xd/nPtyD/pnxx//8cELcvRum7jBSHg6p8bD1NPh/Kw/jxWuqsNBtVs2Sveqz+iPy+Pim
         3usuD82AwEdOTN7hb3iuVTVub6go25YA7vOchxXiEldLpXtGqBH5/78+Td58JVghaHni
         4/pLw4X2TDnNvSgg5lIvV5ZSOqx6mbh7Wnw/R3rLhsRt8TkOY2Zb8DmWYaZ5HeNX56VB
         yftA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=L6sdhAib;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i4si3955746pfa.218.2019.06.21.17.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:01:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=L6sdhAib;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNt0FM005691
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:21 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
 b=L6sdhAibl2kDYaNERgXyACpf60GF1GnZcsIOni0a2TSENSqJxq8vjZD+EXtc/OZjVfNW
 kRzPQ4H7FywUWdxJDaSdsX5SkfuKWwOy8xWd3AvnW/0oAKi5ObXe4/unjMF1LHIqu1GD
 vuF5rZ4br5mqBhWvsyeuVWKrt5nKKagT5tk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t90mjj0ya-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:21 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 17:01:18 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 173AC62E2D56; Fri, 21 Jun 2019 17:01:18 -0700 (PDT)
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
Subject: [PATCH v5 1/5] mm: move memcmp_pages() and pages_identical()
Date: Fri, 21 Jun 2019 17:01:05 -0700
Message-ID: <20190622000109.914695-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190622000109.914695-1-songliubraving@fb.com>
References: <20190622000109.914695-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=948 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
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

