Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9985BC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:52:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D914B21743
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:52:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="LJFRc4/W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D914B21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62C416B0003; Fri, 26 Jul 2019 01:52:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DEC26B0005; Fri, 26 Jul 2019 01:52:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CDA98E0002; Fri, 26 Jul 2019 01:52:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5136B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:52:57 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id h203so38620052ywb.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:52:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
        b=YXRNkm/eKsC8HEP2SFMgAdMQW2eglDg/geaM19ZCifg/HE0YgMw2GYxgSa0svZrVw6
         ZaGxpT6MXsLWl1hBSaN8ZskJIn8lc0nqyp8KXfK60xWonRAZlf2tGuZavdIjQ4Dps6oc
         QpludcBJE7pa7QtPv5LogKOpsE91XmASwsiMPX+HqeJ6SPTTJ41XqNrg3okn5BwA2pz6
         EKL7EUEu1E/LgsPMFhwLi116bW0K2t+FxFqDsB6H3+QEhqfqpUkZOCfZWD8sv4FysKGH
         Kj6j1+vlDQF1lhUy7RnObjGCuhFtsuQ3cPBHfTVrIeoDBrqq0vGvloBxnCBgVnl9VkzK
         ywnQ==
X-Gm-Message-State: APjAAAVUbVFU2jhGww9m439Fz0EiVLUITXFUnIw2T5fcmcBnDWhQRh1d
	bTOy3gjmJumu/yRL8bVUPY3HMq8+BDuzcPZSXG5i7yTEwOwmv0gStknlv1QSrieHd9bx70FFU8w
	MRVMJqsiAFrTqN3gW/nx380++6B3xB6SZaELf9uu4kE5OSssrWaIMVv1vkE7Pgd1L2Q==
X-Received: by 2002:a81:1f87:: with SMTP id f129mr54869392ywf.135.1564120376947;
        Thu, 25 Jul 2019 22:52:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvJNa8UA+MOtdg8TVnAwWfLNDY+I+pkXwkSjrxvJi/x4/EkVBKP1y0zZ0DY+dahe2YVarY
X-Received: by 2002:a81:1f87:: with SMTP id f129mr54869376ywf.135.1564120376420;
        Thu, 25 Jul 2019 22:52:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564120376; cv=none;
        d=google.com; s=arc-20160816;
        b=Pn9/Tk72wUT6e2/WX+u3Il4SB+6Vr6hSAb6KySNsQ2/9HX+izWHsjAPlCwtxN323Vr
         pN9g+GI9gpS5Cx/ZVsjwqnBeOzhXQxEExFnoMbQiQE6d6/En8gsuI4VaeXLzxmAEeZBG
         x/9mOUQ+R3+8xeHYUzK0XFzVJ8tnzybP++1pVrUCh3hO7HBJNmxjZFo0SK3v1BNCYmFE
         rvHGGMldvfFwt1knLPTGmdjUPhsnPyfUGjOjs0Q0u0Oj+2ZTaG1XU3zypIFnTzYDfhE8
         bF8hR2lSxkYSecScdumUWuojaupA62OVGp4LenVOaVkW5sVOJJf1NBKQwtQOr5+N0M5a
         BO4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
        b=SjqXWdSJ7ffcQtUGtNbP0doangLMZd1q5t7TSvXMIJ9RC+DB7BqHOhyUrAR68b8weG
         kFOgwV8GzJyyX8nVtqzeoP22WhOD8Imx7zI4Qlyqi83FvzDNj/mzVD6QIn9R9zxMZ1jZ
         2xjv1/fQT3MOirJ1B2PjMZ1J/17R3j6ir+xS3ufQFApg9zeYbQ0tY5nG9+b0hbWUCz2d
         iVS5v5tZwOTuKMmQl+UJR+z9z6KP+ypfE6CwUWl9vqMzGoI4ejWFfQw5zetu6ucQJOEG
         kyfqSzJMi+i+fCnYQiLyTssUq2D8NzWAA6mngi3kFcku3qPd7staBZ1zlURLWPB7HvWG
         N0bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="LJFRc4/W";
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d130si938205ywe.141.2019.07.25.22.52.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 22:52:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="LJFRc4/W";
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6Q5nq2C007695
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:52:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
 b=LJFRc4/WlENKQaGEyhQOZPKAyhrCrHBmedVrQQOTZOteWyT7+449EpX7k3soqLKZ87sw
 V5tQTSb8+Fl2Cd81F2dtgJUZSQwkCEzYdGvBusb9d6s+bKhf2lzUgJtE4jyuNu5n6H1+
 DFp2XW/xLLMibF6BDcB0grMYeAZMHFauzO4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tyh40t29k-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:52:55 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 25 Jul 2019 22:52:54 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id CE79662E2FC5; Thu, 25 Jul 2019 22:47:09 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <srikar@linux.vnet.ibm.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v9 1/4] mm: move memcmp_pages() and pages_identical()
Date: Thu, 25 Jul 2019 22:46:51 -0700
Message-ID: <20190726054654.1623433-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190726054654.1623433-1-songliubraving@fb.com>
References: <20190726054654.1623433-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-26_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=974 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907260078
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

