Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC396B0348
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 16:19:06 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so373602569pfx.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 13:19:06 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b10si31949871pfd.39.2016.12.22.13.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 13:19:05 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 0/4] Write protect DAX PMDs in *sync path
Date: Thu, 22 Dec 2016 14:18:52 -0700
Message-Id: <1482441536-14550-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Currently dax_mapping_entry_mkclean() fails to clean and write protect the
pmd_t of a DAX PMD entry during an *sync operation.  This can result in
data loss, as detailed in patch 4.

You can find a working tree here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_clean_v2

This series applies cleanly to mmotm-2016-12-19-16-31.

Changes since v1:
 - Included Dan's patch to kill DAX support for UML.
 - Instead of wrapping the DAX PMD code in dax_mapping_entry_mkclean() in
   an #ifdef, we now create a stub for pmdp_huge_clear_flush() for the case
   when CONFIG_TRANSPARENT_HUGEPAGE isn't defined. (Dan & Jan)

Dan Williams (1):
  dax: kill uml support

Ross Zwisler (3):
  dax: add stub for pmdp_huge_clear_flush()
  mm: add follow_pte_pmd()
  dax: wrprotect pmd_t in dax_mapping_entry_mkclean

 fs/Kconfig                    |  2 +-
 fs/dax.c                      | 49 ++++++++++++++++++++++++++++++-------------
 include/asm-generic/pgtable.h | 10 +++++++++
 include/linux/mm.h            |  4 ++--
 mm/memory.c                   | 41 ++++++++++++++++++++++++++++--------
 5 files changed, 79 insertions(+), 27 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
