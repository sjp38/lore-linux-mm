Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59F93C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 121392084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sPuRCB7A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 121392084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D1E56B000E; Mon, 13 May 2019 10:39:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 937596B0010; Mon, 13 May 2019 10:39:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7393A6B0266; Mon, 13 May 2019 10:39:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50DB96B000E
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:13 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id l193so2754622ita.8
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=k+F2ikPI91eVYLszQvHNmFnwWVR/o1Jhouj4HTjs9uc=;
        b=b6infYx7IQ1ziFj9MMmNigNJphzbSFVgfXvt35l7gYUzGgWDYSH6RroqtiqbUgy4C7
         m93sB4F9bJ0D0r2R++ADmgjLoBNNVLUdrAshnxqmCOs3erjwmnsWtbpxJgZj5R1s/QuF
         933qyjk9dzh/e9Y6p2J2SZt5kT2PDlj5CwV1JtNWQMAMQ0NT0UIXBsy5dTuoMcBfc1gQ
         Ta0XQ4/Moe2tC0d+20xf5IRjdDu8oJXG45Ncc8JZyq/ASmQEBnIWdVm1f0V4y/HPucEM
         75lq+UwDzqghKj5n/BpYr2ZQPiRFpe/bAovno0HvukdmyxwTGri1biB4UZLapLZ1HcQE
         muHg==
X-Gm-Message-State: APjAAAUrT7PsWohhPKqUi/Sut6a1gC2Bc6iIr8caThDRmLvO6nCvkpZr
	a92xeIVXC7LQHfC/rXrVuDhvr8ymPXQYtuLFQ7TKb4hVZ4SQWistsB2j2Ihr309j16lGAkIkb8G
	6Mxe6vyDwMRU3LRsyMR1zr6IULKY62cPQS2ydovKLSL4aiyY6HFgR7E0seKf687OjZA==
X-Received: by 2002:a02:b895:: with SMTP id p21mr20003737jam.80.1557758353043;
        Mon, 13 May 2019 07:39:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNasLAbNJSVN/xkQ3g1I3hYCD0qA/QK1ArVNurZOHqESslaPxyWzRzBx9T+q3AkoP2ZDac
X-Received: by 2002:a02:b895:: with SMTP id p21mr20003700jam.80.1557758352431;
        Mon, 13 May 2019 07:39:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758352; cv=none;
        d=google.com; s=arc-20160816;
        b=K7MRQwqyr7+fSo45+0iy2kc61KcYdwV7HhNakTrd31507Q7BePUDsuUWtFlHYXD/dd
         a9QoM2PW5jIQe2e29I5FwPqq+pdK0a2F7DRyCkkZ1qlpkF8hzpW/qufRz7quKHvTMJ0j
         Z42WkhkwVXSzAsrnd9DicBrc3VKtV6ABrh05AxQ3G/S1Pgir2BPlr/edgRyoLxp0NzGw
         ZBl2o4mRH9dQcOcoRnD5UB6dKFyihRJfioX7Zg9B6E87yyV16xFDtnSle3zL73VLg8QH
         U2qv0gtdg5w0ExKNIe7D/kWapONEUSecGDI24nmVFySu5bU2IgCA33xXAvi/8zJ2++0J
         Y+6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=k+F2ikPI91eVYLszQvHNmFnwWVR/o1Jhouj4HTjs9uc=;
        b=uAw46+HRV8IisIiUtfCBgayuDYvCH+M++C4OgyjV0T400U/JB44pvq0VOYIn2+z2NS
         76yJQXosjWslnXqmbtZbo8LVSFoghdg702Q23Uj0+0SnO7wLmJBGhwCNMusThbTHcp6U
         ne6OhpUocFEAtcwnXO0t2a0Td6Ki6C76KMkObWgIUFK+ucfwVZjfCQdTdaGDmOyXARlN
         98yRhLzF2bvu44uOO5UugwenHRYx0ymybDAu/fAMgumNDhq0YShZ/5zog4HmeSNzhtmx
         +77gDICZDcndsI0t3I8FtzYpxNFZPCfE+tqKzJIT/tGwGE5ATUVk2qaspuq3QyrFoTvK
         qT1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sPuRCB7A;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b8si8497089itl.66.2019.05.13.07.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sPuRCB7A;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd4le195008;
	Mon, 13 May 2019 14:39:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=k+F2ikPI91eVYLszQvHNmFnwWVR/o1Jhouj4HTjs9uc=;
 b=sPuRCB7AsbZZWT9m3DPio3N73cCl1qZSGvYcOtO5wcwsHy2zHWKroJG67uw/Upj6MB8h
 as5U+fXDw92G4CC+u+VRhy4iiGPx4okU0TKnt3mZX/RUGaqFhGWJu4ijIoE5Zs9d9SNL
 u//amNhRfak4bvPH2HOHsboCM+M+dxOBIVZGLn3TN6a2pmSvuViBD6jXP4r86MOGViz9
 jN0fBYhsPujDrb6O6Mzol1ztWZq7wn6RT/LFtqlQE5JCw2X/1/QkZ/0lzXFxFT78JDD8
 PNKqvAwiyWmQ5SmRKDUE6R4j7mSNKvwv3s4EEuyCXYkMX1kBdTCqgLL8P3W8I/5vm5L5 rw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7ata-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:04 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQ9022780;
	Mon, 13 May 2019 14:38:56 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 06/27] KVM: x86: Exit KVM isolation on IRQ entry
