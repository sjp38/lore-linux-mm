Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA089C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7111820665
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7111820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64F2B8E004A; Tue,  9 Jul 2019 06:26:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D76C8E0032; Tue,  9 Jul 2019 06:26:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49ED98E004A; Tue,  9 Jul 2019 06:26:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC728E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:26:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h27so12157066pfq.17
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:26:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=zyubi7GnPhOxo4xY4ytnimceoC8yOgFnjeIpW6yeXII=;
        b=iJrskrKUs4gH80F6rnN2flhxRMRutUeopDPZi6IhA+R+UBLlXAwVQaGm2QgU3uDBBH
         DTfyqcnA68SacQ8x8FMTfLl6GRhLMh8R7pBopv8Su3Dry92Z0MSerMnuZbho611BRayp
         3HXYc76ULtsnPbHmrSiqPDkcdUmQasNOq/PVtx/mKpuRQiPhbO8NB2fjMwJ4y+RU0aup
         u0bQQVKrj75XXdIE7dEsRnkLc7+dxykHlZYUvLVFqJ2/Z9xS4pTpWm/hxW4nPsN97Aih
         zw4ENh9jnG5cLSqPqLZRl4lfUY00ealEqOHOgveYIM+2ver2FaPwusMcBkxKz/IzBwDK
         5T/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUZ+N1wZ6ts9mNg3vRMOC/snu/XKTKJ801Iabwf9NLmBmEHr+p9
	wHC79kdRkIH7x76z7tDaykCxYxJ7w+f2W3U6UcxGgabH/4q5gi6iXYwwQeZZxISprlznY4Cu7f4
	EZTM8lb3S2TDAYjT2Hm66/4Hi0w17+btGHoh6HnH5iKoH4KUshLeiApEPB5hzDTouCA==
X-Received: by 2002:a63:4185:: with SMTP id o127mr1484592pga.82.1562667970558;
        Tue, 09 Jul 2019 03:26:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLp2tC4NYh/5BSfQVAEWxn4SMmTtkQq+MKFFoOazbhAXQKoMhJtA2LsZ72jgDuNagDJmzm
X-Received: by 2002:a63:4185:: with SMTP id o127mr1484522pga.82.1562667969600;
        Tue, 09 Jul 2019 03:26:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562667969; cv=none;
        d=google.com; s=arc-20160816;
        b=STZUUMfE0UPGnVACptcf5K4nOX6pXNeZHxPBstvvvgmfKD7Gc52CmkiKDXTxa3RCvr
         5eJMF8aj/4kLXoXWxLJ9/QEbUpu4Y9poz8C8Hij+FgTBIj4nqWL2WKy9t1OsSG3dXJ8C
         qFWBNNL9ij2pJyBy1rqh5aAZov01kl26YOgsXW5j5ppMHBpvsyyNSImjgjix/FQcNHOH
         G25fDbaxTJecf95Aroh25+ivn/zVP9dj9fgy8GnD6YwMXlbpmkqvO9bTxSCn+rrBF5wL
         CmbTbS+5uFeYy9hC88BG9cNG3kNI9Upb2H0wkKSM8YLOpSk0vDqcT1K4SZXGS4wh0Ltr
         A57Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=zyubi7GnPhOxo4xY4ytnimceoC8yOgFnjeIpW6yeXII=;
        b=Ep6LENWCfAnoz2g8CYk5aD5V2qH3HIG7PjAf/LIESBDycEH8lFnd4H3CeOW8OEXVfY
         QMDcz8dWDt3wGitc9DJd+K0BZ/e/wN7zxmR+2ERc83YvKq6pUXXwVWxIY7R8Ty0CxPpZ
         WqmpWgDoxyeK6hoNdWvou5vQYt4P7YJORkIZk+g6a+qtkmLwG0TYtBRidU/5xrfF7RlS
         vGIq1mdepM2KmLImLFmBF3x7MjhbYLEwN38yRkDNe8NH+nMMZ9uMrZ++CGcCMDWk4YZW
         /2/+dWStZgdZpOpEdVngn89UVyU2Gqn4IK1gbj45Xawbo0mYQ89Ui7NxyCMum7VClJ2A
         1FuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s19si4625629pgm.291.2019.07.09.03.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:26:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69AMZbg019725
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:26:09 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tmr3ujuby-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:26:08 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:26:06 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:26:03 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69AQ2NU45154392
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:26:02 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1817FAE04D;
	Tue,  9 Jul 2019 10:26:02 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1CAA4AE056;
	Tue,  9 Jul 2019 10:26:00 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.81.51])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 10:25:59 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>,
        Paul Mackerras <paulus@ozlabs.org>
