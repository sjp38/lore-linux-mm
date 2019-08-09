Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41EB5C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11C642171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11C642171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CB056B026E; Fri,  9 Aug 2019 04:41:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 954056B026F; Fri,  9 Aug 2019 04:41:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CDDE6B0270; Fri,  9 Aug 2019 04:41:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42F166B026E
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:41:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q1so3698649pgt.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:41:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=5LuG0HaO2bEKT13rvG09jejP+YLFYU9mB9zquGtlRoc=;
        b=LaHTHtw6Yh1cmQwDk/OQJZFqVWtmNExNplxsFq//2aIex496/P2kkmy664SD7ePw6z
         KHIXysumMImUW7XAIOGImEcUkCM8bWYVzANM1B5mGZ9mYTjQXy6ih8SNQUyiKVakcZaL
         xKJHtfyehBm7eEGFYxfjdSME8HXQfO4xOzslKFYOrKadUUopKe0qG1WPb1HVizU0s2Qj
         D4XAAfq3asgCqVCswLfag98/+tyAu9Oq1wEAGUFL4MPpDxE2SXSJ4kGWEJ8QHcydC96d
         bgKPRLDI2EjbTsrqQlNbKljRHlrMcazAdwRIYoVbqwomea0U5pWNodM5Ivaena3Lk+zE
         W35A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWLr2nlr2UXzzgPQiCZdie4U4vQMKF0D9h1SD3EARNniHjhDkN8
	3PYVGiPA6a25Ko8g7J7JIcnrN5c8PE0J63fmy2QkRw02pwRq3jrg7cM5B+FU7mcmAeCnYpkxojn
	jnU4LzEkIG8wAa9HZpwtxMkrg+oPTeVxGaHZJ90E9eYh1FAfKeTJAanRUc9CnYIPQlw==
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr8283739pjn.119.1565340112939;
        Fri, 09 Aug 2019 01:41:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiakDODebaHo4gRljLTeTWiSkH8FxPnNd1B8aiPk1a1wt+Y3jgqC47YpWTKFEpoQ7tcdlV
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr8283676pjn.119.1565340111552;
        Fri, 09 Aug 2019 01:41:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565340111; cv=none;
        d=google.com; s=arc-20160816;
        b=09M1E7bWvB6rSWR4HjQ0Y+ng8+a40o9kxxhp++q34A88Y+9/N89q/xe5bL0cJMgqvm
         gX/jLs4Emc+sGQVleAkfregEO+g2ToWziIrgQ4OreiiiAkilk9Mdil0CiCVQ8WDURuaV
         8kRq1nJ8KZHemm+HMc4QI1yRld9m6+DYhpO0tI39QXeZT7Cjq/8c77DGv7IMGK+XM2jd
         J0KWqSolzrCnR14o7I7+0xO3dK+OBMeW5I82ZQreuQn9n6XFm6rVfGlZOcgQjoHxTNHP
         JU+QohfNHEBkgd06Rsonab7WJlV9a91Ugs7ZXrSa78hZ4YeApSDWgtWwwgldtpsumCVv
         sXKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=5LuG0HaO2bEKT13rvG09jejP+YLFYU9mB9zquGtlRoc=;
        b=UxgqjND4d7pq7c5pQs4rcW0LSsgtANP2MkJIl2JgNOX1GqkMnhwXnyVNpCY8qfF6Zy
         ebTHMq7oYlSmYbbHX8DKOyItvPyXSO8NVGqaDsRZQUo0CMs5/+czHg64uEOM+gXbeEkO
         FOSlbcgriXmWMu9MryEW5MA3d0Ue08/7CeiiH931vwctVf1DZSMgtoPMlYNX+k0mAQny
         KWW7iIzMznuHhSTSULakUXxz22FeGQbk3WAxa6su0if2LtFR/LF6nSEltrG+Rsczjnev
         WkYEc76zO78+Db0atOQ/rRtkUC4lLaP6YdVlF5jtl/SGm25KOM+onvXHJOoRlSaM3Pwk
         exFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r8si57480018pgr.243.2019.08.09.01.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:41:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x798buR0101188
	for <linux-mm@kvack.org>; Fri, 9 Aug 2019 04:41:51 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u94vqhdfe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:41:29 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 9 Aug 2019 09:41:26 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 9 Aug 2019 09:41:23 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x798fLDm25231790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 08:41:21 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 58632A4054;
	Fri,  9 Aug 2019 08:41:21 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 60C61A405C;
	Fri,  9 Aug 2019 08:41:19 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.95.61])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 08:41:19 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v6 2/7] kvmppc: Shared pages support for secure guests
Date: Fri,  9 Aug 2019 14:11:03 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190809084108.30343-1-bharata@linux.ibm.com>
References: <20190809084108.30343-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19080908-0016-0000-0000-0000029CA6A9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080908-0017-0000-0000-000032FCADCD
Message-Id: <20190809084108.30343-3-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=705 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090089
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A secure guest will share some of its pages with hypervisor (Eg. virtio
bounce buffers etc). Support sharing of pages between hypervisor and
ultravisor.

