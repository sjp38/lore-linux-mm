Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB08FC282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65AC720989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65AC720989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13F278E0003; Wed, 30 Jan 2019 01:07:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0ED678E0001; Wed, 30 Jan 2019 01:07:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECFA38E0003; Wed, 30 Jan 2019 01:07:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99CD18E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:45 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 12so16052613plb.18
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 22:07:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=mmyKz4kptGbvKwqBTG2lTwIWzDkKtQyO4qCVOR9sy7A=;
        b=ctOs5cuKmY+SMkU0Yy2W3/TYxXXSissPiAty8QVGcVBExw8l7EkF2Ih+XDhkgExJGV
         at3yMlciJ/stA5ftEZY526E5YWTnzEsjFRYOxbq45oi0odNDZIqD2jbYdXXhxipSxXdd
         6P1feJBduA+sqCs+ebthTMtqvc2tilz4QG8jBh4GAosXOHdJovU/1NWtztC+w8nBz/xw
         EPkE+1xrX1pwFQhAUJFAil2xdwIMkqdXk+JtLYE4yOxim2jpEPRHZggDduOLXp+NyG3N
         D9JFJ2PjPqyjzrQuA1fhyx4syIfcnWcNld9J9c35TPbs5iyrycZJTU3EA90twj31b6A3
         56Xw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukeZGwI/DrIaIMVINXfaH2m5D6NSQnhv+W8kJogACj+t1GvmIcFi
	ufUf5qyGmnt6+BLTFTnZjnEGit8pzvSQfqKPtsL+ssHKO8tmtuSZlhviK1mJ7PfbkpcNwmYNKlG
	CcmuHEesLB5xKj2b4eBVFfq7lQHx30tHCeW6l7bQhvkx/E2n/ALl2vj3RgO24VkvrPw==
X-Received: by 2002:a63:cf48:: with SMTP id b8mr26873740pgj.17.1548828465197;
        Tue, 29 Jan 2019 22:07:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6R1DID0otQuujXLAkm09pE8zcIw9TY6mQMOZ35BRBKcMqsBMj9/RsNPOql67bt3OTnroz4
X-Received: by 2002:a63:cf48:: with SMTP id b8mr26873668pgj.17.1548828463734;
        Tue, 29 Jan 2019 22:07:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548828463; cv=none;
        d=google.com; s=arc-20160816;
        b=o6cTlnVy+dynV3TIeiY194KyG6p7/ZGayCIW6FICpNQbkEJKeh/ntq26LjxlumZlp7
         g1EVD2jtuocvCWYrkAV+yAkpW3PYZMcJ3k17oAj9qrasAhrIV65eUM1lxkUrnILpkMMT
         PDKxlXDkNT6QwrohaRngfhVKYyUkU9FO3FFdaO0dkokrH5pedA0jT5RzPB9DnGKRDgyz
         mLkSI2yv4ZQBFI1pH7UW6Mkl8bJ9Xy97VoVDceaHuUALu9nSaAiRWtdY+x0tymEdldpl
         RuJe0sAd0nIv7C6vi8jNdl+xdUJ+M+M8CBU0jddp7+lMM3NA7F9/ZiauoLu+BTQ/LhML
         Copw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=mmyKz4kptGbvKwqBTG2lTwIWzDkKtQyO4qCVOR9sy7A=;
        b=hzTrD7dZCOd25KJXbjuO9rmkNYHtzNtmDjlBz2uG7+Z5r+feeEYoxrsF8tG593DYq2
         /20JkNAltNrUPJ8SOYls4+Uwvn5EmSbmWhLfDy0e+E2u4KnPLjqXlYXbJJdSOM9KPZwk
         lHKuvu3rGuDPuqy8ZE+rbWb3OmUe5jzeV2TF3jXenrMDMr9nYnsu452IYTCzOcktTOpH
         ZQvJX5eXd0/nus00JLNlNe3M41LhLbBUYmkkkVj694ZjjxV2iM/yFJLAz+Tj7H7AGglf
         IXgQK0J3DIVtx3hAEqgDlCHozvdNcn8GqRSUgaIxfJn0+L2U9kgOI4BD5ozz761vvzIY
         FMnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 44si660502plb.57.2019.01.29.22.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 22:07:43 -0800 (PST)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U64Pmq028443
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:43 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qb1fpa13w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:42 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 30 Jan 2019 06:07:40 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 30 Jan 2019 06:07:37 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0U67ZIP3867112
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 30 Jan 2019 06:07:35 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8E25E5204E;
	Wed, 30 Jan 2019 06:07:35 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.36.73])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id AEFBC52059;
	Wed, 30 Jan 2019 06:07:33 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v3 1/4] kvmppc: HMM backend driver to manage pages of secure guest
