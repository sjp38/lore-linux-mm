Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59E18C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 13:24:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1691E218DA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 13:24:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1691E218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9ABF6B0008; Wed, 24 Apr 2019 09:24:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D47EA6B000A; Wed, 24 Apr 2019 09:24:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7B376B000D; Wed, 24 Apr 2019 09:24:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79C5D6B0008
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:25 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id x66so14764804ywx.1
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=ZEy2G1L4e5dWWuDv8ziYDWgBWhVqrzd8jMSYeDsnxko=;
        b=V45G9aOA7RBFfLNSUO/AgJ0fgLbqMNoUh+w1PqfSk4DUvmGKOsHr7cWPkzacTz6RMR
         RaqFlGh3+4Ep2oLr+9T/NBOWH33B2hFjCG8M3rbEzaxU9ds6g+ZKwrMx5NVBlD9lT2Cc
         HU7df3o8yC20NK4xdj/9KQ7WucFazw+iW30nptc38AxZzvEMOAs+fTmv5cHXKw5wtCDA
         FWhOvj9yAkxSktRlcdEv8cNEPThjl/MF12TYsfuVbfAqCWLQUPjH53MLSR+ICpn8Y1S/
         ClpxOJgCYMhPaJfuDWGEIlKM987Da87z4Hz8BMcwAWYQH9J9hhIrDKWTsvdYe2AlH6OJ
         8vvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV5cqJbz77gf3aTTN/B0UpYlOZVbL5ca7AL8YRWbfaT0BfaazZb
	EE/Ubxaqm7zLUNl0iRtumGJExwZt0jJBAqh+5DBc1jz5Db6GubU6hA6AAvUmCoaK1Bo040OQ4yT
	Z39LRTT/8WGPCU6NrW5vwaHvpLHtoThBdFdSvQKHpszEAlIO4OG0U/Njpuq24ZS9WdQ==
X-Received: by 2002:a0d:e1c3:: with SMTP id k186mr842956ywe.355.1556112265228;
        Wed, 24 Apr 2019 06:24:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw32FpIaiLK8CUFEK8ZPN6iXcVMugWCFfT6lCafDeRxuQC9qBpy8ay/+hzAixeyS9Cl47+N
X-Received: by 2002:a0d:e1c3:: with SMTP id k186mr842891ywe.355.1556112264420;
        Wed, 24 Apr 2019 06:24:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556112264; cv=none;
        d=google.com; s=arc-20160816;
        b=d8810/UxpQqbwKLJp+KThrt4lTQRrbZ2xI+fB6drTjuyh0xs0BKn/7eBZ/blozHpku
         y5AQBFS/fXZY/Og8mTqKma80QULTuEtB/XGdZ7JyuYZO/tAhzp0D8eKuNPncwM53cshd
         OUCzyYrchUoTUNfCQDj48qlUPoYS+asyU+vYiZDONASmXPB0QWsrDKx5blDdazeDDn/Z
         II1xR+06vJ/9pCkSR9xxc7ooUkLrvtrKr+PQKXMAAdMuK+EZLQ+riBfEAo7IeHtNHy9S
         vVbOdUwD4vfvI1N5WgIEFnTcASMmbJukVgtgfUFiARn/nppGcVcrNAAZO3WN5ty6/Kws
         KXDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=ZEy2G1L4e5dWWuDv8ziYDWgBWhVqrzd8jMSYeDsnxko=;
        b=0OZfy/1FUm5sC/BPFeWi3Q3/cu7Y53efz9QGUtELCQ+Hbyxsal0hxcY9m2uMoa7zkP
         YJmBRXEvWX7Epekj8gRv1wtw4yqZMQ4xFOdzaAExcm+05sa5tLEHqqfgQc3is2SBVM6I
         O4VB0jcaf2RP5KOfT2kLELze2BLwbJCjIbiJfYSdPxvsT+TBxPUSiCIzAv1J4ZB2CkLU
         +om9VQyT2iM13fISLiI/MXz7Jlk4fYTl/n860hvMyfYKwU7VNc4KvU1qPg3/Agwr5YpF
         zhVlSwhVY6+dr2/DwU2fN5C5a66RsIQSITOSKmQ4InvQtSXbEaPhzhJdgZe0AiaITWtu
         vP2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 62si13203100ybm.424.2019.04.24.06.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:24:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OD4hff138191
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:24 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2r9w994u-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:23 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 24 Apr 2019 14:24:22 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 14:24:19 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3ODOI1W52035774
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 13:24:18 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AB91C4C040;
	Wed, 24 Apr 2019 13:24:18 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DF2554C04A;
	Wed, 24 Apr 2019 13:24:16 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 24 Apr 2019 13:24:16 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 24 Apr 2019 16:24:16 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: x86@kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Christoph Hellwig <hch@infradead.org>,
        Matthew Wilcox <willy@infradead.org>,
        Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 1/2] x86/Kconfig: make SPARSEMEM default for 32-bit
Date: Wed, 24 Apr 2019 16:24:11 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556112252-9339-1-git-send-email-rppt@linux.ibm.com>
References: <1556112252-9339-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042413-0028-0000-0000-00000365144B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042413-0029-0000-0000-000024246691
Message-Id: <1556112252-9339-2-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=13 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=789 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240105
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sparsemem has been a default memory model for x86-64 for over a decade
since the commit b263295dbffd ("x86: 64-bit, make sparsemem vmemmap the
only memory model").

Make it the default for 32-bit NUMA systems (if there any left) as well.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/Kconfig | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 62fc3fd..5662a3e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1609,10 +1609,6 @@ config ARCH_DISCONTIGMEM_ENABLE
 	def_bool y
 	depends on NUMA && X86_32
 
-config ARCH_DISCONTIGMEM_DEFAULT
-	def_bool y
-	depends on NUMA && X86_32
-
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on X86_64 || NUMA || X86_32 || X86_32_NON_STANDARD
@@ -1620,8 +1616,7 @@ config ARCH_SPARSEMEM_ENABLE
 	select SPARSEMEM_VMEMMAP_ENABLE if X86_64
 
 config ARCH_SPARSEMEM_DEFAULT
-	def_bool y
-	depends on X86_64
+	def_bool X86_64 || (NUMA && X86_32)
 
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
-- 
2.7.4

