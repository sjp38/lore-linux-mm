Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0128C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4999F2177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:22:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nmo+VsAq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4999F2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B08E06B000C; Fri, 14 Jun 2019 14:22:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB8DC6B000D; Fri, 14 Jun 2019 14:22:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A7FB6B000E; Fri, 14 Jun 2019 14:22:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62B6A6B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:22:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i2so2358458pfe.1
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=iGcwDY1Isfd+/1REOygvZql6oIZL54j+ywEpsBRw6lQ=;
        b=aDolxPkjiPbbbgOTAQxQ4/BI63RwZ8zhZI5SJNQQ1wqQJQYrjkLZ2hvbhOs6Oqwm2f
         toiJWw2Ij17y/45a641In5MHX2ChF00E3wi9ExvXhkoGX5WjtBQ1xijwNcZCPqX8Xaj5
         o8uHSXohLxkyiJvvuOYwqREa5+E9pa/jBs59ZbncDVqMFtwtSPUkC9UeP4kMa9pFjmSj
         wrgah2sah1W22XFfRab7zufUB9HdzZdY0sbZ3qzln88cPeO1mthMlkBBsCvElbiWo3J0
         geO2ElK93bdjPAv4L9tqnmfpJM7Iwt6zVR26uVRI5JgoE56WOh7ekGUIhRjWYJmhqJPD
         7AJQ==
X-Gm-Message-State: APjAAAXf+PlX/25mktYnek5CJShFzWHrPebfNDucUZ0c/kwcOOTeKdM6
	O+iFXkCKB+6Z3tOfitlKC5gg9rEpXCuwRGENAC7SVJ4KQqHvSsrdYQmgfe9uQ31OG9hQkG9q5o+
	JYEUr/3ItV4w5bbep/N3ff+Y2tIs0HUpX/VCg2s+neNTYcEp+MTAJLd6Ygk42/+XKKQ==
X-Received: by 2002:aa7:84d1:: with SMTP id x17mr76814965pfn.188.1560536531923;
        Fri, 14 Jun 2019 11:22:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDYqsIIzLl+S2FGCwm2JPKlBagPNVM7Xxq3asDFwHm+3t2zHbb6LknhfFd9hRhIuuSe83i
X-Received: by 2002:aa7:84d1:: with SMTP id x17mr76814900pfn.188.1560536531130;
        Fri, 14 Jun 2019 11:22:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560536531; cv=none;
        d=google.com; s=arc-20160816;
        b=tCVt3GhvcHgK1Sd7oBgDYvbghi+Q619H2QYlZ0L9bB226AxHiK6z6qOT/6TPeqwhFG
         80ZsosjrylyROoyBAyYkXbiQrbTNL+vnWEwrUGB9sDmrsTWJTrFTw6yLmSuweQI/4jXg
         nkKyuWLom8qt18D1gXNXS0QWcmXO1kcW+/CtjF9P91q7iuIvgGl/kJBB5E+wSRfmsxZH
         ia8NaLUpv6LpJVxdXEFFFycyRaOOgDznUw2KLrZTaCyBhgEQOTv44Z1mZ1Ayh+/qdiHU
         j8LrEZLPbswHy9I+sK5nn7HND3H4yklCEpggRC8ocajzwIkTdBIyE/CKlgXeIyqCNhmj
         W98Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=iGcwDY1Isfd+/1REOygvZql6oIZL54j+ywEpsBRw6lQ=;
        b=bPiJ3I7cW4jIlmux6mmgor1xzvlmTt/Q2qLffN16Z9TfKxUnV0lrBPZ6zhgit1oNim
         A87PyVcGXcwUGL/tdV+vIyWWeRid5sxNx5A8wy7xohnxSiPDvH8yRyMqz+USQhLjibJ5
         zoo5l0dH4Xhjg7kCWGP6FbuskfA8H7DO/Et3d8iYIJzzp0d+vtY9iiDKI5DyeFjLJaCL
         uc27AZeFLfPFaNi4T0WMQrWkYAO97SoPGXPAZl8ZnnvPMz0ayZ6eG/xCQ00ZDNmuZ3Uv
         HlOn1eexjP6Xz2uabKjN9acbB44yHzErkHC+XWeRW4B7vlffGbRRT/VQ5RXoCyStxlFV
         7eUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nmo+VsAq;
       spf=pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10681bb08d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s3si3206559pgm.208.2019.06.14.11.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 11:22:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nmo+VsAq;
       spf=pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10681bb08d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5EIJxj8020002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:10 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=iGcwDY1Isfd+/1REOygvZql6oIZL54j+ywEpsBRw6lQ=;
 b=nmo+VsAqRBX0nVrtDJwcgrKecKlTGopjQtfttb0tklD5b8O3/MuEuDGRTWy+Gf5XUYHT
 Lp3Oew6X4Tsn4KxeEj+teUdhLmWFc007ouSZA5hDGXOCfs6/GuITPlgFeDPsYLdNBdRI
 tTLzgVe/Nl84mgFLpjpNmuLrFlVOuCEn07Q= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t4e9u8k9u-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:10 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 14 Jun 2019 11:22:08 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4780662E1CF4; Fri, 14 Jun 2019 11:22:07 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v2 0/3] Enable THP for text section of non-shmem files
Date: Fri, 14 Jun 2019 11:22:01 -0700
Message-ID: <20190614182204.2673660-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140145
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

After this call, part of the text section is split out and mapped to THP:

    00400000-00425000 r-xp 00000000 00:27 2006927     app
    00600000-00e00000 r-xp 00200000 00:27 2006927     app   <<< on THP
    00e00000-074d0000 r-xp 00a00000 00:27 2006927     app

Limitations:

1. This only works for text section (vma with VM_DENYWRITE).
2. Once the application put its own pages in THP, the file is read only.
   open(file, O_WRITE) will fail with -ETXTBSY. To modify/update the file,
   it must be removed first. Here is an example case:

    root@virt-test:~/# ./app hugify
    ^C

    root@virt-test:~/# dd if=/dev/zero of=./app bs=1k count=2
    dd: failed to open './app': Text file busy

    root@virt-test:~/# cp app.backup app
    cp: cannot create regular file 'app': Text file busy

    root@virt-test:~/# rm app
    root@virt-test:~/# cp app.backup app
    root@virt-test:~/#

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

Changes v1 => v2:
1. Fixed a missing mem_cgroup_commit_charge() for non-shmem case.

Song Liu (3):
  mm: check compound_head(page)->mapping in filemap_fault()
  mm,thp: stats for file backed THP
  mm,thp: add read-only THP support for (non-shmem) FS

 fs/proc/meminfo.c      |   4 ++
 include/linux/fs.h     |   8 ++++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 +++++
 mm/filemap.c           |   7 +--
 mm/khugepaged.c        | 106 +++++++++++++++++++++++++++++++++--------
 mm/rmap.c              |  12 +++--
 mm/vmstat.c            |   2 +
 8 files changed, 125 insertions(+), 27 deletions(-)

--
2.17.1