Date: Mon, 13 May 2019 16:38:14 +0200
Message-Id: <1557758315-12667-7-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

Next commits will change most of KVM #VMExit handlers to run
in KVM isolated address space. Any interrupt handler raised
during execution in KVM address space needs to switch back
to host address space.

This patch makes sure that IRQ handlers will run in full
host address space instead of KVM isolated address space.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/apic.h    |    4 ++--
 arch/x86/include/asm/hardirq.h |   10 ++++++++++
 arch/x86/kernel/smp.c          |    2 +-
 arch/x86/platform/uv/tlb_uv.c  |    2 +-
 4 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/apic.h b/arch/x86/include/asm/apic.h
index 130e81e..606da8f 100644
--- a/arch/x86/include/asm/apic.h
+++ b/arch/x86/include/asm/apic.h
@@ -515,7 +515,7 @@ static inline unsigned int read_apic_id(void)
 static inline void entering_irq(void)
 {
 	irq_enter();
-	kvm_set_cpu_l1tf_flush_l1d();
+	kvm_cpu_may_access_sensitive_data();
 }
 
 static inline void entering_ack_irq(void)
@@ -528,7 +528,7 @@ static inline void ipi_entering_ack_irq(void)
 {
 	irq_enter();
 	ack_APIC_irq();
-	kvm_set_cpu_l1tf_flush_l1d();
+	kvm_cpu_may_access_sensitive_data();
 }
 
 static inline void exiting_irq(void)
diff --git a/arch/x86/include/asm/hardirq.h b/arch/x86/include/asm/hardirq.h
index d9069bb..e082ecb 100644
--- a/arch/x86/include/asm/hardirq.h
+++ b/arch/x86/include/asm/hardirq.h
@@ -80,4 +80,14 @@ static inline bool kvm_get_cpu_l1tf_flush_l1d(void)
 static inline void kvm_set_cpu_l1tf_flush_l1d(void) { }
 #endif /* IS_ENABLED(CONFIG_KVM_INTEL) */
 
+#ifdef CONFIG_HAVE_KVM
+extern void (*kvm_isolation_exit_handler)(void);
+
+static inline void kvm_cpu_may_access_sensitive_data(void)
+{
+	kvm_set_cpu_l1tf_flush_l1d();
+	kvm_isolation_exit_handler();
+}
+#endif
+
 #endif /* _ASM_X86_HARDIRQ_H */
diff --git a/arch/x86/kernel/smp.c b/arch/x86/kernel/smp.c
index 04adc8d..b99fda0 100644
--- a/arch/x86/kernel/smp.c
+++ b/arch/x86/kernel/smp.c
@@ -261,7 +261,7 @@ __visible void __irq_entry smp_reschedule_interrupt(struct pt_regs *regs)
 {
 	ack_APIC_irq();
 	inc_irq_stat(irq_resched_count);
-	kvm_set_cpu_l1tf_flush_l1d();
+	kvm_cpu_may_access_sensitive_data();
 
 	if (trace_resched_ipi_enabled()) {
 		/*
diff --git a/arch/x86/platform/uv/tlb_uv.c b/arch/x86/platform/uv/tlb_uv.c
index 1297e18..83a17ca 100644
--- a/arch/x86/platform/uv/tlb_uv.c
+++ b/arch/x86/platform/uv/tlb_uv.c
@@ -1285,7 +1285,7 @@ void uv_bau_message_interrupt(struct pt_regs *regs)
 	struct msg_desc msgdesc;
 
 	ack_APIC_irq();
-	kvm_set_cpu_l1tf_flush_l1d();
+	kvm_cpu_may_access_sensitive_data();
 	time_start = get_cycles();
 
 	bcp = &per_cpu(bau_control, smp_processor_id());
-- 
1.7.1

