Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43066C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:56:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BE4320651
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:56:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BE4320651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94F636B000A; Wed,  1 May 2019 15:56:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FF886B000C; Wed,  1 May 2019 15:56:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 704426B000D; Wed,  1 May 2019 15:56:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31FCE6B000A
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:56:41 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j1so11621435pff.1
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:56:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=P75m6J/SgdGed47tgsY1lNl2lZAcF6KSCrTYQ70aoH8=;
        b=cRnC0Pcttt5Rr+lhd8UtlYi19W861Kh54XJrTtV5Bdzy8Lc1D5UMrUd49/NWk/7bW5
         fh3qtdgqP/2g4I1uazHOc1QOPaf+6kaD3BY1GDZb62iwdV777J+u82EHsHAr/EaWubO3
         DgOAmc0jIIgjr+6gNFpJni5D8/MKHWQDkDMMBoLvnqinAd1tQTRd4TfDnMsodEnDi+4J
         3lrfBehpEy+dhvDIzo62R5vNitFTA3SxIPN0fdeK+ynMb7EaXrYsfMXofbJGhlX+R87W
         vsxBcrSW/mP45LQ3Lv+zcm2+huP+6BRhf6KbF23V6XEmNXCCXxIELQ4aap/x6pCByP+t
         2L1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU54u5V7MXLH+1eWMFH94zHzz2TPIQOsutDpgDM1nn8mwd1mpX6
	G9zU+2lQlH8jEHRgvIvCXhoZ3AEF1326hoXhSgBQCI1Ar25Io7XG/7yY6kT8D7bf0nke8xxL034
	C6cqJ7EC63OqX1geOWeTcjT6wO1vkeIg/U0DnZrcLpIsm3C/uISpHsl75RcaVMtYFpg==
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr20580848pff.104.1556740600854;
        Wed, 01 May 2019 12:56:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqya6tqkjrVgYJ5aFvZFyIm+NUiaGxY32IgUTYBc2/e6CgPupUq5SzHYmhLih7vDbbzCOXFD
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr20580808pff.104.1556740600190;
        Wed, 01 May 2019 12:56:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556740600; cv=none;
        d=google.com; s=arc-20160816;
        b=c49x0J9AjuZ9L9TADgqrIJ8873l/EUyf0KrsfnFbwD8mHCvqKYwbsRxIoe4+55Wgbi
         o0K4Va1OaUlGnSo1/UIyGMk/jORR5rYxOMnPCJwm4p9pbnjQbHxIn9DpF1RSt7AXGcZ1
         rLK58lacA7u1NU9YADVxD3hPOxvdTdkbkGPKcj9VS8yDe+cNCJYCzJJO6yCBRBqRi8bH
         RieLIQzQ32q7iBV/nayhKXAVhM7g/7EMaskYmsXBugShqCEwBc89RFO8GdPy9mhGTxWO
         oG/HwSTf8BC8TqJ4BfCsTIqkhr6IpUjYJlx3v59/9HmwQtluqQjJH0xpDcUJhsGfgUXk
         NiEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=P75m6J/SgdGed47tgsY1lNl2lZAcF6KSCrTYQ70aoH8=;
        b=Mv1gCyDoxpkq0HpIF7N3X4eYjDy7OfNvAYNgd81oSoqbvAHM1ApwD7HWoOQdPjIx3Z
         JoMNnDi2pHqvSRQXF2AT3B70klP6+iqoCM/K15KuIEVxFI8bpfJysq3N1aYpn5HIepg/
         tex/TOZmcP9nDWHHh3oHKdGqWkaS2d61He7oaO/bfqj3LXcbrSshdHxVan5OUuV+DVhC
         jo1Ygs2L7jzaKVHLfYlZmsusFZXErNqJ1NBDizMcytt1LiOwg3/+8Fe6E4NaPDXzJEOm
         AIBrfzMEs804wlXwCw6nzRt0yeH1ItXVJGxtt4xYKAj+5NfcdCseotc9zVCTD0qBRNu5
         uBHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b96si40742321plb.426.2019.05.01.12.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:56:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x41JqGOe028514
	for <linux-mm@kvack.org>; Wed, 1 May 2019 15:56:39 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s7f0wrc2e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 May 2019 15:56:39 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 1 May 2019 20:56:36 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 1 May 2019 20:56:33 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x41JuXfo48889916
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 1 May 2019 19:56:33 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EC7F8A4054;
	Wed,  1 May 2019 19:56:32 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BF155A405C;
	Wed,  1 May 2019 19:56:29 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.12])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  1 May 2019 19:56:29 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 01 May 2019 22:56:28 +0300
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
Subject: [PATCH 2/3] s390: remove ARCH_SELECT_MEMORY_MODEL
Date: Wed,  1 May 2019 22:56:16 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
References: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050119-0008-0000-0000-000002E24BDE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050119-0009-0000-0000-0000224EB7A8
Message-Id: <1556740577-4140-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=976 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905010124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The only reason s390 has ARCH_SELECT_MEMORY_MODEL option in
arch/s390/Kconfig is an ancient compile error with allnoconfig which was
fixed by commit 97195d6b411f ("[S390] fix sparsemem related compile error
with allnoconfig on s390") by adding the ARCH_SELECT_MEMORY_MODEL option.

Since then a lot have changed and now allnoconfig builds just fine without
ARCH_SELECT_MEMORY_MODEL, so it can be removed.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/s390/Kconfig | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index b6e3d06..69d3956 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -621,9 +621,6 @@ config ARCH_SPARSEMEM_ENABLE
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
 
-config ARCH_SELECT_MEMORY_MODEL
-	def_bool y
-
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y if SPARSEMEM
 
-- 
2.7.4

