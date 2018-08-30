Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2E56B5392
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 17:55:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j9-v6so10368143qtn.22
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:55:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y24-v6si3319412qve.2.2018.08.30.14.55.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 14:55:27 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 0/4] fs/dcache: Track # of negative dentries
Date: Thu, 30 Aug 2018 17:55:03 -0400
Message-Id: <1535666107-25699-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

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

 Documentation/sysctl/fs.txt | 22 +++++++++++-------
 fs/dcache.c                 | 54 ++++++++++++++++++++++++++++++++++++++++-----
 include/linux/dcache.h      |  5 +++--
 include/linux/fs.h          |  9 ++++----
 kernel/sysctl.c             |  2 +-
 5 files changed, 72 insertions(+), 20 deletions(-)

-- 
1.8.3.1
