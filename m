Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF4F7C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9773921976
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 09:14:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9773921976
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A6CA6B0276; Tue,  4 Jun 2019 05:14:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20C976B0277; Tue,  4 Jun 2019 05:14:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0338E6B0278; Tue,  4 Jun 2019 05:14:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5CAE6B0276
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 05:14:26 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id t141so19085162ywe.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 02:14:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=jU7nJGZqz3W+OPqACHi+vSvZlVzpNc8/McjlBMHYsnE=;
        b=lI7jWWMbKGOtV0IQVSWBVi252/Sijtg+tIHLgHi0EratrryqaTWzz30s60J1y3IZD2
         acMhu4G/R/plLSDwi5tMn3r61hPB4iH2PByO4clwAFvpJO8/QA9JyPEZA05dXpDOeWXY
         EGk/555V87Cw89y/KaPG+xGmtIGg0MBrI7WuKWi9qH4u+MNSkzG6caXRNzNRZ22v5+h5
         /nFzGkztbWoHKN9LKMUPBuiQG9Hf0FdFRfb6ffVmWxmYc99MTFGdbU0vWgXbZOCIG7b7
         iq09o32evbnCtVhtXEVto9NH4yITKtU3Dh5tUytoFNEEqS9Qx3gA32dbc3ljH2tQs9iL
         dVYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUXfJuQqKF8hlR0lWiLfDYGwQ6YkOFp/wgLrIu+MCY1ddHpQaui
	IVEfoPXqPlTzCrCWg1f+pxDAwbGoZNuS8lyjEU+3ZErqPoTyk1lBUkq0Hic6CmVQgGAe9BzX57r
	ejuRbZ/3J9GWslQBuAiKKJp2HP0/anfaa63Gay8taVhjNeLtNdqHPQBpB4U+Xs5sKng==
X-Received: by 2002:a25:7712:: with SMTP id s18mr14242406ybc.263.1559639666562;
        Tue, 04 Jun 2019 02:14:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzaPo8kCnZxOPcr2GMgJgUPLiDEhFthaym2zpQ21SfDg0BbjneYWM01B043eosn17Z3x/q
X-Received: by 2002:a25:7712:: with SMTP id s18mr14242372ybc.263.1559639665457;
        Tue, 04 Jun 2019 02:14:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559639665; cv=none;
        d=google.com; s=arc-20160816;
        b=unCjTB+WcqAPsp/hG3HAyqYxvWcCro6G1+PLottulVOKg1heNocxBghkhNL1XD3IG6
         LXnjj6teVtJrPM4OAtvC1FZ67t5gMl8T0N1F+MMznfJ4EvgFu1sWz8d29HOcp5T3qi5t
         8qidq40ceHUjkTPHQpsDmLAo/U3TjnRoM5orol7EhxVr4CEaDif9qcl/iUUjMHAL5VqD
         S+j6L8qm6J7O0p+c6mAFTepbCovHPxO2FpgYcJXwgMfhmGXj6kaTaYIfoUwig/Tp1G8Q
         rn1VW/ChJFsgf8chSvVyHPaL8A2KMPRzuJQ8/UOEl61VR5b3FQxv3stqgV528NnIUZxj
         tYgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=jU7nJGZqz3W+OPqACHi+vSvZlVzpNc8/McjlBMHYsnE=;
        b=gJks0iZ6hOf1O8VY6TL26QPUD05djq917yeaEG+6L1Vm4XTDx4/E7CLS6qvXdHuv9l
         a1qMIqgsxkFbqGVc0E0ZytS4VNr3B5QSK9wrTC0bcGaRpFupng/u2EjBjZ+isRG36YG9
         BRmwVYenI/3O6AGR8Qdy920gcylT/70HWHwOkBKw8zUszJBlAfDPMrSTJXT1gwkTYR9W
         ZCmjWXjkelHXchm0GuHIxhiAkKkW7AXQITEORdnIA2YtkP4RUgHytMmP90fe1DyD6wSP
         y/m07VjosXvztEqye+J3Y3AvuJfunVMoE79j3UO5MACAJQ+UC1bPG06Mozc5l2kl4Qoh
         MHWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 127si4835519ybu.373.2019.06.04.02.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 02:14:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5497Zka072920
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 05:14:25 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2swjwvqxqg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:14:24 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Jun 2019 10:14:24 +0100
Received: from b01cxnp23034.gho.pok.ibm.com (9.57.198.29)
	by e12.ny.us.ibm.com (146.89.104.199) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 10:14:20 +0100
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x549EKjY34603294
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 09:14:20 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E614AAC05B;
	Tue,  4 Jun 2019 09:14:19 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7647CAC068;
	Tue,  4 Jun 2019 09:14:18 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.234])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 09:14:18 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v3 5/6] mm/nvdimm: Pick the right alignment default when creating dax devices
