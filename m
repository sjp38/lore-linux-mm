Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF9F3C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7277F20C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7277F20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FFB26B026D; Fri,  9 Aug 2019 04:41:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 698626B026A; Fri,  9 Aug 2019 04:41:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 472006B026C; Fri,  9 Aug 2019 04:41:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4926B026A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:41:35 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id f40so12329282ybj.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:41:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=uGMDR2CDCiIKgwl6n7dhirIOqTWlu1NJ7zZOKL5M/sc=;
        b=I0Kgefr2iYVvpNtO+Ig6G5OXDtZoSVJ2rHVauKmf/+lcs0pt3eaMrnDlgizgHri3of
         i/0tXu731e3rNFJqsQKxIos2xzg9+32UhzS5aXrnKYyRxNyDOsaBJt80KV/ZepEBZ5dz
         ffrxTMFpvP1atYWqx5fAStMqJ2qs5d2xs6t8BJ6PSYW7+5mNGhpSyHNg+yGRZK1P0oXf
         oYGVtMtS9B2qS2ZP6v4Qv2RUFWRcwC6ErItY2sTgcTM8K9+2dpMt4kRiV/JiEeUkoZu8
         kQQGxvKGtmdgUjYUuOcS0KqENKgIXHjt296Yd20U+PimHaOP1FyoI0sc895FrftKr/GU
         PdYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXIU1SG/C2DA9juQyQQYY3Rs6CzX06mAgnWafBFmR5t4wplZW4U
	sBDPZRPjLlGxDhYQ+hdMW5D6h2GTUMjTxh3DUVjFiWanv3CDDL8xzl+QazbPz0Nnz1E1eWOi9o9
	EJXWa1apdSjrb2ktYRbLnDD7VnuwEAKHSD4v3WH5INJTKXTibe8IspJlcUljcds0mzA==
X-Received: by 2002:a81:3841:: with SMTP id f62mr5412370ywa.312.1565340094865;
        Fri, 09 Aug 2019 01:41:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/+7V9fzEbfKyuGOzgZnQdpg4HDDR5xLby+SZE47AQ5it3YNe9Nlegg9Ci0ym+zuJGvchY
X-Received: by 2002:a81:3841:: with SMTP id f62mr5412343ywa.312.1565340094097;
        Fri, 09 Aug 2019 01:41:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565340094; cv=none;
        d=google.com; s=arc-20160816;
        b=gD0gqPRaCCZjpM9bSy1eZvQDcjNuo3CoJjjLvgnhJpXOKh+EEVNXyHRtbQK1YqGKor
         t8dRkcgoR/5/S7BQ854RREid9lSYwsoSMnAG/YOsajzrX1+wXlYK3z2QzkYE0q9UPeqf
         Vgd3ggXEogzC9JUAd0yrpPi03MLJ9hvFkMd+Sap1Rok6LyWDDofHd9rX4qnoP7LS+lbA
         wttlU+G4xQ7O0o9K9RiDPoTz1XAzAZjEfODufIYY9erRsf4T7SpkuqLiuQ3PHc5JVs38
         IxVMphsaCc+nvpjLQ+kanhaVscmybm5lzfT90VSavwRtIFOOB7k4xo4YGi1z2v16BOKV
         4nzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=uGMDR2CDCiIKgwl6n7dhirIOqTWlu1NJ7zZOKL5M/sc=;
        b=j4lobqDEEKBAGGlmbqz0IPRXndevP19ecHRKUQoFq38BUCEWGdh/iAKB3/Q3zWJHFS
         ALWJckxMFWOlmc+7uKy4cyidACTISQQUFzxp6rZL4DFsCmv5LtWHh10J1t9Fg9AP3gZp
         /FVeB+n+QjD+GEgimKK0DSI62vZznUiDYoRUwimFWSw7nJaSGebCKtwQvhQOtdG0OTzQ
         bTMRhiymGAYZFVHh9BWloQDJv8VIbJV5rKkg0KCLvQmwOUT5bx8lCGivXE0F9QyScxPs
         rG2TXPe3omr/E+WODnI5iQPCcU8fYJvk/RGyw998Fo9Ld0wYLprb1Q/4ZJvEcWKUrhMN
         506g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x3si4471036ybq.457.2019.08.09.01.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:41:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x798cIHD092958
	for <linux-mm@kvack.org>; Fri, 9 Aug 2019 04:41:33 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2u92w7p603-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:41:33 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 9 Aug 2019 09:41:31 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 9 Aug 2019 09:41:30 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x798fStq33423854
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 08:41:28 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6DFC0A4054;
	Fri,  9 Aug 2019 08:41:28 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 75D41A405B;
	Fri,  9 Aug 2019 08:41:26 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.95.61])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 08:41:26 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v6 5/7] kvmppc: Radix changes for secure guest
