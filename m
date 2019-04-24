Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04578C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 13:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3101218DA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 13:24:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3101218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 957E96B000A; Wed, 24 Apr 2019 09:24:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E32F6B000C; Wed, 24 Apr 2019 09:24:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 756CF6B000D; Wed, 24 Apr 2019 09:24:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 497186B000A
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:28 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 23so385784ybe.16
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:24:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=IV2+HQyP2BC7or9VCP6IbSdO/Atk1DfDq9qZtT5TQ9c=;
        b=ksqW0tPJ4T9gE3vlux4OfeTn68p9rMokbIxImVUivt2VLt8w8A4Dpv9o2yMkGzwR89
         e33/vEpSkXf2yrT7wuxcOsTpdeKrTWAx8nXZnRZFG5EJ3LZfhrN5uHmNAbbVhQ68vqwA
         M0nzs50vO6+O0zZuf0p91yHFhNIynhj+7Rl66pyZD4w0rusmUtTqke7tVRrdkuVS6eNh
         A6Jr9VQNl5XIaDMdedtCuwW5r8B4wAh0zf5rIGGs303Kmpsrh3ieXGw1hYtSRPLoAKBn
         Hz0hpvDNcHByFkzRXNiWHUBqFgaONPXNgiKNsESLBpTtUDttQWH1rl1Qji9hLGrvu1My
         rjlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUZoqEOd9xqAdRiosMeQ8wSe5PSycEqQTOu06lYaslFYuL2lyxe
	Nw/EFDaUtNM+/J7eF1HPloQWYdat5iSFK6gkgER+zy7l94EFKavSG3Z9Jujahjgb7G+Au8hWwH2
	h1m7gKlC1c74ZavmPKwA8e3ATW37sdrdZ/ScudijShf8/IA5AaV39R/oZ4biq2dnSKg==
X-Received: by 2002:a0d:e844:: with SMTP id r65mr20131035ywe.41.1556112268097;
        Wed, 24 Apr 2019 06:24:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLYXC7FCZ3yRV+CaTVQrZbUZqH3Zo455Yy4j8YYxKCyuS7hyy92/2Hqw7jyuwuRebHMexT
X-Received: by 2002:a0d:e844:: with SMTP id r65mr20130988ywe.41.1556112267551;
        Wed, 24 Apr 2019 06:24:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556112267; cv=none;
        d=google.com; s=arc-20160816;
        b=qQ5S+u9RuaYaF4vjAID8grkPt+vuetMW8ckh/WIfd2LBhHlORGf1DtthCnFbdyr/jH
         y9hkDxjZuzyi8s4JXRk3O9bVJC7A3uLXcA6qWPApTu8KIzmfW/4IyfXH1ctg6bNmCnDg
         99eZQje5kZQLAtCIrsECZ3rjJtxrsCRUjRh49+MNL1Q444lqgZkGDbB9nLnFu0VjDXCw
         EMLI/79gb3qPYA9aHl4MzJdhlfTV4GvKZnrdyPp5WOyS5lVeQPfTEphLO1IKggjhKaTZ
         PjftP5k8RzEIfWLyyAtS4/FJIa86OqPYv1FwvESvBbkVqkpUXvX+WPiulVe9QYoteCAD
         cJaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=IV2+HQyP2BC7or9VCP6IbSdO/Atk1DfDq9qZtT5TQ9c=;
        b=QGzxS3d8XHYDyN5rvi8X7rIGUE3Lpz1f0Rh8eyNAcMeWWKImnscIoWxyV/0VA+kPov
         CfbZBOhFyNp8gpdDmCOAG2kh4MB8y+gIbNp7XWvjusZ9s5KcG6EmdSK7tfiBasQxnPzY
         OrXDUaF0us1AknJSqa3X5gU8arxXfa2YVlP0bDedsf1aHH/QWbhRtSjn8PhcFq0btXlR
         lBb1gv6Q2fEWxKquCOrtEt3onDvAaEjC/tJrU8jtgL18Xn4TnCA4aJRe+3dfJnQLzdE2
         pzTLzPxGN7QGz4+c3RB0288r55ObN3eFzqEUufjEZIzCnVtgnVDbUQfdyqjlD8T2cbub
         191A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x190si13384351yba.97.2019.04.24.06.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:24:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3ODM02U090000
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:27 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2rmcg1wc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:24:27 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 24 Apr 2019 14:24:25 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 14:24:22 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3ODOLIf52297786
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 13:24:21 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 27DDEAE058;
	Wed, 24 Apr 2019 13:24:21 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 565D3AE056;
	Wed, 24 Apr 2019 13:24:19 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 24 Apr 2019 13:24:19 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 24 Apr 2019 16:24:18 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: x86@kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Christoph Hellwig <hch@infradead.org>,
        Matthew Wilcox <willy@infradead.org>,
        Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 2/2] x86/Kconfig: deprecate DISCONTIGMEM support for 32-bit
Date: Wed, 24 Apr 2019 16:24:12 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556112252-9339-1-git-send-email-rppt@linux.ibm.com>
References: <1556112252-9339-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19042413-0020-0000-0000-0000033411ED
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042413-0021-0000-0000-00002186776A
Message-Id: <1556112252-9339-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=13 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=795 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240105
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman says:
  32-bit NUMA systems should be non-existent in practice.  The last NUMA
  system I'm aware of that was both NUMA and 32-bit only died somewhere
  between 2004 and 2007. If someone is running a 64-bit capable system in
  32-bit mode with NUMA, they really are just punishing themselves for fun.

Mark DISCONTIGMEM broken for now and remove it in a couple of releases.

Suggested-by: Christoph Hellwig <hch@infradead.org>
Suggested-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5662a3e..bd6f93c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1606,8 +1606,9 @@ config ARCH_FLATMEM_ENABLE
 	depends on X86_32 && !NUMA
 
 config ARCH_DISCONTIGMEM_ENABLE
-	def_bool y
+	def_bool n
 	depends on NUMA && X86_32
+	depends on BROKEN
 
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
-- 
2.7.4

