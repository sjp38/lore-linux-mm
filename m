Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C500C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E245220B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="eYIYZ0Kb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E245220B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AE8B8E0007; Wed, 19 Jun 2019 02:24:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65FCE8E0003; Wed, 19 Jun 2019 02:24:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 526968E0007; Wed, 19 Jun 2019 02:24:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C09C8E0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:24:34 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x9so11001317pfm.16
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=W0J/aM2r1p8f45qTRb5W3kKJad5Cvu0gJmeGFSlgBMA=;
        b=UOV/rTBW6hyNVHzG0/i5H0cakYp0lgtUsgtE9opa6IM4oHXj+S30lHc0EDwldKXaYW
         qiVebboIwQU7YW74Kq1AwZG58wiAvvvHKUOOT/fbPMwSLYXILFueZKBQYhEbIjx407tp
         phtJyLMSivYPciHTNuyqgaj3Yy3KlfKjQOLeVP5eqHx3QGvIq929J9GjiJNRjZdrB9nk
         tXqWUtahmJFWVfT0Tn7jDPHKiOM5TWXUvW4qrw0H825/eH/3/KYmqxy+blbnYfALIxrw
         PQr8ChJ3Fmx8k82MzodYOrcxaHyPGQzj4GK2ki1S2QDHnOj3+kZMzMQd1qGoXLFT0S0w
         nuUQ==
X-Gm-Message-State: APjAAAWjri1HjlcQDVT0+6vTHfKznNZievED0sf7VO49TcRuljdIbPxw
	25HVGBhfwS2qWWxUIJoqBryVRfNIN5fr6XNpDj1RenrL+asYaZTpaGI8jfpE65EuiHgtBubrlUG
	fAf08dGNjL4QS/9Jlg3W2tnl4MRjeVyJcUmT4WV1F+HWxCsWbEjqfUoHaMsvwwHgvHA==
X-Received: by 2002:a17:90a:9385:: with SMTP id q5mr9251425pjo.126.1560925473768;
        Tue, 18 Jun 2019 23:24:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5yL1zUZJ/3eaZWi55PC017Ba+9glPeUfogZVEr0r99T8CLMJnMR4wtLQUmm35DV2BVtJH
X-Received: by 2002:a17:90a:9385:: with SMTP id q5mr9251365pjo.126.1560925472669;
        Tue, 18 Jun 2019 23:24:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925472; cv=none;
        d=google.com; s=arc-20160816;
        b=fjKHwbuPZ67rVsc3sFaqYLdhX4621mhBz459yLBkPaQynlEUI/Gslq9QXQ+cvD3gUn
         BbBW9Qa/uIBNnh+f0B9l/mrtsgDXOFXcKYMdSvvMuI1u71Y98x4IvC05NLiQXUgJ6trO
         xhoDKlGy8NyhPBCF6lUFw9cMxmDw9sIClZTsw6yl8Vfza1KkZhCUNGe7gDnr8aqP0u/R
         CyQEcCbGTjRpp0iZv81Q/pgVclLD+ZblWYaCEhGVwoAhth5rm/VVxhuEvtInnA7NvBMc
         FIvII+dw0jKl9g2unAsI44VrtLiRuhTYfkBfZqmog1ppLPCIjbqsEBJME2mHczK33Ry7
         ZKWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=W0J/aM2r1p8f45qTRb5W3kKJad5Cvu0gJmeGFSlgBMA=;
        b=hcvk6a9jc9a0OEs25xn75LceHOEtN2M0qd1FcCkxB1Deed+/obxw9F0APjjl/rzM6M
         yXbCm+wwLaPt64AddjiVTRZKL6R4eUzvZVyTCoLUq5PuuTWLK2zMSNUIDDGJZTs132nV
         hmXeLwneKNxd2/UcVodk5O4KAIE07R+E4Na69zRTPS12eB2pLJ9m4KuChba+HW12GOWB
         DXb8zr7K2K8FlmTO/+6NEtsSnzXkWRPUrfIJWDAlHw5mfBDEe37lySJ7gOLNamyRrAnS
         tWrpUPSki+V0LHBogHMK4s6egYFDPxob0vsXkYY+LTPeHkDd9ieEux4/Fltb55YohxTI
         An/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=eYIYZ0Kb;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v11si14894668plg.136.2019.06.18.23.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:24:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=eYIYZ0Kb;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5J6N6on010312
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:32 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=W0J/aM2r1p8f45qTRb5W3kKJad5Cvu0gJmeGFSlgBMA=;
 b=eYIYZ0KbdGJ+3ylwX/xuZIebLNhfnOhkJbGIHiTPi9uM+u9k0S+8pH4WYe/YgKTzJFFJ
 eH5nFEFiHJ/vmncQSLp4wuw1RfbVL5mbVqN26iAoMga2RhwE2CY0hSeA2NppAojE1FTB
 Pg2s3gXl5Cpy9zVtoVPt9av4cf+g/s5kn1k= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t78049dtv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:32 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 18 Jun 2019 23:24:30 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 5E97362E30AA; Tue, 18 Jun 2019 23:24:29 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 0/6] Enable THP for text section of non-shmem files
Date: Tue, 18 Jun 2019 23:24:18 -0700
Message-ID: <20190619062424.3486524-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190052
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
  mm,thp: handle writes to file with THP in pagecache

 fs/inode.c             |   3 ++
 fs/proc/meminfo.c      |   4 ++
 include/linux/fs.h     |  31 ++++++++++++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 +++++
 mm/filemap.c           |   9 ++--
 mm/khugepaged.c        | 104 +++++++++++++++++++++++++++++++++--------
 mm/rmap.c              |  12 +++--
 mm/truncate.c          |   7 ++-
 mm/vmstat.c            |   2 +
 10 files changed, 156 insertions(+), 29 deletions(-)

--
2.17.1

