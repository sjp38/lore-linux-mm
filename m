Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE4C6C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEFA420717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEFA420717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 180706B000D; Thu, 25 Apr 2019 17:46:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 159676B000E; Thu, 25 Apr 2019 17:46:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023AA6B0010; Thu, 25 Apr 2019 17:46:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB6CB6B000D
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d1so554694pgk.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:46:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=J7tNEAdBhId4eIA4gAtaSQQAoX1Xp3+wTKKGWYe9kj4=;
        b=bB/bRa4aIJZ3HruAvpd1Y5s1CTrV0HyLcEBYpU/Nm/nbH5f4YH92wOjJ8rfib619S2
         XhCP76SQlgBlzue1MwtJPX6SkpKB3JTriohAZW1ObHNBxwzp1tjc8Rs5o+m4V+E8AfS9
         moMlutgUZiRFWEK7Ej6xI46V4DGxYwsoOdY7v+0rBdId7yfrDFzN6FSGiDLqVsQ78wTT
         43GtGVpGgyQmein2eWUSjKRkxaZUpnAyK4fKh81HFLQeh3tSER/Xt5UW+7uziQ/VLR9U
         o1uAN5/ZiDkgVsBaNgKld2UK+yjm9838OVWDPFXwi5OM8ddjZEdgmrQFf2+Cj2RpZW6O
         BTLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVs6hBlLXaDBzIy3bTIJ2pKFDCywgGbBlPsfdOBeZyiNwgLLvZ8
	by8adaVqE+FuKsZ98Sc8HoAr+3xhzuzfrLKuYwlV2wHtIdOdR5cc+bzqX9g9hMV3nlDgeL9OifX
	Kl8/iOKKlkzqNZ6xKXsT0YtMbSNcdo7yYdWUswdA/Gwg+gHpTFx2clsHj3+CTBouwSA==
X-Received: by 2002:aa7:85d9:: with SMTP id z25mr43385588pfn.31.1556228793439;
        Thu, 25 Apr 2019 14:46:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcdghazKCmCDvZXDf2n4bIfcHnuZ9nzHOFhzR1TG4AlFrcx2zF2gxtz4EWBYfGBBITNGd+
X-Received: by 2002:aa7:85d9:: with SMTP id z25mr43385525pfn.31.1556228792532;
        Thu, 25 Apr 2019 14:46:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556228792; cv=none;
        d=google.com; s=arc-20160816;
        b=SO3VesPUtDZPBWcLSSwGYgTunXHBHRApTz7VMThJaSme2bLSCMRhl4h+hX8yRfNKlI
         dZtZ6omNpN4jYGtUIL7PsAFjr3jBURhwJWSmhXN7TNleuIsOgg0tTNdyTEnFsvkC08bt
         QQFlKkL4Ik/OGB0pobAOBFmPmyyp12/IeVEaMnV6phwTqsnyFpvnKc/klhbHYYB7GIan
         o7+F5jq/A5MDmK3As5blR+8b2nqLOUyWLzHwv7ter0ukT2NVynDMJIDHozjf6mGPGKMu
         NY+IxKU6NDK9iUW5Q1EnKP5S+3IBEbqzpvlB5/XpwZk89kjTRhQDG8Q15Ejg+0h/3/tF
         qWnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=J7tNEAdBhId4eIA4gAtaSQQAoX1Xp3+wTKKGWYe9kj4=;
        b=WNQcHWwhIGseRycBNNqBwZWewdINOBhI+fRSTGlc+T6s0nBOZoAGIeXPLi5Pb9BtvX
         ncAYrEc16gtrjNxJI2tpVTROuVN4s+JOG5eWb7pHR8goxjCiCeTJXRgK6ApzO4hWQ/Ea
         GOOtJddj6Ru0a/BhPHDLZ/w6GxoP1NHAoMDlUM4MV22xiPprw9tcEh7Sq9t4ePxyaO7t
         nTCXv68AjHMGmWUImNhAOCe+0/X/u5k8VqTh6Nfk6FEIhMnGEh/cuYYPL7f4O8F4mk/y
         e8mYtoHJIrldVnnPtuQlngdQg1IMrAqX+MxEGKFWcJYcxXEUXSTXg13jSTyWogTXmhJ4
         5Fsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e126si22045212pgc.211.2019.04.25.14.46.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:46:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PLYAWR084407
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:32 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s3hu3yx1n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:31 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 22:46:29 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 22:46:24 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PLkNkp60686498
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 21:46:23 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1F2B3A4055;
	Thu, 25 Apr 2019 21:46:23 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A1C6BA404D;
	Thu, 25 Apr 2019 21:46:20 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.209])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 21:46:20 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 26 Apr 2019 00:46:19 +0300
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
Subject: [RFC PATCH 6/7] security: enable system call isolation in kernel config
Date: Fri, 26 Apr 2019 00:45:53 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042521-0008-0000-0000-000002E00BF3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042521-0009-0000-0000-0000224C6727
Message-Id: <1556228754-12996-7-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_18:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=994 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add SYSCALL_ISOLATION Kconfig option to enable build of SCI infrastructure.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 security/Kconfig | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/security/Kconfig b/security/Kconfig
index e4fe2f3..0c6929a 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -65,6 +65,16 @@ config PAGE_TABLE_ISOLATION
 
 	  See Documentation/x86/pti.txt for more details.
 
+config SYSCALL_ISOLATION
+	bool "System call isolation"
+	default n
+	depends on PAGE_TABLE_ISOLATION && !X86_PAE
+	help
+	  This is an experimental feature to allow executing system
+	  calls in an isolated address space.
+
+	  If you are unsure how to answer this question, answer N.
+
 config SECURITY_INFINIBAND
 	bool "Infiniband Security Hooks"
 	depends on SECURITY && INFINIBAND
-- 
2.7.4

