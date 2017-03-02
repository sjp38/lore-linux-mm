Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0146A6B0390
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:11:44 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 65so94250444pgi.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:11:43 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e69si3785898pgc.181.2017.03.02.07.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:11:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] thp: fix few MADV_DONTNEED races
Date: Thu,  2 Mar 2017 18:10:30 +0300
Message-Id: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For MADV_DONTNEED to work properly with huge pages, it's critical to not clear
pmd intermittently unless you hold down_write(mmap_sem). Otherwise
MADV_DONTNEED can miss the THP which can lead to userspace breakage.

See example of such race in commit message of patch 2/4.

All these races are found by code inspection. I haven't seen them triggered. 
I don't think it's worth to apply them to stable@.

Kirill A. Shutemov (4):
  thp: reduce indentation level in change_huge_pmd()
  thp: fix MADV_DONTNEED vs. numa balancing race
  thp: fix MADV_DONTNEED vs. MADV_FREE race
  thp: fix MADV_DONTNEED vs clear soft dirty race

 fs/proc/task_mmu.c |  9 +++++-
 mm/huge_memory.c   | 86 ++++++++++++++++++++++++++++++++++++------------------
 2 files changed, 66 insertions(+), 29 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
