Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39C00C48BE0
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:05:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E53602089E
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:05:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="MfGtYDYM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E53602089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97C1F8E0006; Fri, 21 Jun 2019 20:05:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92C088E0001; Fri, 21 Jun 2019 20:05:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81B3B8E0006; Fri, 21 Jun 2019 20:05:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E34E8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:05:39 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 6so5326754pfi.6
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=+YimUimKQQBLlP9zR0QGQoa/u1JNJpS2W46I+y+AhcE=;
        b=UW64gDBa0inUmWMbUbQ0OCbFhpXpkeq/dVUSc3zcqsH8Jqt99s8anUy2aJgywNfyaS
         gilu8TdKfvvTdidboJ2H9K4jU6L7ZQV7FMoCz6MUkLvg72doMZz7DoAOdwB5a+mZrqXJ
         y2SIYYww7PhVA58LGMtMUgSgqS9Oh04HjnbQAGUJwtSvCorIj/JXPovWGCeP/WH00Wnc
         7Rc5j+/PRjB+sytS3xk+jAcPZJl3BYM5XdW6U7gN/hk/sZz4CAbLcWtUJTJ05IKCDeAh
         mCgrhxbKgj/jnCg2twMS+DBsJE3NJZaLo0qsacEXgQ5Scv4NFglPcNDZ/05McGbNplio
         avwg==
X-Gm-Message-State: APjAAAUMxq2DUK9YretQC2y1pxPMW/olJ0He0OoTTicGMX3dYFL/fUNM
	yBS4MlmQ8nmFUOkHIW1z106rm37VpmjgfsnBK+X9xlKIZbsWmTsftDB6to4NvgkXSjbv2k/C9hs
	W3q2Na52vsIJXD5gDBQ2GFerAXL1U/kgRV/ilIqTXXza98a02eUHlR2P/IKAQQy460w==
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr117000752plo.124.1561161938870;
        Fri, 21 Jun 2019 17:05:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlbELPxRDADJiOnUZ+0Lc1I/913AfZkXeSWG/9n7e10e7LhF0irp9Owi9vbkTsbdKLTuRb
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr117000629plo.124.1561161937251;
        Fri, 21 Jun 2019 17:05:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161937; cv=none;
        d=google.com; s=arc-20160816;
        b=jLWgjO1lwwfDvEGV6tyhTOvMqI8fIbfadgpJPrYHuUf5oaEwysICR+eC52a1TCi5Qh
         B/XP34qe4iP9Hg8yENJzinWtOPNRUY2Wax0cMpbe0RI/ozwqu0QHd9J+qRr10CzbBvQQ
         +mXAR/4XRJQLn1uSAJ7dcc2myvokpzbWBstfrCdx+AgvJsVyZoEONkGS7bpu1x9cMgUE
         1FcS8g4/So4wCbO/Z5z7yxWtO9zhtZH2ctXKLHqqpY6BdF/1N84HTVVH7tT3HM1E99iw
         iuHR82G97ENztD8JvvsHN6HGFft647VUPcZiBSxPdYDEAK2KVDMOc2ntnYxhtQeSmjar
         LDCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=+YimUimKQQBLlP9zR0QGQoa/u1JNJpS2W46I+y+AhcE=;
        b=al+TKhnaVw1Jsh/xQBJYGshKz0/AGr0v8CC2tbJZRcZ/OR7052CCIKeN3Tv0AHn8DE
         lck1sOXr7eqd6wddDZuHoMSQoF5YSLuxTiX5gf5no9hm0AiYnLnj+vctlpZ64c8x2R77
         fEVebHVrklyzUYaAbqV7vVzAWMidm9cjzIsmIg2MaZhkKZz3LIfyWcb7mn5MAbarPkyH
         Vr3LllYx0YgfLflwDJ/lBEXJse9xQglFiRlVPDNqQOwg68k734JfKn/ZjgFtJYzqy162
         SYftRwNuTd4yRlwXknoZbgEM6B3PvfleNAvfoe0EpS5ZbVIr05zRUOd27o63EUeeWBBj
         g2AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=MfGtYDYM;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q19si3433840pgv.31.2019.06.21.17.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:05:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=MfGtYDYM;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNubfi026471
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:36 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=+YimUimKQQBLlP9zR0QGQoa/u1JNJpS2W46I+y+AhcE=;
 b=MfGtYDYMxj2HLlQT3wgoNv8GIYTqJ7S4RTRvZdJu9YUvbW1FyGU/+LkYaKIBtveDuI4H
 SLCavFSVX3Gg1oaDJSP6DeDm/5RvLQSuyHZeEZfzLf8i5fAFckvqsG6dpJluFQEfS1aP
 J6itVM4pjHiGZQ2RhwBPIetiQMasgqJB0UY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t99btr0ps-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:36 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 21 Jun 2019 17:05:18 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 56DC862E2D56; Fri, 21 Jun 2019 17:05:18 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 0/6] Enable THP for text section of non-shmem files
