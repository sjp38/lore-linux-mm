Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAEDAC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EA2720C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EA2720C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07C9E6B0010; Fri,  9 Aug 2019 04:41:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 005BE6B0266; Fri,  9 Aug 2019 04:41:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC0786B0269; Fri,  9 Aug 2019 04:41:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A54CE6B0010
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:41:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so60930708pfo.22
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:41:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=Py6ja5kQrd5Wh0Vhg1w/rX2YMsO9pLLJNn85o7CuwKo=;
        b=aA18Rbs9ZzZ4wIX0EeALnonKcvPkMLpqbbiUrlXDcqmKJLkCJFqUd6RnE+N15bsGUl
         WBr9LH7hUtq4n0x2oC/IAmFDvaNxMXpy+Beiri21keDilP6s39q35MnWtHBMSRE8oCqK
         vtA7/8TqEwAkaKc23YXOg/dEPzYBU0CY8FzCCnrW/vryPPtE9xzwYQrB1I6i1P0mh8du
         PhmtuBIRu6GAnzW2lBU4BF4a5PQq5DdWhATG5Pl78yCBvwfiGVVtV/Bbtf7FCr/aORCz
         bxv+eaZEc78J8D9y4yLrf0XhgZx96Uw5X0wc3DCG0W8KnXacRXbWyZkLMQHJVgTvLepz
         IHbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUHfHjUsBS/Mt2D6dYoKkdQiG0bZOCrmXO9kGdrDvUzFDwDJc9U
	P26E6erN2IRY7+CQa/3Vze6nxSJ9Yy0eUwgC/lebECvxFS0qo19yVuQXAlPNXA8j0gfbIuRoqUs
	fdIxjlhmJUUv1NbAOsa7lKx9zox+gB+kMwwmIE0iR+PQzF6YbRUmEVjKp+Pwbx5iP4w==
X-Received: by 2002:a63:6947:: with SMTP id e68mr16750958pgc.60.1565340092219;
        Fri, 09 Aug 2019 01:41:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQeYOQJS20r9qAfXpq82PWInQL8X6C/vw5eatsnfbreg6GJ4Lw6WvXCZ/UGdx0FlLS+Te0
X-Received: by 2002:a63:6947:: with SMTP id e68mr16750909pgc.60.1565340091126;
        Fri, 09 Aug 2019 01:41:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565340091; cv=none;
        d=google.com; s=arc-20160816;
        b=sVdfiwV2s8Kqsntn6I2vYwm7kVqqg52xWV9/glEzJ+iQIP0ZFkE42AmJ0ho+E/PnOz
         VIK8d8TKVH75s6RpJZLeM5DcsRWkXo06O+H1C6v/tgWwqlVNvAndmplvGvPMm+wtgtHj
         f7cUZTnga7/O/l20xb3FruJtXCvasDf8MOyGtkl46Oza3Fj55G5SMIcnFkiKReoW6RLX
         kic4F1fmfCCTgopVmxgbQAzlRLNtqaWdcHb2bnl/0IJS40gTdlqnDbBWsdieL2e77IGD
         MymipIQuo/ow7z6Icw/DDrcPWCeo+QPvuDgwvIcXIkIBYipBCHHn37WFmB8BXega8MWI
         qTyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=Py6ja5kQrd5Wh0Vhg1w/rX2YMsO9pLLJNn85o7CuwKo=;
        b=GyeOUj/letwUsIwssMEykiwGo52xVIVWHHu3yiqQ9mGo7Sofff/ybrTRtFIfHCa+p7
         QEIszaYawQ4TAp5UUImD6Or1tTx0QTL0BMufwQ75LYr+/xTljiAN6RNWcST3bfS8FIcF
         fIfT1fK2grUz1rZjiKDwZbgB+0UamBJSPsModesYZuivPyU9Nl+bTkq3IvkIe1cizBb6
         GciYVDcGsuS7qBCkvdbSU7tPEBN7hV9/TAGx5hJzwpUZiBI+Tvz114QnvMGbEvWqOsUg
         +APw3uepZbGI0Xq+Src4Rur7BxZQZ/PlgCellhZeX4evCtczT/H2RIQZFywVuNnkg4xY
         9GkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b8si47119369pgn.56.2019.08.09.01.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:41:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x798bdUv136827
	for <linux-mm@kvack.org>; Fri, 9 Aug 2019 04:41:30 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u92upeexs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:41:30 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 9 Aug 2019 09:41:27 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 9 Aug 2019 09:41:25 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x798fN4M41091198
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 08:41:23 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BC1B0A4065;
	Fri,  9 Aug 2019 08:41:23 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A1344A4054;
	Fri,  9 Aug 2019 08:41:21 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.95.61])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 08:41:21 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>,
        Paul Mackerras <paulus@ozlabs.org>
