Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22538C4321B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20B4C206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20B4C206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 357276B0006; Thu, 25 Apr 2019 17:46:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 305BA6B0007; Thu, 25 Apr 2019 17:46:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D0606B0008; Thu, 25 Apr 2019 17:46:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA7DA6B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:15 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d71so971578ywd.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:46:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=pnEsqrTuMh8TRPOlpDImzZG2jQNFm6MrhzsaXJdo7Gs=;
        b=Pcz0uZ6fYvZoT5ZvHYv8IcJaftzte5d7nwMBjQHOtFJ+w94LaldHpuoZfB3TrSlNEE
         gSApf1FJm9wki9J5CnG66AveJXNZ50+uGQk9rNtzjCI8fV2/hqXm0163i19SvHYkafLg
         jSV+L1SFZP61jTkto6fMge+yhELF1XzapkAuge//cJt4/UJHthgMLJsb8wuqbLGZgla/
         lmTrNkJnbQgr+vAnYjqDXWqF3ESyxlS6KUzMsVLngQqe2wwXamKmqztcVXhCtgOCfYA5
         Y498ZcPT+1u+7PaXHna5Fw60YcJBDA6uzfu8t1aELtyP7qKI9tixfAFVvImzP60ySIUV
         nv5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW2EoHJaUgjy4lh3lS3XbDhi1zKec5mb5dJVSJaia15LVnvWk66
	Sjtcsr5mfgYnliS0EB/YFd9wjpXqM/vEeEevZFtQXrH8nLYL6SaTkOTo7LeeHvH2LKAT61bVp9y
	oDkcBdu+v1kNvLkSfSbzT7Y049gcuTNa2Pyj5HVtys6e2sXU1nhjXRq8HGlxoJF0UqQ==
X-Received: by 2002:a81:a38b:: with SMTP id a133mr34260543ywh.423.1556228775690;
        Thu, 25 Apr 2019 14:46:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcMZbHPU7O7mfuRCXzE7WILBS1lVzMBZ9LqhKLbY+FlkVn2fyFtl887YfgC2ruv3+WVmWb
X-Received: by 2002:a81:a38b:: with SMTP id a133mr34260478ywh.423.1556228774652;
        Thu, 25 Apr 2019 14:46:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556228774; cv=none;
        d=google.com; s=arc-20160816;
        b=b1lBrl9LCw9rptMuRq4fLdzp44AxhkfQ2niEuJKvUS3KXOEJwfkdA8POBmmxfisdyq
         YVhbrL1+uZKkOC+4PsUtsbVTypMlYbj3o3etriitRm8LRD1FtfNSMnzaQ8ej+U9oLl3W
         ZeIuvWhD1QO4bBO94lamCSYAtqeG9zTiuOU3L23K1KMq1rQBW6yod9t4L1aN/bHmLHU8
         q2KSPRPu3+gKfhwIQOQYjomgdRtytGmWHxvyniPJ7tO7i08J6WKMUEBjTuPvuRCV/ZX8
         CNj/66cPMfYxJFpckcVo3OQOlrLbzUhrYrVCHFaTdOm4GFinajyM/mtmamMbOAz9Vvi5
         hjhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=pnEsqrTuMh8TRPOlpDImzZG2jQNFm6MrhzsaXJdo7Gs=;
        b=NCJHkoWLj5JQC2Lw02vztxfMRK+vLxa7OY+i4QsbDTJzs8mh+nfSffxK7Tc5s5j3WB
         gzLq7XX1enVfrWalcPDhpVDH5DxP5fXgqdQ4cUCnwwQNjH5nDKxI/3tY0dVPjK86jTYJ
         0fZfpEr/mTZiKfcTECEGTpgTNdErqFOgCJc+Zw7MJQY+/x1ZrtHupBiIIh9ZBRX7Rauv
         pdVBfP20tvTqRkpXO1N/f90jcgE2t0vN0ibU3Bw47zaqFynATGeG/N912HtSExUmzkjg
         k8Xci1Xxim7MXJpvdub/KK2dUQyi15td8NyJe2hJef5ca48wo8W6tsOyiFTuYqhi1Gpu
         abHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o8si9823706ywo.404.2019.04.25.14.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:46:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PLY6J5038286
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:14 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s3m1j2hfe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:14 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 22:46:11 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 22:46:07 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PLk6X347775906
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 21:46:06 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7DB174C044;
	Thu, 25 Apr 2019 21:46:06 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0DA044C04E;
	Thu, 25 Apr 2019 21:46:04 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.209])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 21:46:03 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 26 Apr 2019 00:46:03 +0300
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
Subject: [RFC PATCH 1/7] x86/cpufeatures: add X86_FEATURE_SCI
Date: Fri, 26 Apr 2019 00:45:48 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042521-0012-0000-0000-000003150D15
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042521-0013-0000-0000-0000214D68D7
Message-Id: <1556228754-12996-2-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_18:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=745 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The X86_FEATURE_SCI will be set when system call isolation is enabled.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/include/asm/cpufeatures.h       | 1 +
 arch/x86/include/asm/disabled-features.h | 8 +++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 6d61225..a01c6dd 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -221,6 +221,7 @@
 #define X86_FEATURE_ZEN			( 7*32+28) /* "" CPU is AMD family 0x17 (Zen) */
 #define X86_FEATURE_L1TF_PTEINV		( 7*32+29) /* "" L1TF workaround PTE inversion */
 #define X86_FEATURE_IBRS_ENHANCED	( 7*32+30) /* Enhanced IBRS */
+#define X86_FEATURE_SCI			( 7*32+31) /* "" System call isolation */
 
 /* Virtualization flags: Linux defined, word 8 */
 #define X86_FEATURE_TPR_SHADOW		( 8*32+ 0) /* Intel TPR Shadow */
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index a5ea841..79947f0 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -62,6 +62,12 @@
 # define DISABLE_PTI		(1 << (X86_FEATURE_PTI & 31))
 #endif
 
+#ifdef CONFIG_SYSCALL_ISOLATION
+# define DISABLE_SCI		0
+#else
+# define DISABLE_SCI		(1 << (X86_FEATURE_SCI & 31))
+#endif
+
 /*
  * Make sure to add features to the correct mask
  */
@@ -72,7 +78,7 @@
 #define DISABLED_MASK4	(DISABLE_PCID)
 #define DISABLED_MASK5	0
 #define DISABLED_MASK6	0
-#define DISABLED_MASK7	(DISABLE_PTI)
+#define DISABLED_MASK7	(DISABLE_PTI|DISABLE_SCI)
 #define DISABLED_MASK8	0
 #define DISABLED_MASK9	(DISABLE_MPX|DISABLE_SMAP)
 #define DISABLED_MASK10	0
-- 
2.7.4