Date: Wed, 30 Jan 2019 11:37:23 +0530
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190130060726.29958-1-bharata@linux.ibm.com>
References: <20190130060726.29958-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19013006-0028-0000-0000-000003409DC1
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013006-0029-0000-0000-000023FDA3AF
Message-Id: <20190130060726.29958-2-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901300046
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

HMM driver for KVM PPC to manage page transitions of
secure guest via H_SVM_PAGE_IN and H_SVM_PAGE_OUT hcalls.

H_SVM_PAGE_IN: Move the content of a normal page to secure page
H_SVM_PAGE_OUT: Move the content of a secure page to normal page

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/hvcall.h           |   4 +
 arch/powerpc/include/asm/kvm_book3s_hmm.h   |  33 ++
 arch/powerpc/include/asm/kvm_host.h         |  14 +
 arch/powerpc/include/asm/ucall-api.h        |  19 +
 arch/powerpc/include/uapi/asm/uapi_uvcall.h |   3 +
 arch/powerpc/kvm/Makefile                   |   3 +
 arch/powerpc/kvm/book3s_hv.c                |  22 +
 arch/powerpc/kvm/book3s_hv_hmm.c            | 474 ++++++++++++++++++++
 8 files changed, 572 insertions(+)
 create mode 100644 arch/powerpc/include/asm/kvm_book3s_hmm.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_hmm.c

diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm/hvcall.h
index 463c63a9fcf1..2f6b952deb0f 100644
--- a/arch/powerpc/include/asm/hvcall.h
+++ b/arch/powerpc/include/asm/hvcall.h
@@ -337,6 +337,10 @@
 #define H_TLB_INVALIDATE	0xF808
 #define H_COPY_TOFROM_GUEST	0xF80C
 
+/* Platform-specific hcalls used by the Ultravisor */
+#define H_SVM_PAGE_IN		0xEF00
+#define H_SVM_PAGE_OUT		0xEF04
+
 /* Values for 2nd argument to H_SET_MODE */
 #define H_SET_MODE_RESOURCE_SET_CIABR		1
 #define H_SET_MODE_RESOURCE_SET_DAWR		2
diff --git a/arch/powerpc/include/asm/kvm_book3s_hmm.h b/arch/powerpc/include/asm/kvm_book3s_hmm.h
new file mode 100644
index 000000000000..e61519c17485
--- /dev/null
+++ b/arch/powerpc/include/asm/kvm_book3s_hmm.h
@@ -0,0 +1,33 @@
+// SPDX-License-Identifier: GPL-2.0
+#ifndef __POWERPC_KVM_PPC_HMM_H__
+#define __POWERPC_KVM_PPC_HMM_H__
+
+#ifdef CONFIG_PPC_KVM_UV
+extern unsigned long kvmppc_h_svm_page_in(struct kvm *kvm,
+					  unsigned int lpid,
+					  unsigned long gra,
+					  unsigned long flags,
+					  unsigned long page_shift);
+extern unsigned long kvmppc_h_svm_page_out(struct kvm *kvm,
+					  unsigned int lpid,
+					  unsigned long gra,
+					  unsigned long flags,
+					  unsigned long page_shift);
+#else
+static inline unsigned long
+kvmppc_h_svm_page_in(struct kvm *kvm, unsigned int lpid,
+		     unsigned long gra, unsigned long flags,
+		     unsigned long page_shift)
+{
+	return H_UNSUPPORTED;
+}
+
+static inline unsigned long
+kvmppc_h_svm_page_out(struct kvm *kvm, unsigned int lpid,
+		      unsigned long gra, unsigned long flags,
+		      unsigned long page_shift)
+{
+	return H_UNSUPPORTED;
+}
+#endif /* CONFIG_PPC_KVM_UV */
+#endif /* __POWERPC_KVM_PPC_HMM_H__ */
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index 162005ae50e2..15ea03852bf1 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -846,4 +846,18 @@ static inline void kvm_arch_vcpu_blocking(struct kvm_vcpu *vcpu) {}
 static inline void kvm_arch_vcpu_unblocking(struct kvm_vcpu *vcpu) {}
 static inline void kvm_arch_vcpu_block_finish(struct kvm_vcpu *vcpu) {}
 
