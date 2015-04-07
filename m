Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id EC8276B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 04:33:15 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so37253058wgy.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 01:33:15 -0700 (PDT)
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id ey12si11599327wid.87.2015.04.07.01.33.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 01:33:14 -0700 (PDT)
Received: by wgin8 with SMTP id n8so48191705wgi.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 01:33:12 -0700 (PDT)
Message-ID: <55239645.9000507@plexistor.com>
Date: Tue, 07 Apr 2015 11:33:09 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 0/3 v5] dax: some dax fixes and cleanups
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>
Cc: Stable Tree <stable@vger.kernel.org>

Hi Andrew

I finally had the time to beat up these fixes based on linux-next/akpm
and it looks OK.
I'm sending the two fix patches with @stable + a patch-1 for the 4.0
Kernel. The 4.1-rc Kernel will need a different patch.

It is your call if you want these in stable. It is a breakage in the dax
code that went into 4.0. But I guess it will not have that many users right
at the get go. So feel free to remove the CC:@stable. (Also the old XIP that
this DAX changed had all the same problems)

[v5]
* A new patch-1 Based on linux-next/akpm branch because mm/memory.c
  completely changed there.
  Also a 4.0 version of the same patch-1 if needed for stable@

List of patches:
 [PATCH 1/3] mm(v4.1): New pfn_mkwrite same as page_mkwrite for VM_PFNMAP
 [PATCH 2/3] dax: use pfn_mkwrite to update c/mtime + freeze
 [PATCH 3/3] dax: Unify ext2/4_{dax,}_file_operations

	All these patches are based on linux-next/akpm. I'm not sure how
	it will interact with ext4-next though.

 [PATCH 1/3 @stable] mm(v4.0): New pfn_mkwrite same as page_mkwrite for VM_PFNMAP

	This patch is for 4.0 based tree if we decide to send
	[PATCH 2/3] to stable.


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

Matthew hi
I would love to have your ACK on these patches?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
