Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C958DC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:50:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8985D2070D
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:50:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8985D2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3424A6B027A; Tue, 28 May 2019 02:49:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12E026B0279; Tue, 28 May 2019 02:49:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E49336B0281; Tue, 28 May 2019 02:49:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA7A66B027A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:58 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id h143so4675942ybg.6
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:49:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=ni6Y8NNMk18EmIsu7mg+RFI57ZrHdKGoCeGMtguHjBQ=;
        b=FExJrGq60u6BXhBRKGRwify72oYU0q0tf3FTuX9qnoEBGo8Rdw2ZgsJZARDpTfdWHe
         gavtylR0y+N6m/drf3goC1kwsIxvI5YKWTdNETFGwYikZFWU5ia3Om9xFOuUtE1OB3bE
         HVCA7q7b6OKzGB75dPdTxuSWri/I9i/2cAuNpqlrnxoxgB7oRFdISakHzim2v6vvtNxQ
         4UroqzIXMCmb5k9sFrWrctQNpX5MTe0GMp1cOf20S00+CIqjNRzbjA2kgk0yoAgkWiqh
         j35RHLo/qSx3n63nSWMZRmpxvsaoFydAssjb+GMB30mYahKcqL8WijDUTQC0ceK18its
         ZVWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWxX9+8O/lCSkL08jioZwCmgvQ3t79OmhY6mnXITWVxonxOAVZ+
	XmNcA/864nmoX1HWiiV9lpS8lOc50QvuGvQNPu/YdeO9Q71kC9eCX/QWBG5Mpn8zqgtLX4JB7+K
	HSnR1BzCUn4suONJ9DVLqrRlZmimJ5QbLDYC4QCTrkGoyyMJ0PcAplIwE2SmiSUCilQ==
X-Received: by 2002:a25:8803:: with SMTP id c3mr37072603ybl.173.1559026198436;
        Mon, 27 May 2019 23:49:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhyUdiEFiYbb3YdywoCId60lF9sLVTUgqZbmPtRPXbQDuqGRyZkNuTEt1FBNruRaSMQ18e
X-Received: by 2002:a25:8803:: with SMTP id c3mr37072580ybl.173.1559026197439;
        Mon, 27 May 2019 23:49:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559026197; cv=none;
        d=google.com; s=arc-20160816;
        b=wrV1R5kkRjXoskVvCqI4s6cZr9umeRa62JB8mNODLGweMdmh3ke+o7CgzhVVBIPFap
         /cV1OmCcPYkWkAipTiPCv2GTP6+ZcW12GjfS4e0I15uBOTmP4byrQ5n1z6Rs50BHIs8b
         J4AqCdE+DLEXYWSL2uAxoimdY6pGBbSJyyi5LR+s6dCTDrZjeoKBTL1TjvsHUXVxigLU
         uCuJK4+5cugS8yFNoDJoE2ZsLt6jMh90yn7KMTEXjFew85BYgOAKn/Koq65qjOnS06XM
         Jbx+8ZTq6rL/H5P7oGDSbx8Ln0V4UkWh46zPvVNxpcgJAXpw75dkwfgTIV5ab1P8TxsO
         UZ5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=ni6Y8NNMk18EmIsu7mg+RFI57ZrHdKGoCeGMtguHjBQ=;
        b=t20oNkX+bSKAzyDf3rUL73LVFNnCt0VpL4p8c1OPyO2CRGlWg37InerUy/t2mwRzil
         oPQCCL2g4ucPNeZPsTIHPmZ4iUK9XlaKjKlk3tOJ6v7/gZ+P4uYRxFe1vTk+JKR6rbne
         eBTkGR5Von6BnToLKxL0UGkb81gQfJHaIbEO5w7A53QaL7ZEBp9y3OiTzf6JnDHr4cOy
         vJ++aK8LJBjg+DwDoMzNtjX1O8c2qO/tOPDdxynHE5WNpHdkFaOaB0OKLG0bubQW43Qz
         42g4xXv4hTGQuvuPRHK4fhdmximoO8FfA01x0wsazc623UL1/z9xTWL24YZrZeP75LDX
         8YOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 84si2427912ybl.321.2019.05.27.23.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:49:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4S6cgIu078404
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:57 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2srxxjtahn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:56 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 28 May 2019 07:49:55 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 28 May 2019 07:49:54 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4S6nq5A20774936
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 06:49:52 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6124D11C058;
	Tue, 28 May 2019 06:49:52 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B4D8211C050;
	Tue, 28 May 2019 06:49:50 +0000 (GMT)
