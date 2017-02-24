Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3E66B0389
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:40:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v63so34004768pgv.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 03:40:31 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f188si7189337pfb.28.2017.02.24.03.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 03:40:30 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 0/5] mm: support parallel free of memory
Date: Fri, 24 Feb 2017 19:40:31 +0800
Message-Id: <20170224114036.15621-1-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

For regular processes, the time taken in its exit() path to free its
used memory is not a problem. But there are heavy ones that consume
several Terabytes memory and the time taken to free its memory could
last more than ten minutes.

To optimize this use case, a parallel free method is proposed here.
For detailed explanation, please refer to patch 2/5.

I'm not sure if we need patch 4/5 which can avoid page accumulation
being interrupted in some case(patch description has more information).
My test case, which only deal with anon memory doesn't get any help out
of this of course. It can be safely dropped if it is deemed not useful.

A test program that did a single malloc() of 320G memory is used to see
how useful the proposed parallel free solution is, the time calculated
is for the free() call. Test machine is a Haswell EX which has
4nodes/72cores/144threads with 512G memory. All tests are done with THP
disabled.

kernel                             time
v4.10                              10.8s  A+-2.8%
this patch(with default setting)   5.795s A+-5.8%

Patch 3/5 introduced a dedicated workqueue for the free workers and
here are more results when setting different values for max_active of
this workqueue:

max_active:   time
1             8.9s   A+-0.5%
2             5.65s  A+-5.5%
4             4.84s  A+-0.16%
8             4.77s  A+-0.97%
16            4.85s  A+-0.77%
32            6.21s  A+-0.46%

Comments are welcome.

Aaron Lu (5):
  mm: add tlb_flush_mmu_free_batches
  mm: parallel free pages
  mm: use a dedicated workqueue for the free workers
  mm: add force_free_pages in zap_pte_range
  mm: add debugfs interface for parallel free tuning

 include/asm-generic/tlb.h |  12 ++--
 mm/memory.c               | 138 +++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 122 insertions(+), 28 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
