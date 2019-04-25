Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84EFDC4321B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74EFD206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74EFD206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D23FE6B000A; Thu, 25 Apr 2019 17:46:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAA786B000C; Thu, 25 Apr 2019 17:46:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA62C6B000D; Thu, 25 Apr 2019 17:46:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71B056B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:26 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so582001plq.1
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:46:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=i1bfsZjFrXVP5RwntuUxVyAAkzjjd/96go1WsZXyan0=;
        b=llFuxEMUbLCDKiHsZBWjd3KoCAWEhjgUcdb8cezOmZgHrDfQ+RwBazc/8AsRYhA+tN
         Mb2L6++AsIY9YUE4Bg2kvMHWc1UT1OemumYXH9KerD6uzHjIVspLyAAgx/F8skQLCeh0
         nBYOkmoIqQkMFE0zL8F4saDl/BksXZqIwGAtHwKd7sjwhABiVBRS6gGh5w+6kZa6bTTf
         cfkHOagZHG/4Ympe6uuzOtMwD7pdrSAxKFSrdiK1gz7hMnu8z1nsS4HuZnHf1EnL84Mc
         CgeM3qfEzHxmM/IAeYwe9RNffQzNO3C7mI7ABmfS8a6LEqVrpxLCXGYmqdPSVTRdYDkM
         6DZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWaTKFZ9ORlvTNXEUnJYNuoJNdxN0ZVS47o8WnevH6bUN8LpkQW
	QR2ChCs3k5ZFJzktDr3EbTuq/zBq31BfsE6E2R2RWYY627Mr2xSsWANw1/sBMaCs3kMZVYck0RF
	avNA2uPwxRzR216Vd/qeuWQfIQ8VBzFVJGIT5jBzwcnuLHgoAUd4BqyAiKU2u7Axbgg==
X-Received: by 2002:a17:902:2:: with SMTP id 2mr42319825pla.61.1556228786090;
        Thu, 25 Apr 2019 14:46:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7jzOkJQb3H/C5ogKFXZBLVADj/j6pJb2QMXH6DNi9D1HLboMuGt2ZOmG/FRaaOMTGfteW
X-Received: by 2002:a17:902:2:: with SMTP id 2mr42319732pla.61.1556228784858;
        Thu, 25 Apr 2019 14:46:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556228784; cv=none;
        d=google.com; s=arc-20160816;
        b=sYv+7/YWOhQqE839sdWSBOqDVD6bXraLElmf5A/qWny0EKHAIDuBl41c1WDigomBA1
         NIVNfxovmtM4w3tdaVLP0fozbmPuLvfZ5iqPHOtUWzpFNbtsDALBLWN0uxRRpZqc6+A7
         qA/1/r/2taHqetvFC3T4XyPHak5CNN1VgYLWpRuE3c86MtwO9P0s21LOPacweHGhRck6
         mq30YP5kG9xsTLkGvGKM4odhZyQt+bYMXoX5akmRZB5tinPfSQbtue5lR6MHJnpUeBs4
         LNsuG9B7sY9VKAWSjZ4IKhD0K+br1YeXwrV17UJaRcRhU0yMObspvQz2EgrYmS7HC/iq
         m64g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=i1bfsZjFrXVP5RwntuUxVyAAkzjjd/96go1WsZXyan0=;
        b=ZACYhQ+PJlVNbp6rmu3UrtjXU1pixKsyL1nDeew4mEliQHR4sDOkwgYh0Bk7IW9yLX
         5uk202izVhGFzBpBKgqqrI+8e8MgLK4NIw9qLTGUHRQl65RLWefNUiNnlY1Z8z2sr/nN
         MZ8SAvEpR4fSaPd1E/77mdeHuuSfG5LECs4sDcir3XIMuPGKbz6bhhF5MdxBMzV01oBH
         cRSWH4RBZoQLSkrlQ0wcJyFpmk8BDZ72j4fToZdXjFPL4463xXpDrB+zcs9esVP98UJQ
         5nYUAdK7xdzR6brHdhlZESFcvqKx0Pwi91yZAjhgnq/4xFX8bX5f6tsNnnTGlnkrKPzc
         /QWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 6si3433453pgl.470.2019.04.25.14.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:46:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PLZJV1079832
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:24 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s3k8jv6tb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:24 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 22:46:21 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 22:46:17 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PLkGbB52494340
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 21:46:16 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 74A6311C052;
	Thu, 25 Apr 2019 21:46:16 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 00CAC11C04C;
	Thu, 25 Apr 2019 21:46:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.209])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 21:46:13 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 26 Apr 2019 00:46:13 +0300
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
Subject: [RFC PATCH 4/7] x86/sci: hook up isolated system call entry and exit
Date: Fri, 26 Apr 2019 00:45:51 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042521-4275-0000-0000-0000032E1ABE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042521-4276-0000-0000-0000383D6915
Message-Id: <1556228754-12996-5-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_18:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=858 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a system call is required to run in an isolated context, the CR3 will
be switched to the SCI page table a per-cpu variable will contain and
offset from the original CR3. This offset is used to switch back to the
full kernel context when a trap occurs during isolated system call.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/entry/common.c      | 61 ++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/process_64.c |  5 ++++
 kernel/exit.c                |  3 +++
 3 files changed, 69 insertions(+)

