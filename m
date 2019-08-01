Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6422FC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:42:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C6DC2084C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:42:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="G7iqMIII"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C6DC2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A31256B0005; Thu,  1 Aug 2019 14:42:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E1A26B0006; Thu,  1 Aug 2019 14:42:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D5526B0007; Thu,  1 Aug 2019 14:42:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54F426B0005
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:42:55 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h27so46276869pfq.17
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:42:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=NW8BKXx5lCR6jtZRhKIXx1ZmLTOMfwbNocTFcul3hxg=;
        b=hH+vMY1wGxRSk1NRZNa51wQ/PHCP+9tUZazdzwGJH7umB0tRvvQ2GmbqWhJS/LPlp2
         qw0sy7DVJbyBqHiIE0Qg0WDlJRC8IY0EatUeVQyaJCzjV9UVKDmbPKVKXwbLQTzsR2Og
         Jpr69kuAUMA2tTPPo9FkMvgLtK6sqCuykEWinBF6+wKqaOYJlGJ1vLZvCnCtpF/nJO1C
         SAy9ErrYy+POwhIFU0X7McOAaO/Ukk7F6oOhsTwxM/SN2AKLJDNva01+0VHvU7iQOx3G
         s9VZarknPnDlr0j0PLQx/bTeoUvI9/nUWxp4gefXeV01khjw8KiPK0mxa11HgryTb66h
         peyQ==
X-Gm-Message-State: APjAAAWcxCfulhJD0jj6YDkgA3LJc5RLjtPrs8ElZudxPGxF8w3A9PxD
	A5OboXmgPKhRNv8N5M17N9FiSrqhRBfRd6hBhLDbAgA14UcDE3xxl8E/kmbkScFasI/RHIz7Dtr
	p23Kr8kadBVJOY4zwHPjh6Y8Wo3Og20D2YbYbpxOosZWKoo8J3SYnJ7ecw1irWDJUCg==
X-Received: by 2002:a63:4c46:: with SMTP id m6mr123968462pgl.59.1564684974724;
        Thu, 01 Aug 2019 11:42:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuYWF8UOuAc7ebqY15v7/GbYMz2p59iiqrkHQSDNpBbpHez/tPlvAUUYWVxUSR2t5Odeju
X-Received: by 2002:a63:4c46:: with SMTP id m6mr123968400pgl.59.1564684973761;
        Thu, 01 Aug 2019 11:42:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564684973; cv=none;
        d=google.com; s=arc-20160816;
        b=k8ao6nuG99FCl4vuAtmRVm3kmi/YtHwoLVlz835+H78IcsOMP+WJFf4r15f+dSXFoA
         uBgMMWFnmvZb28lRg64sLh5c3Zhuf+ZwF8O0Njvn3M9hz0nQGaF0O6tz5aswDUhHPuUX
         A+6fLWyb4RetJL2248SvjonXtelfuIozdbick3UXobczH99TaQP/jKrs9UPA3iLD3bs1
         LPWPTFT+X9a6HZr/VseMxja206qwreeJyMjrNB3/psNB8qGpw8FCtf0ol0dOvHVrWFxi
         JAVfYcd/1xzrG+g9RrpPZfNKVo8ei0PJZbErCFdXUNkQkqO2hXIdb/VhsaZw7oVH0P3A
         MPvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=NW8BKXx5lCR6jtZRhKIXx1ZmLTOMfwbNocTFcul3hxg=;
        b=RzSs3qYffXXe7oAm9ssrPUdIG7yab8oiFxue2+wcsCXLmkdQWpMmLZ6N3cCP8A6rbG
         eCEq9s60GsnLO3ntb4yFyaKZWwEYlWzQlOR50ahzY70VitTBy/KHzZlJl17j7jTzE7r0
         /QVLS8ZYBvTFoKwCYPBrwCo0zLF1u1WJNnS1d0F7jBtX5Y9rN/6ZRmg3p94OZ1FPlDp8
         JyjqfgCgcvyC0yLTd6u/kBTmaZdOu3FsWcPkY6WNAlY8h7VCYoMPzgCIpFj5vSRKkBMD
         7MaRoAbplI1zTMAh4jx/IFLrVWShhnOMlrIy3+b/BJgriFHhc2aVIcuKntEZ+bpsh2K6
         7Llw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=G7iqMIII;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l64si4662183pjb.93.2019.08.01.11.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:42:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=G7iqMIII;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71IgO6H029153
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:42:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=NW8BKXx5lCR6jtZRhKIXx1ZmLTOMfwbNocTFcul3hxg=;
 b=G7iqMIIIe4DVCG3FNT5l3VmYTykhgH1J3KhbE/LjeCUWZ+EnGcFSej68ZEiiMRQhD2od
 m6goFnJbTZDr9QoNYa/ObdobCEExXIKq1pZbHWM3WlnZSazGmKIgbaJJlwk1218KrAfC
 e4LJCoh2rxIG18+DeJ8AJhD/A1DEAJsnHaM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u423e8x5c-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:42:52 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 1 Aug 2019 11:42:50 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 6523D62E1E18; Thu,  1 Aug 2019 11:42:50 -0700 (PDT)
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
Subject: [PATCH v10 0/7] Enable THP for text section of non-shmem files
Date: Thu, 1 Aug 2019 11:42:37 -0700
Message-ID: <20190801184244.3169074-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010194
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes v9 => v10:
1. Update check for page->mapping in pagecache_get_page() (Johannes)
2. Refactor code in collapse_file() so it is easy to understand (Johannes)
3. Don't call try_to_release() in khugepaged_scan_file() (Johannes)
4. Rebase.

Changes v8 => v9:
1. Fix bad use of IS_ENABLED (kbuild test robot)

Changes v7 => v8:
1. Use IS_ENABLED wherever possible (Kirill A. Shutemov);
2. Improve handling of !PageUptodate case (Kirill A. Shutemov);
3. Add comment for calling lru_add_drain (Kirill A. Shutemov);
4. Add more information about DENYWRITE dynamic (Johannes Weiner).

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

Song Liu (7):
  filemap: check compound_head(page)->mapping in filemap_fault()
  filemap: check compound_head(page)->mapping in pagecache_get_page()
  filemap: update offset check in filemap_fault()
  mm,thp: stats for file backed THP
  khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
  mm,thp: add read-only THP support for (non-shmem) FS
  mm,thp: avoid writes to file with THP in pagecache

 drivers/base/node.c    |   6 ++
 fs/inode.c             |   3 +
 fs/open.c              |   8 ++
 fs/proc/meminfo.c      |   4 +
 fs/proc/task_mmu.c     |   4 +-
 include/linux/fs.h     |  32 ++++++++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 +++
 mm/filemap.c           |  11 +--
 mm/khugepaged.c        | 172 ++++++++++++++++++++++++++++-------------
 mm/rmap.c              |  12 ++-
 mm/vmstat.c            |   2 +
 12 files changed, 204 insertions(+), 63 deletions(-)

--
2.17.1

