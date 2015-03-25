Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 94CF96B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:34:30 -0400 (EDT)
Received: by wgs2 with SMTP id 2so27708997wgs.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:34:30 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id ep2si4434063wjd.40.2015.03.25.06.34.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 06:34:29 -0700 (PDT)
Received: by wibg7 with SMTP id g7so109973808wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:34:28 -0700 (PDT)
Message-ID: <5512B961.8070409@plexistor.com>
Date: Wed, 25 Mar 2015 15:34:25 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 0/3 v4] dax: some dax fixes and cleanups
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

Hi

[v4] dax: some dax fixes and cleanups
* First patch fixed according to Andrew's comments. Thanks Andrew.
  1st and 2nd patch can go into current Kernel as they fix something
  that was merged this release.
* Added a new patch to fix up splice in the dax case, and cleanup.
  This one can wait for 4.1 (Also the first two not that anyone uses dax
  in production.)
* DAX freeze is not fixed yet. As we have more problems then I originally
  hoped for, as pointed out by Dave.
  (Just as a referance I'm sending a NO-GOOD additional patch to show what
   is not good enough to do. Was the RFC of [v3])
* Not re-posting the xfstest Dave please pick this up (It already found bugs
  in none dax FSs)

[v3] dax: Fix mmap-write not updating c/mtime
* I'm re-posting the two DAX patches that fix the mmap-write after read
  problem with DAX. (No changes since [v2])
* I'm also posting a 3rd RFC patch to address what Jan said about fs_freeze
  and making mapping read-only. 
  Jan Please review and see if this is what you meant.

[v2]
Jan Kara has pointed out that if we add the
sb_start/end_pagefault pair in the new pfn_mkwrite we
are then fixing another bug where: A user could start
writing to the page while filesystem is frozen.

[v1]
The main problem is that current mm/memory.c will no call us with page_mkwrite
if we do not have an actual page mapping, which is what DAX uses.
The solution presented here introduces a new pfn_mkwrite to solve this problem.
Please see patch-2 for details.

I've been running with this patch for 4 month both HW and VMs with no apparent
danger, but see patch-1 I played it safe.

I am also posting an xfstest 080 that demonstrate this problem, I believe
that also some git operations (can't remember which) suffer from this problem.
Actually Eryu Guan found that this test fails on some other FS as well.

List of patches:
 [PATCH 1/3] mm: New pfn_mkwrite same as page_mkwrite for VM_PFNMAP
 [PATCH 2/3] dax: use pfn_mkwrite to update c/mtime + freeze
 [PATCH 3/3] dax: Unify ext2/4_{dax,}_file_operations

 [PATCH] NOTGOOD: dax: dax_prepare_freeze

Andrew hi
I believe this needs to eventually go through your tree. Please pick it
up when you feel it is ready. I believe all 3 are ready and fix real
bugs.

Matthew hi
I would love to have your ACK on these patches?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
