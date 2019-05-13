Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4B04C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 685B52084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bc0UAXJu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 685B52084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA2E06B026F; Mon, 13 May 2019 10:39:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2CE06B0270; Mon, 13 May 2019 10:39:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B805C6B0271; Mon, 13 May 2019 10:39:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 919576B026F
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:34 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s16so4234526ioe.22
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=5Qtz3s/XQzDItLwgII6a7yqyolD8+y7jKItUNNZ5jHw=;
        b=aBB/HOTqohJeyniyrqo5cwGyxpRUgXgXhN400akjn6xsXH27xumJ35SsARxt3tjsP+
         2a4vFpnv2vpzCamv28k+gpCkvwzBRHRJ0bzEZGmStMB4FFLdRAOpHUl2J7Hvid0gRqye
         8eryjp/rguI9+ZWuqr9fO36EudTagk5H+SInqGSz8z0QplqAyJGjCwbjS4d3QCI5laJF
         CmMND1VvYUz2SQ35FsG0mpECopNoAXDF2VAKiX6q++MeQaqEEs+tO5sDFKc4ynf8LtDU
         3qxp906pqweMOL+KPvdANqO/vPo+jZn5SqVpzvF04EFVw84SO6EVQ8bbf6otsvCiyIU/
         5qEw==
X-Gm-Message-State: APjAAAVmYo2QsieFKxkbtHNwqwQsKtCGZ4fGD8+6voiDBWhTYCnXYtaN
	6iVaIZPASuMVBj7BmIT5Zm6Nk5cdgw5h4w7E78yNXlWk4ss2athsOPc3IXCsoHUObJ3gfzGJYMs
	WGrXdnxH6t1bUlsMOXEz+KyJ7kExvfwj7Ri3ZBpmyyns1r6FWNdGdH+JowWD95MeVUQ==
X-Received: by 2002:a6b:b485:: with SMTP id d127mr15669209iof.273.1557758374327;
        Mon, 13 May 2019 07:39:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvDU3Nwf8mFFBikeEMO8251HzfLWluPQgB5K1DuBv6JyaWP/FInrEOS7bTZ+Wf5b8/jj8v
X-Received: by 2002:a6b:b485:: with SMTP id d127mr15669150iof.273.1557758373499;
        Mon, 13 May 2019 07:39:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758373; cv=none;
        d=google.com; s=arc-20160816;
        b=XyJpFLr7AzBQxSCT2TyqOplsySinFTHlAwQqPpVb+bZ/m5cx48wpEENWVoGCAiTads
         z9pUoHG7LQOYDSSgpE9WU991A51PUFJ8eiuM53pIynp3hYK/kSheycOnr92GBgRCmb3+
         uaudqaS9bPL4i4oFON5yRJRyd07VGdlhA1zWArT57KHcItL72x6TgfszvTy1Tf/ggDFj
         9SsVXxglvLcImzWTaQ+rfjeZvp0F4y+hV3kPqI6TIkKPtv7KiKFBGWuV1pKEVpKOaPDc
         D2ULNEADTQRLERmzYr1vwiclQqh5SGHHXc+LVTmtM10sia3t1Oacx9oVNPzeofHQqrXI
         8d1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=5Qtz3s/XQzDItLwgII6a7yqyolD8+y7jKItUNNZ5jHw=;
        b=FPhPMztzTTWJtnEqNp+ZYdfynEeDY81Pzd7F5624tGG18AH2FceR27gT/80Hmat3Of
         P4Z/1TNiSQUsDNDD3Dhh8Bsbw7A+aDhlbLUes37Nv5649G6x9J5m+RdXJOlgDGkAA1KQ
         S63jaoZh5myPO/WvLn5wyuCLdbZgFDqd4r5l2haD8yOIFN6/sDIgTUEhnzObFnhmFHt9
         LLwuWN6pEubaDzc2JUELXjiiPaUkcvkk2m98sUPEkOOPhLiEAAfnmrlz1FXMcR0X2OJv
         5Rs+1tuoITMB74rpiVwNmnZlf7+fWdqiclzwo9gHx15cuhr2fxJM9dNNbYBD0YpJcvt7
         QhKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bc0UAXJu;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id b13si8210483itb.143.2019.05.13.07.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bc0UAXJu;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd3jQ193102;
	Mon, 13 May 2019 14:39:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=5Qtz3s/XQzDItLwgII6a7yqyolD8+y7jKItUNNZ5jHw=;
 b=bc0UAXJuEUDdxvyu9LwCdXHqD4qh6pNojWMqcM9jSLBAxGM6igASeeKPL3IWePb5ch0s
 fbCFf/kSYwqFzCOuWD0pbNuB78gAyLFK5Ed4veTVvUvCkVI2DR43VeRRk0g9ufQAr0sw
 e6QhuGNeEnywPiXsoWdU2luDBNsmNNUqdcfqgUJyVy51fsmTOMsXHwAuC4cslhey/L9A
 UYFWoKFzlhctdRm9y9d9iC7Djqvsf9+FCNhU/NbXFxMpjmDvfMOaaoR1Y5lpKRNKz4fW
 VMMMFGBaxysR4n+y/P893dNcj5PpeJwOEyHs1Tnsryx4DvPOgcmS7i7F6ug4vAd8pZZL 3A== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfkxg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:24 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQG022780;
	Mon, 13 May 2019 14:39:16 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 13/27] kvm/isolation: add KVM page table entry set functions
