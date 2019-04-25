Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A869C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B3C020878
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B3C020878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF29E6B0008; Thu, 25 Apr 2019 17:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6256B000A; Thu, 25 Apr 2019 17:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB9806B000C; Thu, 25 Apr 2019 17:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF3B6B0008
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:22 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id z130so988316ywb.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:46:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=DWaMaw38YCIOG4IZh4cGjAUAX82CWnvm1OumHvpNYIE=;
        b=OcEpxlfStSdEMRsMMoRrI/1Ek9X9/Qdj7SSRdJVSJdbRiM/HMl2ZiMWmle5RyCgjIo
         HQ61rQ5iQn1W7sDdLK75/gWjb0TJcYh7CJnuADJJAGAdgoiPGjzf28CzOBKFTYTGXs6K
         A0/8QwhVd1owE+XXHJq8II/TcqyKe67/SHBDaUYZYk7SGzzGIGw1HCq2uMDpCqK7UlM3
         5yjaUQhQX1KT6jTqhgTCsNsa77vUbF+NntyUWlW1+N1ORyyJ/6cZjQgv7JJcFCQgCY4x
         hzKf17b6dp5AigwuoARAUKbra19x0mXeWSQFP6JCroaRzV4iWrTLRrDYf1Z5uuI/93oK
         Vbmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUiOAsAYJLJypklKU7/Rtbu3KEH0X6PEdU+4nt0gp2hMWVn/56K
	yEBqkCHOuQS/GBaoL6WK263Ui/fBjDXd9lFynnT7gvX+KoP8HaFznWGv+0LeIAgMpgZlhIO1kat
	IkiD/ab+pyJKLG+1HaJHW4EPfR7ebvA8io++W8+XiUaNUNTjU6Z0nL2UT59ukc6ucnQ==
X-Received: by 2002:a25:b949:: with SMTP id s9mr10302861ybm.20.1556228782358;
        Thu, 25 Apr 2019 14:46:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx21pQUp0TEY1PsdnYgda5SbMOKtP8KJSKLovMSSMAf0gDwnB5C27bliKEBc9QKX4vIYw7n
X-Received: by 2002:a25:b949:: with SMTP id s9mr10302801ybm.20.1556228781418;
        Thu, 25 Apr 2019 14:46:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556228781; cv=none;
        d=google.com; s=arc-20160816;
        b=VOkNN7rplZLM1zEG+Y17MmsZPnfkmMMHd2xXeKA3SpiGy04SIUtwrtUto4P9CemVj4
         Hq9gUZIjQOYPXn+7Dwt+fGu1nVMBnTknyhq3oNQ8fKzJ+nBD1Ddj4gA0h7OeQQXkfi7K
         OkvYeqrKbb4LfutTwTlaq/XNRjbOZfJmlvRV3z94V8nOLM2BpFnMiU1COmxNcprJzOix
         HpNWMwm9pgElEBkK6i7oAdEjpgDTDinzqlhmVl60SBi7a6XzLJEKLZTq7rB8vIdAOZwZ
         klpNzmCxhaIbMuXl1l2maxlehkLMmaAdprQ9hEnR0OFUHwCC4ROdNfLPado7p8yB76OH
         m+Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=DWaMaw38YCIOG4IZh4cGjAUAX82CWnvm1OumHvpNYIE=;
        b=Da/d72LC/hNNMAY54/HqKfalN/s6WQFlZMYY0M7qcpcc4L5WI9vyONeCxDc516GQs8
         R/qM4xREz3VMumgp+/3UAjlUt8VIyW5hkRRBzAWrb0vuYw+10ZdBKiPOokOyDANjXJ5C
         a0U19+SeRjvh6ZLVuG9QaxCmk9X/fUk9WOtTM4mZJOhgPqDLKOySgwmcYsbK0u1Mz454
         aRYnB6TAAth0oQEc/yg1uWQdwMDDGyaquqMUzoNXh2e9VSoovLM3oWT/NVuc8mWp5mH+
         JfFxf63CVsN9OF/9RWObVZXx+JALAdmEJFH5rXdHxKT4NAfrmlaJ2KMr8D3378ycQpMt
         xG+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t13si9645386ywf.86.2019.04.25.14.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:46:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PLeX4N127091
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:21 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s3n0vr5j8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:20 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 22:46:19 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 22:46:14 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PLkDCu46923840
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 21:46:13 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 263B0A405C;
	Thu, 25 Apr 2019 21:46:13 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AA982A405F;
	Thu, 25 Apr 2019 21:46:10 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.209])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 21:46:10 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 26 Apr 2019 00:46:09 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: linux-kernel@vger.kernel.org
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
        Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
        Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org, x86@kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [RFC PATCH 3/7] x86/entry/64: add infrastructure for switching to isolated syscall context
