Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36E2AC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADE42206B8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:23:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Fk5HOo+q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADE42206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D5228E0003; Tue, 30 Jul 2019 01:23:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05EF68E0002; Tue, 30 Jul 2019 01:23:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E41C58E0003; Tue, 30 Jul 2019 01:23:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6C638E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:23:13 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g18so34590850plj.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=23YFunGSruQwzl/pBIluttH3byxPMyldDYniqzO33c8=;
        b=oUGKQ8wPksF72eT7rODQ8f9da1fgbana7QsfcwqIYoVQCJU6aakfW9gDWVWIIj+bvL
         6OmweYz5t2+s5OYJfIVX2RyzNeMcOPbcSfKoCzMG9D/zbwjtAPFEHVxnrb1df+yxovDT
         O7w95PQoQZ+MGZNyPtuaFRJVVzzjv0+T41EWnfCVwUUfCgC5N1pRTNgXBZF38cBX+e84
         cz7CVslQp7EHr4y3RXhFF54Ngi/WBwQfyw4aGVBTe+EyvPrl0Hx/hv2HErvPlBXe0jah
         4CsYjdIxqPWuMCUvyST6m63tjHlHbJbEIZLq2bsmgLVElmx9jFxJInItU0gEGBTnZEVp
         sYpg==
X-Gm-Message-State: APjAAAUyiJllAxu6GVYPA53SjsGwKYeU4oLo+icCGcBzVJrJWYBjMHm9
	PcFZPMEKJveGLpalUonJJ2veRcg/hbJSr4GwrR7OF9SpCIAPBnbiilyu/CR61TP6kwSTCUXkPdi
	9ZGo8HfLmVAyGsDY8yDriMjgkT7eyW5GOJb8i9kTSYwib5JL5y0oCy5+i1s4EBzBUDA==
X-Received: by 2002:a63:7e1d:: with SMTP id z29mr107293581pgc.346.1564464193187;
        Mon, 29 Jul 2019 22:23:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5YKkEZQ7pL97UvnKSRafm9lhAbTz7ybwmI5OHR5D9+GGJISqtVvLMZ6XHcZQsHm3F7PLS
X-Received: by 2002:a63:7e1d:: with SMTP id z29mr107293537pgc.346.1564464192149;
        Mon, 29 Jul 2019 22:23:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564464192; cv=none;
        d=google.com; s=arc-20160816;
        b=Uau7DL8DdekJ/Zw+672EV37QqW+m/wxiyRsMHWJUw2ZqYrH7PlpTrN/4XacwWrQj+G
         VYdgohhHvy7Og0jeK6aNlzl5mrQdLb1QTRJyiIJKghlfMTUNFzDRGWC2Dbj5PMlLz7tB
         sXGresO9k2sRg7MTVq0S//f/x77p3/prqeqwWxoMjHkb+k5s6o7pP4bhJ00kG7O4aNHs
         kwWGdVV+dzV/emup82Do71ZQWJ5DWoY6OuxHv5lw7ye/sd1diS19Um4ZFVSHQo21SWBM
         omWLp5Fwy9iR2c+I6nUtclnteJYhp4kZfTlbC+nT0pR00ohL5fugpMU6mAtqm7ecm3IG
         zSSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=23YFunGSruQwzl/pBIluttH3byxPMyldDYniqzO33c8=;
        b=wmXCXYZfKI5ho1u7V9t6jclYoKWkkb6KqLsVndph9sWBBOFkUBDWriTMziXztRxnWD
         61LlmiSzf6PsqtXlCVX0nGiqNabuWM4XnMXoJKzsHCGx3t5gqcsVpWtfWoGGGMvJiy1G
         b9tL6j4QOL/Y89z0AwAeXV0ii+31tCsZJdR2IZ2zCqr3DV1/vBXsUTGkYMpYW1anKS/q
         5JJYH6KF0gBY3I96IXm5WdPYBOxfXmSoC2MZAnli6eHgWFEDmhQ940K/ZPBLG6C6cCjX
         VThJGjRqP6uS9FwE9r6jjvfRQBlCrfLFVDH2tUna9V5rZTsUQaKXnaqCqtel3+Wt4BRX
         vBLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Fk5HOo+q;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h185si26354460pge.199.2019.07.29.22.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 22:23:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Fk5HOo+q;
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6U5F7WU003977
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:11 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=23YFunGSruQwzl/pBIluttH3byxPMyldDYniqzO33c8=;
 b=Fk5HOo+qT+vMWBmjfYm0RdQxNn8jOv0H8nVblEUeE8wVq37lpV7EEHyqC8GOWG+cuwNu
 t5NN+NSVdXMmjefoLH/fFma1om9TFgF01e8M6wS6zp50TxFMLCvZeMYXAnK7GRZdQftw
 O4hTxaJX6iFpqA6FmeVTfGQH5DAe+uXy5Kw= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u2d8vrc2g-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:23:11 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 29 Jul 2019 22:23:10 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 6C76F62E2FF0; Mon, 29 Jul 2019 22:23:09 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v10 0/4] THP aware uprobe
Date: Mon, 29 Jul 2019 22:23:01 -0700
Message-ID: <20190730052305.3672336-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300055
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

TODO (temporarily removed in v7+):
After all uprobes within the THP are removed, regroup the PTE-mapped pages
into huge PMD.

This set (plus a few THP patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

Changes v9 => v10:
1. 2/4 incorporate suggestion by Oleg Nesterov.
2. Reword change log of 4/4.

Changes v8 => v9:
1. To replace with orig_page, only unmap old_page. Let the orig_page fault
   in (Oleg Nesterov).

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

 include/linux/mm.h      |  8 +++++
 kernel/events/uprobes.c | 72 ++++++++++++++++++++++++++++++-----------
 mm/gup.c                |  8 +++--
 mm/ksm.c                | 18 -----------
 mm/util.c               | 13 ++++++++
 5 files changed, 80 insertions(+), 39 deletions(-)

--
2.17.1

