Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B506C48BE1
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2D532084E
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bmnEUWpp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2D532084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B29A8E0001; Thu, 20 Jun 2019 16:54:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65D068E0006; Thu, 20 Jun 2019 16:54:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51C078E0006; Thu, 20 Jun 2019 16:54:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30AD18E0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 16:54:05 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 133so3708000ybl.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=Rd2surzaIHpsaXLZZ+uUyTgCfzwHrwQk/kkn9z9rfxg=;
        b=t1ovHxUPj/y9eYeO5+GbJpG/2P4WFYd0gXS8ChIBeCYgvFwvXiUtsUD2YrAu2N09hc
         XUmm3gYs4uu2uTPTBY50i7GgQkRNbkRFdB5F2BouF8Ogux3xbHvKKJOQdwr6GkXAhndY
         0+n/z+bbm+1Yma5F/GuUKwlFhwlYE6r+PSmXvBeWaXP5y9JAIMU13pHHTEiTST3hL79N
         EJpCW5qrzYzC0F6g0K5x+oB7yshIRowJE67GV6DRe2VfiFzSeR8MA6T9C3hx7m4SiJI1
         qCOXKhWqDkIwyGXuJUYwNfnyASMdl1vQjFxhPGnpZdxQMT4v2GfQkMzC27626l61reLq
         MhuQ==
X-Gm-Message-State: APjAAAVokYYcZuufnfsTt5TyjJ3bfHNrp7nfDBfaol7oV64llvv7QsoH
	i2HX8OYE5VZIAlBUbsBCpfCcjZhWlqqelqYMyseHMmDddFFGI+sR62WsqWzjaKm+NfxYh9Jjqf9
	ef9D4NyeXx92bNpf79fbM5ZwAOqTo3ve4O0kTvKE5qH4wFjHqrwGZp64B0s9QVCnSWA==
X-Received: by 2002:a25:8541:: with SMTP id f1mr70095365ybn.417.1561064044944;
        Thu, 20 Jun 2019 13:54:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp2+c3VdAsTHBqsfY3DWARAPezPRtpGMkA+lsmkW5u+5YxmEv8gPo3/J5H/cIPj1oIgOeh
X-Received: by 2002:a25:8541:: with SMTP id f1mr70095348ybn.417.1561064044328;
        Thu, 20 Jun 2019 13:54:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561064044; cv=none;
        d=google.com; s=arc-20160816;
        b=Vztjh9ORxHT9X2nmYAuwFAzNGIY9x0uVMmKuCM0oWHUpp9J3OF7Lp0viRuawplPx6d
         +HjAvMOoQJhroldqz8etK6ksWj0Bw6IPURGCV/wQyM/ry4ZwpcwaUjt//Pt+YxIX7e72
         cnmpsKz6c4vbmQqKDtB/rnZ7ZGhLfNSWMlUipagE8v1U035KwYkzDcT4U8PIG9+Mcj8M
         qidEX9JqRA1k5iVBSS/DZdC3Rc4PRFiws62MseQ6fs6gk9v8E0D/zVI7DsQLXeWRqI8G
         82mAAUnZ1AzTbSWr6z0+ZtT0euMpkBgwWhQRKWjxwzxjlyuuqXx4gNOctrVeVCRjKbRt
         +ZwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=Rd2surzaIHpsaXLZZ+uUyTgCfzwHrwQk/kkn9z9rfxg=;
        b=psNceAhjh+nnRP2rV4Tjw9RGkbRCDpVvbceUS4bWHmZfib+OW+lx2EJRe7mnZbL1iu
         M0h0oJyA8bFob0AsU5el8FQy1OMHFq0qRwm3DziqRWH9WfRkZG6NPEJ48iq09uXpQgiL
         L71yovSAU4nQwzCiSiA//fYXcuNTI1iXUS4ye/HiNdO1c6F7Cr4byiEM1l30gg8gPNaN
         MsJmxUUvKhAwYLOaGw05KjAan85aIU0XCwTnhQpZFCZvWKd2sOcdhl2vpRTML0F58eQz
         sl8yRnqAXoFKO4uUcnWUsG5XOn55q+U5GYb7jYskLOCBTtAiEyYVINQlNq7IB/GC3092
         OuTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bmnEUWpp;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h124si232584ywe.429.2019.06.20.13.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 13:54:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bmnEUWpp;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KKs3ZV010810
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:04 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=Rd2surzaIHpsaXLZZ+uUyTgCfzwHrwQk/kkn9z9rfxg=;
 b=bmnEUWpp8Y8WJH7dw7bmchR2wyhNRQUERSe+Zg6nd5c39AHPWdSFJpF+Ky6w48V4pwA3
 qMjVqvcEns9twS1FqAZeYVdzUfiSwRHkXtvUUpc3IR4eQ8w6EZONYHRKK2baFtmd9OI/
 wngv+NAW04YT2hZzMN91BEvskAUFRzlODFQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8aj31pkj-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:04 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 20 Jun 2019 13:53:53 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id C847B62E2A35; Thu, 20 Jun 2019 13:53:52 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 0/6] Enable THP for text section of non-shmem files
Date: Thu, 20 Jun 2019 13:53:42 -0700
Message-ID: <20190620205348.3980213-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200150
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

 fs/inode.c             |   3 ++
 fs/namei.c             |  22 ++++++++-
 fs/proc/meminfo.c      |   4 ++
 include/linux/fs.h     |  31 ++++++++++++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 +++++
 mm/filemap.c           |   9 ++--
 mm/khugepaged.c        | 104 +++++++++++++++++++++++++++++++++--------
 mm/rmap.c              |  12 +++--
 mm/vmstat.c            |   2 +
 10 files changed, 171 insertions(+), 29 deletions(-)

--
2.17.1