+#ifdef CONFIG_PPC_KVM_UV
+extern int kvmppc_hmm_init(void);
+extern void kvmppc_hmm_free(void);
+extern void kvmppc_hmm_release_pfns(struct kvm_memory_slot *free);
+#else
+static inline int kvmppc_hmm_init(void)
+{
+	return 0;
+}
+
+static inline void kvmppc_hmm_free(void) {}
+static inline void kvmppc_hmm_release_pfns(struct kvm_memory_slot *free) {}
+#endif /* CONFIG_PPC_KVM_UV */
+
 #endif /* __POWERPC_KVM_HOST_H__ */
diff --git a/arch/powerpc/include/asm/ucall-api.h b/arch/powerpc/include/asm/ucall-api.h
index 82d8edd1e409..6c3bddc97b55 100644
--- a/arch/powerpc/include/asm/ucall-api.h
+++ b/arch/powerpc/include/asm/ucall-api.h
@@ -9,6 +9,8 @@
 #include <linux/of_fdt.h>
 #include <linux/libfdt.h>
 
+#define U_SUCCESS 0
+
 extern unsigned int smf_state;
 static inline bool smf_enabled(void)
 {
@@ -54,5 +56,22 @@ static inline int uv_restricted_spr_read(u64 reg, u64 *val)
 	return rc;
 }
 
+static inline int uv_page_in(u64 lpid, u64 src_ra, u64 dst_gpa, u64 flags,
+			     u64 page_shift)
+{
+	unsigned long retbuf[PLPAR_UCALL_BUFSIZE];
+
+	return plpar_ucall(UV_PAGE_IN, retbuf, lpid, src_ra, dst_gpa, flags,
+			   page_shift);
+}
+
+static inline int uv_page_out(u64 lpid, u64 dst_ra, u64 src_gpa, u64 flags,
+			      u64 page_shift)
+{
+	unsigned long retbuf[PLPAR_UCALL_BUFSIZE];
+
+	return plpar_ucall(UV_PAGE_OUT, retbuf, lpid, dst_ra, src_gpa, flags,
+			   page_shift);
+}
 #endif	/* __ASSEMBLY__ */
 #endif	/* _ASM_POWERPC_UCALL_API_H */
diff --git a/arch/powerpc/include/uapi/asm/uapi_uvcall.h b/arch/powerpc/include/uapi/asm/uapi_uvcall.h
index b657af679ca7..3a30820663a2 100644
--- a/arch/powerpc/include/uapi/asm/uapi_uvcall.h
+++ b/arch/powerpc/include/uapi/asm/uapi_uvcall.h
@@ -12,4 +12,7 @@
 #define UV_RESTRICTED_SPR_WRITE 0xf108
 #define UV_RESTRICTED_SPR_READ 0xf10C
 #define UV_RETURN	0xf11C
+#define UV_PAGE_IN	0xF128
+#define UV_PAGE_OUT	0xF12C
+
 #endif /* #ifndef UAPI_UC_H */
