Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5842C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55E822084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="g5WaOGjM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55E822084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEF2A6B0007; Mon, 13 May 2019 10:39:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D78EF6B0008; Mon, 13 May 2019 10:39:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C19716B000A; Mon, 13 May 2019 10:39:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id A18576B0007
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:09 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id y15so9985515iod.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=03NJAuy8gQRMw5NMdO5oIpncwVrdcNhEn/qnXsnIh+Q=;
        b=hzaFK8hVnJVyjg4MTGgXJakwvRGRjh6j8DG3hmU75JphWnfrfvWKEdTjqZyswnYItj
         qEXjuUR/rGXXjk4E3X8oJC+BuvfIJpxsnKimjizuG6LSxTWxNmPb0jEaL8zwOH9VjcJL
         qZ2L89CHSrIYLCB4IV3FEnksJ1ngL3OQq1Qpz091sBdnegicTSbVmYqGHYV5faQucfAi
         tpuZKa8hoc+MP42bT9RxOL7Aht5+mp27lORdnekt2Ve7yJ6QmJoStsBVnQIhG0iYzzW1
         CjZXAgfdUgbikwRgK9LRH5HeJzz4F5/M1767qcx6wTGfy/jAcdEeyGBN0xYjY+ehE1Rs
         Qjxw==
X-Gm-Message-State: APjAAAUEDG3sY17PX/oBhmAce+s/VWyYyuKZCL5MfSzeX1VEg+mpyTV0
	XEUruJdcbvPS2AzCXsJ7LOXfrvL+ThEs5aAn0brBLs/J4eHthY8dXiMZUlbdw1bPEz3d+RJ9vyO
	30Gq+NL7/ldC1+KO3ur+KOR9B0ZJNuqyok2tbkkA87LpdW5f3UgjTiU4lpkbrVAOmqA==
X-Received: by 2002:a02:1a45:: with SMTP id 66mr17674807jai.124.1557758349296;
        Mon, 13 May 2019 07:39:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmAEsDXCkJdMabxYV5G37EOXIhrFAI5/rbbw5RsQdWFiza607CIJKqVO6rmCcxJZjNzOoW
X-Received: by 2002:a02:1a45:: with SMTP id 66mr17674744jai.124.1557758348550;
        Mon, 13 May 2019 07:39:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758348; cv=none;
        d=google.com; s=arc-20160816;
        b=pNYF/ZqkUvIUU24sB7Ko/wuMehgceK+XAXO5PxEleFRhaOQPPUDLzccgOo9x6QqoMk
         Ci7HGiyzcYnpJg25/LwcgFRCbd1tVtc7TYWameGJtK/KLpYbXSHcUZgCcx6bA4Noz1dC
         pdF1/08GWGpXIAMgq/5xtZMwwJICaZpQWO0Cki+5aJCyYX4G0N/9DLypr66gHVulIjev
         vBO5Nbx2pGbxLLKGEL+rAcrjASSdQu6W5/IBDWE5/kJ+woYOCiPAfuiG0PLeBRvxzixl
         oQvYCRmXg+tAgYueh0APyoVTjfbHMHqd0jJyFw5gDizjH52ouOooioNRXSqRzszqKyHm
         vvBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=03NJAuy8gQRMw5NMdO5oIpncwVrdcNhEn/qnXsnIh+Q=;
        b=iL0u9YCcBcxk14eMcOK0ZXCJPND+iK/UFoop3jbnvQf/Gl2lpD4bmT+tvPoHNKj0uz
         r8naNgcmMyuWYlcetIB0MMOarPbgoIt6FWgY5qo3nhpehbeKQe+6utoDH2KG4wAjuMeT
         aVh0E3Yjl2U49NWFVa+/o13/ZKQVbu/0ckRzjqx74XGtQAlM8uaih6VGtX3DSVM6NV4v
         nvLAEjAFhCH/MYeb6fb7PXtlxeooC3pEyyzLoaDrh0BdOxIYRR20IyaZ7Nn7IjV4Z4a+
         fkiOzAappmmoUHYa3v8q79+iHUr2Sb3Vu0ts6Lani9CXw1xHL5G66+Ykw+Ap6fwUXVU9
         cUMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=g5WaOGjM;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o192si8317943itb.38.2019.05.13.07.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=g5WaOGjM;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DESr12184826;
	Mon, 13 May 2019 14:38:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=03NJAuy8gQRMw5NMdO5oIpncwVrdcNhEn/qnXsnIh+Q=;
 b=g5WaOGjMCQGcw3yFQID9Xz5SR+orOYV1jEvqta9pP1dW+3vk6S7rk3Xf0Xqs9c72Ro1w
 /TCodkQB+5Z4YQjeExvs0QvsKAbjAzfxUXW21GiZ7ZoPR7nSWQ/5N76ENeSlLIaBPOuq
 oraTRR4s8rulSGRtJmfzQ6I6tr45ficozvt9Zf9IR0tS1V0R/j/qCwAykrzu4TBWku12
 vyAVK6nNFxTgtyozBfwL3irrf/S3fPxxNjChwJoT7jqQ+3BTuw9SWcfOTckw2b1l05Nd
 oG/FOBhG00v9BsVeDYzcuV3eTXQRhjHKRHxD7Luw1u+N5LvXr+eEUi8yT9Gj8XmE4JX0 Bg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7aqq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:38:48 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQ5022780;
	Mon, 13 May 2019 14:38:45 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 02/27] KVM: x86: Introduce address_space_isolation module parameter
Date: Mon, 13 May 2019 16:38:10 +0200
Message-Id: <1557758315-12667-3-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130102
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
 arch/x86/kvm/Makefile    |    2 +-
 arch/x86/kvm/isolation.c |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 1 deletions(-)
 create mode 100644 arch/x86/kvm/isolation.c

diff --git a/arch/x86/kvm/Makefile b/arch/x86/kvm/Makefile
index 31ecf7a..9f404e9 100644
--- a/arch/x86/kvm/Makefile
+++ b/arch/x86/kvm/Makefile
@@ -10,7 +10,7 @@ kvm-$(CONFIG_KVM_ASYNC_PF)	+= $(KVM)/async_pf.o
 
 kvm-y			+= x86.o mmu.o emulate.o i8259.o irq.o lapic.o \
 			   i8254.o ioapic.o irq_comm.o cpuid.o pmu.o mtrr.o \
-			   hyperv.o page_track.o debugfs.o
+			   hyperv.o page_track.o debugfs.o isolation.o
 
 kvm-intel-y		+= vmx/vmx.o vmx/vmenter.o vmx/pmu_intel.o vmx/vmcs12.o vmx/evmcs.o vmx/nested.o
 kvm-amd-y		+= svm.o pmu_amd.o
diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
new file mode 100644
index 0000000..e25f663
--- /dev/null
+++ b/arch/x86/kvm/isolation.c
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

