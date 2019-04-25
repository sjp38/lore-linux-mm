Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECFFBC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9091206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9091206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52A3D6B000E; Thu, 25 Apr 2019 17:46:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5014F6B0010; Thu, 25 Apr 2019 17:46:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F0566B0266; Thu, 25 Apr 2019 17:46:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 064A06B000E
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:37 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n5so576006pgk.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:46:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=UUXtBSBOzxuFMcQrn8ir4/fAjl8E5MhWLJKi7bnLtb8=;
        b=s+mdHttvfkc7KiudZNO6saW0Edc5dsYIfiIR1JiuM+xJusFLpZd9GOBncY241Q0Ucb
         W73HCEY275TfZQxQr1IU1lM31LbpsbXyf2yG6xyTvQElykuil4z+i/gBfsmrW/zKlQhX
         1xDntx3Bp9N4ape7H4MRVB5DxrzDGSN1ZwLJ/24Mth85o+SXz5CjyxnuEdiv7m7KR85H
         Ch5hETKnpeaFOFqeX6kBeT664xl4gKllLvVvywpmwe8NqkoZHjnOTU/4ULUxTJhPp82F
         P7YvvCWfOvD+spR4oJUwrEm43q0s5JoBx1bu8bAaaMqc0VG5NDiDve1Tii7yMZXe5Svt
         b/pQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWHk2JWluZA57vJ80zFesgf4REyNACWr3AAGba8LenEqivrpUHR
	/3/Ti3lDljPQQICjbhelFkuwjSZ+firlab8QH8dw2SsRZwlBhCQOvThquIGqEyyn6vGCaDcLyo9
	hFtt51xoD1uknU6S3lYdKnYwnWJ8d5MpSqEmFwh5iIcFzi7/hMSWWZs+ujxB1Jfm6wg==
X-Received: by 2002:a17:902:1003:: with SMTP id b3mr42192772pla.306.1556228796654;
        Thu, 25 Apr 2019 14:46:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmALmJT7U4UZMDOqwJT8BT6eXL1rjdjtLXRSAzCYsVV2hmMgPOdaAycSaZL/5+csbGEdhJ
X-Received: by 2002:a17:902:1003:: with SMTP id b3mr42192714pla.306.1556228795772;
        Thu, 25 Apr 2019 14:46:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556228795; cv=none;
        d=google.com; s=arc-20160816;
        b=QYSlCdjIAlxufzabni/WBnz1u18sO+hTIaNCJ/jD+7WYymcVOewGLflX21uC8aBx6t
         OaPeftVZYmLruKGDXa/Y3j8yM4Hd0m5sfMaWnBeGWSaWOzDS27WUci3DNN0v0EJvjC+z
         CVL3nXkD5GCD6Mm1geUpzqX1WlXE7wYIMQ0c1PXpBUdcolPo1i22LQICB2lSXQ7SAtrS
         dzskosvoVuL2BRDmNFMSWVE/domoYh1uEA07xMkH5Ue1KMw5HNXO0WFTZ0U84ZpNRyhc
         66kKixz2QiiSLUp26DtcsnrGKg412gc+TaqNy1DpJFfXChdnnZSI6AtXaDzga3L6Svsw
         QZsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=UUXtBSBOzxuFMcQrn8ir4/fAjl8E5MhWLJKi7bnLtb8=;
        b=DTWwl/bVrOrc0ulE/XwsWbWzDnMXBefvSoWvuxObjYToGiUWwn9Me9OGFj25ecut5e
         1MWd7hEucMVoBMuCoJaorW7VHC0/RJKRryFKd91gGOICdTkmwWp+BV0oNNN18JxJahmU
         WioFgdRQFLqd6HfqYfl4jZZWkLho+sXJ73DB6YvegjQvXivnzKPzVpTM/At2Org1MRk8
         zbFVl1subeNtb5jblZ0Jvx3NUUaU6ZFtrdlSGJsbbkHMiyXG96GSK6s8p6teyIBTfG6s
         u22iPX8Ui5tQQWIC4wN39ZbvywUCI2fmhE3AMx28BEAF6E49U1T82VZ/VHaofLPRio+s
         NMtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b5si10168267pge.550.2019.04.25.14.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:46:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PLY9IC084362
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:35 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s3hu3yx2t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:35 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 22:46:32 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 22:46:27 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PLkQoE46923988
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 21:46:26 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6F4B3AE04D;
	Thu, 25 Apr 2019 21:46:26 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EECBFAE051;
	Thu, 25 Apr 2019 21:46:23 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.209])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 21:46:23 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 26 Apr 2019 00:46:23 +0300
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
Subject: [RFC PATCH 7/7] sci: add example system calls to exercse SCI
Date: Fri, 26 Apr 2019 00:45:54 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042521-0020-0000-0000-000003360C05
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042521-0021-0000-0000-000021887A43
Message-Id: <1556228754-12996-8-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_18:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/entry/common.c                |  6 +++-
 arch/x86/entry/syscalls/syscall_64.tbl |  3 ++
 kernel/Makefile                        |  2 +-
 kernel/sci-examples.c                  | 52 ++++++++++++++++++++++++++++++++++
 4 files changed, 61 insertions(+), 2 deletions(-)
 create mode 100644 kernel/sci-examples.c

