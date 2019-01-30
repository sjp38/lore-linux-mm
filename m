Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F08AC282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE26620989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE26620989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81E338E0005; Wed, 30 Jan 2019 01:07:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A5428E0001; Wed, 30 Jan 2019 01:07:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F6C08E0005; Wed, 30 Jan 2019 01:07:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4DD8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:50 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o7so18866122pfi.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 22:07:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=dpE6+0R2JoBtwDMUcVmMpfwy76dq0y54KJMgBXiiw8I=;
        b=aMuMWA9CdvCgMloQmtRLfC6ADhqMJp7//zwqNRB2rBANGQiDLn08clkD8WjRw9Rl3t
         IjL966wLJAUcBGqcLdTqX7OSRmsid0GT/eoI7ScvLE2l2iCP/IUP6dysS4TCKNt+S41F
         jr5vGGmUn/DmNLI8mhyqmpLMZL6+P48DWF4nYx6rq6itRX9JlNP3mSehJ5MS0fm7m03n
         W8mhAJhdxam0cYHMmeHwmvJld6kWHcxe+iYma2eDjMFf9fluje1ldBf/7wU0RI8R5xly
         7zpUqbcqcGVAkmN1xoXLk66otSQw4Xwsx3P/sfUnI5JjnKvn0xC0bFcVNY8z4GtRJ3Ir
         zk6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukcpO5y3LUnZ8mPLpYJwM/PBOmdx/xnWNwM/lFqtltbbob/bip/x
	g0ev54WHoPE+eAunO4nNESghXEs2baS4HYj88kz6N3wBcN5ZjxO+VCEg1awe1qu5vFjM14XWs8I
	2i2+3bAyd8nNjJaDEFUjekXCj4F04+xm9ICigwjga51uxvv0jIMHuEy4mpHRnUQqRgA==
X-Received: by 2002:a63:cd11:: with SMTP id i17mr26605649pgg.345.1548828469767;
        Tue, 29 Jan 2019 22:07:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5tpR+s1toWEwfzApr/wYNdrZ0ID/2gs86E1Azb4zphAk4ySUaSKtyCf7L7125V+c0ACJ8n
X-Received: by 2002:a63:cd11:: with SMTP id i17mr26605612pgg.345.1548828468855;
        Tue, 29 Jan 2019 22:07:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548828468; cv=none;
        d=google.com; s=arc-20160816;
        b=iyMa+vnwGIvuy4F4wJ0TqPpTHiQyXFJyCho89eRdhyJ7nFndL2N9a8/lh0jrhyFl5m
         Ac5TQErMu2nqgSj31Z4ZsMlC/7dZj8Eaq1W6PNyS+meYV8HLt+E2tWaqebXrr3BkVy1O
         964ZLD8OlKDWla+fr0uZERd+QAwsU0QGMbf8JH5m7NIzGGYwsYe7qquDWda4SxdCkR5u
         s2uTHVIARpF4aidkQK/KL1vQodUCZF5On2aMSXx6mP6Wi5s6xqpLhyozLFa6jF4xsRvG
         fmXNqe8j65lT3kaTPVFhW2IuEG7bb8OOHdr61Hr1zdA02GQWJwtcRXxoJpU+VCIB1IcL
         b1tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=dpE6+0R2JoBtwDMUcVmMpfwy76dq0y54KJMgBXiiw8I=;
        b=ZRW9JMPlSVmCT7DTZ12KW/HHDHVILzA/Kgyw9i/urq9sPU7r+y7i5A7EQOeEeIPbZM
         wABUSZ08TSfaXQkhYKH1HAq5OrAqHQ7/GW92dwJu0ESKNOA600jSGK/FlEnh+yRl2ba8
         LbY86Fbzf9OCKypYkfXt5ojtDU6ylDhvaEsY4FDNxdQNVGXTmlYLgVZzDZYGxI2bldZO
         kA2WNBMSWDjzH9BqOq+5DUTlM7q7lITPa/p7WkGpkfYSd7TnEvcrD6BilaxKlGSQ+VQp
         mMFpd1st8LSlakYfvPBdnJj2c3a2KYEYGTU96Qyh+QAyuW/ygcON5MyqD9icDaqbXDU+
         S2dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b30si647294pla.285.2019.01.29.22.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 22:07:48 -0800 (PST)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U64MMv055380
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:48 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qb1k7hp9d-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:48 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 30 Jan 2019 06:07:45 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 30 Jan 2019 06:07:43 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0U67g6G59113698
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 30 Jan 2019 06:07:42 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DE9695204E;
	Wed, 30 Jan 2019 06:07:41 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.36.73])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id D649452059;
	Wed, 30 Jan 2019 06:07:39 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v3 3/4] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
