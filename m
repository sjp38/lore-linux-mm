Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 305B6C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:50:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA58A2070D
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:50:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA58A2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12F776B027F; Tue, 28 May 2019 02:49:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F35A86B027A; Tue, 28 May 2019 02:49:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CECB06B027F; Tue, 28 May 2019 02:49:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5C336B0279
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:58 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j127so17160398ywd.0
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:49:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=GlvOpkagGXZ9gtQl9pvZlhJubi4axmFCfg0lI+KwUAc=;
        b=SRS1+Qxz+aiVxaRW274bQJj1ZeXD2BM00ht2kWl6zh6aFW4Wdsje4cnnPXwNarw8WC
         g3uiPjjVpql3HJa92B2emH2QrE+pc1G5uK/N8212KjD+Tqtw3QYwV/TYR4wWyEo6hXhG
         uKozCzr3dKYQbWiTBlPbPZjtMd7BUGvMcZTfrfDTT1ctPC/3TSSRL3OADHOT8WFYv4T6
         NawpglMT4Bbkls0k1Gw9L9gVGqpg8bjnxPBaGTpeODVGwcTn1EBKovkqBoqYjuUZ3GEJ
         itWWCRLRPFATiZprYiLNjeoEP+9AfvDFppQpzfSCNY+ykDYMwQOu55tg1ewCOnPCU/lc
         LpzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUbk1Qq+9DF2fvbNB+VAJcrMtfiyRye9IjOGY9u2rp7+g/32eBI
	0H50Ll3lxCjWGSnIEkk60K63LW1fYVIuxxft2+i7MaqFUs05+HphAYBMk2BenBOJrti0BtHSe6W
	nTKicd+pmyGMJ9Zd9ZQHcZWlIwzBnbLQGx+8zVZaMYbk8w/lgTJ5JKTkUPTnAUIYzRw==
X-Received: by 2002:a81:3685:: with SMTP id d127mr10806525ywa.359.1559026198401;
        Mon, 27 May 2019 23:49:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwS9WhflKdA84XWffy4Fq0K2KBiXdSHiH7OjeCVlbN00p89ZUuNkGvdzylUanlUFdO7kK6T
X-Received: by 2002:a81:3685:: with SMTP id d127mr10806494ywa.359.1559026197219;
        Mon, 27 May 2019 23:49:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559026197; cv=none;
        d=google.com; s=arc-20160816;
        b=IhydV1fbsohqJcDDkoYBUzLHzLXcmkX59dnjkRU4sYIpjRdjILbmGKEi0rutT/Vh5f
         pXQNwfujzS+/Gg0rHkgCe9cuteq7OAREKeckZsJzaMKV7003C+49UujOzfJR9mPToP2N
         7c7VP0jbAOY1uwK/MPnTxdFsDeivb4BB7KdMxTaT0HHg32Bd0P42RoXIkrQKV08/0bgV
         7zYF3FYlOgN/pam+FaPXP6IIA4igDCjlHpZBSQFETJZKQfhEo+ty3oqPIZEefPAOkOpK
         E89Lldx683GIKPUNSWJb/5upmg+9uIi2z8Sxx61wyIx5GpFZD7rW+HDr7w8kDuPtqvXc
         qB2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=GlvOpkagGXZ9gtQl9pvZlhJubi4axmFCfg0lI+KwUAc=;
        b=heKnjvqpD3J8wq6GyX0+8lENfr8/JFBpYEsTIbDrjxYgO8nWP+D6bskrtVaoiWliZV
         ReRZhyz4fBfl6kDrWqVZtToXLhWRXpU2z6ayyGM57fY7q5ygV5L/Wc3FC5w87AOV1FZd
         BMru2L4VI0AOgp5fjk9odbgtQw+eiRYPy/D2cmepzs54i5GlnMwSPWv4zsJz6xk8PoBF
         zfFF+fB4HSdxmS1m18JtwOQ+5HyH91Gn/7la+b3bTppOnCF2X58kIEOxgiC5Aqd2EPSl
         WJZAhAOHE5n213a2KudlffRwcLfoj7P63qr6NZGAZlHkQuIy4KUQPSd+T7vEs6kgtD/w
         w4UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n5si4128104ywf.219.2019.05.27.23.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:49:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4S6bupP066385
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:56 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2srxuy2ry6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:56 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 28 May 2019 07:49:55 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 28 May 2019 07:49:52 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4S6noDp57671850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 06:49:50 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6B4D211C052;
	Tue, 28 May 2019 06:49:50 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B503811C04A;
	Tue, 28 May 2019 06:49:48 +0000 (GMT)
Received: from bharata.in.ibm.com (unknown [9.124.35.100])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 28 May 2019 06:49:48 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v4 3/6] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
Date: Tue, 28 May 2019 12:19:30 +0530
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190528064933.23119-1-bharata@linux.ibm.com>
References: <20190528064933.23119-1-bharata@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19052806-0012-0000-0000-000003201D34
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052806-0013-0000-0000-00002158E30A
Message-Id: <20190528064933.23119-4-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=846 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280045
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

H_SVM_INIT_START: Initiate securing a VM
H_SVM_INIT_DONE: Conclude securing a VM

As part of H_SVM_INIT_START register all existing memslots with the UV.
H_SVM_INIT_DONE call by UV informs HV that transition of the guest
to secure mode is complete.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
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
index 21f3de5f2acb..3e13dab7f690 100644
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
+static inine unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
+{
+	return H_UNSUPPORTED;
+}
+
+static inine unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
+{
+	return H_UNSUPPORTED;
+}
 #endif /* CONFIG_PPC_UV */
 #endif /* __POWERPC_KVM_PPC_HMM_H__ */
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index c0c9c3455ac4..845fd2a73506 100644
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
index 51c4e0b5d197..05b17f4351f4 100644
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
index 1e4c51799b43..9befa6fea8db 100644
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
index 2918616198de..3683e517541f 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1098,6 +1098,13 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
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
index 333829682f59..18fec814401d 100644
--- a/arch/powerpc/kvm/book3s_hv_hmm.c
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -55,6 +55,40 @@ struct kvmppc_hmm_migrate_args {
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
 #define KVMPPC_PFN_HMM		(0x1ULL << 61)
 
 static inline bool kvmppc_is_hmm_pfn(unsigned long pfn)
-- 
2.17.1