Received: from bharata.in.ibm.com (unknown [9.124.35.100])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 28 May 2019 06:49:50 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v4 4/6] kvmppc: Handle memory plug/unplug to secure VM
Date: Tue, 28 May 2019 12:19:31 +0530
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190528064933.23119-1-bharata@linux.ibm.com>
References: <20190528064933.23119-1-bharata@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19052806-0028-0000-0000-0000037220BB
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052806-0029-0000-0000-00002431DFA6
Message-Id: <20190528064933.23119-5-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=815 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280045
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Register the new memslot with UV during plug and unregister
the memslot during unplug.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/ultravisor-api.h |  1 +
 arch/powerpc/include/asm/ultravisor.h     |  7 +++++++
 arch/powerpc/kvm/book3s_hv.c              | 19 +++++++++++++++++++
 3 files changed, 27 insertions(+)

diff --git a/arch/powerpc/include/asm/ultravisor-api.h b/arch/powerpc/include/asm/ultravisor-api.h
index 05b17f4351f4..35b71e01177d 100644
--- a/arch/powerpc/include/asm/ultravisor-api.h
+++ b/arch/powerpc/include/asm/ultravisor-api.h
@@ -21,6 +21,7 @@
 #define UV_WRITE_PATE			0xF104
 #define UV_RETURN			0xF11C
 #define UV_REGISTER_MEM_SLOT		0xF120
+#define UV_UNREGISTER_MEM_SLOT		0xF124
 #define UV_PAGE_IN			0xF128
 #define UV_PAGE_OUT			0xF12C
 
diff --git a/arch/powerpc/include/asm/ultravisor.h b/arch/powerpc/include/asm/ultravisor.h
index 9befa6fea8db..5113457c4743 100644
--- a/arch/powerpc/include/asm/ultravisor.h
+++ b/arch/powerpc/include/asm/ultravisor.h
@@ -70,6 +70,13 @@ static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 size,
 	return ucall(UV_REGISTER_MEM_SLOT, retbuf, lpid, start_gpa,
 		     size, flags, slotid);
 }
+
+static inline int uv_unregister_mem_slot(u64 lpid, u64 slotid)
+{
+	unsigned long retbuf[UCALL_BUFSIZE];
+
+	return ucall(UV_UNREGISTER_MEM_SLOT, retbuf, lpid, slotid);
+}
 #endif /* !__ASSEMBLY__ */
 
 #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 3683e517541f..5ef35e230453 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -78,6 +78,7 @@
 #include <asm/firmware.h>
 #include <asm/kvm_host.h>
 #include <asm/kvm_book3s_hmm.h>
+#include <asm/ultravisor.h>
 
 #include "book3s.h"
 
@@ -4498,6 +4499,24 @@ static void kvmppc_core_commit_memory_region_hv(struct kvm *kvm,
 	if (change == KVM_MR_FLAGS_ONLY && kvm_is_radix(kvm) &&
 	    ((new->flags ^ old->flags) & KVM_MEM_LOG_DIRTY_PAGES))
 		kvmppc_radix_flush_memslot(kvm, old);
+	/*
+	 * If UV hasn't yet called H_SVM_INIT_START, don't register memslots.
+	 */
+	if (!kvm->arch.secure_guest)
+		return;
+
+	/*
+	 * TODO: Handle KVM_MR_MOVE
+	 */
+	if (change == KVM_MR_CREATE) {
+		uv_register_mem_slot(kvm->arch.lpid,
+					   new->base_gfn << PAGE_SHIFT,
+					   new->npages * PAGE_SIZE,
+					   0,
+					   new->id);
+	} else if (change == KVM_MR_DELETE) {
+		uv_unregister_mem_slot(kvm->arch.lpid, old->id);
+	}
 }
 
 /*
-- 
2.17.1

