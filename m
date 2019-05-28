Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFAF5C46460
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:12:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 737FD208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:12:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 737FD208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F89E6B0275; Tue, 28 May 2019 05:12:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 181B66B0276; Tue, 28 May 2019 05:12:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023456B0278; Tue, 28 May 2019 05:12:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC9066B0275
	for <linux-mm@kvack.org>; Tue, 28 May 2019 05:12:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j36so13570901pgb.20
        for <linux-mm@kvack.org>; Tue, 28 May 2019 02:12:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=gTTz1+SPW+UsBjIWFUAQ9jgUPxhYvs8KZAFA2fuUwng=;
        b=oZ2Mc/nhS7CtUmYvvqlyWpn/j3gTcZ/W6XJMISThxanPprCiqNA2NFq3+3C61mR72m
         B1WXrI3z9g52JNd34zMhsUPf2R6JVlInD+YFiG+2tbqLJse5NcgIXrWREw+nN+7BPWua
         OYkRPk8quT+9JoHg/NXjqvFOAn+ff0/nvY8wwyJ4eU6reQTtk5R9B/DMi7em5G0rogHS
         JPuyTdpEkD1eQjcgNp1QbI0Qg+JBtg00OTH/LK/czBbGlRfM5XuDVNKM1pLb6N8zIJf8
         Hsg+2yzJjEw0vx4VTGZMzKPwUTTiIglaOa3lGnAl9W30WU7Qk2dtRgVNjtwYXpSgPKps
         cIBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUKLwnt9Kf3M+4jvb20CXDtGzPCC/4ru+g7cHot8yqq0cnUGNuW
	e972C9u8Rhi085/byfB/g9VkuPM4qcK/u1HJqYEu5pbJCx+ePQDzjGwnL8I8MfxgElC/UxkSTlf
	/WkvYtBDH5CVjE9u9CQeuo/8fXLDflxJkC18/l2yDQ+ZAyp6kED2/ucZk3zJBAkP2oA==
X-Received: by 2002:a17:902:a708:: with SMTP id w8mr15037882plq.162.1559034732295;
        Tue, 28 May 2019 02:12:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzItwb8laYSdETEu6LNHPzXDsplFolJEJJMQvyYfP2S1K9/ImpGxDKVvd4aj+tX5r/7rYVI
X-Received: by 2002:a17:902:a708:: with SMTP id w8mr15037784plq.162.1559034731496;
        Tue, 28 May 2019 02:12:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559034731; cv=none;
        d=google.com; s=arc-20160816;
        b=QCtypQL5JKaYGN4fwByb0zyI/8i/Q1SujWhW84CgPlFS+9+0ixc4H8+3oOkXzeKXRX
         k1/p2BdIHRMBFybvkLGpu8Hh+as0F7UptknskeXA5QKb9mFRgtqTkyveDa01Qdbt1mJs
         j+mwWaWHooUov7frlIygwhScItf1tVLinA+8A1vuED/uljxJq8RHFhTNkkl3pKXMPuhr
         7NOcwvKmSvBUFpj2u677CzATSMS6Wd7WieFcrnmxhk3WP6wHk0q28HGk++hwKvyFaHNL
         zxlGAdAIzd8rlFvnmdFLvAh+G+dYvglbK4i/ypFxh4Uy7xDiHB1ph/MbhecEP9OsD44s
         Heqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=gTTz1+SPW+UsBjIWFUAQ9jgUPxhYvs8KZAFA2fuUwng=;
        b=jH8JKVrXLm/N+ZtFPSvODiaCv+yJ4YLHL/v0bb1/7R0gymrmMwxBZPrcGUG2GPONC3
         yTiSfs5QqFDx2TaLhApttYN94OFrb+zpm+c7N9JfsMQE8jz1pK6o/TjkhICZIAWbx1XO
         ThlWLH13elIY6YcLz9SuotIsIFEywTnVNTcAfFLa+b8O4d4Uelr25ztYQpuWb5jyxkzi
         NL5i2+ENxIuaRDgp+8m8qUDEKqKafCb76YoyPk/nZ5Xx6+TM6gBijCWrqUXFTsXXFeAg
         yoF1OmcpQW4W99otlJ9KQ8xYRqgQMClhyiV0xBMoNs4CRzAs9Lagnc04HEa5yAUiemtX
         d0NA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s207si20683214pfs.119.2019.05.28.02.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 02:12:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4S93Tp1137213
	for <linux-mm@kvack.org>; Tue, 28 May 2019 05:12:11 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ss0uqbckg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 May 2019 05:12:10 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 28 May 2019 10:12:09 +0100
Received: from b03cxnp07028.gho.boulder.ibm.com (9.17.130.15)
	by e33.co.us.ibm.com (192.168.1.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 28 May 2019 10:12:07 +0100
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4S9C6F146530724
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 09:12:06 GMT
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 70CF96A047;
	Tue, 28 May 2019 09:12:06 +0000 (GMT)
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 45AB06A04D;
	Tue, 28 May 2019 09:12:04 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.31.115])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue, 28 May 2019 09:12:03 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org, jack@suse.cz, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v2] mm: Move MAP_SYNC to asm-generic/mman-common.h
Date: Tue, 28 May 2019 14:41:20 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19052809-0036-0000-0000-00000AC3B684
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011174; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01209716; UDB=6.00635512; IPR=6.00990746;
 MB=3.00027082; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-28 09:12:09
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052809-0037-0000-0000-00004BF98C6A
Message-Id: <20190528091120.13322-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=725 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280061
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This enables support for synchronous DAX fault on powerpc

The generic changes are added as part of
commit b6fb293f2497 ("mm: Define MAP_SYNC and VM_SYNC flags")

Without this, mmap returns EOPNOTSUPP for MAP_SYNC with MAP_SHARED_VALIDATE

Instead of adding MAP_SYNC with same value to
arch/powerpc/include/uapi/asm/mman.h, I am moving the #define to
asm-generic/mman-common.h. Two architectures using mman-common.h directly are
sparc and powerpc. We should be able to consloidate more #defines to
mman-common.h. That can be done as a separate patch.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
Changes from V1:
* Move #define to mman-common.h instead of powerpc specific mman.h change


 include/uapi/asm-generic/mman-common.h | 3 ++-
 include/uapi/asm-generic/mman.h        | 1 -
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index abd238d0f7a4..bea0278f65ab 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -25,7 +25,8 @@
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
 
-/* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
+/* 0x0100 - 0x40000 flags are defined in asm-generic/mman.h */
+#define MAP_SYNC		0x080000 /* perform synchronous page faults for the mapping */
 #define MAP_FIXED_NOREPLACE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
 /*
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 653687d9771b..2dffcbf705b3 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -13,7 +13,6 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-#define MAP_SYNC	0x80000		/* perform synchronous page faults for the mapping */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
-- 
2.21.0

