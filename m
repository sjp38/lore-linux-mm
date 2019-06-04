Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75A7EC46470
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:10:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3981024CB3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:10:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3981024CB3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C46586B026E; Tue,  4 Jun 2019 05:10:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF7C86B0270; Tue,  4 Jun 2019 05:10:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABF906B0271; Tue,  4 Jun 2019 05:10:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7673C6B026E
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 05:10:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id y187so3949185pgd.1
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 02:10:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=xKD4B/wUTgbX/IFNTtuaqzHVVErLFk3FXESQOTJ+yao=;
        b=Q0UHOfA9vb0NBrO1VOvOksE2JpK2ycQuordNQhQWSNo4nE+uRj3skcdziWjthiIICW
         dtgl1OTKkced/EMjvBOqnM9eV5JiHbQVCH13psXVj8O2D6pS2BvvzabitF+hn59kq/HQ
         KfsU31JhdLoFasDynbrqDwOeuX4JOFZHUXwXxF7/LBBOHa3CKquwo2vwt2xw/N5wWW6u
         qJShlZv2Sh+gAOoLv2e6Y/kOfcs46993iGUW0c4wBSC72LmohuPGlYx5mH66tc5CqtPN
         3Xduj/wsOGNuQK1NgZymXMaSwktnyfdfIu7Fg1Mx8E2Zi5x2cJGZn/IodbYo27GHvx4a
         uTUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWd+31BWgci6ENkOkcl2SQYwtS7uKHmn98BFrAgvHW4YENd0lVZ
	bE5MTtk1TzrxBH1csCRnijewnbP7avslJqe+LWyFYkHcRWD/o/PeFwYhwhmupabP+8dNA6bq6dV
	0sDlLaaKHGE9yYhKy/RvwK3OOyCJScUU8AVeHL4LOx+7UnqC3mW00LpdbYgFL0KQBEA==
X-Received: by 2002:a65:450b:: with SMTP id n11mr33022908pgq.174.1559639405898;
        Tue, 04 Jun 2019 02:10:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmVM3NRSTO5ds/oexiAJ1Q708BzCvXVsKnTutjmbxjFIMPyNqZt3YhE2JpqGved48VWeC7
X-Received: by 2002:a65:450b:: with SMTP id n11mr33022783pgq.174.1559639404122;
        Tue, 04 Jun 2019 02:10:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559639404; cv=none;
        d=google.com; s=arc-20160816;
        b=kCGfvRIaOWY9UtNzfxCyuOgvJBsd+Y+uRDYpYF4sdCkipdhYj2LLDgABhPANIfoGd6
         zNORRenXUMv8mdTaby6q0BPigAficiq5uc8CFEMR96vcg6LDB7RQc8a8yiHYCWIrM6r5
         UCfjdfBdk8U9QqVFsMZY4KyubJYImOTf2NUoU6EjyKORSQOQE2iZyxXJM+REnqluK1Iy
         F8mirrIVKAwYmIKJX4LyIeCTibqSMpiIKivP44vm3CJ5Ps0xnhCUCXB0pxyZNz3Y9aGF
         uL4x2p/XpxhhCslOfLYHkwXXYpkPzawcs940QLi5eiymMj4EI235eFxrwB28ms8+XUmy
         BOpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=xKD4B/wUTgbX/IFNTtuaqzHVVErLFk3FXESQOTJ+yao=;
        b=ecpsyOUJmXWXNDu5g6cOf1S9Pti+/pnxkZ2xOb3hvkjGIghfcQngGM8h4RBrOG4dJV
         F+KQE6aXSpeIdVCvHmzkzuosfhaPgVMeHPaPaVn8VFmUejOPF85f74/7CUc1fyeTAbiO
         CyRrdlsmm9EOFDdcTlmKD4Nc/Kc/HdTh00OZE4HVOvPvivLTmGDjcihIp7YAYchTL/TZ
         jwMmiYs2rQa2AQc6DzmupouDvg/nhn4MwCy2HnRzJQqAkRrM8E/z/I1eLFskSQN1HiAF
         jeC0uSEMHMnPb9jUnCyEEiHHamyHPsnmmvAPNJVbNMbDv9qXm3BKcfw0UZSRruKTlqWW
         h0MA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q10si20819236plr.412.2019.06.04.02.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 02:10:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5497WrB004726
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 05:10:03 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2swnd5s1hf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:10:03 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Jun 2019 10:10:02 +0100
Received: from b01cxnp22033.gho.pok.ibm.com (9.57.198.23)
	by e13.ny.us.ibm.com (146.89.104.200) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 10:09:58 +0100
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5499vQ015728696
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 09:09:57 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 65482AE06D;
	Tue,  4 Jun 2019 09:09:56 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BC025AE063;
	Tue,  4 Jun 2019 09:09:54 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.234])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 09:09:54 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] mm/mmap: Move common defines to mman-common.h
Date: Tue,  4 Jun 2019 14:39:50 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19060409-0064-0000-0000-000003E974B8
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011212; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01213036; UDB=6.00637527; IPR=6.00994103;
 MB=3.00027178; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-04 09:10:00
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060409-0065-0000-0000-00003DBBE0F9
Message-Id: <20190604090950.31417-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=394 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Two architecture that use arch specific MMAP flags are powerpc and sparc.
We still have few flag values common across them and other architectures.
Consolidate this in mman-common.h.

Also update the comment to indicate where to find HugeTLB specific reserved
values

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/uapi/asm/mman.h   | 6 +-----
 arch/sparc/include/uapi/asm/mman.h     | 6 ------
 include/uapi/asm-generic/mman-common.h | 6 +++++-
 include/uapi/asm-generic/mman.h        | 9 ++++-----
 4 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index 65065ce32814..c0c737215b00 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -21,15 +21,11 @@
 #define MAP_DENYWRITE	0x0800		/* ETXTBSY */
 #define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
 
+
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
 #define MCL_ONFAULT	0x8000		/* lock all pages that are faulted in */
 
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
 /* Override any generic PKEY permission defines */
 #define PKEY_DISABLE_EXECUTE   0x4
 #undef PKEY_ACCESS_MASK
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index f6f99ec65bb3..cec9f4109687 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -22,10 +22,4 @@
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
 #define MCL_ONFAULT	0x8000		/* lock all pages that are faulted in */
 
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-
 #endif /* _UAPI__SPARC_MMAN_H__ */
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index bea0278f65ab..ef4623f03156 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -25,7 +25,11 @@
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
 
-/* 0x0100 - 0x40000 flags are defined in asm-generic/mman.h */
+/* 0x0100 - 0x4000 flags are defined in asm-generic/mman.h */
+#define MAP_POPULATE		0x008000	/* populate (prefault) pagetables */
+#define MAP_NONBLOCK		0x010000	/* do not block on IO */
+#define MAP_STACK		0x020000	/* give out an address that is best suited for process/thread stacks */
+#define MAP_HUGETLB		0x040000	/* create a huge page mapping */
 #define MAP_SYNC		0x080000 /* perform synchronous page faults for the mapping */
 #define MAP_FIXED_NOREPLACE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 2dffcbf705b3..57e8195d0b53 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -9,12 +9,11 @@
 #define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
 #define MAP_LOCKED	0x2000		/* pages are locked */
 #define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
 
-/* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
+/*
+ * Bits [26:31] are reserved, see asm-generic/hugetlb_encode.h
+ * for MAP_HUGETLB usage
+ */
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
-- 
2.21.0

