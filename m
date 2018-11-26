Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA2CC6B444B
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:13:13 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so8781155pga.16
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:13:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10-v6sor2483520plk.56.2018.11.26.15.13.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:13:12 -0800 (PST)
Date: Mon, 26 Nov 2018 15:13:03 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 00/10] huge_memory,khugepaged tmpfs split/collapse fixes
Message-ID: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

Hi Andrew,

Here's a set of 10 patches, mostly fixing some crashes and lockups
which can happen when khugepaged collapses tmpfs pages to huge:
by-products of ongoing work to extend upstream's huge tmpfs to
match what we need in Google (but no enhancements included here).

Against v4.20-rc2 == v4.20-rc4: sorry, I haven't looked yet to see
what clashes there might be with mmotm, because I believe that although
these are all (except 10/10) to long-standing bugs, they still deserve
to get into v4.20 and -stable.  See what you think.

Most of the testing has been on the whole series, and on a slightly
earlier kernel: the move to XArray means that almost none of these
patches will apply cleanly to v4.19 or earlier, but I do have the
equivalents lined up ready.

 mm/huge_memory.c |   43 ++++++++-----
 mm/khugepaged.c  |  140 ++++++++++++++++++++++++++-------------------
 mm/rmap.c        |   13 ----
 mm/shmem.c       |    6 +
 4 files changed, 114 insertions(+), 88 deletions(-)

 1/10 mm/huge_memory: rename freeze_page() to unmap_page()
 2/10 mm/huge_memory: splitting set mapping+index before unfreeze
 3/10 mm/huge_memory: fix lockdep complaint on 32-bit i_size_read()
 4/10 mm/khugepaged: collapse_shmem() stop if punched or truncated
 5/10 mm/khugepaged: fix crashes due to misaccounted holes
 6/10 mm/khugepaged: collapse_shmem() remember to clear holes
 7/10 mm/khugepaged: minor reorderings in collapse_shmem()
 8/10 mm/khugepaged: collapse_shmem() without freezing new_page
 9/10 mm/khugepaged: collapse_shmem() do not crash on Compound
10/10 mm/khugepaged: fix the xas_create_range() error path

Thanks,
Hugh
