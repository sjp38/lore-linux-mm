Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8CD56B0621
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 12:49:04 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c15-v6so19342806pls.15
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 09:49:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12-v6sor5820328plk.37.2018.11.08.09.49.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 09:49:03 -0800 (PST)
From: Yangtao Li <tiny.windzz@gmail.com>
Subject: [PATCH] mm: mmap: remove verify_mm_writelocked()
Date: Thu,  8 Nov 2018 12:48:56 -0500
Message-Id: <20181108174856.10811-1-tiny.windzz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, dan.j.williams@intel.com, linux@dominikbrodowski.net, dave.hansen@linux.intel.com, dwmw@amazon.co.uk, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yangtao Li <tiny.windzz@gmail.com>

We should get rid of this function. It no longer serves its purpose.This
is a historical artifact from 2005 where do_brk was called outside of
the core mm.We do have a proper abstraction in vm_brk_flags and that one
does the locking properly.So there is no need to use this function.

Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>
---
 mm/mmap.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f7cd9cb966c0..1cee506494d2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2910,16 +2910,6 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	return ret;
 }
 
-static inline void verify_mm_writelocked(struct mm_struct *mm)
-{
-#ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
-		WARN_ON(1);
-		up_read(&mm->mmap_sem);
-	}
-#endif
-}
-
 /*
  *  this is really a simplified "do_mmap".  it only handles
  *  anonymous maps.  eventually we may be able to do some
@@ -2946,12 +2936,6 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
 	if (error)
 		return error;
 
-	/*
-	 * mm->mmap_sem is required to protect against another thread
-	 * changing the mappings in case we sleep.
-	 */
-	verify_mm_writelocked(mm);
-
 	/*
 	 * Clear old maps.  this also does some error checking for us
 	 */
-- 
2.17.0
