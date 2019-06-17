Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C931C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF5E72187F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF5E72187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9091E8E0005; Mon, 17 Jun 2019 00:38:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 891AA8E0001; Mon, 17 Jun 2019 00:38:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 733168E0005; Mon, 17 Jun 2019 00:38:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA248E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 65so2249402plf.16
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:38:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=DFBoyGt+R8NmTOF963r77w/ya+w4JVWfsRrNAxQkV7c=;
        b=n04nmY3MxCQ4hnBleIhkFpRRH1kEehIM7PwnoqWTWXYngIvP6KREMT5ibUpiransDJ
         dsL6yiMHgitC5bvZh+NdC5UgKLEzFYnrm2HaP5nP9GidjNIqBfKOruPmiztMjtC4OvdM
         QWeJ1ILtjbbo+XK0BMK63MRYaSZZ0wZVbtiJd3BODmac3mL9ev7/9fsXBSO+kKfLVMct
         7TsAcohRbcvKtxtEmp8jbXLBGFQp5oQrtLRIls0XPJsDMoQ8S2LK0On4h5hZEp2LCdmK
         +0T+VezkLUg4b+yVUtmAj94whCpab0oi4yr8vyBpyJCT+0nnRiQm5lDCCRnM4Do6+1qI
         BPsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUgi/MBQwfJVPBxGEQt7xEGt4LBydOj87ACK3rAL4t8CxoR0Z9+
	odpEd4OLMVIEAx/KluThHiPe8K1eDAohcl3UzKFiC+wLjeL47X5Ruv+z1fmEANX6uaCBj9GLmSH
	Bp3TSaEi9IJjQbje4yFafwUDo1ZyJtBB1tO1UsRd4UvnD5dZE26rXBtxCfYl7t3HO7Q==
X-Received: by 2002:a65:64d6:: with SMTP id t22mr44951209pgv.406.1560746292806;
        Sun, 16 Jun 2019 21:38:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRXPJ+QN5JIp7SEj/OjO5A/wrp4VmQpd21PsUPsvmr1Wyha1/ysCgFe/aJAvvk7WLg7py6
X-Received: by 2002:a65:64d6:: with SMTP id t22mr44951167pgv.406.1560746292089;
        Sun, 16 Jun 2019 21:38:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560746292; cv=none;
        d=google.com; s=arc-20160816;
        b=zt/EY/4aJH15dkbf/PYpbQ2K6S00vxlyFn8da0h8+iYYxqWChT5Ep+hO1mjsiwszBg
         2eAqZJknneyBPzq6IuPqkDFgeLSXq4pGZ+O+NPmKwsuVA4slvGPqbEwkYDDOKLkwYeZv
         adq1j585IzeEwigGBX9Nz0LrWHk4pxLd8KvEmHmRiADz8R9c+m6+Z9RcCk686AqF+vxk
         JRBPjXnkbVeesp4v7BZp5K4KplmyE16LKS8m75SGOpWvGfAnIgvpL9Z6UZw1ZzyVUaiZ
         7yGf1m2zNgDEy9o5zyJZtCz1PZiPuF40NW9mAgMUtp1uudUoH/GrzRzy12wg+k/fvGW/
         Y9OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=DFBoyGt+R8NmTOF963r77w/ya+w4JVWfsRrNAxQkV7c=;
        b=aUMXptRvV+yRk6ATpsKQ5PwENkml1/+JOrWcbuxNAMNsfhrqDap11sVt4DIL5GBrmp
         2goPbMFuW8J5Yw3JELWm4v3PGsfQ2/3KgEYvEPoMhpceq4yC5Cr0xStncmmrgIx1YwfB
         Y46EU1tF0UwNEXIPUyEcZg0/ptGP172WcG4viu3NITj3XTwuutWg8Mmasipd7x1qOTMb
         QQHfiLZVoQYbpVJfYdGnoIyFe2FwrhR3PorkqK23VaUVA3m8wZrVy/VQZMFxhh1gwtfA
         Sz9tdqTHXngIR5+GrhSFYYQVkiNF7oZXmtqF9pL83ZVorv41Id22lU9144rcPt9PaPfk
         xRrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a3si9399683plc.132.2019.06.16.21.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 21:38:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H4c3TE129478
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:11 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t63wxg4r5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:11 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Mon, 17 Jun 2019 05:38:08 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 05:38:02 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H4c1mv37093562
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 04:38:01 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6CEAC11C058;
	Mon, 17 Jun 2019 04:38:01 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 14A0211C050;
	Mon, 17 Jun 2019 04:38:01 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 17 Jun 2019 04:38:01 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 01A97A0208;
	Mon, 17 Jun 2019 14:38:00 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Oscar Salvador <osalvador@suse.com>,
        David Hildenbrand <david@redhat.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Juergen Gross <jgross@suse.com>,
        Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>,
        Mukesh Ojha <mojha@codeaurora.org>, Arun KS <arunks@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 2/5] mm: don't hide potentially null memmap pointer in sparse_remove_one_section
Date: Mon, 17 Jun 2019 14:36:28 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190617043635.13201-1-alastair@au1.ibm.com>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19061704-0020-0000-0000-0000034AAC29
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061704-0021-0000-0000-0000219DEF16
Message-Id: <20190617043635.13201-3-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=544 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170042
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

By adding offset to memmap before passing it in to clear_hwpoisoned_pages,
is hides a potentially null memmap from the null check inside
clear_hwpoisoned_pages.

This patch passes the offset to clear_hwpoisoned_pages instead, allowing
memmap to successfully peform it's null check.

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 mm/sparse.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 104a79fedd00..66a99da9b11b 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -746,12 +746,14 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 		kfree(usemap);
 		__kfree_section_memmap(memmap, altmap);
 	}
+
 	return ret;
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 #ifdef CONFIG_MEMORY_FAILURE
-static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+static void clear_hwpoisoned_pages(struct page *memmap,
+		unsigned long map_offset, int nr_pages)
 {
 	int i;
 
@@ -767,7 +769,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 	if (atomic_long_read(&num_poisoned_pages) == 0)
 		return;
 
-	for (i = 0; i < nr_pages; i++) {
+	for (i = map_offset; i < nr_pages; i++) {
 		if (PageHWPoison(&memmap[i])) {
 			atomic_long_sub(1, &num_poisoned_pages);
 			ClearPageHWPoison(&memmap[i]);
@@ -775,7 +777,8 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 	}
 }
 #else
-static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
+static inline void clear_hwpoisoned_pages(struct page *memmap,
+		unsigned long map_offset, int nr_pages)
 {
 }
 #endif
@@ -822,8 +825,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		ms->pageblock_flags = NULL;
 	}
 
-	clear_hwpoisoned_pages(memmap + map_offset,
-			PAGES_PER_SECTION - map_offset);
+	clear_hwpoisoned_pages(memmap, map_offset, PAGES_PER_SECTION);
 	free_section_usemap(memmap, usemap, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
-- 
2.21.0

