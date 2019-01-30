Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49331C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03CD820989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03CD820989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FE8F8E0004; Wed, 30 Jan 2019 01:07:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AF448E0001; Wed, 30 Jan 2019 01:07:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 078828E0004; Wed, 30 Jan 2019 01:07:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFC078E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:46 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k203so24573230qke.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 22:07:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=auIY83jBHJJiEwioLXssSuoSuXNHrDM6UNE4IFyh6Eo=;
        b=kIZ2X8vmbloyXIsp7XGvmt4W1LCW7XjL+HtvXygzYxA0btLWbrWRSFyNHny6HM4mcQ
         JmVcVFEMO5Eg8Y+rlZ3HpvOXu/6IzMnNyTbSMFLGYK8hNEboLv97JZ7/ceLz7fK/xQG6
         4Ncx6g4ggXzUKesM6QfKgXirfc6ot0zy8ic9YKercrO3vH2DxLF6UEnfGl0WHULutaQ5
         lNp3+Y9zzwDA4yEmtIo1GTvVOLsJWaW92RhSmlizSalk3O9w2hlm0m9d17bdHYPFxS1q
         8RBLRO/IzJGMqEAtTtl8Xu7XH94hmxlE60jnczy24ljhUqQ8RsaYoJl9gDMIvORHDHnp
         kEow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukdPHGQu1ZD6CR4mvbCECy5TrMA2LMgU9j8LkJrKOJMXbZwFrxnY
	IkKxIRTgKS7znyzIju+ZdzjDByf/ymAYA65eJYdKKXTWKmSEIez2ZOH+EkcD49u8oXqr+o2BRfa
	MfQNYO187mxLl8TCV4lp0iBXv7zMSaQvM+FC3mozxfZjTlqdgDaKfSawGsZdohOs4DQ==
X-Received: by 2002:a37:9a89:: with SMTP id c131mr26570889qke.173.1548828466603;
        Tue, 29 Jan 2019 22:07:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4JOet8Y/spEObYyeQkHkfc91llNzkKL4RHYY5nOsmybq7pnojyLFCQ2HLypUIr2CbtlnkG
X-Received: by 2002:a37:9a89:: with SMTP id c131mr26570831qke.173.1548828465644;
        Tue, 29 Jan 2019 22:07:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548828465; cv=none;
        d=google.com; s=arc-20160816;
        b=SFTjcic1ayCCrR9kxuVAI+BDgv951WE2AqG6cPoRUOT+zBiSd2sU8r8rDAX3/Lh+Zo
         gURFDdRSJoJhHDwploeBj1zvxTtR5leuEXYq0b7EjUqBk8vGlgpNeoWZX09YsVclVvzb
         MHQisVb41jzFUoMOieKKDym9FajQ+sNO64UsyVUtsLG/J9v/fOVmuAdYtmoJuYDEVHMV
         MhAOFx/ckQnYZIPsv8dNmLV48B0IXKnAu/PBDxkxmkLheZIcUIas/vsgzi1zVbPpOlBe
         YnkZB34siJiYQspALAoJmOIY/jCGPolqk/6tdy2nxIJnXfdJVwcOF3fGOXYbsa5LNb7N
         T/8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=auIY83jBHJJiEwioLXssSuoSuXNHrDM6UNE4IFyh6Eo=;
        b=j5Hq/WYPj87ehY00f479Lu26ZX45RiW82NG1oi/S7HO0RAvRdE7bAz+GSejCb2/vjO
         YKkQNUP/P1BEaucLSoZ9hJPuwLRraXZKuqZYfYGM5bzhs/77kNLAVfq6Et/j1vBMFnHo
         u5YSOhK/BHKnMvxRwdk8pq3TT97nfa/AIuaAAtUr2bylGtcWFOBJclTGfy+dqvsNZLfv
         QlLJ1UFlOJub1Kk3ISwPu8MrZz6T/HvHR8eXxWkJ/J6gPCpXyFp2h4iVBqW88ie1C6R1
         yXhbQCX4OO2/GCP9gYi6QJtb1HltK6nNCRxfhEuo5D3YZ/aQAcFVHpVXYndE4agROHU4
         +bMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l66si448110qkc.26.2019.01.29.22.07.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 22:07:45 -0800 (PST)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U64OrK106604
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:45 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qb591thh5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:45 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 30 Jan 2019 06:07:43 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 30 Jan 2019 06:07:40 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0U67c6N45940802
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 30 Jan 2019 06:07:38 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9BF5F5204E;
	Wed, 30 Jan 2019 06:07:38 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.36.73])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id C898952065;
	Wed, 30 Jan 2019 06:07:36 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v3 2/4] kvmppc: Add support for shared pages in HMM driver
