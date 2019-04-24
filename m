Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F249C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:34:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02F59218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:34:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02F59218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90C406B0005; Wed, 24 Apr 2019 07:34:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B9A56B0006; Wed, 24 Apr 2019 07:34:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7843C6B0007; Wed, 24 Apr 2019 07:34:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57B246B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:34:06 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 10so14367173ybx.19
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:34:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=CK48a1V47w5pk5MuUvIvJ01PE7uUDnX9FP0Tm8x/mAQ=;
        b=sglNFQ1nRAY0yWQu/qs++i/dv+0rzo2zzLWMPJyGnYGTQMnuzio65ksMaafBLZ2CMa
         NySa/Dzk6dFEyyzOLxqHixVw4sspoDV5co4Iy402fn5EEKFKwMWEube5bbsbdBGjSrev
         Je7voyPq3uP89ZTvIdfTJnxgS9UXHYIzLBFKfP8GuiWIVHW22AD+sRERUTXsveA74+ou
         M8d9Q6u+MIoKYRdrd6mADYVw6p/KjYMMdboJmPPs6parKfkSoE8khs17xIZEdaPqvP34
         UGZDqAgvv8+UoHnpV2T4XGG6metYAYA4dSCKZD6ygSdxG7ldYVDZFvPnfbNoWi4cIuVk
         01Gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUvKSrODHEhlCMM58zAD0BQK0SHgRj4f1eiTrisPwiYxoi/5lq/
	m3Rsjz0wXGAq6CyIbZCjDtzkrzs0q/M7LYgQAIlQANGjjmnv7wfBvoNEy+qYO7EA4zFJYEISyDS
	r0suh6VroiyhdhqpxJE7fksbOp0rbqUBJA19FqwuZ2XDL1gjZGGfoEk5lrJum4SVHaw==
X-Received: by 2002:a25:2451:: with SMTP id k78mr20875587ybk.126.1556105646121;
        Wed, 24 Apr 2019 04:34:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyP14XFL2iF3aVwwqRnrQRjVlrNCYZRaMFx9lifakBBgy8eB4UXMDcvQ/uiW7bgNPRSJc6t
X-Received: by 2002:a25:2451:: with SMTP id k78mr20875528ybk.126.1556105645336;
        Wed, 24 Apr 2019 04:34:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556105645; cv=none;
        d=google.com; s=arc-20160816;
        b=ENmaJsaW7cHtBvNlmwdeNFPgfXUSQzotAWVVbPMcII5L1YCkpabc81exmreRtwuChY
         IlycIZT4FBpQXpbzPUupKz+Wdw2z/UPRtJp6jFB4SvBxZB8R6mhVKyZL9AkANUpn8h2+
         0Lz5iwgLxuBgtLm0ihs08KwzGSEl2NB73AOrJcQCWYQPUdEpvPDSrbCqiB+YfJAOgSU5
         DC0aCtieKw55Ow4CYFuIrr28/wtGG+6RwuNK1QsJwbvceQCtJ0u2I6aKinxvtcAoZbWN
         N42QP+iydwig+RqZ9NRpAkefX8g74Nu6CO1GBxn3P9brV6wLSBLa29duy4B6yLhEGsdz
         Cv4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=CK48a1V47w5pk5MuUvIvJ01PE7uUDnX9FP0Tm8x/mAQ=;
        b=IJgaOTxm0SZp2Ld0ycWaZU95n68JoPDvQMelW7u7e+cd7lLFfM6ldgUEWIkrXQ1giP
         A+F1MyGZ1BhpfMXuYfvjiItmYXK1YyBzEDQLw8w2C2QcvnW0SJQdM9V8yJawrSpj4/iy
         r7dWnd8Kl7c2cBKfzO6XUAk7VpAFAzlS5aDPT0+RRcIaFfwi6DsIRrnkTFCQRBPWeltm
         nB9P8vKTVmBulO7+CaQtTjOoSC7lkqGbyq8K9BhsTz4DW3yyFSQRX/qgeO0ARoxCnbeo
         DWISEs4KFvE7HwwDAZUtR25b3xZQ3FniKV1QAXJ3GuNSpvElf47MX/YONH5BovC5OGyk
         DtKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n5si12592588yba.355.2019.04.24.04.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 04:34:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OBU064146491
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:34:04 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s2n2s6746-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:34:04 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 24 Apr 2019 12:34:02 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 12:33:58 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OBXvOw43188232
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 11:33:57 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B0825A4068;
	Wed, 24 Apr 2019 11:33:55 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DBF48A4064;
	Wed, 24 Apr 2019 11:33:54 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 24 Apr 2019 11:33:54 +0000 (GMT)
Date: Wed, 24 Apr 2019 14:33:53 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>,
        Matthew Wilcox <willy@infradead.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mikulas Patocka <mpatocka@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        linux-parisc@vger.kernel.org, linux-mm@kvack.org,
        Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
        linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190421063859.GA19926@rapoport-lnx>
 <20190421132606.GJ7751@bombadil.infradead.org>
 <20190421211604.GN18914@techsingularity.net>
 <20190423071354.GB12114@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423071354.GB12114@infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19042411-4275-0000-0000-0000032C0709
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042411-4276-0000-0000-0000383B4F66
Message-Id: <20190424113352.GA6278@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=874 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 12:13:54AM -0700, Christoph Hellwig wrote:
> On Sun, Apr 21, 2019 at 10:16:04PM +0100, Mel Gorman wrote:
> > 32-bit NUMA systems should be non-existent in practice. The last NUMA
> > system I'm aware of that was both NUMA and 32-bit only died somewhere
> > between 2004 and 2007. If someone is running a 64-bit capable system in
> > 32-bit mode with NUMA, they really are just punishing themselves for fun.
> 
> Can we mark it as BROKEN to see if someone shouts and then remove it
> a year or two down the road?  Or just kill it off now..

How about making SPARSEMEM default for x86-32?

From ac2dc27414e26f799ea063fd1d01e19d70056f43 Mon Sep 17 00:00:00 2001
From: Mike Rapoport <rppt@linux.ibm.com>
Date: Wed, 24 Apr 2019 14:32:12 +0300
Subject: [PATCH] x86/Kconfig: make SPARSEMEM default for X86_32

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/Kconfig | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 62fc3fd..77b17af 100644
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
@@ -1621,7 +1617,7 @@ config ARCH_SPARSEMEM_ENABLE
 
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
-	depends on X86_64
+	depends on X86_64 || (NUMA && X86_32)
 
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
-- 
2.7.4


-- 
Sincerely yours,
Mike.

