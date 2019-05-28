Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A141AC04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 651892070D
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:49:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 651892070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD99A6B0276; Tue, 28 May 2019 02:49:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7C1B6B027A; Tue, 28 May 2019 02:49:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 806406B027C; Tue, 28 May 2019 02:49:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 480EE6B0278
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:57 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 77so11391596pfu.1
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:49:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=B7JDsk73IdojO0N6gIey7LRtWsA77hCHFai+fTFI3Bs=;
        b=A5ql0rAOOgIQOl00E7RvK7UjIR0Bb1pXZeiMWlLhagCZHoUwH2jmBlfcOlxMn7V9Pe
         eF88snkiwOU/TKPFsbC2EVFEEwtvPIzkkI84o9Qq3lU5rBJcJ1kuVO99kA1FxU9+35wF
         GbnCnEWpkKmx0kFjkS1dWzyq1QOB61QzmKu/uCGNBrSyPYWP3qs9AHJaW2LyYJxm9ZdG
         tqtNdxJA0X/k+pZPOGopPWFNYV4K9RDq93y8zhZowgTyadx6LpLzsze2k+W1aPlno5Rk
         zPv9d7MYd+nr1POoZfcXgcqY1ssNun/rG/KsdSG8PeClN2nly10+O57L4KfSFXSNn5V0
         WGZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWs8wUVzH+lHmwqbLWyF1uHP8PvP259cuvzUo4ZP3BHEV40tZkj
	xgse93Y2tby+sI5w5/kkIoAe4UtEdDFP1+0xW7siJUunWCY/WW5NHJrkj9f++0chTYnuDVrlUQq
	jL3HOw5jJckrydY0J7rT3Nv+LL7Mysv3EWr1PvmI2dgvYnqCAZMBcjW9vjjzuuN0nvg==
X-Received: by 2002:a17:902:e40f:: with SMTP id ci15mr135710154plb.280.1559026196889;
        Mon, 27 May 2019 23:49:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDQ7aSQLv0mVVAQ0OVRDBQKG/YQlHRhyH08EYCOjA5kgXWCZIBKmMs47Tj4EA18moLIRCS
X-Received: by 2002:a17:902:e40f:: with SMTP id ci15mr135710096plb.280.1559026195698;
        Mon, 27 May 2019 23:49:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559026195; cv=none;
        d=google.com; s=arc-20160816;
        b=s/LZuLlEUy4krNPMUJmZzXkAqX+YM4DwPqHD9qyKfjoTc4I+nUxeWo6yT6Dpkhp+u2
         8X5xLInglXVxgPTRbR1B/4loDd8mG3Irzj5HBJVnyDNqZTfkEMXZNzVEfe8IyXEqMt5M
         ZzfUjZxQmLpcZwGyJRzK2jbJmuidYa97pQWwpE9dHKohltJnuLDqq7zzUkiQY+kjnmw/
         JgZlBjT6A+aJ7+zNssDdukQjHsLzUiuMkHHnBvgZRSVMZj3+K1yxCqopTUfiAN/DKjYl
         KbqJC/6kKTC7BxrLJlUYLn7LiSt64BGCwX/5vK2CZ44sd0agGvp2gvdr+SvR7jW/YyTG
         1D5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=B7JDsk73IdojO0N6gIey7LRtWsA77hCHFai+fTFI3Bs=;
        b=kgPuZ/SnP+m+5XyDaSOfyZoSU+53D8BVnq8J1E7oMIAtZ0btAeNDEZJm5xNu+EG0Qa
         zVRfP4iCbRc7fwuaeVw6ioRgP8DHu/SuAHiYWTQePlD+PPAHhMD15EBvxEwF5/IQcljf
         ruxsCcid02eaXctEVo8vU+FhA3Br06kaXRb7EXAO4cPchwD44HtgvgsGvvWF2gq4ArCG
         CVMEhcDuaHIcHgFXeZtl/CFot/h1HqUeXKfv4SonuNDi22jlTqpOy7m3P+kdylDOIRtZ
         GofkJis35sOt4LQjRCtkVVbD5mTh7MvdUdvZPui/iXImq6avHpGLW3SzRqpIp0gveh32
         I3gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z19si23849532pfc.265.2019.05.27.23.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:49:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4S6burw098355
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:55 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sry5bj0we-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:54 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 28 May 2019 07:49:52 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 28 May 2019 07:49:50 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4S6nmuI54657230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 06:49:48 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 731DF11C04A;
	Tue, 28 May 2019 06:49:48 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BBBBD11C04C;
	Tue, 28 May 2019 06:49:46 +0000 (GMT)
Received: from bharata.in.ibm.com (unknown [9.124.35.100])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 28 May 2019 06:49:46 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v4 2/6] kvmppc: Shared pages support for secure guests
Date: Tue, 28 May 2019 12:19:29 +0530
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190528064933.23119-1-bharata@linux.ibm.com>
References: <20190528064933.23119-1-bharata@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19052806-0008-0000-0000-000002EB1A71
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052806-0009-0000-0000-00002257E5D2
Message-Id: <20190528064933.23119-3-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=776 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280045
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
index 713806003da3..333829682f59 100644
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

