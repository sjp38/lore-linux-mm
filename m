Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0CC5C04AA7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7015F20879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:55:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7015F20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B5776B0005; Mon, 13 May 2019 22:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1698B6B0007; Mon, 13 May 2019 22:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 007FC6B0008; Mon, 13 May 2019 22:55:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5DE76B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:55:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d12so10966821pfn.9
        for <linux-mm@kvack.org>; Mon, 13 May 2019 19:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=wCExhtisacFTQp03RrDrgvocDKprcZI3ScHOZ0yRhuk=;
        b=GuM1w666DXKoBovfl2PCcAW5b1q3t5OS14xiYpNP8fmcK13g9zADkX9yB9zpfLVzTv
         5Z6S8GNmawaBTufxrO2eOIgZvtyS7c7bnerSZjxFMESdkHlNOZucDu+rZrZsQWtldY49
         4EIWqlDuVC+MbkeZl/8c7WOUipIHJPW2qYNTgG7H7tl742W54egs0uIkmyBVx5g00KtE
         7udvea4oLadHqKtSN0FVNI403za3ft9itJXcNUFcuKJldlKNbQARsI5ocYwGUlO1oUZc
         H7/ubg4m/SYQXBpjNQO3QV/zjZAQrKUf7nwDWSfLUIXaNgt399tv1joz6S2SHoMU/XPr
         4reQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUwpKZ457ZS+wKAWDa8I5NFVDoNiqyh3fha4GaeRTeh3utlO3ZS
	3B7vlD+KY9ES13C6/lA8OMila52pCmknSsM9zi8hZEEqiXSyZLA95KO1Ft0lXEzJkEL3qLp+QdS
	TUucAL0NUVEBbVzKf1Yi81UOAXvceA0ZwXAMI78UZnkls5bbdetP2GWvytQs9DWH8dg==
X-Received: by 2002:a63:8bc9:: with SMTP id j192mr34918730pge.212.1557802501328;
        Mon, 13 May 2019 19:55:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvC1CScYVxk5u9j2Bq+Shv4zMFIhfZUJXlFenljAg8oAuaP6NrwUK5AZhnJwISkhDh0A45
X-Received: by 2002:a63:8bc9:: with SMTP id j192mr34918676pge.212.1557802500307;
        Mon, 13 May 2019 19:55:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557802500; cv=none;
        d=google.com; s=arc-20160816;
        b=mewO+zehj6q6lCGViWNHljeJTt7IWzyMoX6I9PXPcithCOpiwEhpfCoRmrp1BQG1F8
         2XnZ3P58q/XyvaSR4KM6YwPU7apzZbT/dwMN9tAIuMMToKEBiA9YppmUVtbXekgQaGuj
         wN+ktSVhyIoLi+plqRHqppT8FQ2YdBWOWgCW2FAfBygGD75T1QGTndogptXayoBcq13V
         Lx/aio+jz01sqjYiOY8D3pEBbgCO6OrPZmiIaxHLPHLZzXaa2REF4NpTPK3Wtn+WJ/fN
         4FFZG6Nfk/D9NWunlxlWarCwStIejN2V1B5e+JRXuq/e9bjIEOLcEFy74bgmstf7wGHX
         /BCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=wCExhtisacFTQp03RrDrgvocDKprcZI3ScHOZ0yRhuk=;
        b=ApXBy+EDJHs1oPHvbEmEH42jirOpxLAg31jkjxE8BKLbw7ca8hXDxUcGbhCpnH7HTD
         sD6dXdXjo0GMwuSOtRXuwRPotVFbvD5PCBjY8Zl8rvv6p0SOf0Two1rDq6xEgDbPVzeY
         cr2Xe0lFBpQ+fCbLqJL4+TzzUAqmb5QxGzzPj0053UyTnSErdpT7qSO1wtm37D+whRwA
         1+97z2hr/11bCCP1UjGwnASkV8x2ZFhPDoSWkk1desiN4Q6PA+Tc90Gulx10MC2dONA+
         cwh1B8ymnNph8Z4xTdfD4ajiTu9miXRz/xUGe3i4fD3fqKHnfsoia745WVYrYGomQcF0
         yx4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t188si11882167pgc.228.2019.05.13.19.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 19:55:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E2kv4h023725
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:54:59 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sfhg1qeds-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:54:59 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 14 May 2019 03:54:58 +0100
Received: from b03cxnp08028.gho.boulder.ibm.com (9.17.130.20)
	by e31.co.us.ibm.com (192.168.1.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 14 May 2019 03:54:57 +0100
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E2suFV32309566
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 02:54:56 GMT
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2A6D16E04C;
	Tue, 14 May 2019 02:54:56 +0000 (GMT)
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 092F16E04E;
	Tue, 14 May 2019 02:54:53 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.80.221.111])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue, 14 May 2019 02:54:53 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH] mm/nvdimm: Pick the right alignment default when creating dax devices