diff --git a/arch/powerpc/kvm/Makefile b/arch/powerpc/kvm/Makefile
index 64f1135e7732..ed3a9d974059 100644
--- a/arch/powerpc/kvm/Makefile
+++ b/arch/powerpc/kvm/Makefile
@@ -76,6 +76,9 @@ kvm-hv-y += \
 	book3s_64_mmu_radix.o \
 	book3s_hv_nested.o
 
+kvm-hv-$(CONFIG_PPC_KVM_UV) += \
+	book3s_hv_hmm.o
+
 kvm-hv-$(CONFIG_PPC_TRANSACTIONAL_MEM) += \
 	book3s_hv_tm.o
 
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 5a066fc299e1..e7edba1ec16a 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -74,6 +74,8 @@
 #include <asm/opal.h>
 #include <asm/xics.h>
 #include <asm/xive.h>
+#include <asm/kvm_host.h>
+#include <asm/kvm_book3s_hmm.h>
 
 #include "book3s.h"
 
@@ -1001,6 +1003,20 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
 		if (nesting_enabled(vcpu->kvm))
 			ret = kvmhv_copy_tofrom_guest_nested(vcpu);
 		break;
+	case H_SVM_PAGE_IN:
+		ret = kvmppc_h_svm_page_in(vcpu->kvm,
+					   kvmppc_get_gpr(vcpu, 4),
+					   kvmppc_get_gpr(vcpu, 5),
+					   kvmppc_get_gpr(vcpu, 6),
+					   kvmppc_get_gpr(vcpu, 7));
+		break;
+	case H_SVM_PAGE_OUT:
+		ret = kvmppc_h_svm_page_out(vcpu->kvm,
+					    kvmppc_get_gpr(vcpu, 4),
+					    kvmppc_get_gpr(vcpu, 5),
+					    kvmppc_get_gpr(vcpu, 6),
+					    kvmppc_get_gpr(vcpu, 7));
+		break;
 	default:
 		return RESUME_HOST;
 	}
@@ -4354,6 +4370,7 @@ static void kvmppc_core_free_memslot_hv(struct kvm_memory_slot *free,
 					struct kvm_memory_slot *dont)
 {
 	if (!dont || free->arch.rmap != dont->arch.rmap) {
+		kvmppc_hmm_release_pfns(free);
 		vfree(free->arch.rmap);
 		free->arch.rmap = NULL;
 	}
@@ -5429,11 +5446,16 @@ static int kvmppc_book3s_init_hv(void)
 			no_mixing_hpt_and_radix = true;
 	}
 
