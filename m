Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 355C4C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB979227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="UTMtmpDs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB979227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A79156B0006; Wed, 24 Jul 2019 04:38:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2A3F6B0007; Wed, 24 Jul 2019 04:38:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91C9E8E0002; Wed, 24 Jul 2019 04:38:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58BC66B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:38:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f2so23690455plr.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=VyZPAujRnjJdrGvHY4XeDJ0aEYZTJ+C5Qzk2NofeJgc=;
        b=OHMI3CgbMa0OhLo0uWUxqREz2RD7mdvCfOYMlnK9tyxMUH/vc9ryA38BY0RCTBHWth
         +XjCBGSewOjQOnlIJ6OCUQAoVBWBG5tSaCahqJsnK3qEBd6rnYYXVb09qePj9wJRUk3y
         6KZX8DRcihtFQLGzLggHpFLLbGbxmH3n1jIAbQnu/Prlxj6zqjGiVYVLX1S6WSg3mCeM
         znQO3lk7Ldw+Q9faXb5RkhAYauqshl0ObP0ltiKSoiXpXiyb2PoEoLDX6WqmmToWxmFB
         jeYgB5nd341UPKnGT4EzvlZ4GviHJfneCBUdJKdqKpJtHffxD9Qbwo9XPz7Ln7lyWz/x
         uHfg==
X-Gm-Message-State: APjAAAXONZBljaTCWGUPoDqhpL0F616jZo6UWWkliuXcVTXu6A6fgMhj
	sz09EYDvfTb5AtP2HT6rIOyh2zRZycGGLW5YHutbiir/jLwNg5hm4Gz01yIc1Jn8vjFKflp3aZY
	LuZ9T5Q1yXMkU9x5AOghezMTOgEFIe6V5iU0ajPf1QOE2h+JJRb/B1nV2FuqJRmIBZw==
X-Received: by 2002:a65:4546:: with SMTP id x6mr79261594pgr.266.1563957501890;
        Wed, 24 Jul 2019 01:38:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/NpKAzR3RNhW5fkACoD2FHcN0KdNFD4cdvZF436kOYY2lh6b0vQa1gNIDsd7bVanHYHuZ
X-Received: by 2002:a65:4546:: with SMTP id x6mr79261561pgr.266.1563957501132;
        Wed, 24 Jul 2019 01:38:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563957501; cv=none;
        d=google.com; s=arc-20160816;
        b=RxXsrtALjytY1nxUTcPbVh4OlMLbWCbarC4H9imkXtWEWbv+Ckp/7POU8M/22EFeBX
         wC5HRiufr5fHGrToDdH6vj+7vOlIbXOYUErHYbdCzEaR4pLnFDHCBZ6dfnzjKL7xU033
         5ZX9fIn+6+H8/XISiHKw2aEgDszg2NW+Wn6Cxtpu7hNYe3AmJ95IyRfoVwpCg4uLwD/x
         Y7Wv61eFZHjb6vSX63bZoIfqOBCr15i9Yjf7Y64VrRE0Dpi8d8U853LtOFiO0tqcoQxh
         ATNl1CgjK/zTxTK+vYiZBFwgFJRuIiUap5Vc3w8IzP4RARfPE4sIVQOe/Y7IYU245bvk
         097Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=VyZPAujRnjJdrGvHY4XeDJ0aEYZTJ+C5Qzk2NofeJgc=;
        b=MP0D9spTcL5fjOgTYoZxiDdmL98wpFHKJzg5UW4Cjiee7UauS/kPMzT5vdlJqLPxCW
         9QptlbgWqmb7QG3CqMpkRjJUDMMJASp8lQu+47MxE5IvTF7+kC4Neun19kzVfdGNY8iS
         uTAqeGbWgM5jHrk5ROiSgRZkqT1a2CdlYEnVIQCuZTUl4wWRp8Hl2+fh/qBLVc5ZihMw
         E0Op5+QaBfq6h+g5A9y04adcTe3QACglI1qKZHUlNkulE5EsBh8DVOkc5f43lChHAc/j
         k7SotAjNOxu4lr2LQTn4R7m7PA+QmqBXZWqmHI7FfQnI7RgkJnAtXI1tIDaf076nCNtN
         ZnGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UTMtmpDs;
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w10si15091081pgt.451.2019.07.24.01.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:38:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UTMtmpDs;
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6O8c5Ee009731
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=VyZPAujRnjJdrGvHY4XeDJ0aEYZTJ+C5Qzk2NofeJgc=;
 b=UTMtmpDsgr5tql5QtD0DaLJNqoZpOsE2PrBV4ng2dNAPhUVsrty/g9cg2s6pEm2V089y
 2Th4KlG7RjfOzpYfmgV31csHz791hpLFINAOt+t4+v+roaXFaNFi+kpLpvtYCat1w0sE
 5OrqcXFgavvPDbO7Qzitzf1e+nXQ5i9mtis= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2txcwahabe-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:20 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 24 Jul 2019 01:38:17 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 2A9A962E30BF; Wed, 24 Jul 2019 01:36:06 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v8 0/4] THP aware uprobe
