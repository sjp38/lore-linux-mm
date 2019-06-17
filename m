Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4309AC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03A01218A0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03A01218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B09748E0006; Mon, 17 Jun 2019 00:38:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A41908E0001; Mon, 17 Jun 2019 00:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86D438E0006; Mon, 17 Jun 2019 00:38:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 636438E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:15 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id p18so11020496ywe.17
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=JNUaZIXkWp18dhJiS+301s789BGEgEjFsfsmKAuMekU=;
        b=lYELmUo2zX0KNTA810YPviYHr2IeR0kkf7JLOYOwzLLi/v5QygoxA9/enjFtLmZ0po
         rGJv+ED/mGkDuf3kDnqZWIX+kD1rrm/KIQ0c0qtJFp1lvc8SrL2N4El+WGHdGMsayWzO
         vWEVtNTHh3ufhOHO9BPUwf3+V1BkaS65M0vQZocgT3MpY3/eGeRpynYI6Sj+4xRM4jak
         KIJ+oxbDSjsGbaygXWNGhaq6bov61CyC6R4LFpMD2w/VchZRM54RlsiJUiPue8F2sP6T
         Ttgzgk7IFYuxcH2KJRVuawr/1wSN26TvmH6JRsNwXGHc0Mq80zCttnXVvSIQhx/Mv+7r
         MMzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXEDMhYmmosEBqy/VNC8rvma70SMrFI//qI1zQCjW+TrD6qEzns
	1SphZIpXPxHAileplsAhBGozNAk3WtRLyKZbP+Siku16oEKC9O/MyK1uNZww2/DiRt+ebBdheEU
	jRzprte1KUpBMPjdUsQwrgKYjLWLksKDPtYu2DKyQof6RlDLbkzG4NcHRj/uwiYmKIQ==
X-Received: by 2002:a81:1c11:: with SMTP id c17mr61664580ywc.402.1560746295123;
        Sun, 16 Jun 2019 21:38:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbVZCZO38Pfm9QW/+Fiq6pQyzs3E8FkcTVBQYWLIXwWsjE+zYlZ6A8fjhW7fOzYQkxsaZy
X-Received: by 2002:a81:1c11:: with SMTP id c17mr61664568ywc.402.1560746294622;
        Sun, 16 Jun 2019 21:38:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560746294; cv=none;
        d=google.com; s=arc-20160816;
        b=dMKaAQ0yUcKo3MvAUG3WF0CbCtmhzYcKOqxFZAnh9+CAB4mSwihx4p6OJJNkK+/1Sv
         2Z/lb+6fcLmkc1zZhObkLkv934GhNGNlyWAJBs72NLbLnrHTNgdtprjA16D7vPjUZarR
         gMwybkoMWRGp7zXee/AunQ8IKVAiALtWb9yqwK/XWOnZxgotvHLQ0uysb/UKIOFwX55Z
         Z/pHeMhH+6KLFZZLOGgv4bQvgnTnpkSq5nHWd0voXXfK66SrwSM+CMTX8/A+77Dj7G6A
         sBlXdUm9MhMUvl61QNqSkA8soKCI+8WN9R1FLWqGfd6fOKJ96p86ZqBkLRdKjJpbo1Tr
         S0Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=JNUaZIXkWp18dhJiS+301s789BGEgEjFsfsmKAuMekU=;
        b=XHuzpuXKP8bAo3iFuM9LBEaPYq7+HTQc4ew3mpx5hs84MjTzBBmtVitUyNvN4t8wE1
         5aRFNGHb9WQaQsy5lTFXaO5/6lWgMikarHN8mk2b9hb8Nk5T4XxSw58eoc5nuufFiu83
         tgp49NkShqk/27m2V9278PmGX1P0ivi6cjQrkWGJ1fPRzjrAEi9R3EV02OnI8GVzBhv5
         7PxJXftji0HbiH1e/L0jt8alL1159wTPtvkaJkC0FpZETj0Z7u9FVQXEes+amg8QarMo
         2Mny/Uqxq6iSbYfMxJW9RhffIjqD8RPylOPd7K9V/TbwzoLoBbZuIfrwJUymyGXM+pn4
         VE5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x11si3570580ywi.252.2019.06.16.21.38.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 21:38:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H4c1hm087926
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:14 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t62a8juma-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:14 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Mon, 17 Jun 2019 05:38:12 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 05:38:06 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H4c5sM59900020
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 04:38:06 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DF9CC4203F;
	Mon, 17 Jun 2019 04:38:05 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8D7BC42042;
	Mon, 17 Jun 2019 04:38:05 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 17 Jun 2019 04:38:05 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 7B66FA0208;
	Mon, 17 Jun 2019 14:38:04 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>,
        Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Peter Zijlstra <peterz@infradead.org>, Jiri Kosina <jkosina@suse.cz>,
        Mukesh Ojha <mojha@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 3/5] mm: Don't manually decrement num_poisoned_pages
Date: Mon, 17 Jun 2019 14:36:29 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190617043635.13201-1-alastair@au1.ibm.com>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19061704-0028-0000-0000-0000037ADD8F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061704-0029-0000-0000-0000243ADFC2
Message-Id: <20190617043635.13201-4-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=706 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170042
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
index 66a99da9b11b..e2402937efe4 100644
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
@@ -771,7 +773,7 @@ static void clear_hwpoisoned_pages(struct page *memmap,
 
 	for (i = map_offset; i < nr_pages; i++) {
 		if (PageHWPoison(&memmap[i])) {
-			atomic_long_sub(1, &num_poisoned_pages);
+			num_poisoned_pages_dec();
 			ClearPageHWPoison(&memmap[i]);
 		}
 	}
-- 
2.21.0

