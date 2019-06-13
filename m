Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B1C1C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26E43208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ag/wAUTh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26E43208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A230B8E0005; Thu, 13 Jun 2019 13:58:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3748E0004; Thu, 13 Jun 2019 13:58:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8763A8E0005; Thu, 13 Jun 2019 13:58:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4746A8E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:58:02 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a125so14984846pfa.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
        b=biS5ln6UsTWYjUH9a0CFRxUsco8IlGSSXr/xI1FxGqoJRkyX0LnEt+mIqgabYJO7Jb
         GhnuVXW2s6xAyDwhyI6Dh6LdRWbekctkqxBPHRQbEYKIYnMwyn1Nr+kY9h8O1P0AxGos
         pSoG6HLN4z2KzRnf+p8EUhI55kRFKiSFusjAtm+So4VQJiHyCw0uj/R4zEh9dr/iiPb/
         HzX6jc6Z/JC0fLDYMXYVa2CyQOZqYuv9Kf4khDxOELeZMLSu+wkV/hNjTdFrKCEnrkzF
         nHJn8kGVIgyQLjI5dU7roOzJ6w3O+QRNz0PNGElSrcaZXQ4wu5UUXBI76CM5dddPPhQ2
         HzIg==
X-Gm-Message-State: APjAAAWqSoyWBU6wSTbeKwP+goP73T8SWhfsWs+UtOOxvXJPwQIn0nao
	gabSANez7yRJmIVA+lRFSWYWr7g3Eam3stXXnaXwvpIFevp6PinN6qNf+a6Xh5Nle9fCUvhNaWu
	mYgU2C6TYNkeTPxty39m+4so5RjnvH34jlACTBzM0bBdeidz0/GZzURKXCB5SdT7NvQ==
X-Received: by 2002:a17:90a:2706:: with SMTP id o6mr6985191pje.62.1560448681952;
        Thu, 13 Jun 2019 10:58:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxADinQx+crDzPW+u5Su15Uh0vlrTupeTMgDpUKNSGqG+qlY/jWoDubuJckvdHyprpyIoZb
X-Received: by 2002:a17:90a:2706:: with SMTP id o6mr6985140pje.62.1560448681271;
        Thu, 13 Jun 2019 10:58:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560448681; cv=none;
        d=google.com; s=arc-20160816;
        b=hu3XpJUSCnKd1iCGNDrpYKyuRhJ3pzNMaX2QUyyXriCBOqLUnZI0tVdrxA2fD80ANE
         Ts4dDdKujhzPi5Po4HZ0/cL/KQRMSM3B4FKPHtWzqWq+XK+dH/WrkigBtRi33FGtJ9C/
         zHCC7omwKLzw8/RUx4+b7cayjYVNKlogQLtVsWQj4AsJWOjafjOnYgCzpKSwrXkdfZkI
         JFr5vSfF+J0mCDoBvpmioMgGrfwiIIB/oI8DXY+M/r3Y8RfZnk3luuWv1i7McpvzmLKg
         vio2jxeM4fm+FdE5B2TA8ce9B0vAv/aIyn/w0DXW29Gfpxi0beQYnQDwH9oDC0BxQCeE
         rp3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
        b=PH7QLzJ2a/vpix/PJcm3Fv+963T49ERe0ukUhBr9jWlPWBY5aQh+InLV6a3wUq7yHS
         S8A6TuHsYbA1pjGE/sTX974wgDbpug2/gorHuzpLBEb28/sn8oFCa2Gz9KhOWWiCjXhi
         hrFgaNPNO6AIiEDhVGnObEplHdwLfRPT1HNpSLlzs5yRfC3NMDbgIX+5YA24sr1UqSRq
         jAVO9XyDY6y1HgTxZAterYeBVurtWycyHIwocy1CVQeVq/SXnnF8C+UKKxS26DevBD4w
         FY/u+NocdywjsH+owUrZ3pigBpBWVBKqrhF7Q9wUrAjdnalkHqNileUyA4V0St+0ULHN
         MK0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="ag/wAUTh";
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q28si323832pgb.375.2019.06.13.10.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:58:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="ag/wAUTh";
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5DHpv8g018958
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=pQnGGve/Vnh2HyxOCOdI1CzGbYYB1SvJlXif4X9k+UU=;
 b=ag/wAUThFEH/A8UzXs1W+1ceFNTM0hmanYYh0NhLUM+E/J5iTbmPpOW00HmObI+fabof
 ajBQe3ilhE4r5z+0H0m27BKxF4eZNyYl7Ao4bUm7HG+iOs+dPduYAwItUPsFs25atQ0h
 tJg6ASlqckIDTAAQ+j+smnTl4HR3IAR7oXw= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3ru7gn0a-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:00 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 13 Jun 2019 10:57:58 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 0DC4A62E1C18; Thu, 13 Jun 2019 10:57:57 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <oleg@redhat.com>, <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 1/5] mm: move memcmp_pages() and pages_identical()
Date: Thu, 13 Jun 2019 10:57:43 -0700
Message-ID: <20190613175747.1964753-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190613175747.1964753-1-songliubraving@fb.com>
References: <20190613175747.1964753-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=940 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130131
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

