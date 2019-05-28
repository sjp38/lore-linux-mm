Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C370C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E97012070D
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:50:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E97012070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A4436B027C; Tue, 28 May 2019 02:50:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DE7A6B0281; Tue, 28 May 2019 02:50:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E70CC6B0283; Tue, 28 May 2019 02:50:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCA3B6B027C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:50:02 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id k10so3841944ybd.14
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:50:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=B/1DQJluSOy/rrZ6cqxK2UTxrpnxCrmQcp+qzHtwDPI=;
        b=mcFQKS1VejSgPUg4nbpctbULkuFk4+reV55rHut3iC6EFfmzoV4ahaDdoRoCgtjFI5
         DtK0Zyp+76uqTd15GBMnL1rWcDYjl/me2w/2YhVTtWuo3GIpxKlGESMiBZaJgjumE52S
         D/2eOimShuHrVMSxSS06p0FQpqyYpYAEi+XeS4ykVDAxlLLnyPZX7nl0cACy0wKN/F2Z
         muvvWeDgq+IHzvghL4De3yHlE/5RF+BaL9PJ21IPUjXtMudDIQY6LWBDgoWXlCu1XhTI
         r5w9Jgh1V0E3NHNQlDlIO4Fb6nc5IwpJF/8xBgXoPeCmDojszMX5h5e5ShPwCs7fTETU
         W6Fg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXYyaWR9WzUjR1calM1UW+XFKxEy3DKfQ3Mr9y3JR+RogTr15DV
	wd3rqhdMLNfOEuIHEAPcI1xUiKoil1nkcSZdj/1aV/B1lR9LES5cIgPl+tsQEjqL0+n1ow8EsEP
	Y6dILjQBA5oPXhfakTFQsQaKRwOurwEffbW54EjRVo85NhIIVn6CDmHsyuIOdphaWBQ==
X-Received: by 2002:a81:2817:: with SMTP id o23mr59659522ywo.395.1559026202485;
        Mon, 27 May 2019 23:50:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9oRFIspZHg4lZv/NOmevsDcG8tFQvJvv1JKBC5aEOzrmuGBd/6l+ZJB+lzozDDE1ALl6S
X-Received: by 2002:a81:2817:: with SMTP id o23mr59659481ywo.395.1559026201273;
        Mon, 27 May 2019 23:50:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559026201; cv=none;
        d=google.com; s=arc-20160816;
        b=AHePC/3H6tkVZT1u/21Yl06F2NdZwYxjBWwB4b2ERVhcNNE2ojXLtwWdqjsI9qsPKM
         bGAFqQhVgW8ZvS/LJM131MdXCp9Ui4GZBFN7JBxtoyOFocd2sNgga9+FGjX5NcOjWu5a
         QkUKIf6g72idQ22Cx5zG0uPtSBLOyZ+INfAOcWwdMwlbYgBwER8z78varrlu3H2/AHeo
         AQ9GaD9mEcbWNgbvCwJJqEXnPa+MoICiUgF3KKj6L2T4z2F6XiMmIrPPVb7OJHaot/8c
         wXC3/uary6rHyij666lBCQNEC7Vfn/p2B/gnCdfhmSqsDERqRbT2PIi4fKvnlfyKAC2t
         OyrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=B/1DQJluSOy/rrZ6cqxK2UTxrpnxCrmQcp+qzHtwDPI=;
        b=D9YANaV2MBDvZbFNjB0Z5IAxzLFoL1MEtrvQKkRa8XlQMiQDyKFJJ1tAyHGbMbdKKc
         vHd3+v6dpj3SWqgGrrwzOAGHxetYso2R58ukahLI2LagZBmY7caqCy9i5dwQBm3GoTCE
         5zGG3jTIhOkczSKL9W0NsUYr/H4dJBanYYMZxGMt2VDSgKA9ovXGR2jqK70RJOfw+W+g
         7a3k3U2f3LZOMFrL+uiD8ZmCP/FgUzUQJbCtap5MfjC//jvn/zDpFoV26hO9nrdz5UaO
         rDIwzfeVIxvxDKaLBzjKwgFhyap/PNTnFqly2alwbYcmKb4pNT23H/pFGAiuRZVCH4Mt
         MM0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k82si3018770ybb.440.2019.05.27.23.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:50:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4S6bupR066385
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:50:01 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2srxuy2s1r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:50:00 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 28 May 2019 07:49:59 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 28 May 2019 07:49:56 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4S6nsuZ49217660
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 06:49:54 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6A4F411C04A;
	Tue, 28 May 2019 06:49:54 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AE4F811C050;
	Tue, 28 May 2019 06:49:52 +0000 (GMT)
Received: from bharata.in.ibm.com (unknown [9.124.35.100])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 28 May 2019 06:49:52 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v4 5/6] kvmppc: Radix changes for secure guest
Date: Tue, 28 May 2019 12:19:32 +0530
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190528064933.23119-1-bharata@linux.ibm.com>
References: <20190528064933.23119-1-bharata@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19052806-0012-0000-0000-000003201D37
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052806-0013-0000-0000-00002158E30C
Message-Id: <20190528064933.23119-6-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280045
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

- After the guest becomes secure, when we handle a page fault of a page
  belonging to SVM in HV, send that page to UV via UV_PAGE_IN.