Subject: [PATCH v5 3/7] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
Date: Tue,  9 Jul 2019 15:55:41 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190709102545.9187-1-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19070910-0012-0000-0000-000003309D12
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-0013-0000-0000-0000216A01A8
Message-Id: <20190709102545.9187-4-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090127
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

H_SVM_INIT_START: Initiate securing a VM
H_SVM_INIT_DONE: Conclude securing a VM

As part of H_SVM_INIT_START, register all existing memslots with
the UV. H_SVM_INIT_DONE call by UV informs HV that transition of
the guest to secure mode is complete.

These two states (transition to secure mode STARTED and transition
to secure mode COMPLETED) are recorded in kvm->arch.secure_guest.
Setting these states will cause the assembly code that enters the
guest to call the UV_RETURN ucall instead of trying to enter the
guest directly.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
Acked-by: Paul Mackerras <paulus@ozlabs.org>
---
 arch/powerpc/include/asm/hvcall.h         |  2 ++
 arch/powerpc/include/asm/kvm_book3s_hmm.h | 12 ++++++++
 arch/powerpc/include/asm/kvm_host.h       |  4 +++
 arch/powerpc/include/asm/ultravisor-api.h |  1 +
 arch/powerpc/include/asm/ultravisor.h     |  9 ++++++
 arch/powerpc/kvm/book3s_hv.c              |  7 +++++
 arch/powerpc/kvm/book3s_hv_hmm.c          | 34 +++++++++++++++++++++++
 7 files changed, 69 insertions(+)

diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm/hvcall.h
index 05b8536f6653..fa7695928e30 100644
--- a/arch/powerpc/include/asm/hvcall.h
+++ b/arch/powerpc/include/asm/hvcall.h
@@ -343,6 +343,8 @@
 /* Platform-specific hcalls used by the Ultravisor */
 #define H_SVM_PAGE_IN		0xEF00
 #define H_SVM_PAGE_OUT		0xEF04
+#define H_SVM_INIT_START	0xEF08
+#define H_SVM_INIT_DONE		0xEF0C
 
 /* Values for 2nd argument to H_SET_MODE */
 #define H_SET_MODE_RESOURCE_SET_CIABR		1
diff --git a/arch/powerpc/include/asm/kvm_book3s_hmm.h b/arch/powerpc/include/asm/kvm_book3s_hmm.h
index 21f3de5f2acb..8c7aacabb2e0 100644
--- a/arch/powerpc/include/asm/kvm_book3s_hmm.h
+++ b/arch/powerpc/include/asm/kvm_book3s_hmm.h
@@ -11,6 +11,8 @@ extern unsigned long kvmppc_h_svm_page_out(struct kvm *kvm,
 					  unsigned long gra,
 					  unsigned long flags,
 					  unsigned long page_shift);
+extern unsigned long kvmppc_h_svm_init_start(struct kvm *kvm);
+extern unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
 #else
 static inline unsigned long
 kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gra,
@@ -25,5 +27,15 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gra,
 {
 	return H_UNSUPPORTED;
 }
