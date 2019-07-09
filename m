Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D788C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D83220665
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D83220665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A6108E004B; Tue,  9 Jul 2019 06:26:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05C398E0032; Tue,  9 Jul 2019 06:26:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D50528E004B; Tue,  9 Jul 2019 06:26:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A06F8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:26:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b10so12378115pgb.22
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:26:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=32hCg3OAK4vTkSQdInlGvK0p4f/OGsavjsP/JWtx1uE=;
        b=IIy9B8sQkD5GvEeanuSEEcEymhNQOiZGhRDeE3or3Etp85rdpj2NIgEz9rL8koK9qy
         x+sfQqkgKoqyDBAdmMRthiozddcOArGeDFFINfNVYj7whj0eSjIBEGAa+EgridroVId2
         P6d6T7J+l78OS2chncO2JCVerwTU6CDRjnupRtbnSqGpaK0oEw/91WBq5YZ2lMXuh0tU
         fkkeP8inUEoNYszpeqRkBMEvt+btvrgm8LX9ggl5Vnvd/qPvJm9kLCSWYz5+gvgs7f8s
         iiGnUn77uP3uhna/ALhL8P/iHE2Kqh5KD9BwpxKlMbG5+6QctPNKxDtzv0AtZ4oLjaTl
         Shrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWefRlIBoftHuTpkntDbJH13WwYBTV8rxZlG5aeDoLV+p8LGsNi
	SAK+lRzjqzMN/urVF8j8QTWvBuqlkShcT0b2yLzmXdgJIZQqz2Dvpot2J3G0l9L+8gMCHQv45HG
	BRS9us5q1hlA0yUCDbwCBEas34MfnBpfoGCDdvA+PXtF6fesvejjMY1dpaedmihO1iw==
X-Received: by 2002:a17:90a:9905:: with SMTP id b5mr32464909pjp.70.1562667972299;
        Tue, 09 Jul 2019 03:26:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKsJJG1wiyAuBmWM2ef0zP++tgiNGOeXOhPhrJy2pf9syIvaXbMjZ+8yjwYfqs1L1eFSS1
X-Received: by 2002:a17:90a:9905:: with SMTP id b5mr32464847pjp.70.1562667971523;
        Tue, 09 Jul 2019 03:26:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562667971; cv=none;
        d=google.com; s=arc-20160816;
        b=VkzwaBBdpX0qaLqofJA0DkYxWuL0N9qYWpSeU8skqcl4kMfhOXFRw8fEot1AHqTNmY
         KHFoyv5mVqXnhNuTDfDk35YGz+9hVuj8UsvphKmU1hrPsj9xvjPfE/3/34KU126l4kCh
         Zkhe/WRIFgQVHji4M6Fm4iCAojNLBAdpBsEOyd7jt+eK6Y6XHCxzaAEW9hf4g0wtjzkZ
         xEEDB3VuwYKT++jSnC3jGx08seXAaDygsrDRg+iOyhhnAP5hTec+UlIBsqE8CQ93WuBa
         CYDuimn1bvOq5OVOuFlzLw5tN/gMknZ8TPL6mDOr1EblyO5qFSIKzsG/ynzZQ31XqAfm
         TAvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=32hCg3OAK4vTkSQdInlGvK0p4f/OGsavjsP/JWtx1uE=;
        b=urUjzDOKQ9paPAtFKlDnTo2uQ9KoE1rCjGZirtBDeimwYAq46+/ao5lIQ9sg6TZzZH
         bEBU8eFxIOqkHrftvUBlACTy/uS7Nf8V6mtv/Fh7i0lXtV2pbfOAZZkIHAwGAW/Q/WsI
         Dt9435jqfnjVz1kqqGmz94P+RrYOlwiHZoiDoKqYpF1URkGtD2YD6nDbBzFwrdhDHtIT
         47RXIFAZsMeb5iVw+a+kLat1c18lVPuQEaQik19OZJ3PL2F/Xt8dXwfQqiUk6qkSaMQI
         4Deg2lFeDoVLwyYSv2O4h3YI/zZf5MRWqAEXh1/+dl/RXUFCRG2NBRPjRQPwWV8Wk/c4
         rPKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f10si11682452pfq.194.2019.07.09.03.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:26:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69AMbBZ002007
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:26:11 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tmqe6vcva-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:26:10 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:26:08 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:26:05 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69AQ4Hu43516100
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:26:04 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 557F9AE051;
	Tue,  9 Jul 2019 10:26:04 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5F72AAE04D;
	Tue,  9 Jul 2019 10:26:02 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.81.51])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 10:26:02 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>,
        Paul Mackerras <paulus@ozlabs.org>
Subject: [PATCH v5 4/7] kvmppc: Handle memory plug/unplug to secure VM
Date: Tue,  9 Jul 2019 15:55:42 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190709102545.9187-1-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19070910-0028-0000-0000-00000382428F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-0029-0000-0000-000024424E64
Message-Id: <20190709102545.9187-5-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=821 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090127
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Register the new memslot with UV during plug and unregister
the memslot during unplug.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
Acked-by: Paul Mackerras <paulus@ozlabs.org>
---
 arch/powerpc/include/asm/ultravisor-api.h |  1 +
 arch/powerpc/include/asm/ultravisor.h     |  7 +++++++
 arch/powerpc/kvm/book3s_hv.c              | 19 +++++++++++++++++++
 3 files changed, 27 insertions(+)

diff --git a/arch/powerpc/include/asm/ultravisor-api.h b/arch/powerpc/include/asm/ultravisor-api.h
index 07b7d638e7af..d6d6eb2e6e6b 100644
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
index b46042f1aa8f..fe45be9ee63b 100644
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
index b8f801d00ad4..7cbb5edaed01 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -77,6 +77,7 @@
 #include <asm/hw_breakpoint.h>
 #include <asm/kvm_host.h>
 #include <asm/kvm_book3s_hmm.h>
+#include <asm/ultravisor.h>
 
 #include "book3s.h"
 
@@ -4504,6 +4505,24 @@ static void kvmppc_core_commit_memory_region_hv(struct kvm *kvm,
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
2.21.0

