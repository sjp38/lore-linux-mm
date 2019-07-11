Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 486ECC74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F15A52166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iiyyes3p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F15A52166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E0778E00DE; Thu, 11 Jul 2019 10:27:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F04988E00DD; Thu, 11 Jul 2019 10:27:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3FF08E00DC; Thu, 11 Jul 2019 10:27:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0E38E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:27:16 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w17so6989802iom.2
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:27:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=0gU3+EHAnLmrdQwDq6KHZSyy6MdJI7eVGdpzzFAPgXk=;
        b=FT1WFsQ4ljkaMhP7fwxoJH57Ti6cVQBc5AzLVaPSdA6fhfm7MKMr5FOKCz6z6xC9wW
         YEjEtHwoLn8wpezLBjs3efoUbOQ3BI4KvIliwGU/AeSfYbaVwXdvJ5pAX9KHv+sTX1k5
         EE4uM/xaGBc0qi+BO3et6Zr2CnAP5lJyIPlIS53jFxY9R6COmknfZP97G5AhhhC/TDYc
         jVeaSZvHT2dB8VG5U3PoVa9hrc+cC9haqBV8kXiRwB64MaNFKgvkbF4v0Si0QUq36wYe
         M02hPWAvV/E4zkWZQ2DnPCwkgflCKjaYXxNenSbP+W/1xbN/b5hZRK/xGu0xizK0hM9o
         m4nA==
X-Gm-Message-State: APjAAAWDWnkCjgLNw1W5/dNGGpw5pLZIcGIDa8xIkwpnrJ7sYHccfVLQ
	Gpe/G5qSCA2+PRlt4suWaFNhJXynkEJ101G55y8rUeaiTFvbJgrSc8OjK8c9ap2eLx4dvM/Fg7J
	w5yZbVArg7KPVE8O2kgPA6EcdDquHhhtmgPdwFueWg8oOzg6cwg0qPMfQx5w934g+Ag==
X-Received: by 2002:a6b:dc13:: with SMTP id s19mr4682193ioc.53.1562855236378;
        Thu, 11 Jul 2019 07:27:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+dg2vp6x5QjuMXysOlicwZ/bRZTT+fUXicQSj1yHU21CsQlh5PwTRgrvhdxUfQwzhtH7L
X-Received: by 2002:a6b:dc13:: with SMTP id s19mr4682108ioc.53.1562855235381;
        Thu, 11 Jul 2019 07:27:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855235; cv=none;
        d=google.com; s=arc-20160816;
        b=JZE3FdX1Xq81bwG/L8LAAncxbYmqw8gTnuJW5YMra/jmDK8v0lI5/cIEo7b3NhQWNL
         KKL+uMj09TzszcHfWaZ8prLAfGcl3y2xaR5LNBBXAfwNyeHIGFa83/E8YZ3ROqKzbuc5
         8HU/hyht9MAV2tnl0J/TkYtsU+XqzQ5WvangPBq2Wx4E6hR+u/FMwywT28Q07f4J6Gkd
         sfMZ/SWE3pxxoObdmv814jMLz9NNdmIUZUvbdBGdqADi61tk81acvy8tqScEIIeu39ew
         wZY2qgjtOppm28wo8pt/2fsibq/7c+TJy9Ph7kwTOomwSj0KLLd4kbx6Cs1nCxFZVIql
         DaxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=0gU3+EHAnLmrdQwDq6KHZSyy6MdJI7eVGdpzzFAPgXk=;
        b=Wbo1ut+dX4Tvmz4jqCRSGQ8cgBF8tFzKqW/5RI5WhBoYCi/JT2GR1W678S/p7XJ+7d
         ecJeEdyYb6d5l5bCf84h+JJmgaA3BzORLYXU+ZpnPMvWticyQEIfDIq1LedIBSQVnS5V
         OV741xosPP/uzj2wQvEUXZYxJToaxHuc14XYHIBvsnBE2Cx9HarCNpcQBAYNg8no2nRX
         Jj2tRyjBNnlkoL0UggxWmNiV1+96tf7KEqqj3kmiMqz3oQpSt+xRpdCh5PO/7K89Fosr
         RlNXB4IBYNLZO4ZXFt8mVuo4uN9+rIlaiZPSn3npg4qclk1GgaECVnYJ8ct9bxjFpWh7
         ltwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iiyyes3p;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t2si9936464jam.54.2019.07.11.07.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:27:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iiyyes3p;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO8MS001456;
	Thu, 11 Jul 2019 14:27:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=0gU3+EHAnLmrdQwDq6KHZSyy6MdJI7eVGdpzzFAPgXk=;
 b=iiyyes3p413lD4tawJspczGrP6E0lodllk7rkaTrmsT9/Hc2gRBbnS6pJ51rtyC6w6oK
 s0zXzPmMoMMZfu+NfOM5wgMpW+ZwZb5dNJIjL1sOQ2wAe8I6VnoBZVNNsVBlEfHguvjZ
 UWzv4mgQ5Z/QbJM2eHak92dK2mAAiscm2gFOv4AEAAm/6hM07TfZIH/hBOE3puhP7Woq
 7qMIQ3AxCkBa3FdCnuUeCDTF3Vl7BFaFDKI8v0ZHZA9v/ppmgWW2qg65hjSCEFqy4KMB
 vWZ/Kr+eO2oRgHWyu5lBLP3blCrBHPO1SGFrwvoYGRq8pBU17+caS24D540bGjrkqGJ+ fA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0e4s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:27:05 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuG021444;
	Thu, 11 Jul 2019 14:26:57 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 23/26] KVM: x86/asi: Introduce KVM address space isolation
