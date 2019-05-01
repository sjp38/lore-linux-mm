Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26099C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:56:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E33B720651
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:56:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E33B720651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C9406B0007; Wed,  1 May 2019 15:56:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7792F6B0008; Wed,  1 May 2019 15:56:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 641E86B000A; Wed,  1 May 2019 15:56:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24F026B0007
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:56:37 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z12so28612pgs.4
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:56:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=zK+YPOxjYYA3BiDROsRPZYAnKij8b3UfyGW7PsFOTBo=;
        b=gzi/jTtl7Swdu6qMWVjgqHMih2NgxW7J4kEhYRkz9bCqcIZYox701I2ji5P8oXiw26
         noq4dNa4SILMau/vJcqsfBdJh3BECYvePd4/oLWha/ABfWrsf1xXZNb1EJvFj27mz3Hg
         lx3wyJK2wC/BbD5ukeZu6m/Y85TzkBGmIvIN3Oa5mnYK77gROaQNP0I/2uA+zBrcT36b
         UfbYxWGetytObVoIDW8WHyFrZFyftIiVnl9AGJ9hTxn6wnVyUMjhqSbm9Wvpm1aoK5P9
         wVRxNb8wJOd3OzpfkcuYAUv2AJZjlBZaIilmNpGhFoeu1DKZaouEtUqjdnmUEt2ZjpdS
         Sriw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUSm+3Y+LhwALE9RXnYvH6T6E7Kkgee+BBlZhq0FPRO2d5JSlWJ
	f1hvepvCfZG1CcXImJdNJSalTEUUiDbyLvst6yMBQvMxMFt5ebhEQLcXS17ZPEPrflMD6TOKx13
	N4Ws/EioqbjqUxwiiM2lrjfD+/JYg672//Ixpwn7LUduEkjoryWLMfF1ltWNXB6cFSg==
X-Received: by 2002:a63:5953:: with SMTP id j19mr74998397pgm.260.1556740596731;
        Wed, 01 May 2019 12:56:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWIRiXsVC6oKrT0lELibHIQJOLOJnHUTwgqOgq7hKcH2gYdTVO4E5Mu2Qi+z0ObwgWCKvx
X-Received: by 2002:a63:5953:: with SMTP id j19mr74998342pgm.260.1556740595934;
        Wed, 01 May 2019 12:56:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556740595; cv=none;
        d=google.com; s=arc-20160816;
        b=p9JcPADcvrwquxd4PmWWkoDlkTRAM9YMPNri+rvcW7YO0xJZdt+0cEamEIf7gIG3il
         aThxU12CAF8ud3lzOgXzTQO4jHUqDnRV+jpkrw7UCfMR8lR9tWDMPe/q1VtFramea4xB
         P5+S3g/td+6k5jKXOKc4YlA+YQcYb04Q/VVYdUI6HELvhLriJeNrkC/y7Izgh1okPO5Y
         D021daNIllf2n69zTeJewvvIqArM/wJ5Ph88uvDDd5QTDI/YfPUmsdNLMY8YVF/vC1RF
         WXwyml0JqXu/X0eHWx9fw31mcrtEjitp+1lpR+X/mzBrw0dLpTcXVKOPkmKkTI6CbOY2
         VE4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=zK+YPOxjYYA3BiDROsRPZYAnKij8b3UfyGW7PsFOTBo=;
        b=AxhAI+HHPzaEbqgFtAzCbRqALxYQwrdJA+RDjsn+GtVhOsLFZqNAgk3622YbItLIvm
         JEGGOTR7MwZsrePGaUl+7gp0BLiikKBIM26Vbn0+HhLlc01P/xlEkmN2MeqlOCwuazBe
         WydBD+60TxVHxm4qBKI5hLXSj/glifLYeZevIe1zuJn+j+gBilYpTPTkBo/whSK1i+uT
         nHJx8PwWWh0HbL8yz0HiAZln2/+NI6i8sXSlLJHl+IFKt/c1Wcm2XrY68pfYmPJ8H0Ur
         zBbw8heRHWLRLz5Gru+lKjrE7qifrazxkj9v8YihbEtZvYSJTo7YmR+ZKREfApE/TZM1
         MBKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x18si9611662pgi.193.2019.05.01.12.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:56:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x41JqoqQ120172
	for <linux-mm@kvack.org>; Wed, 1 May 2019 15:56:35 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s7eeh1fff-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 May 2019 15:56:35 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 1 May 2019 20:56:32 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 1 May 2019 20:56:29 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x41JuS8U46792752
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 1 May 2019 19:56:28 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3BC024203F;
	Wed,  1 May 2019 19:56:28 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 16D8B4204C;
	Wed,  1 May 2019 19:56:25 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.12])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  1 May 2019 19:56:24 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 01 May 2019 22:56:23 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 1/3] arm: remove ARCH_SELECT_MEMORY_MODEL
Date: Wed,  1 May 2019 22:56:15 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
References: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050119-0028-0000-0000-00000369516A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050119-0029-0000-0000-00002428BA50
Message-Id: <1556740577-4140-2-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905010124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The ARCH_SELECT_MEMORY_MODEL in arch/arm/Kconfig is enabled only when
ARCH_SPARSEMEM_ENABLE=y. But in this case, ARCH_SPARSEMEM_DEFAULT is also
enabled and this in turn enables SPARSEMEM_MANUAL.

Since there is no definition of ARCH_FLATMEM_ENABLE in arch/arm/Kconfig,
SPARSEMEM_MANUAL is the only enabled memory model, hence the final
selection will evaluate to SPARSEMEM=y.

Since ARCH_SPARSEMEM_ENABLE is set to 'y' only by several sub-arch
configurations, the default for must sub-arches would be the falback to
FLATMEM regardless of ARCH_SELECT_MEMORY_MODEL.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arm/Kconfig | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 9aed25a..25a69a3 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1592,9 +1592,6 @@ config ARCH_SPARSEMEM_ENABLE
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool ARCH_SPARSEMEM_ENABLE
 
-config ARCH_SELECT_MEMORY_MODEL
-	def_bool ARCH_SPARSEMEM_ENABLE
-
 config HAVE_ARCH_PFN_VALID
 	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
 
-- 
2.7.4

