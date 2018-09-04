Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1836B6EE9
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 14:33:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m4-v6so2179323pgq.19
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 11:33:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n12-v6sor4912420pgi.23.2018.09.04.11.33.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Sep 2018 11:33:41 -0700 (PDT)
Subject: [PATCH 1/2] mm: Move page struct poisoning from CONFIG_DEBUG_VM to
 CONFIG_DEBUG_VM_PGFLAGS
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 04 Sep 2018 11:33:39 -0700
Message-ID: <20180904183339.4416.44582.stgit@localhost.localdomain>
In-Reply-To: <20180904181550.4416.50701.stgit@localhost.localdomain>
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, mhocko@suse.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

From: Alexander Duyck <alexander.h.duyck@intel.com>

On systems with a large amount of memory it can take a significant amount
of time to initialize all of the page structs with the PAGE_POISON_PATTERN
value. I have seen it take over 2 minutes to initialize a system with
over 12GB of RAM.

In order to work around the issue I had to disable CONFIG_DEBUG_VM and then
the boot time returned to something much more reasonable as the
arch_add_memory call completed in milliseconds versus seconds. However in
doing that I had to disable all of the other VM debugging on the system.

I did a bit of research and it seems like the only function that checks
for this poison value is the PagePoisoned function, and it is only called
in two spots. One is the PF_POISONED_CHECK macro that is only in use when
CONFIG_DEBUG_VM_PGFLAGS is defined, and the other is as a part of the
__dump_page function which is using the check to prevent a recursive
failure in the event of discovering a poisoned page.

With this being the case I am opting to move the poisoning of the page
structs from CONFIG_DEBUG_VM to CONFIG_DEBUG_VM_PGFLAGS so that we are
only performing the memset if it will be used to test for failures.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 mm/memblock.c |    2 +-
 mm/sparse.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 237944479d25..51e8ae927257 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1444,7 +1444,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
 
 	ptr = memblock_virt_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
-#ifdef CONFIG_DEBUG_VM
+#ifdef CONFIG_DEBUG_VM_PGFLAGS
 	if (ptr && size > 0)
 		memset(ptr, PAGE_POISON_PATTERN, size);
 #endif
diff --git a/mm/sparse.c b/mm/sparse.c
index 10b07eea9a6e..0fd9ad5021b0 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -696,7 +696,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 		goto out;
 	}
 
-#ifdef CONFIG_DEBUG_VM
+#ifdef CONFIG_DEBUG_VM_PGFLAGS
 	/*
 	 * Poison uninitialized struct pages in order to catch invalid flags
 	 * combinations.