Date: Fri,  9 Aug 2019 14:11:06 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190809084108.30343-1-bharata@linux.ibm.com>
References: <20190809084108.30343-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19080908-0012-0000-0000-0000033CA6CA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080908-0013-0000-0000-00002176ABF4
Message-Id: <20190809084108.30343-6-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090089
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

- After the guest becomes secure, when we handle a page fault of a page
  belonging to SVM in HV, send that page to UV via UV_PAGE_IN.
- Whenever a page is unmapped on the HV side, inform UV via UV_PAGE_INVAL.
- Ensure all those routines that walk the secondary page tables of
  the guest don't do so in case of secure VM. For secure guest, the
  active secondary page tables are in secure memory and the secondary
  page tables in HV are freed when guest becomes secure.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/kvm_host.h       | 12 ++++++++++++
 arch/powerpc/include/asm/ultravisor-api.h |  1 +
 arch/powerpc/include/asm/ultravisor.h     |  5 +++++
 arch/powerpc/kvm/book3s_64_mmu_radix.c    | 22 ++++++++++++++++++++++
 arch/powerpc/kvm/book3s_hv_devm.c         | 20 ++++++++++++++++++++
 5 files changed, 60 insertions(+)

diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index 1827c22909cd..db680d7f5779 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -856,6 +856,8 @@ static inline void kvm_arch_vcpu_block_finish(struct kvm_vcpu *vcpu) {}
 #ifdef CONFIG_PPC_UV
 extern int kvmppc_devm_init(void);
 extern void kvmppc_devm_free(void);
+extern bool kvmppc_is_guest_secure(struct kvm *kvm);
+extern int kvmppc_send_page_to_uv(struct kvm *kvm, unsigned long gpa);
 #else
 static inline int kvmppc_devm_init(void)
 {
@@ -863,6 +865,16 @@ static inline int kvmppc_devm_init(void)
 }
 
 static inline void kvmppc_devm_free(void) {}
+
+static inline bool kvmppc_is_guest_secure(struct kvm *kvm)
+{
+	return false;
+}
+
+static inline int kvmppc_send_page_to_uv(struct kvm *kvm, unsigned long gpa)
+{
+	return -EFAULT;
+}
 #endif /* CONFIG_PPC_UV */
 
 #endif /* __POWERPC_KVM_HOST_H__ */
diff --git a/arch/powerpc/include/asm/ultravisor-api.h b/arch/powerpc/include/asm/ultravisor-api.h
index 46b1ee381695..cf200d4ce703 100644
--- a/arch/powerpc/include/asm/ultravisor-api.h
+++ b/arch/powerpc/include/asm/ultravisor-api.h
@@ -29,5 +29,6 @@
 #define UV_UNREGISTER_MEM_SLOT		0xF124
 #define UV_PAGE_IN			0xF128
 #define UV_PAGE_OUT			0xF12C
+#define UV_PAGE_INVAL			0xF138
 
 #endif /* _ASM_POWERPC_ULTRAVISOR_API_H */
diff --git a/arch/powerpc/include/asm/ultravisor.h b/arch/powerpc/include/asm/ultravisor.h
index 79c415bf5ee8..640db659c8c8 100644
--- a/arch/powerpc/include/asm/ultravisor.h
+++ b/arch/powerpc/include/asm/ultravisor.h
@@ -45,4 +45,9 @@ static inline int uv_unregister_mem_slot(u64 lpid, u64 slotid)
 	return ucall_norets(UV_UNREGISTER_MEM_SLOT, lpid, slotid);
 }
 
