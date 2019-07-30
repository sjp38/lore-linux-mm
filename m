Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09DD3C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4009206B8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="FZ8sYBoX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4009206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A7718E0005; Tue, 30 Jul 2019 01:23:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 430658E0002; Tue, 30 Jul 2019 01:23:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233CF8E0005; Tue, 30 Jul 2019 01:23:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF9B78E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:23:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f2so34579044plr.0
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
        b=B9z+kUg4+Txs5I5DlfrAtwihiYdLhEDvxUAjY08DIcVpbmsUXlNOL+6N8soF55sLzy
         1Fg93GOH1L2UBt0VfwBbx1YijnaQndFmYABW+yUJZ4M8K4bC/z44cw2dkrABGZ/OdJwv
         quzmxvjOoEelSUMwz/QcsbjaZSbQ5RvQjk4zFbT8mdk84cOTafI2GJxKo527MX1dxq0h
         QzczI96T0RoqxQyTiarcnv5FmogpU9oGi1ZMmRlwxRN2xt7wiEKA5XdPt1NehOcWVsE3
         4AH+8/lLWyBLM+n9ZHVf1UUYId9bmV6EB9loR+vERAp/gS0TkbxZMDkwjWh3pwOxI0Ah
         K9mQ==
X-Gm-Message-State: APjAAAVY4aBj+uBoPde0HMf6vNBjF86aWHfyzX/CRKzxs/Cu3l9sU6eh
	14dEdR/oQ4BhXMH20uN0vPq4PX0kvDPqIzkUQlfFEcXLSj8OK4WhWQUPAvPaFOnsVRhGconVe2S
	qluR8W/YGpC+2Z9d8+7d2Fs8aDRj67NxlQcQoDf/9GkcSu9eIxaywRdaPSNVtQFjwMA==
X-Received: by 2002:a62:1ac9:: with SMTP id a192mr265765pfa.260.1564464197602;
        Mon, 29 Jul 2019 22:23:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyElYYtctg0cQda5kcYYfwWAVecDQKXVWhUGv5fblag15y10MHOAIBwicqkPnJ3DAapghln
X-Received: by 2002:a62:1ac9:: with SMTP id a192mr265738pfa.260.1564464196972;
        Mon, 29 Jul 2019 22:23:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564464196; cv=none;
        d=google.com; s=arc-20160816;
        b=TgDJxM1EGQN9UbyL66/5U0Xu053lV+0iFE+UTDfg0xukZe7txLyUoRuQKBG74EzhGW
         uM2aR9WySxZkcl1hAW6hrj+5aI0HkUrwPRoJUNgYgtME2kLRx+gqOb9uHLKHjbPjDzPu
         tzTkVevW9mJkGT9pIm0Sm3kyv3J8omXD6ZUPbDv3T4hdFQb56HEKA6Rzb5IWP+UKNlOU
         pwqUBJOMbZDgy39QxfMhhzi5KjAk5cX9RdS+qsP+qt+2QNVhNKn1OzIM7RchsBiQ1K6m
         ambN+pSQKLdzHfjrAp/GdDvYJkpZu5QNa03W0LaTOZz3ka3THMnYQym1gXFRUpnzOVmK
         Ovcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
        b=JKbBGQRuXWMS4l/6MjCNNUs09pRl0QivGIPJXdITpN8XQxRcX/svb4mjKay7Z59gTN
         V3dQrtLWD+WZgRAc2YqgCTIOqX5BXcREaGkUEIY49iLSiwafZhgRO8EU9n2uM8262AF4
         tB3QTfn60yKvo0SleVIEfsaeSMOioaztwjVvI2NcyTTNnLlvKDXxrt5RMhxLYmGwd0Mx
         yC+b6aVLwKvvj/7Bla1c5KgKPJI/4JUBcJXEYHIWb6DH/qVSGInDO4GkAAap66y7R47S
         ESvaYQV9ujpb4FnmP+7CmGIe9Tkup+9J3SmxFylNfO+xN1NGLlmXz2pX4JBFuXp+OCUg
         oZyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=FZ8sYBoX;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g5si25610195pjp.71.2019.07.29.22.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 22:23:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=FZ8sYBoX;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6U5NGvE007601
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
 b=FZ8sYBoX1zYxSfEM8Uw9qs+wcIdA9UYk6UGgoYdqGW7UnZoweZCeVEOTe7wbBCH1LzB8
 g4N5ojVnHFY8EpM4RdU7A5ZcxyLwwPhXr/fv7wd5MGvFW4+A3gnTzZyME4Jduw0djfPb
 RUF/kdizCk8DHkQX8nUILEhA4PXDAvUBEHc= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u2f53r2wf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:16 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 29 Jul 2019 22:23:15 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id BEC1E62E2FF0; Mon, 29 Jul 2019 22:23:14 -0700 (PDT)
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
Subject: [PATCH v10 1/4] mm: move memcmp_pages() and pages_identical()
Date: Mon, 29 Jul 2019 22:23:02 -0700
Message-ID: <20190730052305.3672336-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190730052305.3672336-1-songliubraving@fb.com>
References: <20190730052305.3672336-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=971 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300056
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

