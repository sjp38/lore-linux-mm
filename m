Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE9EC6B0038
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 05:10:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v1so34129024pgv.8
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:10:47 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id t9si7571483pgb.66.2017.04.26.02.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 02:10:47 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 63so16708205pgh.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 02:10:47 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 0/2] mm: hwpoison: fix mce-test.ras.fail on 23a003bfd2
Date: Wed, 26 Apr 2017 18:10:39 +0900
Message-Id: <1493197841-23986-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xiaolong.ye@intel.com, Andrew Morton <akpm@linux-foundation.org>, Chen Gong <gong.chen@linux.intel.com>, lkp@01.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hello,

I wrote fixes for the problems reported by http://lkml.kernel.org/r/20170417055948.GM31394@yexl-desktop.
These 2 patches make tsimpleinj.c delivered in mce-test test suite pass.

  [build8:~/mce-test-official/cases/function/hwpoison]$ ./tsimpleinj
  dirty page 0x7f657aecb000
  signal 7 code 4 addr 0x7f657aecb000
  recovered
  mlocked page 0x7f657aeca000
  signal 7 code 4 addr 0x7f657aeca000
  recovered
  clean file page 0x7f657aec9000
  23
  recovered
  file dirty page 0x7f657aec8000
  signal 7 code 4 addr 0x7f657aec8000
  recovered
  no error on msync expect error
  no error on fsync expect error
  hole file dirty page 0x7f657aec7000
  signal 7 code 4 addr 0x7f657aec7000
  recovered
  no error on hole msync expect error
  no error on hole fsync expect error
  SUCCESS

I'm digging another similar issue for hugetlb pages, which need some more
research and code, so I'll send it separately later.

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (2):
      mm: hwpoison: call shake_page() unconditionally
      mm: hwpoison: call shake_page() after try_to_unmap() for mlocked page

 mm/hwpoison-inject.c |  3 +--
 mm/memory-failure.c  | 35 +++++++++++++++++++----------------
 2 files changed, 20 insertions(+), 18 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