+static inline int uv_page_inval(u64 lpid, u64 gpa, u64 page_shift)
+{
+	return ucall_norets(UV_PAGE_INVAL, lpid, gpa, page_shift);
+}
+
 #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index 2d415c36a61d..93ad34e63045 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -19,6 +19,8 @@
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
 #include <asm/pte-walk.h>
+#include <asm/ultravisor.h>
+#include <asm/kvm_host.h>
 
 /*
  * Supported radix tree geometry.
@@ -915,6 +917,9 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	if (!(dsisr & DSISR_PRTABLE_FAULT))
 		gpa |= ea & 0xfff;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return kvmppc_send_page_to_uv(kvm, gpa & PAGE_MASK);
+
 	/* Get the corresponding memslot */
 	memslot = gfn_to_memslot(kvm, gfn);
 
@@ -972,6 +977,11 @@ int kvm_unmap_radix(struct kvm *kvm, struct kvm_memory_slot *memslot,
 	unsigned long gpa = gfn << PAGE_SHIFT;
 	unsigned int shift;
 
+	if (kvmppc_is_guest_secure(kvm)) {
+		uv_page_inval(kvm->arch.lpid, gpa, PAGE_SIZE);
+		return 0;
+	}
+
 	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
 	if (ptep && pte_present(*ptep))
 		kvmppc_unmap_pte(kvm, ptep, gpa, shift, memslot,
@@ -989,6 +999,9 @@ int kvm_age_radix(struct kvm *kvm, struct kvm_memory_slot *memslot,
 	int ref = 0;
 	unsigned long old, *rmapp;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return ref;
+
 	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
 	if (ptep && pte_present(*ptep) && pte_young(*ptep)) {
 		old = kvmppc_radix_update_pte(kvm, ptep, _PAGE_ACCESSED, 0,
@@ -1013,6 +1026,9 @@ int kvm_test_age_radix(struct kvm *kvm, struct kvm_memory_slot *memslot,
 	unsigned int shift;
 	int ref = 0;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return ref;
+
 	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
 	if (ptep && pte_present(*ptep) && pte_young(*ptep))
 		ref = 1;
@@ -1030,6 +1046,9 @@ static int kvm_radix_test_clear_dirty(struct kvm *kvm,
 	int ret = 0;
 	unsigned long old, *rmapp;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return ret;
+
 	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
 	if (ptep && pte_present(*ptep) && pte_dirty(*ptep)) {
 		ret = 1;
@@ -1082,6 +1101,9 @@ void kvmppc_radix_flush_memslot(struct kvm *kvm,
 	unsigned long gpa;
 	unsigned int shift;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return;
+
 	gpa = memslot->base_gfn << PAGE_SHIFT;
 	spin_lock(&kvm->mmu_lock);
 	for (n = memslot->npages; n; --n) {
diff --git a/arch/powerpc/kvm/book3s_hv_devm.c b/arch/powerpc/kvm/book3s_hv_devm.c
index c55bb5f57928..9c4b05cd5b0a 100644
--- a/arch/powerpc/kvm/book3s_hv_devm.c
+++ b/arch/powerpc/kvm/book3s_hv_devm.c
@@ -65,6 +65,11 @@ struct kvmppc_devm_copy_args {
 	unsigned long page_shift;
 };
 
+bool kvmppc_is_guest_secure(struct kvm *kvm)
+{
+	return !!(kvm->arch.secure_guest & KVMPPC_SECURE_INIT_DONE);
+}
+
 unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
 {
 	struct kvm_memslots *slots;
@@ -483,6 +488,21 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gpa,
 	return ret;
 }
 
+int kvmppc_send_page_to_uv(struct kvm *kvm, unsigned long gpa)
+{
+	unsigned long pfn;
+	int ret;
+
+	pfn = gfn_to_pfn(kvm, gpa >> PAGE_SHIFT);
+	if (is_error_noslot_pfn(pfn))
+		return -EFAULT;
+
+	ret = uv_page_in(kvm->arch.lpid, pfn << PAGE_SHIFT, gpa, 0, PAGE_SHIFT);
+	kvm_release_pfn_clean(pfn);
+
+	return (ret == U_SUCCESS) ? RESUME_GUEST : -EFAULT;
+}
+
 static u64 kvmppc_get_secmem_size(void)
 {
 	struct device_node *np;
-- 
2.21.0