Date: Tue, 14 May 2019 08:24:49 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19051402-8235-0000-0000-00000E94EB97
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011095; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000285; SDB=6.01202996; UDB=6.00631417; IPR=6.00983915;
 MB=3.00026876; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-14 02:54:58
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051402-8236-0000-0000-0000458C3210
Message-Id: <20190514025449.9416-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140018
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Allow arch to provide the supported alignments and use hugepage alignment only
if we support hugepage. Right now we depend on compile time configs whereas this
patch switch this to runtime discovery.

Architectures like ppc64 can have THP enabled in code, but then can have
hugepage size disabled by the hypervisor. This allows us to create dax devices
with PAGE_SIZE alignment in this case.

Existing dax namespace with alignment larger than PAGE_SIZE will fail to
initialize in this specific case. We still allow fsdax namespace initialization.

With respect to identifying whether to enable hugepage fault for a dax device,
if THP is enabled during compile, we default to taking hugepage fault and in dax
fault handler if we find the fault size > alignment we retry with PAGE_SIZE
fault size.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/asm/libnvdimm.h |  9 ++++++++
 arch/powerpc/mm/Makefile             |  1 +
 arch/powerpc/mm/nvdimm.c             | 34 ++++++++++++++++++++++++++++
 arch/x86/include/asm/libnvdimm.h     | 19 ++++++++++++++++
 drivers/nvdimm/nd.h                  |  6 -----
 drivers/nvdimm/pfn_devs.c            | 32 +++++++++++++++++++++++++-
 include/linux/huge_mm.h              |  7 +++++-
 7 files changed, 100 insertions(+), 8 deletions(-)
 create mode 100644 arch/powerpc/include/asm/libnvdimm.h
 create mode 100644 arch/powerpc/mm/nvdimm.c
 create mode 100644 arch/x86/include/asm/libnvdimm.h

diff --git a/arch/powerpc/include/asm/libnvdimm.h b/arch/powerpc/include/asm/libnvdimm.h
new file mode 100644
index 000000000000..d35fd7f48603
--- /dev/null
+++ b/arch/powerpc/include/asm/libnvdimm.h
@@ -0,0 +1,9 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_POWERPC_LIBNVDIMM_H
+#define _ASM_POWERPC_LIBNVDIMM_H
+
+#define nd_pfn_supported_alignments nd_pfn_supported_alignments
+extern unsigned long *nd_pfn_supported_alignments(void);
+extern unsigned long nd_pfn_default_alignment(void);
+
+#endif
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 0f499db315d6..42e4a399ba5d 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -20,3 +20,4 @@ obj-$(CONFIG_HIGHMEM)		+= highmem.o
 obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_PPC_PTDUMP)	+= ptdump/
 obj-$(CONFIG_KASAN)		+= kasan/