Date: Mon, 13 May 2019 16:38:21 +0200
Message-Id: <1557758315-12667-14-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add wrappers around the page table entry (pgd/p4d/pud/pmd) set function
to check that an existing entry is not being overwritten.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |  107 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 107 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 6ec86df..b681e4f 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -342,6 +342,113 @@ static inline void kvm_p4d_free(struct mm_struct *mm, p4d_t *p4d)
 	return p4d;
 }
 
+/*
+ * kvm_set_pXX() functions are equivalent to kernel set_pXX() functions
+ * but, in addition, they ensure that they are not overwriting an already
+ * existing reference in the page table. Otherwise an error is returned.
+ *
+ * Note that this is not used for PTE because a PTE entry points to page
+ * frames containing the actual user data, and not to another entry in the
+ * page table. However this is used for PGD.
+ */
+
+static int kvm_set_pmd(pmd_t *pmd, pmd_t pmd_value)
+{
+#ifdef DEBUG
+	/*
+	 * The pmd pointer should come from kvm_pmd_alloc() or kvm_pmd_offset()
+	 * both of which check if the pointer is in the KVM page table. So this
+	 * is a paranoid check to ensure the pointer is really in the KVM page
+	 * table.
+	 */
+	if (!kvm_valid_pgt_entry(pmd)) {
+		pr_err("PMD %px is not in KVM page table\n", pmd);
+		return -EINVAL;
+	}
+#endif
+	if (pmd_val(*pmd) == pmd_val(pmd_value))
+		return 0;
+
+	if (!pmd_none(*pmd)) {
+		pr_err("PMD %px: overwriting %lx with %lx\n",
+		    pmd, pmd_val(*pmd), pmd_val(pmd_value));
+		return -EBUSY;
+	}
+
+	set_pmd(pmd, pmd_value);
+
+	return 0;
+}
+
+static int kvm_set_pud(pud_t *pud, pud_t pud_value)
+{
+#ifdef DEBUG
+	/*
+	 * The pud pointer should come from kvm_pud_alloc() or kvm_pud_offset()
+	 * both of which check if the pointer is in the KVM page table. So this
+	 * is a paranoid check to ensure the pointer is really in the KVM page
+	 * table.
+	 */
+	if (!kvm_valid_pgt_entry(pud)) {
+		pr_err("PUD %px is not in KVM page table\n", pud);
+		return -EINVAL;
+	}
+#endif
+	if (pud_val(*pud) == pud_val(pud_value))
+		return 0;
+
+	if (!pud_none(*pud)) {
+		pr_err("PUD %px: overwriting %lx\n", pud, pud_val(*pud));
+		return -EBUSY;
+	}
+
+	set_pud(pud, pud_value);
+
+	return 0;
+}
+
+static int kvm_set_p4d(p4d_t *p4d, p4d_t p4d_value)
+{
+#ifdef DEBUG
+	/*
+	 * The p4d pointer should come from kvm_p4d_alloc() or kvm_p4d_offset()
+	 * both of which check if the pointer is in the KVM page table. So this
+	 * is a paranoid check to ensure the pointer is really in the KVM page
+	 * table.
+	 */
+	if (!kvm_valid_pgt_entry(p4d)) {
+		pr_err("P4D %px is not in KVM page table\n", p4d);
+		return -EINVAL;
+	}
+#endif
+	if (p4d_val(*p4d) == p4d_val(p4d_value))
+		return 0;
+
+	if (!p4d_none(*p4d)) {
+		pr_err("P4D %px: overwriting %lx\n", p4d, p4d_val(*p4d));
+		return -EBUSY;
+	}
+
+	set_p4d(p4d, p4d_value);
+
+	return 0;
+}
+
+static int kvm_set_pgd(pgd_t *pgd, pgd_t pgd_value)
+{
+	if (pgd_val(*pgd) == pgd_val(pgd_value))
+		return 0;
+
+	if (!pgd_none(*pgd)) {
+		pr_err("PGD %px: overwriting %lx\n", pgd, pgd_val(*pgd));
+		return -EBUSY;
+	}
+
+	set_pgd(pgd, pgd_value);
+
+	return 0;
+}
+
 
 static int kvm_isolation_init_mm(void)
 {
-- 
1.7.1