Date: Wed, 30 Jan 2019 11:37:24 +0530
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190130060726.29958-1-bharata@linux.ibm.com>
References: <20190130060726.29958-1-bharata@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19013006-0008-0000-0000-000002B7C312
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013006-0009-0000-0000-000022240866
Message-Id: <20190130060726.29958-3-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=873 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901300046
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A secure guest will share some of its pages with hypervisor (Eg. virtio
bounce buffers etc). Support shared pages in HMM driver.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/hvcall.h |  3 ++
 arch/powerpc/kvm/book3s_hv_hmm.c  | 58 +++++++++++++++++++++++++++++--
 2 files changed, 58 insertions(+), 3 deletions(-)

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
diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
index edc512acebd3..d8112092a242 100644
--- a/arch/powerpc/kvm/book3s_hv_hmm.c
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -45,6 +45,7 @@ struct kvmppc_hmm_page_pvt {
 	unsigned long *rmap;
 	unsigned int lpid;
 	unsigned long gpa;
+	bool skip_page_out;
 };
 
 struct kvmppc_hmm_migrate_args {
@@ -212,6 +213,45 @@ static const struct migrate_vma_ops kvmppc_hmm_migrate_ops = {
 	.finalize_and_map = kvmppc_hmm_migrate_finalize_and_map,
 };
 
+/*
+ * Shares the page with HV, thus making it a normal page.
+ *
+ * - If the page is already secure, then provision a new page and share
+ * - If the page is a normal page, share the existing page
+ *
+ * In the former case, uses the HMM fault handler to release the HMM page.
+ */
+static unsigned long
+kvmppc_share_page(struct kvm *kvm, unsigned long *rmap, unsigned long gpa,
+		  unsigned long addr, unsigned long page_shift)
+{
+
+	int ret;
+	unsigned int lpid = kvm->arch.lpid;
+	struct page *hmm_page;
+	struct kvmppc_hmm_page_pvt *pvt;
+	unsigned long pfn;
+	int srcu_idx;
+
+	if (kvmppc_is_hmm_pfn(*rmap)) {
+		hmm_page = pfn_to_page(*rmap & ~KVMPPC_PFN_HMM);
+		pvt = (struct kvmppc_hmm_page_pvt *)
+			hmm_devmem_page_get_drvdata(hmm_page);
+		pvt->skip_page_out = true;
+	}
+
+	srcu_idx = srcu_read_lock(&kvm->srcu);
+	pfn = gfn_to_pfn(kvm, gpa >> page_shift);
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	if (is_error_noslot_pfn(pfn))
+		return H_PARAMETER;
+
+	ret = uv_page_in(lpid, pfn << page_shift, gpa, 0, page_shift);
+	kvm_release_pfn_clean(pfn);
+
+	return (ret == U_SUCCESS) ? H_SUCCESS : H_PARAMETER;
+}
+
 /*
  * Move page from normal memory to secure memory.
  */
@@ -242,9 +282,12 @@ kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
 
 	end = addr + (1UL << page_shift);
 
-	if (flags)
+	if (flags & ~H_PAGE_IN_SHARED)
 		return H_P2;
 
+	if (flags & H_PAGE_IN_SHARED)
+		return kvmppc_share_page(kvm, rmap, gpa, addr, page_shift);
+
 	args.rmap = rmap;
 	args.lpid = kvm->arch.lpid;
 	args.gpa = gpa;
@@ -291,8 +334,17 @@ kvmppc_hmm_fault_migrate_alloc_and_copy(struct vm_area_struct *vma,
 	       hmm_devmem_page_get_drvdata(spage);
 
 	pfn = page_to_pfn(dpage);
-	ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
-			  pvt->gpa, 0, PAGE_SHIFT);
+
+	/*
+	 * This same alloc_and_copy() callback is used in two cases:
+	 * - When HV touches a secure page, for which we do page-out
+	 * - When a secure page is converted to shared page, we touch
+	 *   the page to essentially discard the HMM page. In this case we
+	 *   skip page-out.
+	 */
+	if (!pvt->skip_page_out)
+		ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
+				  pvt->gpa, 0, PAGE_SHIFT);
 	if (ret == U_SUCCESS)
 		*dst_pfn = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
 }
-- 
2.17.1

