Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3BFBF6B0008
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 13:44:14 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id y12-v6so1268240lfh.16
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 10:44:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15-v6sor3966816lfh.11.2018.10.16.10.44.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 10:44:12 -0700 (PDT)
From: Kuo-Hsin Yang <vovoy@chromium.org>
Subject: [PATCH 1/2] shmem: export shmem_unlock_mapping
Date: Wed, 17 Oct 2018 01:42:59 +0800
Message-Id: <20181016174300.197906-2-vovoy@chromium.org>
In-Reply-To: <20181016174300.197906-1-vovoy@chromium.org>
References: <20181016174300.197906-1-vovoy@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org
Cc: mhocko@suse.com, akpm@linux-foundation.org, chris@chris-wilson.co.uk, peterz@infradead.org, dave.hansen@intel.com, corbet@lwn.net, hughd@google.com, joonas.lahtinen@linux.intel.com, marcheu@chromium.org, hoegsberg@chromium.org, Kuo-Hsin Yang <vovoy@chromium.org>

By exporting this function, drivers can mark/unmark a shmemfs address
space as unevictable in the following way: 1. mark an address space as
unevictable with mapping_set_unevictable(), pages in the address space
will be moved to unevictable list in vmscan. 2. mark an address space
evictable with mapping_clear_unevictable(), and move these pages back to
evictable list with shmem_unlock_mapping().

Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
---
 Documentation/vm/unevictable-lru.rst | 4 +++-
 mm/shmem.c                           | 2 ++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/unevictable-lru.rst b/Documentation/vm/unevictable-lru.rst
index fdd84cb8d511..a812fb55136d 100644
--- a/Documentation/vm/unevictable-lru.rst
+++ b/Documentation/vm/unevictable-lru.rst
@@ -143,7 +143,7 @@ using a number of wrapper functions:
 	Query the address space, and return true if it is completely
 	unevictable.
 
-These are currently used in two places in the kernel:
+These are currently used in three places in the kernel:
 
  (1) By ramfs to mark the address spaces of its inodes when they are created,
      and this mark remains for the life of the inode.
@@ -154,6 +154,8 @@ These are currently used in two places in the kernel:
      swapped out; the application must touch the pages manually if it wants to
      ensure they're in memory.
 
+ (3) By the i915 driver to mark pinned address space until it's unpinned.
+
 
 Detecting Unevictable Pages
 ---------------------------
diff --git a/mm/shmem.c b/mm/shmem.c
index 446942677cd4..d1ce34c09df6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -786,6 +786,7 @@ void shmem_unlock_mapping(struct address_space *mapping)
 		cond_resched();
 	}
 }
+EXPORT_SYMBOL_GPL(shmem_unlock_mapping);
 
 /*
  * Remove range of pages and swap entries from radix tree, and free them.
@@ -3874,6 +3875,7 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 void shmem_unlock_mapping(struct address_space *mapping)
 {
 }
+EXPORT_SYMBOL_GPL(shmem_unlock_mapping);
 
 #ifdef CONFIG_MMU
 unsigned long shmem_get_unmapped_area(struct file *file,
-- 
2.19.1.331.ge82ca0e54c-goog