Subject: [PATCH v6 3/7] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
Date: Fri,  9 Aug 2019 14:11:04 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190809084108.30343-1-bharata@linux.ibm.com>
References: <20190809084108.30343-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19080908-0028-0000-0000-0000038DA5B0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080908-0029-0000-0000-0000244FAAD1
Message-Id: <20190809084108.30343-4-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090089
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
 arch/powerpc/include/asm/hvcall.h          |  2 ++
 arch/powerpc/include/asm/kvm_book3s_devm.h | 12 ++++++++
 arch/powerpc/include/asm/kvm_host.h        |  4 +++
 arch/powerpc/include/asm/ultravisor-api.h  |  1 +
 arch/powerpc/include/asm/ultravisor.h      |  7 +++++
 arch/powerpc/kvm/book3s_hv.c               |  7 +++++
 arch/powerpc/kvm/book3s_hv_devm.c          | 34 ++++++++++++++++++++++
 7 files changed, 67 insertions(+)

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
diff --git a/arch/powerpc/include/asm/kvm_book3s_devm.h b/arch/powerpc/include/asm/kvm_book3s_devm.h
index 21f3de5f2acb..8c7aacabb2e0 100644
--- a/arch/powerpc/include/asm/kvm_book3s_devm.h
+++ b/arch/powerpc/include/asm/kvm_book3s_devm.h
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
index 86bbe607ad7e..1827c22909cd 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -261,6 +261,10 @@ struct kvm_hpt_info {
 
 struct kvm_resize_hpt;
 
+/* Flag values for kvm_arch.secure_guest */
+#define KVMPPC_SECURE_INIT_START	0x1 /* H_SVM_INIT_START has been called */
+#define KVMPPC_SECURE_INIT_DONE		0x2 /* H_SVM_INIT_DONE completed */
+
 struct kvm_arch {
 	unsigned int lpid;
 	unsigned int smt_mode;		/* # vcpus per virtual core */
diff --git a/arch/powerpc/include/asm/ultravisor-api.h b/arch/powerpc/include/asm/ultravisor-api.h
index 1cd1f595fd81..c578d9b13a56 100644
--- a/arch/powerpc/include/asm/ultravisor-api.h
+++ b/arch/powerpc/include/asm/ultravisor-api.h
@@ -25,6 +25,7 @@
 /* opcodes */
 #define UV_WRITE_PATE			0xF104
 #define UV_RETURN			0xF11C
+#define UV_REGISTER_MEM_SLOT		0xF120
 #define UV_PAGE_IN			0xF128
 #define UV_PAGE_OUT			0xF12C
 
diff --git a/arch/powerpc/include/asm/ultravisor.h b/arch/powerpc/include/asm/ultravisor.h
index d668a59e099b..8a722c575c56 100644
--- a/arch/powerpc/include/asm/ultravisor.h
+++ b/arch/powerpc/include/asm/ultravisor.h
@@ -33,4 +33,11 @@ static inline int uv_page_out(u64 lpid, u64 dst_ra, u64 src_gpa, u64 flags,
 			    page_shift);
 }
 
+static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 size,
+				       u64 flags, u64 slotid)
+{
+	return ucall_norets(UV_REGISTER_MEM_SLOT, lpid, start_gpa,
+			    size, flags, slotid);
+}
+
 #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 00b43ee8b693..33b8ebffbef0 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1089,6 +1089,13 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
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
diff --git a/arch/powerpc/kvm/book3s_hv_devm.c b/arch/powerpc/kvm/book3s_hv_devm.c
index c9189e58401d..c55bb5f57928 100644
--- a/arch/powerpc/kvm/book3s_hv_devm.c
+++ b/arch/powerpc/kvm/book3s_hv_devm.c
@@ -65,6 +65,40 @@ struct kvmppc_devm_copy_args {
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

