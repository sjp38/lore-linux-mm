Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 153126B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 08:47:57 -0400 (EDT)
Received: by wegp1 with SMTP id p1so136804509weg.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:47:56 -0700 (PDT)
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id s5si11595201wik.109.2015.03.23.05.47.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 05:47:55 -0700 (PDT)
Received: by wgra20 with SMTP id a20so144997563wgr.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:47:54 -0700 (PDT)
Message-ID: <55100B78.501@plexistor.com>
Date: Mon, 23 Mar 2015 14:47:52 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 0/3 v3] dax: Fix mmap-write not updating c/mtime
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

Hi

[v3]
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
  [PATCH 3/3] RFC: dax: dax_prepare_freeze

  [PATCH v4] xfstest: generic/080 test that mmap-write updates c/mtime

Please I need that some mm person review the first patch?

Andrew hi
I believe this needs to eventually go through your tree. Please pick it
up when you feel it is ready. I believe the first 2 are ready and fix real
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