diff --git a/arch/x86/entry/common.c b/arch/x86/entry/common.c
index 8f2a6fd..be0e1a7 100644
--- a/arch/x86/entry/common.c
+++ b/arch/x86/entry/common.c
@@ -275,7 +275,11 @@ __visible inline void syscall_return_slowpath(struct pt_regs *regs)
 #ifdef CONFIG_SYSCALL_ISOLATION
 static inline bool sci_required(unsigned long nr)
 {
-	return false;
+	if (!static_cpu_has(X86_FEATURE_SCI))
+		return false;
+	if (nr < __NR_get_answer)
+		return false;
+	return true;
 }
 
 static inline unsigned long sci_syscall_enter(unsigned long nr)
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index f0b1709..a25e838 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -343,6 +343,9 @@
 332	common	statx			__x64_sys_statx
 333	common	io_pgetevents		__x64_sys_io_pgetevents
 334	common	rseq			__x64_sys_rseq
+335	64	get_answer		__x64_sys_get_answer
+336	64	sci_write_dmesg		__x64_sys_sci_write_dmesg
+337	64	sci_write_dmesg_bad	__x64_sys_sci_write_dmesg_bad
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/kernel/Makefile b/kernel/Makefile
index 6aa7543..d6441d0 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -10,7 +10,7 @@ obj-y     = fork.o exec_domain.o panic.o \
 	    extable.o params.o \
 	    kthread.o sys_ni.o nsproxy.o \
 	    notifier.o ksysfs.o cred.o reboot.o \
-	    async.o range.o smpboot.o ucount.o
+	    async.o range.o smpboot.o ucount.o sci-examples.o
 
 obj-$(CONFIG_MODULES) += kmod.o
 obj-$(CONFIG_MULTIUSER) += groups.o
diff --git a/kernel/sci-examples.c b/kernel/sci-examples.c
new file mode 100644
index 0000000..9bfaad0
--- /dev/null
+++ b/kernel/sci-examples.c
@@ -0,0 +1,52 @@
+#include <linux/kernel.h>
+#include <linux/pid.h>
+#include <linux/syscalls.h>
+#include <linux/hugetlb.h>
+#include <asm/special_insns.h>
+
+SYSCALL_DEFINE0(get_answer)
+{
+	return 42;
+}
+
+#define BUF_SIZE 1024
+
+typedef void (*foo)(void);
+
+SYSCALL_DEFINE2(sci_write_dmesg, const char __user *, ubuf, size_t, count)
+{
+	char buf[BUF_SIZE];
+
+	if (!ubuf || count >= BUF_SIZE)
+		return -EINVAL;
+
+	buf[count] = '\0';
+	if (copy_from_user(buf, ubuf, count))
+		return -EFAULT;
+
+	printk("%s\n", buf);
+
+	return count;
+}
+
+SYSCALL_DEFINE2(sci_write_dmesg_bad, const char __user *, ubuf, size_t, count)
+{
+	unsigned long addr = (unsigned long)(void *)hugetlb_reserve_pages;
+	char buf[BUF_SIZE];
+	foo func1;
+
+	addr += 0xc5;
+	func1 = (foo)(void *)addr;
+	func1();
+
+	if (!ubuf || count >= BUF_SIZE)
+		return -EINVAL;
+
+	buf[count] = '\0';
+	if (copy_from_user(buf, ubuf, count))
+		return -EFAULT;
+
+	printk("%s\n", buf);
+
+	return count;
+}
-- 
2.7.4

