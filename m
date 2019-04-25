Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C366C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C3E0206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C3E0206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6B996B000C; Thu, 25 Apr 2019 17:46:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1ACA6B000D; Thu, 25 Apr 2019 17:46:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A361F6B000E; Thu, 25 Apr 2019 17:46:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB976B000C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u78so757419pfa.12
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:46:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=eOsJDCQYnDhxIgZUo3pOOqasW3JRJUKG00CA3rD/iBs=;
        b=YUtdWJcSnv32iG90BZfxEU5MxPeNI8AzVajDClCkLHQMDxzrpz/SBlgL249S2/wPH/
         D8CMHIZLo1NmNCCNv1bu9Spb2tF/giRryWSEhMR2u5WwF9J6XBB8Nc2xQrPEpAyHf04/
         DcMDUTDUIsjoYwoGOvBSKJCyEMH20rdajgsjQcyVvFh5EX5pwviUCSwoXHtJ5uWEvnlQ
         MmCxJKuKBOSiVOy/2U+fK1zx5juEwOFp99YtITIECWuDc+vfCGfFsVLWrz93i5s159S/
         gDeC79cF61BmlXNs4Yp/IG9csA7zD7cw71CdmVGcw6VcHkxV4nHwnaLPxGqDIt0TLRwN
         IbFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUQ/Y0NzgaLO+/4oIx7ezAdIYCYY/u/4CCP805XnK2VJb3K805U
	Om/Qb55OkC0jh5G89IMJj2Z9nTdzwRjEUO8UBPrvDke/My5caSxsRWsEjkUqOjZOG6GCiXKNg85
	HowPIMCioXbcGaVehxUBzrbi7R60ouqVbei55X8tDztLIbf70tte+hMZ91dH+3ZIGQw==
X-Received: by 2002:a63:5560:: with SMTP id f32mr40041509pgm.334.1556228790091;
        Thu, 25 Apr 2019 14:46:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOLoZm21SXQikx/kYeT0v+qMw2mR/nn+1sqQsnMUUKpmZJse98FqXnQCGDWA4VMFSIzzn9
X-Received: by 2002:a63:5560:: with SMTP id f32mr40041457pgm.334.1556228789276;
        Thu, 25 Apr 2019 14:46:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556228789; cv=none;
        d=google.com; s=arc-20160816;
        b=wWifL32evRmEfgVyDEECnApqMfECUjIrS9cF+KZXq27yNK6XalNMTMdefDd7FnxGTO
         nr396QUL/dpDYqOQzalsXBxIauo81Is8dClBiEnsJpWpNgn54oigd/SzDMIYdU+RRiwn
         bVNLQojwyOIwlIgyVlGihj2LRKF7kG45z+Syo53HgRNOiu3KAN7/7xx+/YB7xLRUubxr
         3Npt1mHliggEP0jiD4hxsflgann3FQarSiBgV0cf2t+8zcAse/XjdejR69bebEgVEA7r
         sh5lQO+zI7NkBuwx1/umysy0i9buMNZXBs3XYx1ZQO/t/MRzRraxhXKr3CYf1CpooYN4
         goiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=eOsJDCQYnDhxIgZUo3pOOqasW3JRJUKG00CA3rD/iBs=;
        b=jFQNVPnCgSt2DaryiyYLJFmt0fq7bhSpxISV0pmuH5zzOwOENFdzSSjkbhsP8gMqRq
         z8cdSVmpTnAVRdcMBjCRY7H2dQK57EYu3sSFNYIm0HEvq5l7UWW0RMCD19euiARKyz0T
         q8VIYslII4M7QUfKlVpkXHqRDnYD21fvt1NHDVbtwlpn0NEeqrfA4m4iqVgUP0WEnGXd
         vp9T8CWfor0pH6fx3sjX2hq2yh21JRfhxp11ls7FKW1SoXK0G9efgswlGkd0hT1AbSsH
         hwoF2qOeHlPI4ULyOMzmp/9WPV/U9s0e9hkXCiZwGS55Cyb2zhkG+/QaV796+qbHgriO
         mOLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 14si21584636pgv.248.2019.04.25.14.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:46:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PLdOi4090774
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:28 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s3hf9r74g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:28 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 22:46:26 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 22:46:20 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PLkJQT61538416
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 21:46:19 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CA28142041;
	Thu, 25 Apr 2019 21:46:19 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 50F4B42049;
	Thu, 25 Apr 2019 21:46:17 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.209])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 21:46:17 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 26 Apr 2019 00:46:16 +0300
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
Subject: [RFC PATCH 5/7] x86/mm/fault: hook up SCI verification
Date: Fri, 26 Apr 2019 00:45:52 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042521-0016-0000-0000-000002750F36
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042521-0017-0000-0000-000032D18954
Message-Id: <1556228754-12996-6-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_18:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=450 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If a system call runs in isolated context, it's accesses to kernel code and
data will be verified by SCI susbsytem.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/mm/fault.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 9d5c75f..baa2a2f 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -18,6 +18,7 @@
 #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
 #include <linux/efi.h>			/* efi_recover_from_page_fault()*/
 #include <linux/mm_types.h>
+#include <linux/sci.h>			/* sci_verify_and_map()		*/
 
 #include <asm/cpufeature.h>		/* boot_cpu_has, ...		*/
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
@@ -1254,6 +1255,30 @@ static int fault_in_kernel_space(unsigned long address)
 	return address >= TASK_SIZE_MAX;
 }
 
+#ifdef CONFIG_SYSCALL_ISOLATION
+static int sci_fault(struct pt_regs *regs, unsigned long hw_error_code,
+		     unsigned long address)
+{
+	struct task_struct *tsk = current;
+
+	if (!tsk->in_isolated_syscall)
+		return 0;
+
+	if (!sci_verify_and_map(regs, address, hw_error_code)) {
+		this_cpu_write(cpu_sci.sci_syscall, 0);
+		no_context(regs, hw_error_code, address, SIGKILL, 0);
+	}
+
+	return 1;
+}
+#else
+static inline int sci_fault(struct pt_regs *regs, unsigned long hw_error_code,
+			    unsigned long address)
+{
+	return 0;
+}
+#endif
+
 /*
  * Called for all faults where 'address' is part of the kernel address
  * space.  Might get called for faults that originate from *code* that
@@ -1301,6 +1326,9 @@ do_kern_addr_fault(struct pt_regs *regs, unsigned long hw_error_code,
 	if (kprobes_fault(regs))
 		return;
 
+	if (sci_fault(regs, hw_error_code, address))
+		return;
+
 	/*
 	 * Note, despite being a "bad area", there are quite a few
 	 * acceptable reasons to get here, such as erratum fixups
-- 
2.7.4