Date: Wed, 24 Jul 2019 01:35:56 -0700
Message-ID: <20190724083600.832091-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-24_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907240097
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This set makes uprobe aware of THPs.

Currently, when uprobe is attached to text on THP, the page is split by
FOLL_SPLIT. As a result, uprobe eliminates the performance benefit of THP.

This set makes uprobe THP-aware. Instead of FOLL_SPLIT, we introduces
FOLL_SPLIT_PMD, which only split PMD for uprobe.

TODO (temporarily removed in v7):
After all uprobes within the THP are removed, regroup the PTE-mapped pages
into huge PMD.

This set (plus a few THP patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

Changes v7 => v8:
1. check PageUptodate() for orig_page (Oleg Nesterov).

Changes v6 => v7:
1. Include Acked-by from Kirill A. Shutemov for the first 4 patches;
2. Keep only the first 4 patches (while I working on improving the last 2).

Changes v5 => v6:
1. Enable khugepaged to collapse pmd for pte-mapped THP
   (Kirill A. Shutemov).
2. uprobe asks khuagepaged to collaspe pmd. (Kirill A. Shutemov)

Note: Theast two patches in v6 the set apply _after_ v7 of set "Enable THP
      for text section of non-shmem files"

Changes v4 => v5:
1. Propagate pte_alloc() error out of follow_pmd_mask().

Changes since v3:
1. Simplify FOLL_SPLIT_PMD case in follow_pmd_mask(), (Kirill A. Shutemov)
2. Fix try_collapse_huge_pmd() to match change in follow_pmd_mask().

Changes since v2:
1. For FOLL_SPLIT_PMD, populated the page table in follow_pmd_mask().
2. Simplify logic in uprobe_write_opcode. (Oleg Nesterov)
3. Fix page refcount handling with FOLL_SPLIT_PMD.
4. Much more testing, together with THP on ext4 and btrfs (sending in
   separate set).
5. Rebased.

Changes since v1:
1. introduces FOLL_SPLIT_PMD, instead of modifying split_huge_pmd*();
2. reuse pages_identical() from ksm.c;
3. rewrite most of try_collapse_huge_pmd().

Song Liu (4):
  mm: move memcmp_pages() and pages_identical()
  uprobe: use original page when all uprobes are removed
  mm, thp: introduce FOLL_SPLIT_PMD
  uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT

 include/linux/mm.h      |  8 +++++++
 kernel/events/uprobes.c | 52 +++++++++++++++++++++++++++++++----------
 mm/gup.c                |  8 +++++--
 mm/ksm.c                | 18 --------------
 mm/util.c               | 13 +++++++++++
 5 files changed, 67 insertions(+), 32 deletions(-)

--
2.17.1

