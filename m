Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10669C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB33620657
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="E93Z851D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB33620657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63FF26B0007; Sun, 23 Jun 2019 01:48:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F0928E0007; Sun, 23 Jun 2019 01:48:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DF798E0006; Sun, 23 Jun 2019 01:48:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 184C26B0007
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d3so6885921pgc.9
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=yFG8/r5qpsg2DKJVAhc736HHmCqcCn1u5+2mp6Xf//s=;
        b=E4mzDzjc9bEx1JNCGd/HLucfVdpm+1GqNVKKDwU0U29g23KQjo/qgFLN2xh8P5R5E3
         mNZIAIdbS9mOwpJvzUaFR5VQgDEjnIkx1UjEPQnIFA37cnOGuH4zDbeW+iyxaswYUQS2
         dJcCX48rmgH0q3aRX4Y2rjWcK3jNaJzbzh1NVqX4H/Zw/5lxzH0/pSnbGUNkvmefBOVs
         aIhe0ItdVc92rexOtU3+8MTUCW8uUD0z1P4wtY9IlfZygmLZt61LkR7S7S9TqBaN8vpY
         QblKIJ0vlZD1NcVMGf+rn5+DwHmlSwfq/jGIO/V5Ft0hySF+ErjReDnnkDuopLvysLDK
         H4Sg==
X-Gm-Message-State: APjAAAWZj5YcJIr5KYr+2sgWhNeVbLn2ATt2XFgB67XxZmtg8pxviGf7
	T9zKx0TuY6AEBTiPjl49nUiMGwPcCBH2BA4JMYVInfz+7eHFKovFUkny3OhVg2iLRb+vqtt1rUA
	ywE6yZ97cq8RVWoEwmf7LESEJUNbbWJ9Lyj9+++JFtSKdSjajGZONUU+GaZVINnclSw==
X-Received: by 2002:a63:8041:: with SMTP id j62mr14849244pgd.414.1561268926604;
        Sat, 22 Jun 2019 22:48:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKwPu+4WU1/nelvefNoz4jIZ7gYpkWSZo2m7jtrKNreYkj2FnVAG0tB3vdLbpktcsFb/F1
X-Received: by 2002:a63:8041:: with SMTP id j62mr14849209pgd.414.1561268925738;
        Sat, 22 Jun 2019 22:48:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268925; cv=none;
        d=google.com; s=arc-20160816;
        b=q9H7KPzEIo2QtrHvmFo5iIE/VFM/l+Pq7MOo1Sf/olP5xwYZNCqXelJ5oLqHLaZ3J2
         axYBuE7D2QE8fqKy1lQTJURZ6xXPx3BXQyK7mW+j2c4jNKOqIMGchcozmdRivKfP/Ugu
         XBcHzwOZPPLi20yL1t53KrqyJ89rrPZ0fZGiUidxmOQBGHnr7M8FJmNoYQH6zBET0z87
         vUFb6KvKjNkRlk1Pbk368yodQR3s8Lw6fBmu9Tniiki8WPQk/Fh4W3ZMlMBjp11fd0sT
         OQlWtRtSSm9k9rTkVt8M6DRtWZPQrqkqMqxN1Hvxj/qixciwST4lgpTct03iWIF11++U
         Cctw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=yFG8/r5qpsg2DKJVAhc736HHmCqcCn1u5+2mp6Xf//s=;
        b=ilraXljtotYilWmFyPuKtcJvw17xFyyLJnDMQaXX7hAi8kBXtM4Fb5bnRtBU8hGqyS
         IgBga5G62Q4+XAzWIYKKD3Paqvs/4JqIR5O71rqfOxhCSVsE/H4icVICLDpVkiE3sQ3W
         XIZOOfNxdXdkHgmf6jlA7HYyIRwN4wLDfZ+4H8KosNmgLWfAvzz+rr4izRDC0+sXua6D
         FTXHO6q79oR3bNiaQo5vWZFDdckrMqfkBwD/Z228qDu2l8AsXc5VgpHMQnrIj86YQOcH
         JsK+VsIrqSBLY1CFpaDoa8kpbjH3GuCiSN9IDKEZNcH9ti99yuwrE4nj2c1Yp8NyALYn
         Vgbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=E93Z851D;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l3si6464495pgp.179.2019.06.22.22.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=E93Z851D;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5gg68018602
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=yFG8/r5qpsg2DKJVAhc736HHmCqcCn1u5+2mp6Xf//s=;
 b=E93Z851D1tURIhVL5ba3aOywHXlj43rdASbcf2PMN+luOpfcBlaFfbnnl/6K78RRLBwU
 ZqbZ1fzUKArr5RqblEZ4gYsSwofc5JuCAIhvIYUi0YLuP8y6/VJhU+milPZ979stfKCC
 y8wouch/9pOQ0c+BtNzk0AgAJ1bjIHOZTZY= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9kmja10b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:45 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:48:43 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 9898862E2CFB; Sat, 22 Jun 2019 22:48:42 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 0/6] THP aware uprobe
Date: Sat, 22 Jun 2019 22:48:23 -0700
Message-ID: <20190623054829.4018117-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
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
FOLL_SPLIT_PMD, which only split PMD for uprobe. After all uprobes within
the THP are removed, the PTEs are regrouped into huge PMD.

Note that, with uprobes attached, the process runs with PTEs for the huge
page. The performance benefit of THP is recovered _after_ all uprobes on
the huge page are detached.

This set (plus a few THP patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

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

Song Liu (6):
  mm: move memcmp_pages() and pages_identical()
  uprobe: use original page when all uprobes are removed
  mm, thp: introduce FOLL_SPLIT_PMD
  uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
  khugepaged: enable collapse pmd for pte-mapped THP
  uprobe: collapse THP pmd after removing all uprobes

 include/linux/mm.h      |  8 +++++
 include/linux/pagemap.h |  1 +
 kernel/events/uprobes.c | 55 ++++++++++++++++++++++++-------
 mm/gup.c                |  8 +++--
 mm/khugepaged.c         | 72 +++++++++++++++++++++++++++++++++--------
 mm/ksm.c                | 18 -----------
 mm/util.c               | 13 ++++++++
 7 files changed, 130 insertions(+), 45 deletions(-)

--
2.17.1

