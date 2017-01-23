Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB6976B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:47:20 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so93432752pfg.4
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:47:20 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d127si3086980pga.322.2017.01.23.15.47.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 15:47:19 -0800 (PST)
Subject: [PATCH 0/3] 1G transparent hugepage support for device dax
From: Dave Jiang <dave.jiang@intel.com>
Date: Mon, 23 Jan 2017 16:47:18 -0700
Message-ID: <148521477073.31533.17781371321988910714.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

The following series implements support for 1G trasparent hugepage on
x86 for device dax. The bulk of the code was written by Mathew Wilcox
a while back supporting transparent 1G hugepage for fs DAX. I have
forward ported the relevant bits to 4.10-rc. The current submission has
only the necessary code to support device DAX.

---

Dave Jiang (1):
      dax: Support for transparent PUD pages for device DAX

Matthew Wilcox (2):
      mm,fs,dax: Change ->pmd_fault to ->huge_fault
      mm,x86: Add support for PUD-sized transparent hugepages


 arch/Kconfig                          |    3 
 arch/x86/Kconfig                      |    1 
 arch/x86/include/asm/paravirt.h       |   11 +
 arch/x86/include/asm/paravirt_types.h |    2 
 arch/x86/include/asm/pgtable-2level.h |   17 ++
 arch/x86/include/asm/pgtable-3level.h |   24 +++
 arch/x86/include/asm/pgtable.h        |  145 +++++++++++++++++++
 arch/x86/include/asm/pgtable_64.h     |   15 ++
 arch/x86/kernel/paravirt.c            |    1 
 arch/x86/mm/pgtable.c                 |   31 ++++
 drivers/dax/dax.c                     |   82 ++++++++---
 fs/dax.c                              |   43 ++++--
 fs/ext2/file.c                        |    2 
 fs/ext4/file.c                        |    6 -
 fs/xfs/xfs_file.c                     |   10 +
 fs/xfs/xfs_trace.h                    |    2 
 include/asm-generic/pgtable.h         |   75 +++++++++-
 include/asm-generic/tlb.h             |   14 ++
 include/linux/dax.h                   |    6 -
 include/linux/huge_mm.h               |   83 ++++++++++-
 include/linux/mm.h                    |   40 +++++
 include/linux/mmu_notifier.h          |   14 ++
 include/linux/pfn_t.h                 |    8 +
 mm/gup.c                              |    7 +
 mm/huge_memory.c                      |  249 +++++++++++++++++++++++++++++++++
 mm/memory.c                           |  102 ++++++++++++--
 mm/pagewalk.c                         |   20 +++
 mm/pgtable-generic.c                  |   14 ++
 28 files changed, 952 insertions(+), 75 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
