Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31CD7C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFD6720883
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="g8AnEw7N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFD6720883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A7F36B0003; Tue, 25 Jun 2019 19:53:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17E6C8E0005; Tue, 25 Jun 2019 19:53:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA0EE6B0007; Tue, 25 Jun 2019 19:53:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7BA26B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:53:35 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id j124so1066361ywf.11
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=WYZxiREwAeaU2t88V8DNSwbVqkRoedXJSQJxp8fHgHM=;
        b=ozM0IbJcJp5hebPt832o23w+JdUGcKHSfnBuCJDzUNYNM+hkeWSaKYOjj8q4tkNAcv
         tplLX5saaWXJSLY+y+4BwsaWOI8h+ycI5pTfOHa96UID+rIcZJqqdNbjQMwiREWKd+qZ
         YrKL319YmoT9f7rojg1jrkSfqy0YX7ks6uHgTrNekHP04YjBmIpKIL4lChcuLtjA1Kdb
         rWhDGCmIVNBqD3IxIyRfTBoCkOm5ZWYu3PkU+9gK96qRP1eVY1RJruylr/OygaW/qjSG
         11NwHMDjk8wVFpKBurjQOqDehFKXqderbN5RkWYVENtcYeRXpwYDPbjFfgXi8aNaVxEo
         M0BQ==
X-Gm-Message-State: APjAAAXPi/MVcomjriAv3vRTvq6JC/NX3boxvEsZw8Oud4+3NTOMWmn9
	FmqWN1CHZ5JGbF6vvE7NNSPzTF4gggUUfb+ph5uYtp1JZtTb8+OJNS+KcgGDt+pATB+AP/rP4H6
	WwgNYcdQDqWzWTFzrSrEoWXhwamfePgxnfBGJfGkGEwYXdun7BJOkOtUfGAmXtlrbZg==
X-Received: by 2002:a25:d856:: with SMTP id p83mr759736ybg.434.1561506815514;
        Tue, 25 Jun 2019 16:53:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHOGyj8dot8ErJOzbp6nWzMxQMHPurSD26yWyU5yp1ur55qHQuMqcpcvRf5jU5tXOuPRyS
X-Received: by 2002:a25:d856:: with SMTP id p83mr759716ybg.434.1561506814914;
        Tue, 25 Jun 2019 16:53:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561506814; cv=none;
        d=google.com; s=arc-20160816;
        b=I1Ouh/w2WAscbvlxQ0POms587VOVMherVm09co5DmI/waiSAqaNUU7Y9jgh1sTx44u
         DQXQ9h7PLnkSpzZ6mFxjnPuMvAiLxjSfk5FawHoKFqDE1/Yab+2LAxAWe3jxgjJGENcz
         Vvyp595QijgF34/WDBrDh8U76xpviLOB6bZd6ViTj25W5AdVNfvL7R1IAHCPsgQyAFUz
         fe5W0P7iICd5shOgMBiWy++t912JvFAICY6zl77lNWr5P7XIF0QQGcBVgCVkhqC+4vs1
         raGX/BrcbBfleHLIJ1TtIyTjUf15HMjGCr12hptg+EO8PlMdf5Tv3sbWKZqtBIwY9aWR
         xMdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=WYZxiREwAeaU2t88V8DNSwbVqkRoedXJSQJxp8fHgHM=;
        b=N5lZ7NuOmP8ymZj41Q7r8io3pvg5rV7KMLjqGaBXSlTJMMEggJzxjkzyGCNyGTlH5M
         0QuikVy/friFJ88y0OIq2vpG/h2HHSKvdNgWcjF5th9Ph8PNgIDBEYjpTVTkf+SfZg1Y
         95ot66Mj+8OxRTpFbE89fP5hMT0AcjL/fGroLNZq4KoiA1u7NLADNYpgWMJrSnBVs7vO
         j0ZqH+ALVVW6zOQ5KKrFNz61iBNUjyUO5g32AlrJrXcM100UbncXo+b7ZKiwFPS5L2tQ
         8Y0h4KPXBFLw/BKmVVgpQh8rRVAzSXGyBs9+QnHEPlFftfpawQuyV2H0Qrfwfho06LnX
         gZsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=g8AnEw7N;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 138si5787806ywq.162.2019.06.25.16.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 16:53:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=g8AnEw7N;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5PNqZpk032119
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:34 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=WYZxiREwAeaU2t88V8DNSwbVqkRoedXJSQJxp8fHgHM=;
 b=g8AnEw7Nee6zUOfEHaIFdF2U2Apd6FhKQ98r8Kaqs7LYcIqS0iTu7YVgVMd95RvucnAy
 gi6OLa9EEizO+f1oGGM3yP8Yp7HysNFeaR5vJy9l3GLH44rrTqS48GhA/pu/DL85W6Uv
 XSxmFIwEQevIYRJmNQ2BsTBt9fUDhLOk85M= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2tbpv81mvh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:34 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 25 Jun 2019 16:53:33 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4223262E1F8B; Tue, 25 Jun 2019 16:53:33 -0700 (PDT)
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
Subject: [PATCH v7 1/4] mm: move memcmp_pages() and pages_identical()
Date: Tue, 25 Jun 2019 16:53:22 -0700
Message-ID: <20190625235325.2096441-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190625235325.2096441-1-songliubraving@fb.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-25_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=986 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250196
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