+
+static inline unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
+{
+	return H_UNSUPPORTED;
+}
+
+static inline unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
+{
+	return H_UNSUPPORTED;
+}
 #endif /* CONFIG_PPC_UV */
 #endif /* __POWERPC_KVM_PPC_HMM_H__ */
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index ac1a101beb07..0c49c3401c63 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -272,6 +272,10 @@ struct kvm_hpt_info {
 
 struct kvm_resize_hpt;
 
+/* Flag values for kvm_arch.secure_guest */
+#define KVMPPC_SECURE_INIT_START	0x1 /* H_SVM_INIT_START has been called */
+#define KVMPPC_SECURE_INIT_DONE		0x2 /* H_SVM_INIT_DONE completed */
+
 struct kvm_arch {
 	unsigned int lpid;
 	unsigned int smt_mode;		/* # vcpus per virtual core */
diff --git a/arch/powerpc/include/asm/ultravisor-api.h b/arch/powerpc/include/asm/ultravisor-api.h
index f1c5800ac705..07b7d638e7af 100644
--- a/arch/powerpc/include/asm/ultravisor-api.h
+++ b/arch/powerpc/include/asm/ultravisor-api.h
@@ -20,6 +20,7 @@
 /* opcodes */
 #define UV_WRITE_PATE			0xF104
 #define UV_RETURN			0xF11C
+#define UV_REGISTER_MEM_SLOT		0xF120
 #define UV_PAGE_IN			0xF128
 #define UV_PAGE_OUT			0xF12C
 
diff --git a/arch/powerpc/include/asm/ultravisor.h b/arch/powerpc/include/asm/ultravisor.h
index 16f8e0e8ec3f..b46042f1aa8f 100644
--- a/arch/powerpc/include/asm/ultravisor.h
+++ b/arch/powerpc/include/asm/ultravisor.h
@@ -61,6 +61,15 @@ static inline int uv_page_out(u64 lpid, u64 dst_ra, u64 src_gpa, u64 flags,
 	return ucall(UV_PAGE_OUT, retbuf, lpid, dst_ra, src_gpa, flags,
 		     page_shift);
 }
+
+static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 size,
+				       u64 flags, u64 slotid)
+{
+	unsigned long retbuf[UCALL_BUFSIZE];
+
+	return ucall(UV_REGISTER_MEM_SLOT, retbuf, lpid, start_gpa,
+		     size, flags, slotid);
+}
 #endif /* !__ASSEMBLY__ */
 
 #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 8ee66aa0da58..b8f801d00ad4 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1097,6 +1097,13 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
 					    kvmppc_get_gpr(vcpu, 5),
 					    kvmppc_get_gpr(vcpu, 6));
 		break;
+	case H_SVM_INIT_START:
+		ret = kvmppc_h_svm_init_start(vcpu->kvm);
+		break;
+	case H_SVM_INIT_DONE:
+		ret = kvmppc_h_svm_init_done(vcpu->kvm);
+		break;
+
 	default:
 		return RESUME_HOST;
 	}
diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
index 36562b382e70..55bab9c4e60a 100644
--- a/arch/powerpc/kvm/book3s_hv_hmm.c
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -62,6 +62,40 @@ struct kvmppc_hmm_migrate_args {
 	unsigned long page_shift;
 };
 
+unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
+{
+	struct kvm_memslots *slots;
+	struct kvm_memory_slot *memslot;
+	int ret = H_SUCCESS;
+	int srcu_idx;
+
+	srcu_idx = srcu_read_lock(&kvm->srcu);
+	slots = kvm_memslots(kvm);
+	kvm_for_each_memslot(memslot, slots) {
+		ret = uv_register_mem_slot(kvm->arch.lpid,
+					   memslot->base_gfn << PAGE_SHIFT,
+					   memslot->npages * PAGE_SIZE,
+					   0, memslot->id);
+		if (ret < 0) {
+			ret = H_PARAMETER;
+			goto out;
+		}
+	}
+	kvm->arch.secure_guest |= KVMPPC_SECURE_INIT_START;
+out:
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	return ret;
+}
+
+unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
+{
+	if (!(kvm->arch.secure_guest & KVMPPC_SECURE_INIT_START))
+		return H_UNSUPPORTED;
+
+	kvm->arch.secure_guest |= KVMPPC_SECURE_INIT_DONE;
+	return H_SUCCESS;
+}
+
 /*
  * Bits 60:56 in the rmap entry will be used to identify the
  * different uses/functions of rmap. This definition with move
-- 
2.21.0