Date: Thu, 11 Jul 2019 16:25:35 +0200
Message-Id: <1562855138-19507-24-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

Create a separate address space for KVM that will be active when
KVM #VMExit handlers run. Up until the point which we architectully
need to access host (or other VM) sensitive data.

This patch just create the address space using address space
isolation (asi) but never makes it active yet. This will be done
by next commits.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/vmx/isolation.c |   58 ++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/vmx/vmx.c       |    7 ++++-
 arch/x86/kvm/vmx/vmx.h       |    3 ++
 include/linux/kvm_host.h     |    5 +++
 4 files changed, 72 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/vmx/isolation.c b/arch/x86/kvm/vmx/isolation.c
index e25f663..644d8d3 100644
--- a/arch/x86/kvm/vmx/isolation.c
+++ b/arch/x86/kvm/vmx/isolation.c
@@ -7,6 +7,15 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/printk.h>
+#include <asm/asi.h>
+#include <asm/vmx.h>
+
+#include "vmx.h"
+#include "x86.h"
+
+#define VMX_ASI_MAP_FLAGS	\
+	(ASI_MAP_STACK_CANARY | ASI_MAP_CPU_PTR | ASI_MAP_CURRENT_TASK)
 
 /*
  * When set to true, KVM #VMExit handlers run in isolated address space
@@ -24,3 +33,52 @@
  */
 static bool __read_mostly address_space_isolation;
 module_param(address_space_isolation, bool, 0444);
+
+static int vmx_isolation_init_mapping(struct asi *asi, struct vcpu_vmx *vmx)
+{
+	/* TODO: Populate the KVM ASI page-table */
+
+	return 0;
+}
+
+int vmx_isolation_init(struct vcpu_vmx *vmx)
+{
+	struct kvm_vcpu *vcpu = &vmx->vcpu;
+	struct asi *asi;
+	int err;
+
+	if (!address_space_isolation) {
+		vcpu->asi = NULL;
+		return 0;
+	}
+
+	asi = asi_create(VMX_ASI_MAP_FLAGS);
+	if (!asi) {
+		pr_debug("KVM: x86: Failed to create address space isolation\n");
+		return -ENXIO;
+	}
+
+	err = vmx_isolation_init_mapping(asi, vmx);
+	if (err) {
+		vcpu->asi = NULL;
+		return err;
+	}
+
+	vcpu->asi = asi;
+
+	pr_info("KVM: x86: Running with isolated address space\n");
+
+	return 0;
+}
+
+void vmx_isolation_uninit(struct vcpu_vmx *vmx)
+{
+	struct kvm_vcpu *vcpu = &vmx->vcpu;
+
+	if (!address_space_isolation || !vcpu->asi)
+		return;
+
+	asi_destroy(vcpu->asi);
+	vcpu->asi = NULL;
+	pr_info("KVM: x86: End of isolated address space\n");
+}
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index d98eac3..9b92467 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -202,7 +202,7 @@
 };
 
 #define L1D_CACHE_ORDER 4
-static void *vmx_l1d_flush_pages;
+void *vmx_l1d_flush_pages;
 
 static int vmx_setup_l1d_flush(enum vmx_l1d_flush_state l1tf)
 {
@@ -6561,6 +6561,7 @@ static void vmx_free_vcpu(struct kvm_vcpu *vcpu)
 {
 	struct vcpu_vmx *vmx = to_vmx(vcpu);
 
+	vmx_isolation_uninit(vmx);
 	if (enable_pml)
 		vmx_destroy_pml_buffer(vmx);
 	free_vpid(vmx->vpid);
@@ -6672,6 +6673,10 @@ static void vmx_free_vcpu(struct kvm_vcpu *vcpu)
 
 	vmx->ept_pointer = INVALID_PAGE;
 
+	err = vmx_isolation_init(vmx);
+	if (err)
+		goto free_vmcs;
+
 	return &vmx->vcpu;
 
 free_vmcs:
diff --git a/arch/x86/kvm/vmx/vmx.h b/arch/x86/kvm/vmx/vmx.h
index 61128b4..09c1593 100644
--- a/arch/x86/kvm/vmx/vmx.h
+++ b/arch/x86/kvm/vmx/vmx.h
@@ -525,4 +525,7 @@ static inline void decache_tsc_multiplier(struct vcpu_vmx *vmx)
 
 void dump_vmcs(void);
 
+int vmx_isolation_init(struct vcpu_vmx *vmx);
+void vmx_isolation_uninit(struct vcpu_vmx *vmx);
+
 #endif /* __KVM_X86_VMX_H */
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index d1ad38a..2a9d073 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -34,6 +34,7 @@
 #include <linux/kvm_types.h>
 
 #include <asm/kvm_host.h>
+#include <asm/asi.h>
 
 #ifndef KVM_MAX_VCPU_ID
 #define KVM_MAX_VCPU_ID KVM_MAX_VCPUS
@@ -320,6 +321,10 @@ struct kvm_vcpu {
 	bool preempted;
 	struct kvm_vcpu_arch arch;
 	struct dentry *debugfs_dentry;
+
+#ifdef CONFIG_ADDRESS_SPACE_ISOLATION
+	struct asi *asi;
+#endif
 };
 
 static inline int kvm_vcpu_exiting_guest_mode(struct kvm_vcpu *vcpu)
-- 
1.7.1

