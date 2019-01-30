Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D870C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E1FC20989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E1FC20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D72AD8E0006; Wed, 30 Jan 2019 01:07:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFBAD8E0001; Wed, 30 Jan 2019 01:07:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C10EC8E0006; Wed, 30 Jan 2019 01:07:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 78C0A8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:53 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g13so16084843plo.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 22:07:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=sbRUPV1sPwWxlA95znkEDMZvUUkuccpMzCUBfcCeo+w=;
        b=TWMxuZut/PjozgjsWk8hxwqm+ZadW864u2VL19GSpS4upm9lYUvpCNtAppHzJbc+ci
         YSrml+AR2LN+O95HA79FuX+h2t4l7rEkAE2MySYzqhQRsvYzx2g3qkOsgDQhIvqQeoj8
         YbhHfZ6SXYTbWq0AStWnWzSx65g6M+3ZqvDIP1lnOhjvDTZlU16y+5XI5wBh1T3Qef2I
         e2GkrIOG9jFJbayQrncEvh51V4RzFy6j7oJJYr1n3iwfXS4Ci2PE4vDezEL7846briEg
         54DNigajol36BXjFGKD7NZzgIfh6hakTORD48H2+Kzqpm3FeB2qn6vY9uvBxRMfZc6Ae
         3fuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukey0ziuvWoZrWtauizZWVqhwEfynonf2PRWNJJ+C62LUmKDPZyl
	vHI1ErfrHqCZRIepPy6bWn/JJ4rRXwkdCxUuPk3dAMzrIIw+qapZXNx5YQBRvva6Iq62NvLRotJ
	g70wJJQeCGc//kEVJmsYrLVUW/7q2y+ArccJhDj+HxrmPtb8jYkq27d/d/9sB6xMP0Q==
X-Received: by 2002:a63:5455:: with SMTP id e21mr26675429pgm.316.1548828473035;
        Tue, 29 Jan 2019 22:07:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4EDK2j7b1PDX3N2NJlX9ZqQCGkfIToTI3zKJuhS7b5eLzR4mvdHRM8N8gPjCZK++LrK85f
X-Received: by 2002:a63:5455:: with SMTP id e21mr26675386pgm.316.1548828472223;
        Tue, 29 Jan 2019 22:07:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548828472; cv=none;
        d=google.com; s=arc-20160816;
        b=LbQ2d34AICQKMaEjgr8jSiZOU3e+/mySiPdliG1wy7kzs1pWheZ2XFOkGZZHQ3QfhC
         eSAV5EvcKdL3KwPtKd8d9SqpesQDah5R6U5EKDUCvQ33WC6a+gWIAbWF40o7zVHReKKl
         FSALnAecUSnWEhjqUnjFoqYS8cHwNluskEbYjKNs5beXZ80peGaQxFdnaXEx08TiJ8Wl
         3bBkEHADkUi9fR0B6CBleLuqiSmxU9kwgt6tij5rlUbx1xGNziIrsHzHu31dITuE9iwR
         jgy+3+eWwD3Bmo6o5SnuCS097Ng5navn4hi32YqCn1Xn4YPer7IUPjQGQIOqY7qqtRti
         cZ3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=sbRUPV1sPwWxlA95znkEDMZvUUkuccpMzCUBfcCeo+w=;
        b=kQBMPA9i+XEEi2to16VcFtB05QYLRFG4fyytsGmLwsdBFcQilPQVn/zhnUSnUtinoL
         1Vt3cr1Nox8KYSJczLeXlCzVtXohxWy2wXTpPiFX5JQ2dR9RllV0+jdQgBIgNGQA88fv
         IAxhiwkfi5NZNkTeyfzKW7Y/7FPsz1WpPW+C3MX1k9f3ip2SAbYZXYP7Q8yLaulz9qGQ
         /jkBTBqRdJhQR7HtNox3FToGRFUk0rlnszO9atnuwQw9d4FGpdw0IU8RBrOVDKQZMLu7
         5In8SySAh78K77M5qyshBVrLmUBN9Lim3VHKqejI/4BKZb+mOl8u+p22dktRumcLs/hM
         DHpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n19si620009pgd.271.2019.01.29.22.07.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 22:07:52 -0800 (PST)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U64Nth055457
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:51 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qb1k7hpbk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:51 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 30 Jan 2019 06:07:49 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 30 Jan 2019 06:07:46 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0U67juv42467504
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 30 Jan 2019 06:07:45 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E0C4852080;
	Wed, 30 Jan 2019 06:07:44 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.36.73])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2EDAC5204F;
	Wed, 30 Jan 2019 06:07:43 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v3 4/4] kvmppc: Handle memory plug/unplug to secure VM
Date: Wed, 30 Jan 2019 11:37:26 +0530
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190130060726.29958-1-bharata@linux.ibm.com>
References: <20190130060726.29958-1-bharata@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19013006-0028-0000-0000-000003409DC5
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013006-0029-0000-0000-000023FDA3B1
Message-Id: <20190130060726.29958-5-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=799 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901300046
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Register the new memslot with UV during plug and unregister
the memslot during unplug.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/ucall-api.h        |  7 +++++++
 arch/powerpc/include/uapi/asm/uapi_uvcall.h |  1 +
 arch/powerpc/kvm/book3s_hv.c                | 19 +++++++++++++++++++
 3 files changed, 27 insertions(+)

diff --git a/arch/powerpc/include/asm/ucall-api.h b/arch/powerpc/include/asm/ucall-api.h
index d266670229cb..cbb8bb38eb8b 100644
--- a/arch/powerpc/include/asm/ucall-api.h
+++ b/arch/powerpc/include/asm/ucall-api.h
@@ -82,5 +82,12 @@ static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 size,
 	return plpar_ucall(UV_REGISTER_MEM_SLOT, retbuf, lpid, start_gpa,
 			   size, flags, slotid);
 }
+
+static inline int uv_unregister_mem_slot(u64 lpid, u64 slotid)
+{
+	unsigned long retbuf[PLPAR_UCALL_BUFSIZE];
+
+	return plpar_ucall(UV_UNREGISTER_MEM_SLOT, retbuf, lpid, slotid);
+}
 #endif	/* __ASSEMBLY__ */
 #endif	/* _ASM_POWERPC_UCALL_API_H */
diff --git a/arch/powerpc/include/uapi/asm/uapi_uvcall.h b/arch/powerpc/include/uapi/asm/uapi_uvcall.h
index 79a11a6ee436..60e44c7b58c4 100644
--- a/arch/powerpc/include/uapi/asm/uapi_uvcall.h
+++ b/arch/powerpc/include/uapi/asm/uapi_uvcall.h
@@ -13,6 +13,7 @@
 #define UV_RESTRICTED_SPR_READ 0xf10C
 #define UV_RETURN	0xf11C
 #define UV_REGISTER_MEM_SLOT    0xF120
+#define UV_UNREGISTER_MEM_SLOT    0xF124
 #define UV_PAGE_IN	0xF128
 #define UV_PAGE_OUT	0xF12C
 
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 1dfb42ac9626..61e36c4516d5 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -76,6 +76,7 @@
 #include <asm/xive.h>
 #include <asm/kvm_host.h>
 #include <asm/kvm_book3s_hmm.h>
+#include <asm/ucall-api.h>
 
 #include "book3s.h"
 
@@ -4433,6 +4434,24 @@ static void kvmppc_core_commit_memory_region_hv(struct kvm *kvm,
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

