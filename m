Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11EA58E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 06:44:58 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id y74so11352164wmc.0
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 03:44:58 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id h25si17199614wmb.160.2018.12.27.03.44.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Dec 2018 03:44:56 -0800 (PST)
From: Colin Ian King <colin.king@canonical.com>
Subject: bug report: hugetlbfs: use i_mmap_rwsem for more pmd sharing,
 synchronization
Message-ID: <5c8be807-03cd-991d-c79b-3c10a4d6d67b@canonical.com>
Date: Thu, 27 Dec 2018 11:44:53 +0000
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, stable@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

Static analysis with CoverityScan on linux-next detected a potential
null pointer dereference with the following commit:

>From d8a1051ed4ba55679ef24e838a1942c9c40f0a14 Mon Sep 17 00:00:00 2001
From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Sat, 22 Dec 2018 10:55:57 +1100
Subject: [PATCH] hugetlbfs: use i_mmap_rwsem for more pmd sharing

The earlier check implies that "mapping" may be a null pointer:

var_compare_op: Comparing mapping to null implies that mapping might be
null.

1008        if (!(flags & MF_MUST_KILL) && !PageDirty(hpage) && mapping &&
1009            mapping_cap_writeback_dirty(mapping)) {

..however later "mapper" is dereferenced when it may be potentially null:

1034                /*
1035                 * For hugetlb pages, try_to_unmap could potentially
call
1036                 * huge_pmd_unshare.  Because of this, take semaphore in
1037                 * write mode here and set TTU_RMAP_LOCKED to
indicate we
1038                 * have taken the lock at this higer level.
1039                 */
    CID 1476097 (#1 of 1): Dereference after null check (FORWARD_NULL)

var_deref_model: Passing null pointer mapping to
i_mmap_lock_write, which dereferences it.

1040                i_mmap_lock_write(mapping);
1041                unmap_success = try_to_unmap(hpage,
ttu|TTU_RMAP_LOCKED);
1042                i_mmap_unlock_write(mapping);


Colin
