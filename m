Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6A586B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:24:43 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b81so13253589lfe.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:24:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d4si3629163lfe.50.2016.10.19.10.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:24:41 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/5] mm: workingset: radix tree subtleties & single-page file refaults
Date: Wed, 19 Oct 2016 13:24:23 -0400
Message-Id: <20161019172428.7649-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

this is a follow-up to d3798ae8c6f3 ("mm: filemap: don't plant shadow
entries without radix tree node"). That patch fixed an issue that was
caused mainly by the page cache sneaking special shadow page entries
into the radix tree and relying on subtleties in the radix tree code
to make that work. The fix also had to stop tracking refaults for
single-page files because shadow pages stored as direct pointers in
radix_tree_root->rnode weren't properly handled during tree extension.

These patches make the radix tree code explicitely support and track
such special entries, to eliminate the subtleties and to restore the
thrash detection for single-page files.

They then turn the BUG_ONs in the shadow shrinker into mere warnings,
to prevent unnecessary crashes such as those mentioned in d3798ae8c6f3.

The changes have been running stable on my main machines for a couple
of days, survived kernel builds, chrome, and various synthetic stress
tests that excercise the shadow page tracking code. They've also been
solid doing scalability and page cache tests from Mel's mmtests.

It's more code, but it should be a lot less fragile. What do you think?

 include/linux/radix-tree.h      |  33 +++++----
 include/linux/swap.h            |  16 +++--
 lib/dma-debug.c                 |   6 +-
 lib/radix-tree.c                | 142 +++++++++++++++++++++++---------------
 mm/filemap.c                    |  25 ++++---
 mm/truncate.c                   |   2 +
 mm/workingset.c                 |  19 +++--
 tools/testing/radix-tree/test.c |   4 +-
 8 files changed, 149 insertions(+), 98 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