Date: Tue,  4 Jun 2019 14:43:56 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
References: <20190604091357.32213-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19060409-0060-0000-0000-0000034BD866
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011212; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01213037; UDB=6.00637528; IPR=6.00994104;
 MB=3.00027178; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-04 09:14:22
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060409-0061-0000-0000-0000499E0C1C
Message-Id: <20190604091357.32213-5-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040061
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

This also addresses the below failure scenario on ppc64

ndctl create-namespace --mode=devdax  | grep align
 "align":16777216,
 "align":16777216

cat /sys/devices/ndbus0/region0/dax0.0/supported_alignments
 65536 16777216

daxio.static-debug  -z -o /dev/dax0.0
  Bus error (core dumped)

  $ dmesg | tail
   lpar: Failed hash pte insert with error -4
   hash-mmu: mm: Hashing failure ! EA=0x7fff17000000 access=0x8000000000000006 current=daxio
   hash-mmu:     trap=0x300 vsid=0x22cb7a3 ssize=1 base psize=2 psize 10 pte=0xc000000501002b86
   daxio[3860]: bus error (7) at 7fff17000000 nip 7fff973c007c lr 7fff973bff34 code 2 in libpmem.so.1.0.0[7fff973b0000+20000]
   daxio[3860]: code: 792945e4 7d494b78 e95f0098 7d494b78 f93f00a0 4800012c e93f0088 f93f0120
   daxio[3860]: code: e93f00a0 f93f0128 e93f0120 e95f0128 <f9490000> e93f0088 39290008 f93f0110

The failure was due to guest kernel using wrong page size.

The namespaces created with 16M alignment will appear as below on a config with
16M page size disabled.

$ ndctl list -Ni
[
  {
    "dev":"namespace0.1",
    "mode":"fsdax",
    "map":"dev",
    "size":5351931904,
    "uuid":"fc6e9667-461a-4718-82b4-69b24570bddb",
    "align":16777216,
    "blockdev":"pmem0.1",
    "supported_alignments":[
      65536
    ]
  },
  {
    "dev":"namespace0.0",
    "mode":"fsdax",    <==== devdax 16M alignment marked disabled.
    "map":"mem",
    "size":5368709120,
    "uuid":"a4bdf81a-f2ee-4bc6-91db-7b87eddd0484",
    "state":"disabled"
  }
]

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
index 191d62af0e51..524be92c1cd0 100644
--- a/drivers/nvdimm/nd.h
+++ b/drivers/nvdimm/nd.h
@@ -296,12 +296,6 @@ static inline struct device *nd_btt_create(struct nd_region *nd_region)
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
index d137f52f46ee..9855357c9040 100644
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
@@ -505,6 +523,18 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 		return -EOPNOTSUPP;
 	}
 
+	/*
+	 * Check whether the we support the alignment. For Dax if the
+	 * superblock alignment is not matching, we won't initialize
+	 * the device.
+	 */
+	if (!nd_supported_alignment(align) &&
+	    !memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN)) {
+		dev_err(&nd_pfn->dev, "init failed, alignment mismatch: "
+			"%lx:%lx\n", nd_pfn->align, align);
+		return -EOPNOTSUPP;
+	}
+
 	if (!nd_pfn->uuid) {
 		/*
 		 * When probing a namepace via nd_pfn_probe() the uuid
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7cd5c150c21d..64d16794bb27 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -108,7 +108,12 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
 
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