diff --git a/arch/x86/entry/common.c b/arch/x86/entry/common.c
index 7bc105f..8f2a6fd 100644
--- a/arch/x86/entry/common.c
+++ b/arch/x86/entry/common.c
@@ -25,12 +25,14 @@
 #include <linux/uprobes.h>
 #include <linux/livepatch.h>
 #include <linux/syscalls.h>
+#include <linux/sci.h>
 
 #include <asm/desc.h>
 #include <asm/traps.h>
 #include <asm/vdso.h>
 #include <linux/uaccess.h>
 #include <asm/cpufeature.h>
+#include <asm/tlbflush.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/syscalls.h>
@@ -269,6 +271,50 @@ __visible inline void syscall_return_slowpath(struct pt_regs *regs)
 }
 
 #ifdef CONFIG_X86_64
+
+#ifdef CONFIG_SYSCALL_ISOLATION
+static inline bool sci_required(unsigned long nr)
+{
+	return false;
+}
+
+static inline unsigned long sci_syscall_enter(unsigned long nr)
+{
+	unsigned long sci_cr3, kernel_cr3;
+	unsigned long asid;
+
+	kernel_cr3 = __read_cr3();
+	asid = kernel_cr3 & ~PAGE_MASK;
+
+	sci_cr3 = build_cr3(current->sci->pgd, 0) & PAGE_MASK;
+	sci_cr3 |= (asid | (1 << X86_CR3_SCI_PCID_BIT));
+
+	current->in_isolated_syscall = 1;
+	current->sci->cr3_offset = kernel_cr3 - sci_cr3;
+
+	this_cpu_write(cpu_sci.sci_syscall, 1);
+	this_cpu_write(cpu_sci.sci_cr3_offset, current->sci->cr3_offset);
+
+	write_cr3(sci_cr3);
+
+	return kernel_cr3;
+}
+
+static inline void sci_syscall_exit(unsigned long cr3)
+{
+	if (cr3) {
+		write_cr3(cr3);
+		current->in_isolated_syscall = 0;
+		this_cpu_write(cpu_sci.sci_syscall, 0);
+		sci_clear_data();
+	}
+}
+#else
+static inline bool sci_required(unsigned long nr) { return false; }
+static inline unsigned long sci_syscall_enter(unsigned long nr) { return 0; }
+static inline void sci_syscall_exit(unsigned long cr3) {}
+#endif
+
 __visible void do_syscall_64(unsigned long nr, struct pt_regs *regs)
 {
 	struct thread_info *ti;
@@ -286,10 +332,25 @@ __visible void do_syscall_64(unsigned long nr, struct pt_regs *regs)
 	 */
 	nr &= __SYSCALL_MASK;
 	if (likely(nr < NR_syscalls)) {
+		unsigned long sci_cr3 = 0;
+
 		nr = array_index_nospec(nr, NR_syscalls);
+
+		if (sci_required(nr)) {
+			int err = sci_init(current);
+
+			if (err) {
+				regs->ax = err;
+				goto err_return_from_syscall;
+			}
+			sci_cr3 = sci_syscall_enter(nr);
+		}
+
 		regs->ax = sys_call_table[nr](regs);
+		sci_syscall_exit(sci_cr3);
 	}
 
+err_return_from_syscall:
 	syscall_return_slowpath(regs);
 }
 #endif
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 6a62f4a..b8aa624 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -55,6 +55,8 @@
 #include <asm/resctrl_sched.h>
 #include <asm/unistd.h>
 #include <asm/fsgsbase.h>
+#include <asm/sci.h>
+
 #ifdef CONFIG_IA32_EMULATION
 /* Not included via unistd.h */
 #include <asm/unistd_32_ia32.h>
@@ -581,6 +583,9 @@ __switch_to(struct task_struct *prev_p, struct task_struct *next_p)
 
 	switch_to_extra(prev_p, next_p);
 
+	/* update syscall isolation per-cpu data */
+	sci_switch_to(next_p);
+
 #ifdef CONFIG_XEN_PV
 	/*
 	 * On Xen PV, IOPL bits in pt_regs->flags have no effect, and
diff --git a/kernel/exit.c b/kernel/exit.c
index 2639a30..8e81353 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -62,6 +62,7 @@
 #include <linux/random.h>
 #include <linux/rcuwait.h>
 #include <linux/compat.h>
+#include <linux/sci.h>
 
 #include <linux/uaccess.h>
 #include <asm/unistd.h>
@@ -859,6 +860,8 @@ void __noreturn do_exit(long code)
 	tsk->exit_code = code;
 	taskstats_exit(tsk, group_dead);
 
+	sci_exit(tsk);
+
 	exit_mm();
 
 	if (group_dead)
-- 
2.7.4

