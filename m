Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 789E78E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:18:36 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q3-v6so21949864qki.4
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 12:18:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 97-v6si6142473qva.253.2018.09.11.12.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 12:18:34 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v3 0/4] fs/dcache: Track # of negative dentries
Date: Tue, 11 Sep 2018 15:18:22 -0400
Message-Id: <1536693506-11949-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

 v2->v3:
  - With confirmation that the dummy array in dentry_stat structure
    was never a replacement of a previously used field, patch 3 is now
    reverted back to use one of dummy field as the negative dentry count
    instead of adding a new field.

 v1->v2:
  - Clarify what the new nr_dentry_negative per-cpu counter is tracking
    and open-code the increment and decrement as suggested by Dave Chinner.
  - Append the new nr_dentry_negative count as the 7th element of dentry-state
    instead of replacing one of the dummy entries.
  - Remove patch "fs/dcache: Make negative dentries easier to be
    reclaimed" for now as I need more time to think about what
    to do with it.
  - Add 2 more patches to address issues found while reviewing the
    dentry code.
  - Add another patch to change the conditional branch of
    nr_dentry_negative accounting to conditional move so as to reduce
    the performance impact of the accounting code.

This patchset addresses 2 issues found in the dentry code and adds a
new nr_dentry_negative per-cpu counter to track the total number of
negative dentries in all the LRU lists.

Patch 1 fixes a bug in the accounting of nr_dentry_unused in
shrink_dcache_sb().

Patch 2 removes the ____cacheline_aligned_in_smp tag from super_block
LRU lists.

Patch 3 adds the new nr_dentry_negative per-cpu counter.

Patch 4 removes conditional branches in nr_dentry_negative accounting
code.

Various filesystem related tests were run and no statistically
significant changes in performance was observed.

Waiman Long (4):
  fs/dcache: Fix incorrect nr_dentry_unused accounting in
    shrink_dcache_sb()
  fs: Don't need to put list_lru into its own cacheline
  fs/dcache: Track & report number of negative dentries
  fs/dcache: Eliminate branches in nr_dentry_negative accounting

 Documentation/sysctl/fs.txt | 26 +++++++++++++---------
 fs/dcache.c                 | 54 ++++++++++++++++++++++++++++++++++++++++-----
 include/linux/dcache.h      |  7 +++---
 include/linux/fs.h          |  9 ++++----
 4 files changed, 74 insertions(+), 22 deletions(-)

-- 
1.8.3.1
