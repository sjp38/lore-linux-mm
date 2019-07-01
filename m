Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D6EBC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:40:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68C3A2146E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:40:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68C3A2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EB606B0003; Mon,  1 Jul 2019 09:40:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39CBF8E0003; Mon,  1 Jul 2019 09:40:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 263CE8E0002; Mon,  1 Jul 2019 09:40:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id E50BB6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 09:40:56 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id u10so7305401plq.21
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 06:40:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=HxUtE+xZhSuK8adkAHK7jewtaQf5I9Y0BwrNqTC2ay0=;
        b=A1U74nCweGtL0Sqjhx7GUQ0e2LdsmS9cHckYp+kUwsqhHeBqFBCgLOIYJWYAmIjyjy
         Vh74imnoPDcdYcYLYfv8L5Q3uey26Lz5x5RCBJr/kOzxDA3jvKT+7BXoCLD9SRHde+of
         glIK5amocr1DEu7BBU3RX8y4FnZuX05mtmKWa4U0T2vUF1+j94ixdxWFjAqMxHTqSfmz
         /lkSTTzoercQZJRimDIBwj32Ef/2dsmJu5u01xRffFfO5Yj1Je6dll7fYXbWdmLiGdLh
         JRWyqTnmpeTTIE9mgBEGRkNFDnB1aRfgjlpA8VaDt5Lboc5ZKUctWMN1GHY1EcRWcfe6
         UqFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVJxUTjSoeWpQW3Cd4hbE+BBKQMD1wAkXdvf6+ZWBKzB91wlot6
	WSsBGByQ7BvzcpOfWnZBRy3nD6LbQjKq0bnwULKh1+Kq8usIGJc7p/0VGbr+Q5eTnLzRmuGPRGC
	PpsUNCSL/AjnZrT+FJ3FIoqpUVecIqzryw8U/8PUJ9d2ZVESO1KFNOgvyZvv54B9dPg==
X-Received: by 2002:a17:902:7295:: with SMTP id d21mr27237972pll.299.1561988456629;
        Mon, 01 Jul 2019 06:40:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWAxbSQUptlso1TU80fC38Urqnda+va5lBoY0rY3jy2AdBq9gmAx5795/+WopXeCnQUROY
X-Received: by 2002:a17:902:7295:: with SMTP id d21mr27237901pll.299.1561988455610;
        Mon, 01 Jul 2019 06:40:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561988455; cv=none;
        d=google.com; s=arc-20160816;
        b=B2cncGzHBysxbfwZnW/ui4hcY6gY5DPUbRIUPED+skcTipytbWfT1XJL7hVq5kMePu
         F0OVh3rBulABSte2SVA0YeSt88q+bUZM+/N0RaCOYeNJRSb4+A+hP552I/eKpldWFw65
         L7Fo1fwRVLV3KnjSNFEG1/44noj7fIAA5YlrHh4ygyeDbJ98DayB9crnbMKtvM0mCPjC
         RJsnnWYsavQUS5Rzt3Uyh/VH8YQWcd3aWJ8/xnzJZdmX3XPyeALFQhJ5QlL5MU1XrJIg
         fzLdY0WDs7sCrxgDWl6YDjspFT34QJob0rpF4k6MLyuiERUTPZCKnkVPiH7Kp8mVnGD5
         orrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=HxUtE+xZhSuK8adkAHK7jewtaQf5I9Y0BwrNqTC2ay0=;
        b=lDrM/I4+uTuhyo/RfbOtB+2CItB7Jhgp64237qSagcl/zc7RnHwVC039bZtLiETOd7
         hjfvvM8e+9K1Qq9+YDRM1h5TUwjUwJAOQdMpF6rafKWegqRbxBRIPwpJmOevL3iRcd4S
         jT2XyqfQxkJYdNlip9/lrCqHRNsZRnZaO4Dr6JT5Voau8dwvBn9zHcWYdxib8AjyY1zZ
         RatABN3TtG78vDyZNPC3mV343v0L4lOCt3/Z1CLQzPgp5VmLBzTtErl/R36tTjfBvd3u
         P9YYC1LjCKZqhKjZmWzcQP4BGufKsY6dyk7vJ/XAY4T15MSNgGnfRqAv4UR1noZUFLX5
         CV9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 123si6885742pgb.374.2019.07.01.06.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 06:40:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x61Db5pr010781
	for <linux-mm@kvack.org>; Mon, 1 Jul 2019 09:40:55 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tfhsswsah-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 Jul 2019 09:40:54 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 1 Jul 2019 14:40:53 +0100
Received: from b01cxnp23034.gho.pok.ibm.com (9.57.198.29)
	by e13.ny.us.ibm.com (146.89.104.200) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 1 Jul 2019 14:40:49 +0100
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x61DemPZ30540184
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 1 Jul 2019 13:40:48 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D6EBCAC060;
	Mon,  1 Jul 2019 13:40:48 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 84695AC059;
	Mon,  1 Jul 2019 13:40:46 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.85.81.231])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon,  1 Jul 2019 13:40:46 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com, akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] mm/nvdimm: Add is_ioremap_addr and use that to check ioremap address
Date: Mon,  1 Jul 2019 19:10:38 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19070113-0064-0000-0000-000003F5BBF2
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011359; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01225913; UDB=6.00645348; IPR=6.01007125;
 MB=3.00027534; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-01 13:40:51
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070113-0065-0000-0000-00003E195962
Message-Id: <20190701134038.14165-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=929 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907010168
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Architectures like powerpc use different address range to map ioremap
and vmalloc range. The memunmap() check used by the nvdimm layer was
wrongly using is_vmalloc_addr() to check for ioremap range which fails for
ppc64. This result in ppc64 not freeing the ioremap mapping. The side effect
of this is an unbind failure during module unload with papr_scm nvdimm driver

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/asm/pgtable.h | 14 ++++++++++++++
 include/linux/mm.h                 |  5 +++++
 kernel/iomem.c                     |  2 +-
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 3f53be60fb01..64145751b2fd 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -140,6 +140,20 @@ static inline void pte_frag_set(mm_context_t *ctx, void *p)
 }
 #endif
 
+#ifdef CONFIG_PPC64
+#define is_ioremap_addr is_ioremap_addr
+static inline bool is_ioremap_addr(const void *x)
+{
+#ifdef CONFIG_MMU
+	unsigned long addr = (unsigned long)x;
+
+	return addr >= IOREMAP_BASE && addr < IOREMAP_END;
+#else
+	return false;
+#endif
+}
+#endif /* CONFIG_PPC64 */
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_POWERPC_PGTABLE_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 973ebf71f7b6..65b2eb6c9f0a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -633,6 +633,11 @@ static inline bool is_vmalloc_addr(const void *x)
 	return false;
 #endif
 }
+
+#ifndef is_ioremap_addr
+#define is_ioremap_addr(x) is_vmalloc_addr(x)
+#endif
+
 #ifdef CONFIG_MMU
 extern int is_vmalloc_or_module_addr(const void *x);
 #else
diff --git a/kernel/iomem.c b/kernel/iomem.c
index 93c264444510..62c92e43aa0d 100644
--- a/kernel/iomem.c
+++ b/kernel/iomem.c
@@ -121,7 +121,7 @@ EXPORT_SYMBOL(memremap);
 
 void memunmap(void *addr)
 {
-	if (is_vmalloc_addr(addr))
+	if (is_ioremap_addr(addr))
 		iounmap((void __iomem *) addr);
 }
 EXPORT_SYMBOL(memunmap);
-- 
2.21.0

