Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 023756B026B
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:34:30 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b185-v6so14543862qkg.19
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:34:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o37-v6si9013637qvh.216.2018.07.06.12.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 12:34:28 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Date: Fri,  6 Jul 2018 15:32:45 -0400
Message-Id: <1530905572-817-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Waiman Long <longman@redhat.com>

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

A rogue application can potentially create a large number of negative
dentries in the system consuming most of the memory available if it
is not under the direct control of a memory controller that enforce
kernel memory limit.

This patchset introduces changes to the dcache subsystem to track and
optionally limit the number of negative dentries allowed to be created by
background pruning of excess negative dentries or even kill it after use.
This capability will help to limit the amount of memory that can be
consumed by negative dentries.

Patch 1 tracks the number of negative dentries present in the LRU
lists and reports it in /proc/sys/fs/dentry-state.

Patch 2 adds a "neg-dentry-pc" sysctl parameter that can be used to to
specify a soft limit on the number of negative allowed as a percentage
of total system memory. This parameter is 0 by default which means no
negative dentry limiting will be performed.

Patch 3 enables automatic pruning of least recently used negative
dentries when the total number is close to the preset limit.

Patch 4 spreads the negative dentry pruning effort to multiple CPUs to
make it more fair.

Patch 5 moves the negative dentries to the head of the LRU after they
are initially created. They will be moved to the tail like the positive
dentries the second time they are accessed. This will make sure that
all those accssed-once negative dentries will be removed first when a
shrinker is running.

Patch 6 adds a "neg-dentry-enforce" sysctl parameter which can be
dynamically enabled at run time to enforce the negative dentry limit
by killing excess negative dentires right after use, if necessary.

Patch 7 makes the negative dentry tracking and limiting code a user
configurable option so that it can be configured out, if desired.

With a 4.18 based kernel, the positive & negative dentries lookup rates
(lookups per second) after initial boot on a 2-socket 24-core 48-thread
64GB memory system with and without the patch were as follows: `

  Metric                    w/o patch  neg_dentry_pc=0  neg_dentry_pc=1
  ------                    ---------  ---------------  ---------------
  Positive dentry lookup      584299       586749	   582670
  Negative dentry lookup     1422204      1439994	  1438440
  Negative dentry creation    643535       652194	   641841

For the lookup rate, there isn't any signifcant difference with or
without the patch or with a zero or non-zero value of neg_dentry_pc.

The negative dentry creation test created 10 millions unique negative
dentries. When neg_dentry_pc=1, the number of negative dentries exceeded
the limit and hence the shrinker was activated.

  dcache: Negative dentry: percpu limit = 54871, free pool = 658461

As the shrinker was running on the CPU doing the negative dentry
creation, there was a slight decrease of performance of about 1.5%
which was not that significant.

Running the AIM7 high-systime workload, the system had a jobs/min
rate of 300,868.

By reserving 48G of memory so that the system had effectively 16G of
memory, a negative dentry generator was used to deplete free memory with
neg_dentry_pc=0. The MemFree value dropped to as low as 130M before
bouncing up with memory shrinker activated. The negative dentry count
went up to about 75M. The AIM7 job rate dropped to as low as 167,562
when the memory shrinker was working. Even shutting the system could take
a while because of the need to free up all the allocated dentries first.

By setting both neg_dentry_pc and neg_dentry_enforce to 1, for example,
the negative dentry count never went higher than 800k when the negative
dentry generator was running. The AIM7 job rate was 297,994. There was
a bit of performance drop, but nothing significant.

Waiman Long (7):
  fs/dcache: Track & report number of negative dentries
  fs/dcache: Add sysctl parameter neg-dentry-pc as a soft limit on
    negative dentries
  fs/dcache: Enable automatic pruning of negative dentries
  fs/dcache: Spread negative dentry pruning across multiple CPUs
  fs/dcache: Add negative dentries to LRU head initially
  fs/dcache: Allow optional enforcement of negative dentry limit
  fs/dcache: Allow deconfiguration of negative dentry code to reduce
    kernel size

 Documentation/sysctl/fs.txt |  38 +++-
 fs/Kconfig                  |  10 +
 fs/dcache.c                 | 469 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/dcache.h      |  17 +-
 include/linux/list_lru.h    |  18 ++
 kernel/sysctl.c             |  23 +++
 mm/list_lru.c               |  23 ++-
 7 files changed, 583 insertions(+), 15 deletions(-)

-- 
1.8.3.1
