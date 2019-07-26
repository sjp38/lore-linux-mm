Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B48AC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7749217D4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 05:57:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="SPS/fe56"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7749217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A3C16B0003; Fri, 26 Jul 2019 01:57:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 453FD6B0005; Fri, 26 Jul 2019 01:57:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31C5F8E0002; Fri, 26 Jul 2019 01:57:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC7346B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:57:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x19so32289807pgx.1
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:57:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=2G2JqqAaL+zcE7XbmXR266BSDdjMJVA1jPdlyObFpEo=;
        b=lQbG6VneF0Zg9NPJZShRuaaIvF5mqjKXbXWSAi9QEqEkKOO6L6M1Ofs+vvq6sbz9NV
         47onuQVsC0VTQ8gBo2IWCjiax348aat44ISdo6rVouzG9taRp2OhLD8+1KOEz4t//uOu
         ppUH/kwIcVV4MdXQMcqm2oi9EB7iFGgBKNh7q4rJBto+2qIpKSvSBQATiSKv4Eu2W73C
         M1HUynHd7+zPjNt1oICQQPPlSa0zzBGAo1BEuqp2pjyy9VG8GUj8meY/jPqnjXhnkpoS
         hjDCeyR2oXEhYNgW7cenqOO7+sVxu1p7PR89/klVo7FfGQE9onbMPLrDhW1TNy8HK793
         Y+fg==
X-Gm-Message-State: APjAAAVNDoUzKuOdmiwfG1VpEj7EuFVu8LogLTzvExDvvDNBAN6D19UH
	zEu8zARRV4zDzl1sgVGLE4xIOiZuHf7FBkp5ae6bcxUkQIjYgKxeMTw/ypy8JPu45pur5YTUkoF
	YYqBRAVg4fpiCOhmnExZIfY0ed8aHf/FdWWKkoB+8WjBBXkEpE/uxcKV6r3ureLq1AQ==
X-Received: by 2002:a63:31c1:: with SMTP id x184mr85796799pgx.128.1564120678554;
        Thu, 25 Jul 2019 22:57:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0a67LAKYtuq17HOtHOMQIjEfyPTIlgGF0iR6MfBO2DFfJ77Z+69Z5pn/qLBIaOFZSAL4D
X-Received: by 2002:a63:31c1:: with SMTP id x184mr85796755pgx.128.1564120677718;
        Thu, 25 Jul 2019 22:57:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564120677; cv=none;
        d=google.com; s=arc-20160816;
        b=GDyarJAjOKw9UQP0wzo6RoJdmwofk1PjG7TtyV2Cv5p6YBEXFu6b97qoR22pLmcF3E
         OvtyjK9xcpUb6ZBzFWGqXb+zxDlhHzSB0mej/xuKupZ7SHciUTdaS+tEkXFdI5ESblY7
         9szhFgjkmyz5FCU5jr5llAjhTYTtn/Z2l26GFPC6UrzoRc4MG2fsRQQwSZ/l8Holw6OD
         x1Kja7IeJmHysOveTp8CYSkBp1WcSQ+O06YdcX7EjqZDiu4nrfTm0+cAmAVr/yazXJkd
         TO7WuW9Nq0Y5LT2nALqcOzc/ariGwAWcHLqLX9Y7suaP/SJxRP5pLW2IyT4e8Mq2A7Dh
         S1fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=2G2JqqAaL+zcE7XbmXR266BSDdjMJVA1jPdlyObFpEo=;
        b=G1Nxl/opiNt0V66dGqh4c+2VeNPOUAV8avgj8mzKXifKaaOkDNdPedqXOtVcWlqLSO
         AorCRzVqdLVi5fQ3HBlD8qMlSlbpmjIodaBLr061HPfWbY4+BZUxhkw0BzJW+LMA0Y7x
         pZ9o0lU8f7N/FggwzaGsOUEqDxYMk6QyayPY/X5DsetfbyHPzRui0wCUTKZCBNRniigZ
         yF5NHKcDmhI5yYY37rBqwrWLyeyvCTpAiX6XpVSos7MRHZcsCfK7epB8ToLkJzf9bphN
         ZyuvFFqiMNBZG+ZeTcvsWJ4KZi3NdxEmVt5Uza9kxbI7Fg5pL5fz3Wa9CY+qMgecGnqV
         1JOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="SPS/fe56";
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l70si17298782pgd.363.2019.07.25.22.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 22:57:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="SPS/fe56";
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6Q5stA1025299
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:57:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=2G2JqqAaL+zcE7XbmXR266BSDdjMJVA1jPdlyObFpEo=;
 b=SPS/fe56KW9xYLIqPiVObNLis76IMHdUsW73YXz7ZBBgbMGLYx1ne8K/htFE8JtLRxTP
 KJYh/4BtcSj97wWgnnpQG5jSeaMRLT3bbL1cOaFE/STRZ2w5HyTOohlrc6kqH2SmV6K7
 oI4G4SAInRHtbNKRD8O3kQ9xDbcwWIN87Ck= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tyh4n27a7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 22:57:57 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 25 Jul 2019 22:57:55 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id A1F8D62E2163; Thu, 25 Jul 2019 22:47:01 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <srikar@linux.vnet.ibm.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v9 0/4] THP aware uprobe
Date: Thu, 25 Jul 2019 22:46:50 -0700
Message-ID: <20190726054654.1623433-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-26_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907260079
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
 kernel/events/uprobes.c | 68 +++++++++++++++++++++++++++++------------
 mm/gup.c                |  8 +++--
 mm/ksm.c                | 18 -----------
 mm/util.c               | 13 ++++++++
 5 files changed, 76 insertions(+), 39 deletions(-)

--
2.17.1

