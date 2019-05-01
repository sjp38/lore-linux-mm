Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C778BC004C9
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:56:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8052220651
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:56:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8052220651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24AA96B000D; Wed,  1 May 2019 15:56:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FB696B000E; Wed,  1 May 2019 15:56:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E9766B0010; Wed,  1 May 2019 15:56:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id DAA816B000D
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:56:44 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q2so396078ywd.9
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:56:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=ql5sRn553pbmvzkl6VYt+sDfuCGFt2/kqpttabHkmVk=;
        b=kbrMo8YhIjPnjPbIoCMliio6gTMGraZ+7ZIHTGO9//eCAKQgxJQjh3wKcEzFHOsfI+
         38ej7ArYSE9zKGQPKC85flAyY1ah4/6Gaq57LFKSXp5/uX2CkjwZraoPCzUA3I8G2lbV
         jXppiUvnnISP6yRXZQvKOiCrtkvVv9waTRqxLB+34KnBXy/mCX/VCZq5b/xvY4LQBI7l
         V4PvdH/mStckoPmY/YupVofWXnqJne/i4kkGKy6/tEzgNRrk1WnfGZaZAmUHZUB5Hmeg
         RRX6frayc0mbB5k9/iZSPN2Bs2DNkwGzcmtsSmUbXBVXjWAdx9GGm5gAWN5oPzrQWzKf
         NVCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUHdNqA6M96TEDHBsyFea6KWxuPIqaqTgL6fcsb2qZGTubhsXqc
	HbzqdwofHfgkTkde0xGoafGF4m51kevFyWJaPGhQqa9b2sUf6KQCEqZQrc9QvBGYEIQBnS6WUDc
	jY7M2rZC0r5Uci/2p9W7u2SrsgJM5s057UkoOCAyyVxsGGXkKUTeeKdQbTDN8g/puEA==
X-Received: by 2002:a25:b949:: with SMTP id s9mr39751374ybm.20.1556740604664;
        Wed, 01 May 2019 12:56:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7rkYSddNm+0g22gSOlWxSkCNxU3TXJYUS4t2QPGJLmH6KkeI1j89+ZTZWhB+qc7sU0JiM
X-Received: by 2002:a25:b949:: with SMTP id s9mr39751338ybm.20.1556740604080;
        Wed, 01 May 2019 12:56:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556740604; cv=none;
        d=google.com; s=arc-20160816;
        b=kaiwwIpdtahL5+v9kn//jq3rMlsodAxIVsxcVVj5iEyjIwBR7iMqOJmDruyevzwM57
         cPCdiLaxtvqJfDIn5+S2PmtC+zx1qfrPAP3Mrp68utExFTFvWyOxmZEa2KqvFn8HjPQP
         8xqjzZd4yltNp70YxJyvLCMlKzvV5nw3rnyOLZDokCif4lXi8Xe7GqjK/kz+Z1LSEfcV
         X0xQYduIP9AYUjMBxeY3ampfTlXDWlkN3wwpLI0CW6sOYm941bt5DBxx27JsroT/w361
         OD6hF0LcveKBSk2yvf360qgkKLWilJvukdZ8ZM2+iNEnhA7JY3Ystc8svLp7a42ihjS+
         tSZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=ql5sRn553pbmvzkl6VYt+sDfuCGFt2/kqpttabHkmVk=;
        b=goV6K5GmwetAxvhZSZ4uWWIuKG4Nrvu+IHtQnEUQlbFWytdS0FpINulcuTGzSUdHHy
         ysdGelX5tMQ6jQwkQlJCuByxrkrZjtAk/jg5wc+DawdvFGnAANVC8voNySxk7qG08VYT
         s2LfoqXL6P0vYjRQtFd5kgZIob0+X3GmpdzaN+/9EDtGx+TZ6F0zdCnZf/90xTeyHFvA
         WTxIugPEf3X9Gg6yNT2nGuceUuiG9fJmonKXcyHCAJMgswSJiDO54XvkWuQLcbFixNdJ
         vbrHeXyfwRFWz35lSgOQN2QuMrz6Gd+UtmDkYfJj/r2bKk/ilxmGy7gE2TqF0hZ8vhFA
         IMmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t205si23034883yba.109.2019.05.01.12.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:56:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x41JqHGh037409
	for <linux-mm@kvack.org>; Wed, 1 May 2019 15:56:43 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s7dvw2jy4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 May 2019 15:56:43 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 1 May 2019 20:56:41 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 1 May 2019 20:56:38 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x41Jubuk48365568
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 1 May 2019 19:56:37 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9BE3842049;
	Wed,  1 May 2019 19:56:37 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7CAD542047;
	Wed,  1 May 2019 19:56:34 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.12])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  1 May 2019 19:56:34 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 01 May 2019 22:56:33 +0300
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
Subject: [PATCH 3/3] sparc: remove ARCH_SELECT_MEMORY_MODEL
Date: Wed,  1 May 2019 22:56:17 +0300
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
References: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050119-0028-0000-0000-00000369516B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050119-0029-0000-0000-00002428BA52
Message-Id: <1556740577-4140-4-git-send-email-rppt@linux.ibm.com>
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

The ARCH_SELECT_MEMORY_MODEL option is enabled only for 64-bit. However,
64-bit configuration also enables ARCH_SPARSEMEM_DEFAULT and there is no
ARCH_FLATMEM_ENABLE in arch/sparc/Kconfig.

With such settings, the dependencies in mm/Kconfig are always evaluated to
SPARSEMEM=y for 64-bit and to FLATMEM=y for 32-bit.

The ARCH_SELECT_MEMORY_MODEL option in arch/sparc/Kconfig does not affect
anything and can be removed.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/sparc/Kconfig | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 40f8f4f..9137dbe 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -305,9 +305,6 @@ config NODES_SPAN_OTHER_NODES
 	def_bool y
 	depends on NEED_MULTIPLE_NODES
 
-config ARCH_SELECT_MEMORY_MODEL
-	def_bool y if SPARC64
-
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y if SPARC64
 	select SPARSEMEM_VMEMMAP_ENABLE
-- 
2.7.4

