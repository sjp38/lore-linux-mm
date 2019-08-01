Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D121AC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:48:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86E7720838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:48:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="KEn2iKzr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86E7720838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C6266B0269; Thu,  1 Aug 2019 14:48:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 375BC6B026A; Thu,  1 Aug 2019 14:48:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F1976B026B; Thu,  1 Aug 2019 14:48:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id F38936B0269
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:48:38 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id x20so53633420ywg.23
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:48:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=+37X0RibitZUAeswArEIGq+Z3GPvqESwv4PubAKnT74=;
        b=RIMVW4gzcYrccUFPdOWbb+F4W1nmi9BJ16nPrU3WFgp+xeMYntwZrN+XfPHGcwutqA
         SHOSNkakt2hc+5E8QtV3enqadiFhxIJ8PfmaCNW5aX8sz6+9s/ppy7qR5h1CQaKth2gv
         lVwnpsXx8nM+qs9XgmsS/uGroull9a1V8fg+yIN8NJk3HxubcgYUFa/b0Z9fDHeRGZ2r
         LVmOEs4gSACWPYzdFfNzDU0tzQ8z4cyoOWnLJ/cgydfUIkliwF1M0ho5RMBBKQp9Frvk
         B7CiCfb9lZ51xeI9aOjQwzUpDFBVyKjzxuU8h9DiJmEo1jOFXcMZ61vx2SAYfcXJ8AEL
         b9WQ==
X-Gm-Message-State: APjAAAW3KrBv31M01z6RgwGRf85WUR0m0Gc1lRtZHilbj9FTo2CnM9Cn
	mQBKRe/kBY/t2v2RVYFqPlP3zOyMal4670fELlaEyiMe3jTLEql74FiWGvqMlYb1j6gHrV/mszG
	2pGwwqYYdKt95uzIzlCcqw3VVRx5zavIWUAx1d0oqI5a0cRh57WAZwMIXyi8lOQF+Wg==
X-Received: by 2002:a0d:ce84:: with SMTP id q126mr74158329ywd.88.1564685318788;
        Thu, 01 Aug 2019 11:48:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyw0gwSd6ahMTnrz3Rx91sgCy2YV5uK91XWXmcmn1SI9uiGDbMkclKmuZfdl6SeNDsENsSR
X-Received: by 2002:a0d:ce84:: with SMTP id q126mr74158302ywd.88.1564685318284;
        Thu, 01 Aug 2019 11:48:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564685318; cv=none;
        d=google.com; s=arc-20160816;
        b=GHfQNJXewrNTgotNHIEnq/PisaVfUGnW+rvAn/B83hLT+C2GlbaSSY2js3aPI3IfUD
         XF3jM+KRtOqh7PFMxjiX/JDHmCbAuOjRnoxhJJI7t47tivTJHNR1hWSUvBjEv0RAYhhW
         mMncxuaYwFLjej+TzbSq0f6u/bkNKU9aUW4udfA0d6GWapgPTkbM/i4RZ+2WzC7fZ8x9
         ve9m3oAvhNzCrILeWAbkz5RYyahY5r8y88d7HHV6+Iedts/2dOYMd14diAwcJ3sFLlag
         cQWey8s5Dp4cJdY+lbVsDqTRT8Aq5YwL6ZZLNRB6N1TbZp1GfVKPzlf0Vhm2P1EVYtQp
         sPDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=+37X0RibitZUAeswArEIGq+Z3GPvqESwv4PubAKnT74=;
        b=AfEUih3k5Qp0ypEkcC63lIG7NMLUmRejNfe5EGDo2VCKihLKiZz44D4Ir8sLgtI7Rc
         HjA3f1xY+NSFIj7E/1d3247fC6Rgv2OYFfKyOV4+DQhuLqOSn7OhbTw7vJefOjpm/TVA
         e0LznD3EXNVag4JqeCTPK/vtQb5mfw552Ju7afdYNSf3pvWBi4HoxWZmjktYO0p0v10C
         BlZzJbhB/swHFil6Q8i51Zplo1zp6sIi3aztKJ3krcRRo51v2Y7fOjZdxlauA4bQLyh8
         +dSd/xvc2EK3XjmzT9Z8UuQOTpxpYrSDPySNPeBOhe/E28F08rVCfjW8ItKFsdAzC9Tt
         aAtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=KEn2iKzr;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 83si26674698ybn.303.2019.08.01.11.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:48:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=KEn2iKzr;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x71Il0cO024401
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:48:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=+37X0RibitZUAeswArEIGq+Z3GPvqESwv4PubAKnT74=;
 b=KEn2iKzrLT9jsBa3cwHz7s7TBpUPl4WhFgn+zaCYhgv2ie8mtyo9foOx6DRTRiWqU6m9
 5kmkWuj7Wqsyb4MHclgETGbNNY6XNKiN5ZdWE7I0luaJ47JndtuLFokJNA2JUOIVKJoq
 uHqxr4odrTOjIpZk9vsSDZXOkazTDljzMAg= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2u449ggbq8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:48:38 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 1 Aug 2019 11:48:37 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id E577962E1FCA; Thu,  1 Aug 2019 11:48:36 -0700 (PDT)
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
Subject: [PATCH v3 2/2] uprobe: collapse THP pmd after removing all uprobes
Date: Thu, 1 Aug 2019 11:48:23 -0700
Message-ID: <20190801184823.3184410-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190801184823.3184410-1-songliubraving@fb.com>
References: <20190801184823.3184410-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=452 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010195
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After all uprobes are removed from the huge page (with PTE pgtable), it
is possible to collapse the pmd and benefit from THP again. This patch
does the collapse by calling collapse_pte_mapped_thp().

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 27b596f14463..e5c30941ea04 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -26,6 +26,7 @@
 #include <linux/percpu-rwsem.h>
 #include <linux/task_work.h>
 #include <linux/shmem_fs.h>
+#include <linux/khugepaged.h>
 
 #include <linux/uprobes.h>
 
@@ -472,6 +473,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	struct page *old_page, *new_page;
 	struct vm_area_struct *vma;
 	int ret, is_register, ref_ctr_updated = 0;
+	bool orig_page_huge = false;
 
 	is_register = is_swbp_insn(&opcode);
 	uprobe = container_of(auprobe, struct uprobe, arch);
@@ -529,6 +531,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 				/* let go new_page */
 				put_page(new_page);
 				new_page = NULL;
+
+				if (PageCompound(orig_page))
+					orig_page_huge = true;
 			}
 			put_page(orig_page);
 		}
@@ -547,6 +552,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	if (ret && is_register && ref_ctr_updated)
 		update_ref_ctr(uprobe, mm, -1);
 
+	/* try collapse pmd for compound page */
+	if (!ret && orig_page_huge)
+		collapse_pte_mapped_thp(mm, vaddr & HPAGE_PMD_MASK);
+
 	return ret;
 }
 
-- 
2.17.1

