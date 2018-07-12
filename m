Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18AB26B000D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:47:04 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id j189-v6so35247731qkf.0
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:47:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w138-v6si17787970qka.122.2018.07.12.09.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 09:47:02 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v7 0/6] fs/dcache: Track & limit # of negative dentries
Date: Thu, 12 Jul 2018 12:45:59 -0400
Message-Id: <1531413965-5401-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

 v6->v7:
  - Drop the 2 patches that add a new shrinker for negative dentries.
    Instead, the default memory shrinker will be relied on to get
    rid of excess negative dentries when free memory is low.
  - Change the sysctl parameter "neg-dentry-pc" to "neg-dentry-limit"
    and the unit is now 1/1000 of the total system memory with a range
    of 0-100.
  - Add a patch to brief up the warning so that one warning will be
    printed every minute to the console if the limit is exceeded until
    the system administrator does something about it. It can be disabling
    the limit, raising the limit or turning on the enforcement option.

 v5->v6:
  - Drop the neg_dentry_pc boot command line option, but add a
    "neg-dentry-pc" sysctl parameter instead.
  - Change the "enforce-neg-dentry-limit" sysctl parameter to
    "neg-dentry-enforce".
  - Add a patch to add negative dentry to the head of the LRU initially
    so that they will be the first to be removed if they are not
    accessed again.
  - Run some additional performance test.

 v4->v5:
  - Backed to the latest 4.18 kernel and modify the code
    accordingly. Patch 1 "Relocate dentry_kill() after lock_parent()"
    is now no longer necessary.
  - Make tracking and limiting of negative dentries a user configurable
    option (CONFIG_DCACHE_TRACK_NEG_ENTRY) so that users can decide if
    they want to include this capability in the kernel.
  - Make killing excess negative dentries an optional feature that can be
    enabled via a boot command line option or a sysctl parameter.
  - Spread negative dentry pruning across multiple CPUs.

 v4: https://lkml.org/lkml/2017/9/18/739
 v5: https://lkml.org/lkml/2018/7/2/21
 v6: https://lkml.org/lkml/2018/7/6/875

A rogue application can potentially create a large number of negative
dentries in the system consuming a significant portion of the memory
available if it is not under the direct control of a memory controller
that enforces kernel memory limit. Unlike other user activities that
can be easily tracked, generation of too many negative dentries is hard
to detect.

This patchset introduces changes to the dcache subsystem to track and
optionally limit the number of negative dentries allowed to be created.
Once the limit is exceeded, warnings will be printed in the console.
System administrators can then either disable the limit, raise the limit
or enforce the limit by killing off excess negative dentries. They
should also investigate if something wrong is happening that causes
the number of negative dentries used to go way up.

Patch 1 tracks the number of negative dentries present in the LRU
lists and reports it in /proc/sys/fs/dentry-state.

Patch 2 moves the negative dentries to the head of the LRU after they
are initially created. They will be moved to the tail like the positive
dentries the second time they are reinserted. This will make sure that
all those accssed-once negative dentries will be removed first when a
shrinker is running.

Patch 3 adds a "neg-dentry-limit" sysctl parameter that can be used to
to specify a soft limit on the number of negative allowed as a multiple
of 1/1000 of the total system memory available. This parameter is 0 by
default which means no negative dentry limiting will be performed.

Patch 4 briefs up the warning to once every minute and gives instruction
on how to disable it.

Patch 5 adds a "neg-dentry-enforce" sysctl parameter which can be
dynamically enabled at run time to enforce the negative dentry limit
by killing excess newly created negative dentires right after use,
if necessary.

Patch 6 makes the negative dentry limiting code a user configurable
option so that it can be configured out, if desired.

With a 4.18 based kernel and a simple microbenchmark to measure dentry
lookup and creation rates, the rates (average on 3 runs) after initial
boot on a 2-socket 24-core 48-thread 128G memory system with and without
the patch were as follows:

  Metric               w/o patch   limit=0  limit=1  limit=1,enforce
  ------               ---------   -------  -------  ---------------
  +ve dentry lookup      672313     679720   676250      676071
  -ve dentry lookup     1547694    1555210  1542731     1559395
  -ve dentry creation    696427     700975   697713      693494

For the lookup and creation rates, there wasn't any signifcant difference
with or without the patch. It could be hard to compare the figures as
they were from different kernels and other factors like code layout
could have an impact.

When the limit was enabled, a very slight performance drop (0.5%-0.8%)
was observed.

The negative dentry creation test created 10 millions unique negative
dentries. With a setting of neg-dentry-limit=1, the warning threshold
was about 339020.  So most of negative dentries were created with the
limit exceeded.  The performance drop was only about 0.5% which was not
much. Turning on the enforce option to kill excess negative dentries
dropped the performance by a further 0.6% (1.1% in total).

I had also run other microbenchmarks, but I didn't observe any changes
in performance that were not in the run-to-run variation range for
those benchmarks.

Waiman Long (6):
  fs/dcache: Track & report number of negative dentries
  fs/dcache: Add negative dentries to LRU head initially
  fs/dcache: Add sysctl parameter neg-dentry-limit as a soft limit on
    negative dentries
  fs/dcache: Print negative dentry warning every min until turned off by
    user
  fs/dcache: Allow optional enforcement of negative dentry limit
  fs/dcache: Allow deconfiguration of negative dentry code to reduce
    kernel size

 Documentation/sysctl/fs.txt |  40 +++++-
 fs/Kconfig                  |  10 ++
 fs/dcache.c                 | 310 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/dcache.h      |  17 ++-
 include/linux/list_lru.h    |  17 +++
 kernel/sysctl.c             |  22 ++++
 mm/list_lru.c               |  19 ++-
 7 files changed, 421 insertions(+), 14 deletions(-)

-- 
1.8.3.1
