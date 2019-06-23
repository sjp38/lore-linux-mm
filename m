Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46591C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CCCC20657
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="aqXk+llh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CCCC20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFBE26B0003; Sun, 23 Jun 2019 01:47:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A85CB8E0002; Sun, 23 Jun 2019 01:47:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 926B68E0001; Sun, 23 Jun 2019 01:47:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0AA6B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:47:59 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h27so7138428pfq.17
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:47:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=N4p2KBB2M58AXrXvSXMaov3ijBFbuQ4LQynUr7EYajE=;
        b=LrgsEVZG1haTSYYPxAT3RwrxG4gI6bsM6pra05qwm7eKjMi03wyIlzTg/I3U9VHPol
         UpW3JSDJ1uS5C112yF+eR/vCVG+Kw+cTzD1fvH8SaI/XWv0LI4aSzFYeBKV1CxisUpva
         u57pwkgOaEnnFEw9cythykMELm8Cte7WVq4BN4xVz2Rkfu/ge3A9f97oqZJRriOr0cUx
         Bdu9hIJJpulLWhDhiar893b59rT/oBhWZRFuArD7IYvU4cWCQb55dxffZ3PiVpEwXaiK
         H9BrIj0C+qHt8ZjxhnPy+TAzOKRxmTGK5sEgTqeO5mZZSmA4BdSvxLYF4xgdKXNUdy1D
         AldA==
X-Gm-Message-State: APjAAAUPZS/kBRVNSa3EEw777wWM9vE5lcgirP1MtMaZLq5UpaHkikc3
	s074KALAkq8IC+85eVNw3BV5pcQ1SFautwZpuHCMsk2iuhNJD7EwvdQuKWpe+17SeAgblTChGi/
	3/GBhrKoS10HNbmluQ1TpoDcaQrCGFxOVJB26fsT9b9bWa8khN1ch7AQBAGD+2lNjaA==
X-Received: by 2002:a17:902:2926:: with SMTP id g35mr95138628plb.269.1561268878787;
        Sat, 22 Jun 2019 22:47:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0beRkM1N9SPtFTXUL5T5eluAgP9cbsTk813SizmByM9T5XuzQEOkSP/NXnFqyiUgV6efv
X-Received: by 2002:a17:902:2926:: with SMTP id g35mr95138574plb.269.1561268877568;
        Sat, 22 Jun 2019 22:47:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268877; cv=none;
        d=google.com; s=arc-20160816;
        b=gcGDMnxOTfWjIgqMZZI9uxEMjR2pPheKMkznW+6F+OqDiJsR1fIMK9sppm82eSfcSE
         +zcxHXhs0ScnQ0uIx4vVFXzCvsiCO+cOluYqgdGfiya4LZA+d9Da6KCHRLkv8bNbGt/O
         R5JF33CEdY3lpcJyGAUI/ejUNt5T2fWC1CSjBdpmW7HUytzczwMfaghdaXN2edgYElW7
         CPny39TRgH0odouez4DZ9QyWplju49uotODNbIDhG3fK4IVAepPOPHAIIogQJ8nJIrJ3
         tsR1ZZG67tyO5/ST+OJQCbeVwRMNREdkh/+8orSjzTL9BUX9+9TcDH/7LMrEhU6Tpx8I
         fXlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=N4p2KBB2M58AXrXvSXMaov3ijBFbuQ4LQynUr7EYajE=;
        b=w2z6/JOQjYMYmLWbn8t0nNzB6NBLWsa8rcIvyzQddfTr1QL/dvI7+8KyLKr+16SS1w
         PaTvyIutrI65LD4T3F7EGmZ7Z1hcLGD79t1BULSNxXtVW9V/HYygmLYevI7ihVCew8BT
         jLGDYIvx2oNkekdW08e5FES1vkHXSXdlud1lsISigiTHN0JDD6GXod4tQXnxCNiOkiWW
         9NkGeZd44LoEks6MzYgT9I9IkMIM0pVkDSMU45reN02I5dRnByLoJssl61mRrIChECXt
         Wv/21T87JaiqU6yGtZoxz4OC4I3D6BBbtW7y3e2KekbC06jWdZT0MdkqVutyjl29BVcJ
         Mh9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=aqXk+llh;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y10si6917049pjr.109.2019.06.22.22.47.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:47:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=aqXk+llh;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5jFjY016702
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:47:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=N4p2KBB2M58AXrXvSXMaov3ijBFbuQ4LQynUr7EYajE=;
 b=aqXk+llhlxf02/luaoTtoMU/QnV7fgpAZH4oiXC817GCprF8wIzbKUp2eizSg1UnMbpE
 c+s0KSeRKCD1fnrA2+yzsV0izvJoGFdvddXdaCkSEnBcHRo9VNYxIJYQR35gq6DOI5KD
 OXqYsIXNU8/PM07z9k08FsPArBIURLCqz/Y= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9fmjjfmb-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:47:56 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:47:54 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 3779762E2CFB; Sat, 22 Jun 2019 22:47:54 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, <hdanton@sina.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v7 0/6] Enable THP for text section of non-shmem files
Date: Sat, 22 Jun 2019 22:47:43 -0700
Message-ID: <20190623054749.4016638-1-songliubraving@fb.com>
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

Changes v6 => v7:
1. Avoid accessing vma without holding mmap_sem (Hillf Dayton)
2. In collapse_file() use readahead API instead of gup API. This matches
   better with existing logic for shmem.
3. Add inline documentation for @nr_thps (kbuild test robot)

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

This set (plus a few uprobe patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

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
 fs/namei.c             |  22 +++++++-
 fs/proc/meminfo.c      |   4 ++
 fs/proc/task_mmu.c     |   4 +-
 include/linux/fs.h     |  32 ++++++++++++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 ++++
 mm/filemap.c           |   9 ++--
 mm/khugepaged.c        | 113 +++++++++++++++++++++++++++++++----------
 mm/rmap.c              |  12 +++--
 mm/vmstat.c            |   2 +
 12 files changed, 184 insertions(+), 36 deletions(-)

--
2.17.1