Date: Wed, 30 Jan 2019 11:37:25 +0530
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190130060726.29958-1-bharata@linux.ibm.com>
References: <20190130060726.29958-1-bharata@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19013006-4275-0000-0000-000003079FD4
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013006-4276-0000-0000-00003815A45F
Message-Id: <20190130060726.29958-4-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=647 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901300046
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

H_SVM_INIT_START: Initiate securing a VM
H_SVM_INIT_DONE: Conclude securing a VM

During early guest init, these hcalls will be issued by UV.
As part of these hcalls, [un]register memslots with UV.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/hvcall.h           |  2 ++
 arch/powerpc/include/asm/kvm_book3s_hmm.h   | 12 ++++++++
 arch/powerpc/include/asm/ucall-api.h        |  9 ++++++
 arch/powerpc/include/uapi/asm/uapi_uvcall.h |  1 +
 arch/powerpc/kvm/book3s_hv.c                |  7 +++++
 arch/powerpc/kvm/book3s_hv_hmm.c            | 33 +++++++++++++++++++++
 6 files changed, 64 insertions(+)

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
index e61519c17485..af093f8b86cf 100644
--- a/arch/powerpc/include/asm/kvm_book3s_hmm.h
+++ b/arch/powerpc/include/asm/kvm_book3s_hmm.h
@@ -13,6 +13,8 @@ extern unsigned long kvmppc_h_svm_page_out(struct kvm *kvm,
 					  unsigned long gra,
 					  unsigned long flags,
 					  unsigned long page_shift);
+extern unsigned long kvmppc_h_svm_init_start(struct kvm *kvm);
+extern unsigned long kvmppc_h_svm_init_done(struct kvm *kvm);
 #else
 static inline unsigned long
 kvmppc_h_svm_page_in(struct kvm *kvm, unsigned int lpid,
@@ -29,5 +31,15 @@ kvmppc_h_svm_page_out(struct kvm *kvm, unsigned int lpid,
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
 #endif /* CONFIG_PPC_KVM_UV */
 #endif /* __POWERPC_KVM_PPC_HMM_H__ */
diff --git a/arch/powerpc/include/asm/ucall-api.h b/arch/powerpc/include/asm/ucall-api.h
index 6c3bddc97b55..d266670229cb 100644
--- a/arch/powerpc/include/asm/ucall-api.h
+++ b/arch/powerpc/include/asm/ucall-api.h
@@ -73,5 +73,14 @@ static inline int uv_page_out(u64 lpid, u64 dst_ra, u64 src_gpa, u64 flags,
 	return plpar_ucall(UV_PAGE_OUT, retbuf, lpid, dst_ra, src_gpa, flags,
 			   page_shift);
 }
+
+static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 size,
+				       u64 flags, u64 slotid)
+{
+	unsigned long retbuf[PLPAR_UCALL_BUFSIZE];
+
+	return plpar_ucall(UV_REGISTER_MEM_SLOT, retbuf, lpid, start_gpa,
+			   size, flags, slotid);
+}
 #endif	/* __ASSEMBLY__ */
 #endif	/* _ASM_POWERPC_UCALL_API_H */
diff --git a/arch/powerpc/include/uapi/asm/uapi_uvcall.h b/arch/powerpc/include/uapi/asm/uapi_uvcall.h
index 3a30820663a2..79a11a6ee436 100644
--- a/arch/powerpc/include/uapi/asm/uapi_uvcall.h
+++ b/arch/powerpc/include/uapi/asm/uapi_uvcall.h
@@ -12,6 +12,7 @@
 #define UV_RESTRICTED_SPR_WRITE 0xf108
 #define UV_RESTRICTED_SPR_READ 0xf10C
 #define UV_RETURN	0xf11C
+#define UV_REGISTER_MEM_SLOT    0xF120
 #define UV_PAGE_IN	0xF128
 #define UV_PAGE_OUT	0xF12C
 
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index e7edba1ec16a..1dfb42ac9626 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1017,6 +1017,13 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
 					    kvmppc_get_gpr(vcpu, 6),
 					    kvmppc_get_gpr(vcpu, 7));
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
index d8112092a242..b8a980172833 100644
--- a/arch/powerpc/kvm/book3s_hv_hmm.c
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -55,6 +55,39 @@ struct kvmppc_hmm_migrate_args {
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
+			ret = H_PARAMETER; /* TODO: proper retval */
+			goto out;
+		}
+	}
+	kvm->arch.secure_guest = true;
+out:
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	return ret;
+}
+
+unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
+{
+	if (!kvm->arch.secure_guest)
+		return H_UNSUPPORTED;
+
+	return H_SUCCESS;
+}
+
 #define KVMPPC_PFN_HMM		(0x1ULL << 61)
 
 static inline bool kvmppc_is_hmm_pfn(unsigned long pfn)
-- 
2.17.1