Date: Fri, 21 Jun 2019 17:05:06 -0700
Message-ID: <20190622000512.923867-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes v5 => v6:
1. Improve THP stats in 3/6, (Kirill).

Changes v4 => v5:
1. Move the logic to drop THP from pagecache to open() path (Rik).
2. Revise description of CONFIG_READ_ONLY_THP_FOR_FS.

Changes v3 => v4:
1. Put the logic to drop THP from pagecache in a separate function (Rik).
2. Move the function to drop THP from pagecache to exit_mmap().
3. Revise confusing commit log 6/6.

Changes v2 => v3:
1. Removed the limitation (cannot write to file with THP) by truncating
   whole file during sys_open (see 6/6);
2. Fixed a VM_BUG_ON_PAGE() in filemap_fault() (see 2/6);
3. Split function rename to a separate patch (Rik);
4. Updated condition in hugepage_vma_check() (Rik).

Changes v1 => v2:
1. Fixed a missing mem_cgroup_commit_charge() for non-shmem case.

This set follows up discussion at LSF/MM 2019. The motivation is to put
text section of an application in THP, and thus reduces iTLB miss rate and
improves performance. Both Facebook and Oracle showed strong interests to
this feature.

To make reviews easier, this set aims a mininal valid product. Current
version of the work does not have any changes to file system specific
code. This comes with some limitations (discussed later).

This set enables an application to "hugify" its text section by simply
running something like:

          madvise(0x600000, 0x80000, MADV_HUGEPAGE);

Before this call, the /proc/<pid>/maps looks like:

    00400000-074d0000 r-xp 00000000 00:27 2006927     app

After this call, part of the text section is split out and mapped to
THP:

    00400000-00425000 r-xp 00000000 00:27 2006927     app
    00600000-00e00000 r-xp 00200000 00:27 2006927     app   <<< on THP
    00e00000-074d0000 r-xp 00a00000 00:27 2006927     app

Limitations:

1. This only works for text section (vma with VM_DENYWRITE).
2. Original limitation #2 is removed in v3.

We gated this feature with an experimental config, READ_ONLY_THP_FOR_FS.
Once we get better support on the write path, we can remove the config and
enable it by default.

Tested cases:
1. Tested with btrfs and ext4.
2. Tested with real work application (memcache like caching service).
3. Tested with "THP aware uprobe":
   https://patchwork.kernel.org/project/linux-mm/list/?series=131339

Please share your comments and suggestions on this.

Thanks!

Song Liu (6):
  filemap: check compound_head(page)->mapping in filemap_fault()
  filemap: update offset check in filemap_fault()
  mm,thp: stats for file backed THP
  khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
  mm,thp: add read-only THP support for (non-shmem) FS
  mm,thp: avoid writes to file with THP in pagecache

 drivers/base/node.c    |   6 +++
 fs/inode.c             |   3 ++
 fs/namei.c             |  22 ++++++++-
 fs/proc/meminfo.c      |   4 ++
 fs/proc/task_mmu.c     |   4 +-
 include/linux/fs.h     |  31 ++++++++++++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 +++++
 mm/filemap.c           |   9 ++--
 mm/khugepaged.c        | 104 +++++++++++++++++++++++++++++++++--------
 mm/rmap.c              |  12 +++--
 mm/vmstat.c            |   2 +
 12 files changed, 180 insertions(+), 30 deletions(-)

--
2.17.1