- Whenever a page is unmapped on the HV side, inform UV via UV_PAGE_INVAL.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/kvm_host.h       | 13 +++++++++++++
 arch/powerpc/include/asm/ultravisor-api.h |  1 +
 arch/powerpc/include/asm/ultravisor.h     |  7 +++++++
 arch/powerpc/kvm/book3s_64_mmu_radix.c    | 19 +++++++++++++++++++
 arch/powerpc/kvm/book3s_hv_hmm.c          | 23 +++++++++++++++++++++++
 5 files changed, 63 insertions(+)

diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index 845fd2a73506..63d56f7a357e 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -866,6 +866,8 @@ static inline void kvm_arch_vcpu_block_finish(struct kvm_vcpu *vcpu) {}
 extern int kvmppc_hmm_init(void);
 extern void kvmppc_hmm_free(void);
 extern void kvmppc_hmm_release_pfns(struct kvm_memory_slot *free);
+extern bool kvmppc_is_guest_secure(struct kvm *kvm);
+extern int kvmppc_send_page_to_uv(struct kvm *kvm, unsigned long gpa);
 #else
 static inline int kvmppc_hmm_init(void)
 {
@@ -874,6 +876,17 @@ static inline int kvmppc_hmm_init(void)
 
 static inline void kvmppc_hmm_free(void) {}
 static inline void kvmppc_hmm_release_pfns(struct kvm_memory_slot *free) {}
+
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
index 35b71e01177d..eaca65ea2070 100644
--- a/arch/powerpc/include/asm/ultravisor-api.h
+++ b/arch/powerpc/include/asm/ultravisor-api.h
@@ -24,5 +24,6 @@
 #define UV_UNREGISTER_MEM_SLOT		0xF124
 #define UV_PAGE_IN			0xF128
 #define UV_PAGE_OUT			0xF12C
+#define UV_PAGE_INVAL			0xF138
 
 #endif /* _ASM_POWERPC_ULTRAVISOR_API_H */
diff --git a/arch/powerpc/include/asm/ultravisor.h b/arch/powerpc/include/asm/ultravisor.h
index 5113457c4743..28dbc0f0eddb 100644
--- a/arch/powerpc/include/asm/ultravisor.h
+++ b/arch/powerpc/include/asm/ultravisor.h
@@ -77,6 +77,13 @@ static inline int uv_unregister_mem_slot(u64 lpid, u64 slotid)
 
 	return ucall(UV_UNREGISTER_MEM_SLOT, retbuf, lpid, slotid);
 }
+
+static inline int uv_page_inval(u64 lpid, u64 gpa, u64 page_shift)
+{
+	unsigned long retbuf[UCALL_BUFSIZE];
+
+	return ucall(UV_PAGE_INVAL, retbuf, lpid, gpa, page_shift);
+}
 #endif /* !__ASSEMBLY__ */
 
 #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
index f55ef071883f..e5d63449ad77 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
@@ -21,6 +21,8 @@
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
 #include <asm/pte-walk.h>
+#include <asm/ultravisor.h>
+#include <asm/kvm_host.h>
 
 /*
  * Supported radix tree geometry.
@@ -923,6 +925,9 @@ int kvmppc_book3s_radix_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 	if (!(dsisr & DSISR_PRTABLE_FAULT))
 		gpa |= ea & 0xfff;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return kvmppc_send_page_to_uv(kvm, gpa & PAGE_MASK);
+
 	/* Get the corresponding memslot */
 	memslot = gfn_to_memslot(kvm, gfn);
 
@@ -980,6 +985,11 @@ int kvm_unmap_radix(struct kvm *kvm, struct kvm_memory_slot *memslot,
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
@@ -997,6 +1007,9 @@ int kvm_age_radix(struct kvm *kvm, struct kvm_memory_slot *memslot,
 	int ref = 0;
 	unsigned long old, *rmapp;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return ref;
+
 	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
 	if (ptep && pte_present(*ptep) && pte_young(*ptep)) {
 		old = kvmppc_radix_update_pte(kvm, ptep, _PAGE_ACCESSED, 0,
@@ -1021,6 +1034,9 @@ int kvm_test_age_radix(struct kvm *kvm, struct kvm_memory_slot *memslot,
 	unsigned int shift;
 	int ref = 0;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return ref;
+
 	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
 	if (ptep && pte_present(*ptep) && pte_young(*ptep))
 		ref = 1;
@@ -1038,6 +1054,9 @@ static int kvm_radix_test_clear_dirty(struct kvm *kvm,
 	int ret = 0;
 	unsigned long old, *rmapp;
 
+	if (kvmppc_is_guest_secure(kvm))
+		return ret;
+
 	ptep = __find_linux_pte(kvm->arch.pgtable, gpa, NULL, &shift);
 	if (ptep && pte_present(*ptep) && pte_dirty(*ptep)) {
 		ret = 1;
diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
index 18fec814401d..a0d47fc140b6 100644
--- a/arch/powerpc/kvm/book3s_hv_hmm.c
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -55,6 +55,11 @@ struct kvmppc_hmm_migrate_args {
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
@@ -478,6 +483,24 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gpa,
 	return ret;
 }
 
+int kvmppc_send_page_to_uv(struct kvm *kvm, unsigned long gpa)
+{
+	int srcu_idx;
+	unsigned long pfn;
+	int ret;
+
+	srcu_idx = srcu_read_lock(&kvm->srcu);
+	pfn = gfn_to_pfn(kvm, gpa >> PAGE_SHIFT);
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
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
2.17.1

