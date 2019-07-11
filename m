Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D44FC74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF4C62166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sYC68pAg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF4C62166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 628F08E00DA; Thu, 11 Jul 2019 10:27:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58BB18E00C4; Thu, 11 Jul 2019 10:27:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DDF98E00DA; Thu, 11 Jul 2019 10:27:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16F048E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:27:15 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id c5so6906174iom.18
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:27:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=44bGpNhDn4CQMJWfcA7dlBtv4lKR0GVNyXSLf3OmODU=;
        b=pCh4uDFC4XTL4WcSU0wuXIeIUkorjXDot+y2+4jEE8RoxkJtT1lJH9juewRxfzrDi3
         WuAWabhtXVYbXt9bq0XRRaE9W+Bij5XzTppglk8an3q96agwDGdvTOBiQ8BfTc9Dvrto
         SKDYZAT1f6mDZWft9RRH18fYsGPLqktQKj3ni2AqFKdmFGD9dyUUnQjsgu5GxkberAgS
         atjgP0qREbQbIHA8XCF50YJOE/0c2arHf3yetw/dLFl9tzusey+mym69DMVUEHaG1YKa
         KSa5wa3fSIvSfkzEh3pl1h120DDabY3xqqNhQbEuFf5vanwKz98dlDAVJ5wkUnsgqC0I
         eldw==
X-Gm-Message-State: APjAAAUUrKweYkyKfSclYsBJhZPwTPslkbVa3j1EsCx2k7dn+0HUeCtP
	w7RAsKWccPWm371Au2xgum0ZTtwJHojlLcsIrPvKVaHE30EPzfYLruLim0tFLjlnUiK5FlcoPC0
	ohoj87J6AGZ8avtSu2hPrKhjkjsecTYhMsCs4jHN393g7Vm+ywdy6LPUv2h2MNitd5Q==
X-Received: by 2002:a02:3093:: with SMTP id q141mr4960915jaq.128.1562855234866;
        Thu, 11 Jul 2019 07:27:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx3JkDeJKtCxBqVSCeUIqJnOuzov8HrqcpnK9a9zqX+fscGxJvEeAJYuz6e1cSdeWxUTeD
X-Received: by 2002:a02:3093:: with SMTP id q141mr4960846jaq.128.1562855234036;
        Thu, 11 Jul 2019 07:27:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855234; cv=none;
        d=google.com; s=arc-20160816;
        b=qqc9rGT3yFowwWs8IFINc9KYAPWwodVCqvyKkoCbcj5BWz2sRG52nOIf9CRUmZHoj4
         oAXc5vU0xRGWJasY7P7t81rviuWNL0nXkM7TeMq7EtLPEuIpTxV54/EBhhGWFp7B1Cgb
         aA4i/0jFjboyqvqlZnusbQWl/4TeWglJGxc0xdfbYyI9YK7aAJPm03cL+/vovz8b6Mc9
         8Z9w4e9VjfBr2Unom/dJ+nHTFPSgLt1ydGB+DEIIv0ruQ62qhDf85TZKyI2/ZHvBYbhn
         ZhY3NUf0LP5H5bXOdiqH/NRWmamg3CN+A+IX0sg1DYZpuRccns5iTiP1PTvQenqmG7td
         cqZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=44bGpNhDn4CQMJWfcA7dlBtv4lKR0GVNyXSLf3OmODU=;
        b=r5OMBZ3h5L/OovWYRfJIQ1L7gSyLbqDfmolcOMEA+u+2RJPPT+OTAiH4q1b/GhXY3e
         FJkHtfp+MwSOshydpHRmZp5noaqNFesaoPDqiWF4WWCSrtK1Pq4qK6TllSyLWnkyZrJv
         SRs0b4Uu4LnGDT/pmhDtup4e8g/RzoPUX1NdjD16/CbsPNYqrSKUVxKQgxVjlnnw7pNW
         HrEae8Xb7btL96Ykym0dEygCsNiWzO9nbJ0jKRlxCEz5SB9anazmhoHnEVDanOZSW4g6
         zevcsl4u+3pMY+NoCoje467ZC7M6+gBg3jkkECHR6Eu1RzLDtgdHOiOo/8LoU0icFU/k
         dZ9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sYC68pAg;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f1si8316787jaa.44.2019.07.11.07.27.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:27:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sYC68pAg;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO8ft001446;
	Thu, 11 Jul 2019 14:27:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=44bGpNhDn4CQMJWfcA7dlBtv4lKR0GVNyXSLf3OmODU=;
 b=sYC68pAgGYMeZCzOFkUOuj4EApQvKlshFt7mE2WAdPKV4oXjKlwvx1k4YJanPkydZ+Rn
 nhL5rnoahTfhc8IS1gDxcvz2TkFDuiQbUpBXbrUM3d7hA1hqNT1LXCfxGliFZOD6TdOF
 /3LBjw+5bGaWzvBtKCMuwVIUzbBatm/N7BwPJzQJCnQfj9Csi3AeniX/ps6uYP+y0BkL
 obw32Tp/dAVmexQz4kk3ptW1s2ArR2RXMrCD7YlTDm2ZoFxL1jsctlJFVVEs2mdJMt1K
 kWQize+PYuE3+4ce/ZZAOApqTAW4neDTZZCWGAKbNKb/yPwlRIT1dU+LMDkfey1//U/x dQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0e4a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:27:03 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuH021444;
	Thu, 11 Jul 2019 14:27:00 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 24/26] KVM: x86/asi: Populate the KVM ASI page-table