Date: Fri, 26 Apr 2019 00:45:50 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042521-0028-0000-0000-000003670D69
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042521-0029-0000-0000-00002426659F
Message-Id: <1556228754-12996-4-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_18:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=680 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The isolated system calls will use a separate page table that does not map
the entire kernel. Exception and interrupts entries should switch the
context to the full kernel page tables and then restore it back to continue
the execution of the isolated system call.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/entry/calling.h               | 65 ++++++++++++++++++++++++++++++++++
 arch/x86/entry/entry_64.S              | 13 +++++--
 arch/x86/include/asm/processor-flags.h |  8 +++++
 arch/x86/include/asm/tlbflush.h        |  8 ++++-
 arch/x86/kernel/asm-offsets.c          |  7 ++++
 5 files changed, 98 insertions(+), 3 deletions(-)

diff --git a/arch/x86/entry/calling.h b/arch/x86/entry/calling.h
index efb0d1b..766e74e 100644
--- a/arch/x86/entry/calling.h
+++ b/arch/x86/entry/calling.h
@@ -187,6 +187,56 @@ For 32-bit we have the following conventions - kernel is built with
 #endif
 .endm
 
+#ifdef CONFIG_SYSCALL_ISOLATION
+
+#define SCI_PCID_BIT		X86_CR3_SCI_PCID_BIT
+
+#define THIS_CPU_sci_syscall   \
+	PER_CPU_VAR(cpu_sci) + SCI_SYSCALL
+
+#define THIS_CPU_sci_cr3_offset   \
+	PER_CPU_VAR(cpu_sci) + SCI_CR3_OFFSET
+
+.macro SAVE_AND_SWITCH_SCI_TO_KERNEL_CR3 scratch_reg:req save_reg:req
+	ALTERNATIVE "jmp .Ldone_\@", "", X86_FEATURE_SCI
+	movq	THIS_CPU_sci_syscall, \scratch_reg
+	cmpq	$0, \scratch_reg
+	je	.Ldone_\@
+	movq	%cr3, \scratch_reg
+	bt	$SCI_PCID_BIT, \scratch_reg
+	jc	.Lsci_context_\@
+	xorq	\save_reg, \save_reg
+	jmp	.Ldone_\@
+.Lsci_context_\@:
+	movq	\scratch_reg, \save_reg
+	addq	THIS_CPU_sci_cr3_offset, \scratch_reg
+	movq	\scratch_reg, %cr3
+.Ldone_\@:
+.endm
+
+.macro RESTORE_SCI_CR3 scratch_reg:req save_reg:req
+	ALTERNATIVE "jmp .Ldone_\@", "", X86_FEATURE_SCI
+	movq	THIS_CPU_sci_syscall, \scratch_reg
+	cmpq	$0, \scratch_reg
+	je	.Ldone_\@
+	movq	\save_reg, \scratch_reg
+	cmpq	$0, \scratch_reg
+	je	.Ldone_\@
+	xorq	\save_reg, \save_reg
+	movq	\scratch_reg, %cr3
+.Ldone_\@:
+.endm
+
+#else /* CONFIG_SYSCALL_ISOLATION */
+
+.macro SAVE_AND_SWITCH_SCI_TO_KERNEL_CR3 scratch_reg:req save_reg:req
+.endm
+
+.macro RESTORE_SCI_CR3 scratch_reg:req save_reg:req
+.endm
+
+#endif /* CONFIG_SYSCALL_ISOLATION */
+
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 
 /*
@@ -264,6 +314,21 @@ For 32-bit we have the following conventions - kernel is built with
 	ALTERNATIVE "jmp .Ldone_\@", "", X86_FEATURE_PTI
 	movq	%cr3, \scratch_reg
 	movq	\scratch_reg, \save_reg
+
+#ifdef CONFIG_SYSCALL_ISOLATION
+	/*
+	 * Test the SCI PCID bit. If set, then the SCI page tables are
+	 * active. If clear CR3 has either the kernel or user page
+	 * table active.
+	 */
+	ALTERNATIVE "jmp .Lcheck_user_pt_\@", "", X86_FEATURE_SCI
+	bt	$SCI_PCID_BIT, \scratch_reg
+	jnc	.Lcheck_user_pt_\@
+	addq	THIS_CPU_sci_cr3_offset, \scratch_reg
+	movq	\scratch_reg, %cr3
+	jmp	.Ldone_\@
+.Lcheck_user_pt_\@:
+#endif
 	/*
 	 * Test the user pagetable bit. If set, then the user page tables
 	 * are active. If clear CR3 already has the kernel page table
diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index 1f0efdb..3cef67b 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -543,7 +543,7 @@ ENTRY(interrupt_entry)
 	ENCODE_FRAME_POINTER 8
 
 	testb	$3, CS+8(%rsp)
-	jz	1f
+	jz	.Linterrupt_entry_kernel
 
 	/*
 	 * IRQ from user mode.
@@ -559,12 +559,17 @@ ENTRY(interrupt_entry)
 
 	CALL_enter_from_user_mode
 
-1:
+.Linterrupt_entry_done:
 	ENTER_IRQ_STACK old_rsp=%rdi save_ret=1
 	/* We entered an interrupt context - irqs are off: */
 	TRACE_IRQS_OFF
 
 	ret
