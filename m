Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CE5AC74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 208F22166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LYEr+9/u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 208F22166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 341B58E00D9; Thu, 11 Jul 2019 10:27:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CB698E00C4; Thu, 11 Jul 2019 10:27:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16BF98E00D9; Thu, 11 Jul 2019 10:27:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id DEB488E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:27:11 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id h3so6951210iob.20
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:27:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=R7Xfip06p699muIVGHbRVSpcUyRHanu29pNDIpaJD54=;
        b=qp+C1QJ9y1Lg/RytDcG5BgEwRzJRL1RbRbtf3330AH/VjmkGWPWeFVrUkMNipvxK9v
         UEvpQ5jiztBH2XJbkLVKtxbVEEaQzXz/ptanKEGKjMlF4l8+Ofe1y5SVubhSG7fuLM4f
         pbl+vnI84KMXw2rSAiJxjvH+Z6ozkDgLfhmh5Gpjc+mAuot7xd1XRovWJLTyzCq8tObU
         XBA8YgZ7rtnPhwqyIFVyYoDOEXaT1szdusxM9PFWuRhxQbdGxnHjJGlxwwqHCDrIMKdr
         NVCf6JqZoFj1EAx82eEpPPB5gqM6T7K2NNF1oRoxvOO0ONNP5BQrWU9h4AoNKVcS9MM/
         JOOA==
X-Gm-Message-State: APjAAAWM33VIuNdH89h84DJN8JF84Jh1gl9o++ajbrqzHZwsEoZHFGPr
	beRAxI1uURGiHFhY59tnf5EIPUGjyaVgsJkMgga0yaJ95VRT0jfQUC0S3iETq9aim6hYCjVKdyc
	sQ851qzlIzkk+X3Xsn76fGnVTd83mjFQ4lsdDeiukMOSm7KH7D7+TwVdkLDWrFpjmWA==
X-Received: by 2002:a6b:5103:: with SMTP id f3mr587517iob.142.1562855231661;
        Thu, 11 Jul 2019 07:27:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7ECHKQ2f7hZwF0jY9gg0NOF5NdD+0PPtXIE+BNEroqN7fMCZozDADEyX33L3/3/sQfsLb
X-Received: by 2002:a6b:5103:: with SMTP id f3mr587449iob.142.1562855230986;
        Thu, 11 Jul 2019 07:27:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855230; cv=none;
        d=google.com; s=arc-20160816;
        b=eKRj/sdoIMCWdm+TtQhioNDmtW0kVBWOiB3w+IVfbaOBMvj2aWt0scG3Jchath9/6X
         2JnVadnZyzdMQvCbplDCV3XX8XWxUjeKSEjdBkMPUFOmAgvzmUPstgzDXILxvLOj7eJ4
         RHbfQs06qqi1BM6YIQfR/BVJUPnwDmNYSv/pQDoYEYMw7EuTBSroXoxSHneAEcl5Olyz
         qJL9X3a6uSoOFALIfhDVGN9dutzEKHBMqccu3kYGCyQJ4AlTvG6ZcBSi9TOXhb01XJ7g
         m4lnw/bU5hkGboTZdeku4025oZg5h2gVKtoxtSyXv1atesaj1todn4xzFeG2q7uuePCu
         E5fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=R7Xfip06p699muIVGHbRVSpcUyRHanu29pNDIpaJD54=;
        b=0sOKxK+mQ9aLwJibUkKy5Lc7QN7yyoatt8O1SL0s61k3TAoqxIFnKN3/QkTiB0ykqh
         P9QYRZiNM1TAgrJr/jxWdJEZEToZQOFox7GdC1vIFXbxf/ET0jiM1jyaRx5JYhmFtJUg
         rzwAWcTdi3H7YRUfhbvIM500tUaW0ooeKuYsObjvnURvH0afgW/pYaI3jRqREP7D6aZ6
         gz1Ofy545QotQrSIhqj8mBOpc5apByRJ8faFsTy1gkz9VCLgJxD4OUBjuPM5/PqNDWlw
         585uejGQ9DXqrdbkhFLAR5Rq+kRTW01s2nxYDOVUB0fJyJ7xSIrl7vOIPmn4lPDIs63V
         tI1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="LYEr+9/u";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p24si8131931ioj.51.2019.07.11.07.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:27:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="LYEr+9/u";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEOGvb100511;
	Thu, 11 Jul 2019 14:27:02 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=R7Xfip06p699muIVGHbRVSpcUyRHanu29pNDIpaJD54=;
 b=LYEr+9/uvSyvI7OVyk9UP5FJcmH4YzsINobd9Ws4d1Sn7zQRqsU665EFWo2tRiz/cBWH
 TQPi+azMpPQ50ca6ZxpYu/g0a8JuwQaUyBMwUTLzLIprNNem/R910eIUU8P5Bv98N3Zz
 VQLKGIpKXFE80COh/4g3j2DCRhhYcgvjn2KBcjXSAHnxcqRegfAAZE4hnlxbfYZgQOEd
 YTBZwZfCqCbfS+eDaW7yYwGctCL21NUDe7ydmDXBTvwj7gQ1BR2oLXZZ5z2nmPV3Av6O
 uW3d4XWaCBCFsg3LcCI9MxRw/Tgth3Gipeew1Xr8UIl8LL6WLVneXw3ZkgDZG2ZEH0Xh 4A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2tjkkq0cdp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:27:02 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuF021444;
	Thu, 11 Jul 2019 14:26:53 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 22/26] KVM: x86/asi: Introduce address_space_isolation module parameter
