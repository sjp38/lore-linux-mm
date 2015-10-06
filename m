Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BD2DB6B0256
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 18:28:56 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so226857586pac.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 15:28:56 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id yk2si52218071pac.192.2015.10.06.15.28.55
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 15:28:55 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 0/2] Revert locking changes in DAX for v4.3
Date: Tue,  6 Oct 2015 16:28:47 -0600
Message-Id: <1444170529-12814-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <matthew.r.wilcox@intel.com>

This series reverts some recent changes to the locking scheme in DAX introduced
by these two commits:

commit 843172978bb9 ("dax: fix race between simultaneous faults")
commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")

Changes from v3:
 - reduced the revert of 46c043ede471 in patch 1 so that we still drop the
   mapping->i_mmap_rwsem before calling unmap_mapping_range().  This prevents
   the deadlock in the __dax_pmd_fault() path so there is no longer a need to
   temporarily disable DAX PMD faults.

Ross Zwisler (2):
  Revert "mm: take i_mmap_lock in unmap_mapping_range() for DAX"
  Revert "dax: fix race between simultaneous faults"

 fs/dax.c    | 70 +++++++++++++++++++++++++------------------------------------
 mm/memory.c |  2 ++
 2 files changed, 31 insertions(+), 41 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