+	r = kvmppc_hmm_init();
+	if (r < 0)
+		pr_err("KVM-HV: kvmppc_hmm_init failed %d\n", r);
+
 	return r;
 }
 
 static void kvmppc_book3s_exit_hv(void)
 {
+	kvmppc_hmm_free();
 	kvmppc_free_host_rm_ops();
 	if (kvmppc_radix_possible())
 		kvmppc_radix_exit();
diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
new file mode 100644
index 000000000000..edc512acebd3
--- /dev/null
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -0,0 +1,474 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * HMM driver to manage page migration between normal and secure
+ * memory.
+ *
+ * Based on Jérôme Glisse's HMM dummy driver.
+ *
+ * Copyright 2018 Bharata B Rao, IBM Corp. <bharata@linux.ibm.com>
+ */
+
+/*
+ * A pseries guest can be run as a secure guest on Ultravisor-enabled
+ * POWER platforms. On such platforms, this driver will be used to manage
+ * the movement of guest pages between the normal memory managed by
+ * hypervisor (HV) and secure memory managed by Ultravisor (UV).
+ *
+ * Private ZONE_DEVICE memory equal to the amount of secure memory
+ * available in the platform for running secure guests is created
+ * via a HMM device. The movement of pages between normal and secure
+ * memory is done by ->alloc_and_copy() callback routine of migrate_vma().
+ *
+ * The page-in or page-out requests from UV will come to HV as hcalls and
+ * HV will call back into UV via uvcalls to satisfy these page requests.
+ *
+ * For each page that gets moved into secure memory, a HMM PFN is used
+ * on the HV side and HMM migration PTE corresponding to that PFN would be
+ * populated in the QEMU page tables.
+ */
+
+#include <linux/hmm.h>
+#include <linux/kvm_host.h>
+#include <linux/sched/mm.h>
+#include <asm/ucall-api.h>
+
+struct kvmppc_hmm_device {
+	struct hmm_device *device;
+	struct hmm_devmem *devmem;
+	unsigned long *pfn_bitmap;
+};
+
+static struct kvmppc_hmm_device kvmppc_hmm;
+spinlock_t kvmppc_hmm_lock;
+
+struct kvmppc_hmm_page_pvt {
+	unsigned long *rmap;
+	unsigned int lpid;
+	unsigned long gpa;
+};
+
+struct kvmppc_hmm_migrate_args {
+	unsigned long *rmap;
+	unsigned int lpid;
+	unsigned long gpa;
+	unsigned long page_shift;
+};
+
+#define KVMPPC_PFN_HMM		(0x1ULL << 61)
+
+static inline bool kvmppc_is_hmm_pfn(unsigned long pfn)
+{
+	return !!(pfn & KVMPPC_PFN_HMM);
+}
+
+void kvmppc_hmm_release_pfns(struct kvm_memory_slot *free)
+{
+	int i;
+
+	for (i = 0; i < free->npages; i++) {
+		unsigned long *rmap = &free->arch.rmap[i];
+
+		if (kvmppc_is_hmm_pfn(*rmap))
+			put_page(pfn_to_page(*rmap & ~KVMPPC_PFN_HMM));
+	}
+}
+
+/*
+ * Get a free HMM PFN from the pool
+ *
+ * Called when a normal page is moved to secure memory (UV_PAGE_IN). HMM
+ * PFN will be used to keep track of the secure page on HV side.
+ */
+/*
+ * TODO: In this and subsequent functions, we pass around and access
+ * individual elements of kvm_memory_slot->arch.rmap[] without any
+ * protection. Figure out the safe way to access this.
+ */
+static struct page *kvmppc_hmm_get_page(unsigned long *rmap,
+					unsigned long gpa, unsigned int lpid)
+{
+	struct page *dpage = NULL;
+	unsigned long bit, hmm_pfn;
+	unsigned long nr_pfns = kvmppc_hmm.devmem->pfn_last -
+				kvmppc_hmm.devmem->pfn_first;
+	unsigned long flags;
+	struct kvmppc_hmm_page_pvt *pvt;
+
+	if (kvmppc_is_hmm_pfn(*rmap))
+		return NULL;
+
+	spin_lock_irqsave(&kvmppc_hmm_lock, flags);
+	bit = find_first_zero_bit(kvmppc_hmm.pfn_bitmap, nr_pfns);
+	if (bit >= nr_pfns)
+		goto out;
+
+	bitmap_set(kvmppc_hmm.pfn_bitmap, bit, 1);
+	hmm_pfn = bit + kvmppc_hmm.devmem->pfn_first;
+	dpage = pfn_to_page(hmm_pfn);
+
+	if (!trylock_page(dpage))
+		goto out_clear;
+
+	*rmap = hmm_pfn | KVMPPC_PFN_HMM;
+	pvt = kzalloc(sizeof(*pvt), GFP_ATOMIC);
+	if (!pvt)
+		goto out_unlock;
+	pvt->rmap = rmap;
+	pvt->gpa = gpa;
+	pvt->lpid = lpid;
+	hmm_devmem_page_set_drvdata(dpage, (unsigned long)pvt);
+	spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+
+	get_page(dpage);
+	return dpage;
+
+out_unlock:
+	unlock_page(dpage);
+out_clear:
+	bitmap_clear(kvmppc_hmm.pfn_bitmap,
+		     hmm_pfn - kvmppc_hmm.devmem->pfn_first, 1);
+out:
+	spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+	return NULL;
+}
+
+/*
+ * Release the HMM PFN back to the pool
+ *
+ * Called when secure page becomes a normal page during UV_PAGE_OUT.
+ */
+static void kvmppc_hmm_put_page(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long flags;
+	struct kvmppc_hmm_page_pvt *pvt;
+
+	spin_lock_irqsave(&kvmppc_hmm_lock, flags);
+	pvt = (struct kvmppc_hmm_page_pvt *)hmm_devmem_page_get_drvdata(page);
+	hmm_devmem_page_set_drvdata(page, 0);
+
+	bitmap_clear(kvmppc_hmm.pfn_bitmap,
+		     pfn - kvmppc_hmm.devmem->pfn_first, 1);
+	*(pvt->rmap) = 0;
+	spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+	kfree(pvt);
+}
+
+/*
+ * migrate_vma() callback to move page from normal memory to secure memory.
+ *
+ * We don't capture the return value of uv_page_in() here because when
+ * UV asks for a page and then fails to copy it over, we don't care.
+ */
+static void
+kvmppc_hmm_migrate_alloc_and_copy(struct vm_area_struct *vma,
+				  const unsigned long *src_pfn,
+				  unsigned long *dst_pfn,
+				  unsigned long start,
+				  unsigned long end,
+				  void *private)
+{
+	struct kvmppc_hmm_migrate_args *args = private;
+	struct page *spage = migrate_pfn_to_page(*src_pfn);
+	unsigned long pfn = *src_pfn >> MIGRATE_PFN_SHIFT;
+	struct page *dpage;
+
+	*dst_pfn = 0;
+	if (!(*src_pfn & MIGRATE_PFN_MIGRATE))
+		return;
+
+	dpage = kvmppc_hmm_get_page(args->rmap, args->gpa, args->lpid);
+	if (!dpage)
+		return;
+
+	if (spage)
+		uv_page_in(args->lpid, pfn << args->page_shift,
+			   args->gpa, 0, args->page_shift);
+
+	*dst_pfn = migrate_pfn(page_to_pfn(dpage)) |
+		    MIGRATE_PFN_DEVICE | MIGRATE_PFN_LOCKED;
+}
+
+/*
+ * This migrate_vma() callback is typically used to updated device
+ * page tables after successful migration. We have nothing to do here.
+ *
+ * Also as we don't care if UV successfully copied over the page in
+ * kvmppc_hmm_migrate_alloc_and_copy(), we don't bother to check
+ * dst_pfn for any errors here.
+ */
+static void
+kvmppc_hmm_migrate_finalize_and_map(struct vm_area_struct *vma,
+				    const unsigned long *src_pfn,
+				    const unsigned long *dst_pfn,
+				    unsigned long start,
+				    unsigned long end,
+				    void *private)
+{
+}
+
+static const struct migrate_vma_ops kvmppc_hmm_migrate_ops = {
+	.alloc_and_copy = kvmppc_hmm_migrate_alloc_and_copy,
+	.finalize_and_map = kvmppc_hmm_migrate_finalize_and_map,
+};
+
+/*
+ * Move page from normal memory to secure memory.
+ */
+unsigned long
+kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
+		     unsigned long flags, unsigned long page_shift)
+{
+	unsigned long addr, end;
+	unsigned long src_pfn, dst_pfn;
+	struct kvmppc_hmm_migrate_args args;
+	struct vm_area_struct *vma;
+	int srcu_idx;
+	unsigned long gfn = gpa >> page_shift;
+	struct kvm_memory_slot *slot;
+	unsigned long *rmap;
+	int ret = H_SUCCESS;
+
+	if (page_shift != PAGE_SHIFT)
+		return H_P3;
+
+	srcu_idx = srcu_read_lock(&kvm->srcu);
+	slot = gfn_to_memslot(kvm, gfn);
+	rmap = &slot->arch.rmap[gfn - slot->base_gfn];
+	addr = gfn_to_hva(kvm, gpa >> page_shift);
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	if (kvm_is_error_hva(addr))
+		return H_PARAMETER;
+
+	end = addr + (1UL << page_shift);
+
+	if (flags)
+		return H_P2;
+
+	args.rmap = rmap;
+	args.lpid = kvm->arch.lpid;
+	args.gpa = gpa;
+	args.page_shift = page_shift;
+
+	down_read(&kvm->mm->mmap_sem);
+	vma = find_vma_intersection(kvm->mm, addr, end);
+	if (!vma || vma->vm_start > addr || vma->vm_end < end) {
+		ret = H_PARAMETER;
+		goto out;
+	}
+	ret = migrate_vma(&kvmppc_hmm_migrate_ops, vma, addr, end,
+			  &src_pfn, &dst_pfn, &args);
+	if (ret < 0)
+		ret = H_PARAMETER;
+out:
+	up_read(&kvm->mm->mmap_sem);
+	return ret;
+}
+
+static void
+kvmppc_hmm_fault_migrate_alloc_and_copy(struct vm_area_struct *vma,
+					const unsigned long *src_pfn,
+					unsigned long *dst_pfn,
+					unsigned long start,
+					unsigned long end,
+					void *private)
+{
+	struct page *dpage, *spage;
+	struct kvmppc_hmm_page_pvt *pvt;
+	unsigned long pfn;
+	int ret = U_SUCCESS;
+
+	*dst_pfn = MIGRATE_PFN_ERROR;
+	spage = migrate_pfn_to_page(*src_pfn);
+	if (!spage || !(*src_pfn & MIGRATE_PFN_MIGRATE))
+		return;
+	if (!is_zone_device_page(spage))
+		return;
+	dpage = hmm_vma_alloc_locked_page(vma, start);
+	if (!dpage)
+		return;
+	pvt = (struct kvmppc_hmm_page_pvt *)
+	       hmm_devmem_page_get_drvdata(spage);
+
+	pfn = page_to_pfn(dpage);
+	ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
+			  pvt->gpa, 0, PAGE_SHIFT);
+	if (ret == U_SUCCESS)
+		*dst_pfn = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
+}
+
+/*
+ * This migrate_vma() callback is typically used to updated device
+ * page tables after successful migration. We have nothing to do here.
+ */
+static void
+kvmppc_hmm_fault_migrate_finalize_and_map(struct vm_area_struct *vma,
+					  const unsigned long *src_pfn,
+					  const unsigned long *dst_pfn,
+					  unsigned long start,
+					  unsigned long end,
+					  void *private)
+{
+}
+
+static const struct migrate_vma_ops kvmppc_hmm_fault_migrate_ops = {
+	.alloc_and_copy = kvmppc_hmm_fault_migrate_alloc_and_copy,
+	.finalize_and_map = kvmppc_hmm_fault_migrate_finalize_and_map,
+};
+
+/*
+ * Fault handler callback when HV touches any page that has been
+ * moved to secure memory, we ask UV to give back the page by
+ * issuing a UV_PAGE_OUT uvcall.
+ */
+static int kvmppc_hmm_devmem_fault(struct hmm_devmem *devmem,
+				   struct vm_area_struct *vma,
+				   unsigned long addr,
+				   const struct page *page,
+				   unsigned int flags,
+				   pmd_t *pmdp)
+{
+	unsigned long end = addr + PAGE_SIZE;
+	unsigned long src_pfn, dst_pfn = 0;
+
+	if (migrate_vma(&kvmppc_hmm_fault_migrate_ops, vma, addr, end,
+			&src_pfn, &dst_pfn, NULL))
+		return VM_FAULT_SIGBUS;
+	if (dst_pfn == MIGRATE_PFN_ERROR)
+		return VM_FAULT_SIGBUS;
+	return 0;
+}
+
+static void kvmppc_hmm_devmem_free(struct hmm_devmem *devmem,
+				   struct page *page)
+{
+	kvmppc_hmm_put_page(page);
+}
+
+static const struct hmm_devmem_ops kvmppc_hmm_devmem_ops = {
+	.free = kvmppc_hmm_devmem_free,
+	.fault = kvmppc_hmm_devmem_fault,
+};
+
+/*
+ * Move page from secure memory to normal memory.
+ */
+unsigned long
+kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gpa,
+		      unsigned long flags, unsigned long page_shift)
+{
+	unsigned long addr, end;
+	struct vm_area_struct *vma;
+	unsigned long src_pfn, dst_pfn = 0;
+	int srcu_idx;
+	int ret = H_SUCCESS;
+
+	if (page_shift != PAGE_SHIFT)
+		return H_P3;
+
+	if (flags)
+		return H_P2;
+
+	srcu_idx = srcu_read_lock(&kvm->srcu);
+	addr = gfn_to_hva(kvm, gpa >> page_shift);
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	if (kvm_is_error_hva(addr))
+		return H_PARAMETER;
+
+	end = addr + (1UL << page_shift);
+
+	down_read(&kvm->mm->mmap_sem);
+	vma = find_vma_intersection(kvm->mm, addr, end);
+	if (!vma || vma->vm_start > addr || vma->vm_end < end) {
+		ret = H_PARAMETER;
+		goto out;
+	}
+	ret = migrate_vma(&kvmppc_hmm_fault_migrate_ops, vma, addr, end,
+			  &src_pfn, &dst_pfn, NULL);
+	if (ret < 0)
+		ret = H_PARAMETER;
+out:
+	up_read(&kvm->mm->mmap_sem);
+	return ret;
+}
+
+static u64 kvmppc_get_secmem_size(void)
+{
+	struct device_node *np;
+	int i, len;
+	const __be32 *prop;
+	u64 size = 0;
+
+	np = of_find_node_by_path("/ibm,ultravisor/ibm,uv-firmware");
+	if (!np)
+		goto out;
+
+	prop = of_get_property(np, "secure-memory-ranges", &len);
+	if (!prop)
+		goto out_put;
+
+	for (i = 0; i < len / (sizeof(*prop) * 4); i++)
+		size += of_read_number(prop + (i * 4) + 2, 2);
+
+out_put:
+	of_node_put(np);
+out:
+	return size;
+}
+
+static int kvmppc_hmm_pages_init(void)
+{
+	unsigned long nr_pfns = kvmppc_hmm.devmem->pfn_last -
+				kvmppc_hmm.devmem->pfn_first;
+
+	kvmppc_hmm.pfn_bitmap = kcalloc(BITS_TO_LONGS(nr_pfns),
+					 sizeof(unsigned long), GFP_KERNEL);
+	if (!kvmppc_hmm.pfn_bitmap)
+		return -ENOMEM;
+
+	spin_lock_init(&kvmppc_hmm_lock);
+
+	return 0;
+}
+
+int kvmppc_hmm_init(void)
+{
+	int ret = 0;
+	unsigned long size;
+
+	size = kvmppc_get_secmem_size();
+	if (!size) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	kvmppc_hmm.device = hmm_device_new(NULL);
+	if (IS_ERR(kvmppc_hmm.device)) {
+		ret = PTR_ERR(kvmppc_hmm.device);
+		goto out;
+	}
+
+	kvmppc_hmm.devmem = hmm_devmem_add(&kvmppc_hmm_devmem_ops,
+					   &kvmppc_hmm.device->device, size);
+	if (IS_ERR(kvmppc_hmm.devmem)) {
+		ret = PTR_ERR(kvmppc_hmm.devmem);
+		goto out_device;
+	}
+	ret = kvmppc_hmm_pages_init();
+	if (ret < 0)
+		goto out_device;
+
+	pr_info("KVMPPC-HMM: Secure Memory size %lx\n", size);
+	return ret;
+
+out_device:
+	hmm_device_put(kvmppc_hmm.device);
+out:
+	return ret;
+}
+
+void kvmppc_hmm_free(void)
+{
+	kfree(kvmppc_hmm.pfn_bitmap);
+	hmm_device_put(kvmppc_hmm.device);
+}
-- 
2.17.1