Once a secure page is converted to shared page, stop tracking that page
as a device page.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/hvcall.h |  3 ++
 arch/powerpc/kvm/book3s_hv_devm.c | 67 +++++++++++++++++++++++++++++--
 2 files changed, 67 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm/hvcall.h
index 2f6b952deb0f..05b8536f6653 100644
--- a/arch/powerpc/include/asm/hvcall.h
+++ b/arch/powerpc/include/asm/hvcall.h
@@ -337,6 +337,9 @@
 #define H_TLB_INVALIDATE	0xF808
 #define H_COPY_TOFROM_GUEST	0xF80C
 
+/* Flags for H_SVM_PAGE_IN */
+#define H_PAGE_IN_SHARED        0x1
+
 /* Platform-specific hcalls used by the Ultravisor */
 #define H_SVM_PAGE_IN		0xEF00
 #define H_SVM_PAGE_OUT		0xEF04
diff --git a/arch/powerpc/kvm/book3s_hv_devm.c b/arch/powerpc/kvm/book3s_hv_devm.c
index 2e6c077bd22e..c9189e58401d 100644
--- a/arch/powerpc/kvm/book3s_hv_devm.c
+++ b/arch/powerpc/kvm/book3s_hv_devm.c
@@ -55,6 +55,7 @@ struct kvmppc_devm_page_pvt {
 	unsigned long *rmap;
 	unsigned int lpid;
 	unsigned long gpa;
+	bool skip_page_out;
 };
 
 struct kvmppc_devm_copy_args {
@@ -188,6 +189,54 @@ kvmppc_devm_migrate_alloc_and_copy(struct migrate_vma *mig,
 	return 0;
 }
 
+/*
+ * Shares the page with HV, thus making it a normal page.
+ *
+ * - If the page is already secure, then provision a new page and share
+ * - If the page is a normal page, share the existing page
+ *
+ * In the former case, uses the dev_pagemap_ops migrate_to_ram handler to
+ * release the device page.
+ */
+static unsigned long
+kvmppc_share_page(struct kvm *kvm, unsigned long gpa, unsigned long page_shift)
+{
+
+	int ret = H_PARAMETER;
+	struct page *devm_page;
+	struct kvmppc_devm_page_pvt *pvt;
+	unsigned long pfn;
+	unsigned long *rmap;
+	struct kvm_memory_slot *slot;
+	unsigned long gfn = gpa >> page_shift;
+	int srcu_idx;
+
+	srcu_idx = srcu_read_lock(&kvm->srcu);
+	slot = gfn_to_memslot(kvm, gfn);
+	if (!slot)
+		goto out;
+
+	rmap = &slot->arch.rmap[gfn - slot->base_gfn];
+	if (kvmppc_is_devm_pfn(*rmap)) {
+		devm_page = pfn_to_page(*rmap & ~KVMPPC_PFN_DEVM);
+		pvt = (struct kvmppc_devm_page_pvt *)
+			devm_page->zone_device_data;
+		pvt->skip_page_out = true;
+	}
+
+	pfn = gfn_to_pfn(kvm, gpa >> page_shift);
+	if (is_error_noslot_pfn(pfn))
+		goto out;
+
+	ret = uv_page_in(kvm->arch.lpid, pfn << page_shift, gpa, 0, page_shift);
+	if (ret == U_SUCCESS)
+		ret = H_SUCCESS;
+	kvm_release_pfn_clean(pfn);
+out:
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	return ret;
+}
+
 /*
  * Move page from normal memory to secure memory.
  */
@@ -209,9 +258,12 @@ kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
 	if (page_shift != PAGE_SHIFT)
 		return H_P3;
 
-	if (flags)
+	if (flags & ~H_PAGE_IN_SHARED)
 		return H_P2;
 
+	if (flags & H_PAGE_IN_SHARED)
+		return kvmppc_share_page(kvm, gpa, page_shift);
+
 	ret = H_PARAMETER;
 	down_read(&kvm->mm->mmap_sem);
 	srcu_idx = srcu_read_lock(&kvm->srcu);
@@ -279,8 +331,17 @@ kvmppc_devm_fault_migrate_alloc_and_copy(struct migrate_vma *mig)
 	pvt = (struct kvmppc_devm_page_pvt *)spage->zone_device_data;
 
 	pfn = page_to_pfn(dpage);
-	ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
-			  pvt->gpa, 0, PAGE_SHIFT);
+
+	/*
+	 * This same function is used in two cases:
+	 * - When HV touches a secure page, for which we do page-out
+	 * - When a secure page is converted to shared page, we touch
+	 *   the page to essentially discard the device page. In this
+	 *   case we skip page-out.
+	 */
+	if (!pvt->skip_page_out)
+		ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
+				  pvt->gpa, 0, PAGE_SHIFT);
 	if (ret == U_SUCCESS)
 		*mig->dst = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
 	return 0;
-- 
2.21.0

