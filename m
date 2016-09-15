Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD42E6B0253
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:32 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so83628729pab.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:32 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id if10si3971206pad.130.2016.09.15.04.55.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 00/41] ext4: support of huge pages
Date: Thu, 15 Sep 2016 14:54:42 +0300
Message-Id: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's respin of my huge ext4 patchset on top of v4.8-rc6 with couple of
fixes (see below).

Please review and consider applying.

I don't see any xfstests regressions with huge pages enabled. Patch with
new configurations for xfstests-bld is below.

The basics are the same as with tmpfs[1] which is in Linus' tree now and
ext4 built on top of it. The main difference is that we need to handle
read out from and write-back to backing storage.

Head page links buffers for whole huge page. Dirty/writeback tracking
happens on per-hugepage level.

We read out whole huge page at once. It required bumping BIO_MAX_PAGES to
not less than HPAGE_PMD_NR. I defined BIO_MAX_PAGES to HPAGE_PMD_NR if
huge pagecache enabled.

On split_huge_page() we need to free buffers before splitting the page.
Page buffers takes additional pin on the page and can be a vector to mess
with the page during split. We want to avoid this.
If try_to_free_buffers() fails, split_huge_page() would return -EBUSY.

Readahead doesn't play with huge pages well: 128k max readahead window,
assumption on page size, PageReadahead() to track hit/miss.  I've got it
to allocate huge pages, but it doesn't provide any readahead as such.
I don't know how to do this right. It's not clear at this point if we
really need readahead with huge pages. I guess it's good enough for now.

Shadow entries ignored on allocation -- recently evicted page is not
promoted to active list. Not sure if current workingset logic is adequate
for huge pages. On eviction, we split the huge page and setup 4k shadow
entries as usual.

Unlike tmpfs, ext4 makes use of tags in radix-tree. The approach I used
for tmpfs -- 512 entries in radix-tree per-hugepages -- doesn't work well
if we want to have coherent view on tags. So the first 8 patches of the
patchset converts tmpfs to use multi-order entries in radix-tree.
The same infrastructure used for ext4.

Encryption doesn't handle huge pages yet. To avoid regressions we just
disable huge pages for the inode if it has EXT4_INODE_ENCRYPT.

Tested with 4k, 1k, encryption and bigalloc. All with and without
huge=always. I think it's reasonable coverage.

The patchset is also in git:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugeext4/v3

[1] http://lkml.kernel.org/r/1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com

Changes since v2:
  - fix intermittent crash in generic/299;
  - typo (condition inversion) in do_generic_file_read(),
    reported by Jitendra;

TODO:
  - readahead ?;
  - wire up madvise()/fadvise();
  - encryption with huge pages;
  - reclaim of file huge pages can be optimized -- split_huge_page() is not
    required for pages with backing storage;