Date: Thu, 11 Jul 2019 16:25:36 +0200
Message-Id: <1562855138-19507-25-git-send-email-alexandre.chartre@oracle.com>
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

Add mappings to the KVM ASI page-table so that KVM can run with its
address space isolation without faulting too much.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/vmx/isolation.c |  155 ++++++++++++++++++++++++++++++++++++++++-
 arch/x86/kvm/vmx/vmx.c       |    1 -
 arch/x86/kvm/vmx/vmx.h       |    3 +
 3 files changed, 154 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kvm/vmx/isolation.c b/arch/x86/kvm/vmx/isolation.c
index 644d8d3..d82f6b6 100644
--- a/arch/x86/kvm/vmx/isolation.c
+++ b/arch/x86/kvm/vmx/isolation.c
@@ -5,7 +5,7 @@
  * KVM Address Space Isolation
  */
 
-#include <linux/module.h>
+#include <linux/kvm_host.h>
 #include <linux/moduleparam.h>
 #include <linux/printk.h>
 #include <asm/asi.h>
@@ -14,8 +14,11 @@
 #include "vmx.h"
 #include "x86.h"
 
-#define VMX_ASI_MAP_FLAGS	\
-	(ASI_MAP_STACK_CANARY | ASI_MAP_CPU_PTR | ASI_MAP_CURRENT_TASK)
+#define VMX_ASI_MAP_FLAGS (ASI_MAP_STACK_CANARY |	\
+			   ASI_MAP_CPU_PTR |		\
+			   ASI_MAP_CURRENT_TASK |	\
+			   ASI_MAP_RCU_DATA |		\
+			   ASI_MAP_CPU_HW_EVENTS)
 
 /*
  * When set to true, KVM #VMExit handlers run in isolated address space
@@ -34,9 +37,153 @@
 static bool __read_mostly address_space_isolation;
 module_param(address_space_isolation, bool, 0444);
 
+/*
+ * Map various kernel data.
+ */
+static int vmx_isolation_map_kernel_data(struct asi *asi)
+{
+	int err;
+
+	/* map context_tracking, used by guest_enter_irqoff() */
+	err = ASI_MAP_CPUVAR(asi, context_tracking);
+	if (err)
+		return err;
+
+	/* map irq_stat, used by kvm_*_cpu_l1tf_flush_l1d */
+	err = ASI_MAP_CPUVAR(asi, irq_stat);
+	if (err)
+		return err;
+	return 0;
+}
+
+/*
+ * Map kvm module and data from that module.
+ */
+static int vmx_isolation_map_kvm_data(struct asi *asi, struct kvm *kvm)
+{
+	int err;
+
+	/* map kvm module */
+	err = asi_map_module(asi, "kvm");
+	if (err)
+		return err;
+
+	err = asi_map_percpu(asi, kvm->srcu.sda,
+			     sizeof(struct srcu_data));
+	if (err)
+		return err;
+
+	return 0;
+}
+
+/*
+ * Map kvm-intel module and generic x86 data.
+ */
+static int vmx_isolation_map_kvm_x86_data(struct asi *asi)
+{
+	int err;
+
+	/* map current module (kvm-intel) */
+	err = ASI_MAP_THIS_MODULE(asi);
+	if (err)
+		return err;
+
+	/* map current_vcpu, used by vcpu_enter_guest() */
+	err = ASI_MAP_CPUVAR(asi, current_vcpu);
+	if (err)
+		return (err);
+
+	return 0;
+}
+
+/*
+ * Map vmx data.
+ */
+static int vmx_isolation_map_kvm_vmx_data(struct asi *asi, struct vcpu_vmx *vmx)
+{
+	struct kvm_vmx *kvm_vmx;
+	struct kvm_vcpu *vcpu;
+	struct kvm *kvm;
+	int err;
+
+	vcpu = &vmx->vcpu;
+	kvm = vcpu->kvm;
+	kvm_vmx = to_kvm_vmx(kvm);
+
+	/* map kvm_vmx (this also maps kvm) */
+	err = asi_map(asi, kvm_vmx, sizeof(*kvm_vmx));
+	if (err)
+		return err;
+
+	/* map vmx (this also maps vcpu) */
+	err = asi_map(asi, vmx, sizeof(*vmx));
+	if (err)
+		return err;
+
+	/* map vcpu data */
+	err = asi_map(asi, vcpu->run, PAGE_SIZE);
+	if (err)
+		return err;
+
+	err = asi_map(asi, vcpu->arch.apic, sizeof(struct kvm_lapic));
+	if (err)
+		return err;
+
+	/*
+	 * Map additional vmx data.
+	 */
+
+	if (vmx_l1d_flush_pages) {
+		err = asi_map(asi, vmx_l1d_flush_pages,
+			      PAGE_SIZE << L1D_CACHE_ORDER);
+		if (err)
+			return err;
+	}
+
+	if (enable_pml) {
+		err = asi_map(asi, vmx->pml_pg, sizeof(struct page));
+		if (err)
+			return err;
+	}
+
+	err = asi_map(asi, vmx->guest_msrs, PAGE_SIZE);
+	if (err)
+		return err;
+
+	err = asi_map(asi, vmx->vmcs01.vmcs, PAGE_SIZE << vmcs_config.order);
+	if (err)
+		return err;
+
+	err = asi_map(asi, vmx->vmcs01.msr_bitmap, PAGE_SIZE);
+	if (err)
+		return err;
+
+	err = asi_map(asi, vmx->vcpu.arch.pio_data, PAGE_SIZE);
+	if (err)
+		return err;
+
+	return 0;
+}
+
 static int vmx_isolation_init_mapping(struct asi *asi, struct vcpu_vmx *vmx)
 {
-	/* TODO: Populate the KVM ASI page-table */
+	int err;
+
+	err = vmx_isolation_map_kernel_data(asi);
+	if (err)
+		return err;
+
+	err = vmx_isolation_map_kvm_data(asi, vmx->vcpu.kvm);
+	if (err)
+		return err;
+
+	err = vmx_isolation_map_kvm_x86_data(asi);
+	if (err)
+		return err;
+
+	err = vmx_isolation_map_kvm_vmx_data(asi, vmx);
+	if (err)
+		return err;
 
 	return 0;
 }
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index 9b92467..d47f093 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -201,7 +201,6 @@
 	[VMENTER_L1D_FLUSH_NOT_REQUIRED] = {"not required", false},
 };
 
-#define L1D_CACHE_ORDER 4
 void *vmx_l1d_flush_pages;
 
 static int vmx_setup_l1d_flush(enum vmx_l1d_flush_state l1tf)
diff --git a/arch/x86/kvm/vmx/vmx.h b/arch/x86/kvm/vmx/vmx.h
index 09c1593..e8de23b 100644
--- a/arch/x86/kvm/vmx/vmx.h
+++ b/arch/x86/kvm/vmx/vmx.h
@@ -11,6 +11,9 @@
 #include "ops.h"
 #include "vmcs.h"
 
+#define L1D_CACHE_ORDER 4
+extern void *vmx_l1d_flush_pages;
+
 extern const u32 vmx_msr_index[];
 extern u64 host_efer;
 
-- 
1.7.1