+obj-$(CONFIG_NVDIMM_PFN)		+= nvdimm.o
diff --git a/arch/powerpc/mm/nvdimm.c b/arch/powerpc/mm/nvdimm.c
new file mode 100644
index 000000000000..a29a4510715e
--- /dev/null
+++ b/arch/powerpc/mm/nvdimm.c
@@ -0,0 +1,34 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <asm/pgtable.h>
+#include <asm/page.h>
+
+#include <linux/mm.h>
+/*
+ * We support only pte and pmd mappings for now.
+ */
+const unsigned long *nd_pfn_supported_alignments(void)
+{
+	static unsigned long supported_alignments[3];
+
+	supported_alignments[0] = PAGE_SIZE;
+
+	if (has_transparent_hugepage())
+		supported_alignments[1] = HPAGE_PMD_SIZE;
+	else
+		supported_alignments[1] = 0;
+
+	supported_alignments[2] = 0;
+	return supported_alignments;
+}
+
+/*
+ * Use pmd mapping if supported as default alignment
+ */
+unsigned long nd_pfn_default_alignment(void)
+{
+
+	if (has_transparent_hugepage())
+		return HPAGE_PMD_SIZE;
+	return PAGE_SIZE;
+}
diff --git a/arch/x86/include/asm/libnvdimm.h b/arch/x86/include/asm/libnvdimm.h
new file mode 100644
index 000000000000..3d5361db9164
--- /dev/null
+++ b/arch/x86/include/asm/libnvdimm.h
@@ -0,0 +1,19 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_X86_LIBNVDIMM_H
+#define _ASM_X86_LIBNVDIMM_H
+
+static inline unsigned long nd_pfn_default_alignment(void)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	return HPAGE_PMD_SIZE;
+#else
+	return PAGE_SIZE;
+#endif
+}
+
+static inline unsigned long nd_altmap_align_size(unsigned long nd_align)
+{
+	return PMD_SIZE;
+}
+
+#endif
diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
index a5ac3b240293..44fe923b2ee3 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -292,12 +292,6 @@ static inline struct device *nd_btt_create(struct nd_region *nd_region)
 struct nd_pfn *to_nd_pfn(struct device *dev);
 #if IS_ENABLED(CONFIG_NVDIMM_PFN)
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define PFN_DEFAULT_ALIGNMENT HPAGE_PMD_SIZE
-#else
-#define PFN_DEFAULT_ALIGNMENT PAGE_SIZE
-#endif
-
 int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns);
 bool is_nd_pfn(struct device *dev);
 struct device *nd_pfn_create(struct nd_region *nd_region);
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 01f40672507f..347cab166376 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -18,6 +18,7 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <asm/libnvdimm.h>
 #include "nd-core.h"
 #include "pfn.h"
 #include "nd.h"
@@ -111,6 +112,8 @@ static ssize_t align_show(struct device *dev,
 	return sprintf(buf, "%ld\n", nd_pfn->align);
 }
 
+#ifndef nd_pfn_supported_alignments
+#define nd_pfn_supported_alignments nd_pfn_supported_alignments
 static const unsigned long *nd_pfn_supported_alignments(void)
 {
 	/*
@@ -133,6 +136,7 @@ static const unsigned long *nd_pfn_supported_alignments(void)
 
 	return data;
 }
+#endif
 
 static ssize_t align_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
@@ -310,7 +314,7 @@ struct device *nd_pfn_devinit(struct nd_pfn *nd_pfn,
 		return NULL;
 
 	nd_pfn->mode = PFN_MODE_NONE;
-	nd_pfn->align = PFN_DEFAULT_ALIGNMENT;
+	nd_pfn->align = nd_pfn_default_alignment();
 	dev = &nd_pfn->dev;
 	device_initialize(&nd_pfn->dev);
 	if (ndns && !__nd_attach_ndns(&nd_pfn->dev, ndns, &nd_pfn->ndns)) {
@@ -420,6 +424,20 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn *nd_pfn)
 	return 0;
 }
 
+static bool nd_supported_alignment(unsigned long align)
+{
+	int i;
+	const unsigned long *supported = nd_pfn_supported_alignments();
+
+	if (align == 0)
+		return false;
+
+	for (i = 0; supported[i]; i++)
+		if (align == supported[i])
+			return true;
+	return false;
+}
+
 int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 {
 	u64 checksum, offset;
@@ -474,6 +492,18 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 		align = 1UL << ilog2(offset);
 	mode = le32_to_cpu(pfn_sb->mode);
 
+	/*
+	 * Check whether the we support the alignment. For Dax if the
+	 * superblock alignment is not matching, we won't initialize
+	 * the device.
+	 */
+	if (!nd_supported_alignment(align) &&
+	    memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN)) {
+		dev_err(&nd_pfn->dev, "init failed, settings mismatch\n");
+		dev_dbg(&nd_pfn->dev, "align: %lx:%lx\n", nd_pfn->align, align);
+		return -EINVAL;
+	}
+
 	if (!nd_pfn->uuid) {
 		/*
 		 * When probing a namepace via nd_pfn_probe() the uuid
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 381e872bfde0..d5cfea3d8b86 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -110,7 +110,12 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
 
 	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
 		return true;
-
+	/*
+	 * For dax let's try to do hugepage fault always. If we don't support
+	 * hugepages we will not have enabled namespaces with hugepage alignment.
+	 * This also means we try to handle hugepage fault on device with
+	 * smaller alignment. But for then we will return with VM_FAULT_FALLBACK
+	 */
 	if (vma_is_dax(vma))
 		return true;
 
-- 
2.21.0

