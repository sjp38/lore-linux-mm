Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2ED082F6B
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 16:33:03 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so190187494pac.2
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 13:33:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yn6si42788136pab.112.2015.10.05.13.33.03
        for <linux-mm@kvack.org>;
        Mon, 05 Oct 2015 13:33:03 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 0/3]  Revert locking changes in DAX for v4.3
Date: Mon,  5 Oct 2015 14:32:51 -0600
Message-Id: <1444077174-22016-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org

This series reverts some recent changes to the locking scheme in DAX introduced
by these two commits:

commit 843172978bb9 ("dax: fix race between simultaneous faults")
commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")

It also temporarily disables the newly added DAX PMD fault path because of a
deadlock. We are re-working the way that DAX does its locking for v4.4, so for
now just disable DAX PMD faults and fall back to PAGE_SIZE faults to make sure
we don't hit this deadlock.

Changes from v2:
 - Temporarily disable the DAX PMD fault path while we re-work DAX locking for
   v4.4.

Ross Zwisler (3):
  Revert "mm: take i_mmap_lock in unmap_mapping_range() for DAX"
  Revert "dax: fix race between simultaneous faults"
  dax: temporarily disable DAX PMD fault path

 fs/dax.c    | 90 ++++++++++++++++++++++++++++---------------------------------
 mm/memory.c |  2 ++
 2 files changed, 43 insertions(+), 49 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
