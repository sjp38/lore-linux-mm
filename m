Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01DF6C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B82E12133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:11:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B82E12133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9426B8E0008; Wed, 26 Jun 2019 02:11:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 856A28E0002; Wed, 26 Jun 2019 02:11:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BCED8E0008; Wed, 26 Jun 2019 02:11:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 288218E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:50 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 133so3382965ybl.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:11:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=FngNSEjVr0gOwVr44YRwnoW9tR97PzgW3sZ5tY6OUkQ=;
        b=HSadeyDBHD2JgrdYCm+7onkdC/zU+DFplvyBSUrYDRos9OFx8Qw7WKAhLdKEBQkXpD
         WkKPcJbY+ydQ0qja1ViqSdA233B7RqRdw3QGfFWJVjPMUZB2GdUUzWGxG/VLdw6wJMw8
         qs0MUl81NUlPwFGPNdVtNtvsN6CNsS84TWi6bTxGAU9gonKPo/PK/GbfXZRaz/ug6Ijk
         BzSLW4gaMbfpeH4YhUyh0BEhS83MX3tnBoz52RD/hy5Vv+Ya8lI8+o5UhPqMg/COmQaX
         da8Uvy6aEDfz31LIaoRKwUDqvG249cS4KWNDTr6hgwrLMz73GX6/LdZWu+AWNWKfoGjt
         PvJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVEIB5c2SyKhrbayOTKpNXs7+FIBSLTKjO9nsUuzq9yecCWY5uc
	p+0IjWZIZJiCX9wXcr9jMN8I9YN9aRLqgNQczsMShnc3Dt9Liu3YLuBOQ+jKTtRm5cH4zWe3URm
	STpiO67qxBa2uLxuyA+MpzKoHq97ABQUNxlvkERb0S/JdLMWCrLoV2tsa/M//wE5TqQ==
X-Received: by 2002:a25:bb83:: with SMTP id y3mr1558417ybg.221.1561529509970;
        Tue, 25 Jun 2019 23:11:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziTjPKYsuJW5fl98GUKSTePONmS9EtEVgxRWiZGayH6+uF0TgULh9aI9oo5YNquVcTWe4h
X-Received: by 2002:a25:bb83:: with SMTP id y3mr1558397ybg.221.1561529509497;
        Tue, 25 Jun 2019 23:11:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561529509; cv=none;
        d=google.com; s=arc-20160816;
        b=Yvf3TwEFAmGjqUXEufhXiF5mKpNPI0s7kHywIVYtdxtvtXPFIuATFL8eIFi73KSPI+
         Vt5oddqkYL7XDwzdmjKDFnJZ9hUwgI/xoAt67JfWrUkB4UHO3pT6cnpWnkyPx9pBOGc4
         fdnjxpslTxKeVDswtUCOjtmcbkPY74rPJFgt/NKD98EOJgH0mj9SUp0q78lsWPKNqNcX
         qzpucSQpGV437Ywh/NCNMvV4UfUnmfeOId3dxVxllWF0XcpiQ+DuT/vahVNLpwaCFAda
         hpTZ+XrcMLz4CK+/u9t8UArzeamq1US7LkzfonNFuylztZ7GQd/WEWRgEtnSb3OOoVE2
         7EkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=FngNSEjVr0gOwVr44YRwnoW9tR97PzgW3sZ5tY6OUkQ=;
        b=a6KB+XKDgUHo6Nl3vilTZlskJeeZyAsjW5cGCO8pj+pasoEBN6K+V/us9u8XoELNeN
         eLgN+lF+h3SILwEYniWYPkGE1kYuGGpzEHxbcOwlxkCllchoUtRmLYrUXIsmZrw8liGJ
         9cR7rF3eD1Zb8Cn35sDuC2puFw+TROwqW5YpGnmIImvLbwQu6TjJr+CKzkvDMB1lx1cg
         9cwb2VZmkSRjCrnVioEoac0xLXj+LmEJvw5wQkLquTpQwemoEu2AtuZX+udc2M6pk66t
         N1xSUiIn2AxpTS7A5OIGTx42amjhU8goEN5eInZALot4ze4Gfx+hP0nOMJwpiJ6hMOnz
         b4Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w207si6129508yww.333.2019.06.25.23.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:11:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5Q677HM025634
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:49 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tc045nr17-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:11:49 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Wed, 26 Jun 2019 07:11:46 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 26 Jun 2019 07:11:42 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5Q6BfoY41025540
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 06:11:41 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7EB9CA4054;
	Wed, 26 Jun 2019 06:11:41 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2A885A405C;
	Wed, 26 Jun 2019 06:11:41 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 26 Jun 2019 06:11:41 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 18A61A01B9;
	Wed, 26 Jun 2019 16:11:40 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
        Wei Yang <richard.weiyang@gmail.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: [PATCH v2 3/3] mm: Don't manually decrement num_poisoned_pages
Date: Wed, 26 Jun 2019 16:11:23 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190626061124.16013-1-alastair@au1.ibm.com>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19062606-0020-0000-0000-0000034D7215
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19062606-0021-0000-0000-000021A0E536
Message-Id: <20190626061124.16013-4-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-26_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=764 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906260074
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

Use the function written to do it instead.

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 mm/sparse.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 1ec32aef5590..d9b3625bfdf0 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -11,6 +11,8 @@
 #include <linux/export.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 
 #include "internal.h"
 #include <asm/dma.h>
@@ -772,7 +774,7 @@ static void clear_hwpoisoned_pages(struct page *memmap,
 
 	for (i = start; i < start + count; i++) {
 		if (PageHWPoison(&memmap[i])) {
-			atomic_long_sub(1, &num_poisoned_pages);
+			num_poisoned_pages_dec();
 			ClearPageHWPoison(&memmap[i]);
 		}
 	}
-- 
2.21.0

