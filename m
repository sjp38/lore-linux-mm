Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E356DC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A67A620C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:41:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A67A620C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A80106B026A; Fri,  9 Aug 2019 04:41:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FCDB6B0269; Fri,  9 Aug 2019 04:41:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55FEF6B026B; Fri,  9 Aug 2019 04:41:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBD56B0269
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:41:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q67so1211242pfc.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:41:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=H8A/coTF7+9kyLoTkdNkQGmFjwECtBuCUBSoO+bEiyE=;
        b=VJwcyeHT1RfbOqfeX83zi8I/zz9Nebibls2lpVDWYgMEddb1IQHgQkMQhlmELTdZ0R
         dQs0K6L9FeslSL/MxA/yTw1YIRw5nIKxClCoNHbbuJ8XPg33zKJp2dptQgHZMO718GuW
         82G85PJ1OUm01frRyn9lf6dRAbpgik9VQ59vT4GeW4tF4qdhUh8bdsQWlhb2+PjFuthx
         q/jwDHHxsvvCjxs0ka/0P2vNumeKHrVSPiNaMTKNLAa5GVNhC7UpSb/SBsYzCW7+Ee6M
         3rMLvXugYggWNlVBGAbj6hBVBOqhD+9O6Z7qBTrX/eNJfnHn/bAvhO7S87milHJnDB84
         ALsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV/a0P3oK9TW1tq28hKu46oUl2b9CA8gpxVsw/HMJm9GDAy0LTa
	GMhfeh4XHnAg19LZhxWHtzS2iRwfGnhpJ9rdDOfTXO+V28S+aIuDZDNH1stwFZ0HxrlVcS0JNO0
	n15NOA2sdPBKmZgu9frM7U02/FILCkZYAT3yJ15iSe3xW3tEwrMau99N3oLHPFs0zog==
X-Received: by 2002:a17:90a:cb87:: with SMTP id a7mr4815764pju.130.1565340094726;
        Fri, 09 Aug 2019 01:41:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0hYXa/DBX+wLjEalsjwBH10o60YVDCeb079VWlG0J4EVc4RLcEVaQj3Cencn4ip1gROJr
X-Received: by 2002:a17:90a:cb87:: with SMTP id a7mr4815719pju.130.1565340093885;
        Fri, 09 Aug 2019 01:41:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565340093; cv=none;
        d=google.com; s=arc-20160816;
        b=s7GsEWsTarqR0FV8ioU1vtZstKafgE8BXqA9Mn0j/uYbWm2YzeyITmgNRtHRgSayUh
         WtjgVUD8qEtW/gshwbj7+Dl2BgScRvf13pmBvvfui+jVXj+0vifq+KBx1xyauTVnSe+e
         qK+aIzGpaT2IxHyBY8UHTzMvDw9hj1AP8A70KOyPyYm5QH59LG3pduMvP6TTodvUUcs9
         +ObJk9JAzRjhHVlZxe9cyFSnnXTHUraGezRqgugYIEncg8MWMun9gdZ7WOSBMUffrysK
         yAlWetoL4IJsIZclfbzo+Tf46IeVslwy0RUJgeSjRa/0YtrDDck4fz0p9YLL3U4MFHxq
         7Yhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=H8A/coTF7+9kyLoTkdNkQGmFjwECtBuCUBSoO+bEiyE=;
        b=urXtU3H4e3IPPnGu6rLlnCLkOjLsmlhKIA2R9/id+14vdGjAYS2tcJjF6Kn806U2Oc
         BcaCywMagqJAsyNu+/59WcripXMyBDOCAkidEB0w/Do4+c536OZlf564ymXrtm+ULOPp
         MwvEOPeOCVEZVtJNSOaPFvyPJgbiOzJpH4PVU8ZlGwOvzNQ0fxr54o6tCvXz7TXzsW6d
         fM0RsdUZBz/MTPz04wTfDwjPE2cC5rRJQdm7BJiCP9HpcKzz7T+FmXgMPqOATtz/m+M/
         kpO2FmdgcprUVBEIaNQ0nBY3jSU/MTKSHj7/2TSOKPkhqFgj9/5K84tvGMgzyY4Rl3KC
         vxdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d4si52449243pgc.75.2019.08.09.01.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:41:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x798bc9N021131
	for <linux-mm@kvack.org>; Fri, 9 Aug 2019 04:41:33 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u93rwm7f6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:41:33 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 9 Aug 2019 09:41:30 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 9 Aug 2019 09:41:27 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x798fQGl50593842
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 08:41:26 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2DEDDA405F;
	Fri,  9 Aug 2019 08:41:26 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 10C40A4060;
	Fri,  9 Aug 2019 08:41:24 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.95.61])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri,  9 Aug 2019 08:41:23 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>,
        Paul Mackerras <paulus@ozlabs.org>
Subject: [PATCH v6 4/7] kvmppc: Handle memory plug/unplug to secure VM
Date: Fri,  9 Aug 2019 14:11:05 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190809084108.30343-1-bharata@linux.ibm.com>
References: <20190809084108.30343-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19080908-4275-0000-0000-00000357054D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080908-4276-0000-0000-000038690CC9
Message-Id: <20190809084108.30343-5-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=762 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090089
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
 arch/powerpc/include/asm/ultravisor.h     |  5 +++++
 arch/powerpc/kvm/book3s_hv.c              | 19 +++++++++++++++++++
 3 files changed, 25 insertions(+)

diff --git a/arch/powerpc/include/asm/ultravisor-api.h b/arch/powerpc/include/asm/ultravisor-api.h
index c578d9b13a56..46b1ee381695 100644
--- a/arch/powerpc/include/asm/ultravisor-api.h
+++ b/arch/powerpc/include/asm/ultravisor-api.h
@@ -26,6 +26,7 @@
 #define UV_WRITE_PATE			0xF104
 #define UV_RETURN			0xF11C
 #define UV_REGISTER_MEM_SLOT		0xF120
+#define UV_UNREGISTER_MEM_SLOT		0xF124
 #define UV_PAGE_IN			0xF128
 #define UV_PAGE_OUT			0xF12C
 
diff --git a/arch/powerpc/include/asm/ultravisor.h b/arch/powerpc/include/asm/ultravisor.h
index 8a722c575c56..79c415bf5ee8 100644
--- a/arch/powerpc/include/asm/ultravisor.h
+++ b/arch/powerpc/include/asm/ultravisor.h
@@ -40,4 +40,9 @@ static inline int uv_register_mem_slot(u64 lpid, u64 start_gpa, u64 size,
 			    size, flags, slotid);
 }
 
+static inline int uv_unregister_mem_slot(u64 lpid, u64 slotid)
+{
+	return ucall_norets(UV_UNREGISTER_MEM_SLOT, lpid, slotid);
+}
+
 #endif	/* _ASM_POWERPC_ULTRAVISOR_H */
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 33b8ebffbef0..13e31ef3583e 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -74,6 +74,7 @@
 #include <asm/hw_breakpoint.h>
 #include <asm/kvm_host.h>
 #include <asm/kvm_book3s_devm.h>
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