Date: Thu, 11 Jul 2019 16:25:34 +0200
Message-Id: <1562855138-19507-23-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

Add the address_space_isolation parameter to the kvm module.

When set to true, KVM #VMExit handlers run in isolated address space
which maps only KVM required code and per-VM information instead of
entire kernel address space.

This mechanism is meant to mitigate memory-leak side-channels CPU
vulnerabilities (e.g. Spectre, L1TF and etc.) but can also be viewed
as security in-depth as it also helps generically against info-leaks
vulnerabilities in KVM #VMExit handlers and reduce the available
gadgets for ROP attacks.

This is set to false by default because it incurs a performance hit
which some users will not want to take for security gain.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/Makefile        |    3 ++-
 arch/x86/kvm/vmx/isolation.c |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 1 deletions(-)
 create mode 100644 arch/x86/kvm/vmx/isolation.c

diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
index 31ecf7a..71579ed 100644
--- a/arch/x86/kvm/Makefile
+++ b/arch/x86/kvm/Makefile
@@ -12,7 +12,8 @@ kvm-y			+= x86.o mmu.o emulate.o i8259.o irq.o lapic.o \
 			   i8254.o ioapic.o irq_comm.o cpuid.o pmu.o mtrr.o \
 			   hyperv.o page_track.o debugfs.o
 
-kvm-intel-y		+= vmx/vmx.o vmx/vmenter.o vmx/pmu_intel.o vmx/vmcs12.o vmx/evmcs.o vmx/nested.o
+kvm-intel-y		+= vmx/vmx.o vmx/vmenter.o vmx/pmu_intel.o vmx/vmcs12.o \
+			   vmx/evmcs.o vmx/nested.o vmx/isolation.o
 kvm-amd-y		+= svm.o pmu_amd.o
 
 obj-$(CONFIG_KVM)	+= kvm.o
diff --git a/arch/x86/kvm/vmx/isolation.c b/arch/x86/kvm/vmx/isolation.c
new file mode 100644
index 0000000..e25f663
--- /dev/null
+++ b/arch/x86/kvm/vmx/isolation.c
@@ -0,0 +1,26 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
+ *
+ * KVM Address Space Isolation
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+
+/*
+ * When set to true, KVM #VMExit handlers run in isolated address space
+ * which maps only KVM required code and per-VM information instead of
+ * entire kernel address space.
+ *
+ * This mechanism is meant to mitigate memory-leak side-channels CPU
+ * vulnerabilities (e.g. Spectre, L1TF and etc.) but can also be viewed
+ * as security in-depth as it also helps generically against info-leaks
+ * vulnerabilities in KVM #VMExit handlers and reduce the available
+ * gadgets for ROP attacks.
+ *
+ * This is set to false by default because it incurs a performance hit
+ * which some users will not want to take for security gain.
+ */
+static bool __read_mostly address_space_isolation;
+module_param(address_space_isolation, bool, 0444);
-- 
1.7.1