+
+.Linterrupt_entry_kernel:
+	SAVE_AND_SWITCH_SCI_TO_KERNEL_CR3 scratch_reg=%rax save_reg=%r14
+	jmp	.Linterrupt_entry_done
+
 END(interrupt_entry)
 _ASM_NOKPROBE(interrupt_entry)
 
@@ -656,6 +661,8 @@ retint_kernel:
 	 */
 	TRACE_IRQS_IRETQ
 
+	RESTORE_SCI_CR3 scratch_reg=%rax save_reg=%r14
+
 GLOBAL(restore_regs_and_return_to_kernel)
 #ifdef CONFIG_DEBUG_ENTRY
 	/* Assert that pt_regs indicates kernel mode. */
@@ -1263,6 +1270,8 @@ ENTRY(error_entry)
 	 * for these here too.
 	 */
 .Lerror_kernelspace:
+	SAVE_AND_SWITCH_SCI_TO_KERNEL_CR3 scratch_reg=%rax save_reg=%r14
+
 	leaq	native_irq_return_iret(%rip), %rcx
 	cmpq	%rcx, RIP+8(%rsp)
 	je	.Lerror_bad_iret
diff --git a/arch/x86/include/asm/processor-flags.h b/arch/x86/include/asm/processor-flags.h
index 02c2cbd..eca9e17 100644
--- a/arch/x86/include/asm/processor-flags.h
+++ b/arch/x86/include/asm/processor-flags.h
@@ -53,4 +53,12 @@
 # define X86_CR3_PTI_PCID_USER_BIT	11
 #endif
 
+#ifdef CONFIG_SYSCALL_ISOLATION
+# if defined(X86_CR3_PTI_PCID_USER_BIT)
+#  define X86_CR3_SCI_PCID_BIT		(X86_CR3_PTI_PCID_USER_BIT - 1)
+# else
+#  define X86_CR3_SCI_PCID_BIT		11
+# endif
+#endif
+
 #endif /* _ASM_X86_PROCESSOR_FLAGS_H */
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index f4204bf..dc69cc4 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -54,7 +54,13 @@
 # define PTI_CONSUMED_PCID_BITS	0
 #endif
 
-#define CR3_AVAIL_PCID_BITS (X86_CR3_PCID_BITS - PTI_CONSUMED_PCID_BITS)
+#ifdef CONFIG_SYSCALL_ISOLATION
+# define SCI_CONSUMED_PCID_BITS	1
+#else
+# define SCI_CONSUMED_PCID_BITS	0
+#endif
+
+#define CR3_AVAIL_PCID_BITS (X86_CR3_PCID_BITS - PTI_CONSUMED_PCID_BITS - SCI_CONSUMED_PCID_BITS)
 
 /*
  * ASIDs are zero-based: 0->MAX_AVAIL_ASID are valid.  -1 below to account
diff --git a/arch/x86/kernel/asm-offsets.c b/arch/x86/kernel/asm-offsets.c
index 168543d..f2c9cd3f 100644
--- a/arch/x86/kernel/asm-offsets.c
+++ b/arch/x86/kernel/asm-offsets.c
@@ -18,6 +18,7 @@
 #include <asm/bootparam.h>
 #include <asm/suspend.h>
 #include <asm/tlbflush.h>
+#include <asm/sci.h>
 
 #ifdef CONFIG_XEN
 #include <xen/interface/xen.h>
@@ -105,4 +106,10 @@ static void __used common(void)
 	OFFSET(TSS_sp0, tss_struct, x86_tss.sp0);
 	OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);
 	OFFSET(TSS_sp2, tss_struct, x86_tss.sp2);
+
+#ifdef CONFIG_SYSCALL_ISOLATION
+	/* system calls isolation */
+	OFFSET(SCI_SYSCALL, sci_percpu_data, sci_syscall);
+	OFFSET(SCI_CR3_OFFSET, sci_percpu_data, sci_cr3_offset);
+#endif
 }
-- 
2.7.4

