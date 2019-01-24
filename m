Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 216EF8E0097
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 16:15:42 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id p4so4789989pgj.21
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 13:15:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3sor32781977pli.15.2019.01.24.13.15.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 13:15:40 -0800 (PST)
From: Suren Baghdasaryan <surenb@google.com>
Subject: [PATCH v3 0/5] psi: pressure stall monitors v3
Date: Thu, 24 Jan 2019 13:15:13 -0800
Message-Id: <20190124211518.244221-1-surenb@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com, Suren Baghdasaryan <surenb@google.com>

This is respin of:
  https://lwn.net/ml/linux-kernel/20190110220718.261134-1-surenb@google.com/

Android is adopting psi to detect and remedy memory pressure that
results in stuttering and decreased responsiveness on mobile devices.

Psi gives us the stall information, but because we're dealing with
latencies in the millisecond range, periodically reading the pressure
files to detect stalls in a timely fashion is not feasible. Psi also
doesn't aggregate its averages at a high-enough frequency right now.

This patch series extends the psi interface such that users can
configure sensitive latency thresholds and use poll() and friends to
be notified when these are breached.

As high-frequency aggregation is costly, it implements an aggregation
method that is optimized for fast, short-interval averaging, and makes
the aggregation frequency adaptive, such that high-frequency updates
only happen while monitored stall events are actively occurring.

With these patches applied, Android can monitor for, and ward off,
mounting memory shortages before they cause problems for the user.
For example, using memory stall monitors in userspace low memory
killer daemon (lmkd) we can detect mounting pressure and kill less
important processes before device becomes visibly sluggish. In our
memory stress testing psi memory monitors produce roughly 10x less
false positives compared to vmpressure signals. Having ability to
specify multiple triggers for the same psi metric allows other parts
of Android framework to monitor memory state of the device and act
accordingly.

The new interface is straight-forward. The user opens one of the
pressure files for writing and writes a trigger description into the
file descriptor that defines the stall state - some or full, and the
maximum stall time over a given window of time. E.g.:

        /* Signal when stall time exceeds 100ms of a 1s window */
        char trigger[] = "full 100000 1000000"
        fd = open("/proc/pressure/memory")
        write(fd, trigger, sizeof(trigger))
        while (poll() >= 0) {
                ...
        };
        close(fd);

When the monitored stall state is entered, psi adapts its aggregation
frequency according to what the configured time window requires in
order to emit event signals in a timely fashion. Once the stalling
subsides, aggregation reverts back to normal.

The trigger is associated with the open file descriptor. To stop
monitoring, the user only needs to close the file descriptor and the
trigger is discarded.

Patches 1-4 prepare the psi code for polling support. Patch 5
implements the adaptive polling logic, the pressure growth detection
optimized for short intervals, and hooks up write() and poll() on the
pressure files.

The patches were developed in collaboration with Johannes Weiner.

The patches are based on 4.20-rc7.

Johannes Weiner (2):
  fs: kernfs: add poll file operation
  kernel: cgroup: add poll file operation

Suren Baghdasaryan (3):
  psi: introduce state_mask to represent stalled psi states
  psi: rename psi fields in preparation for psi trigger addition
  psi: introduce psi monitor

 Documentation/accounting/psi.txt | 104 ++++++
 fs/kernfs/file.c                 |  31 +-
 include/linux/cgroup-defs.h      |   4 +
 include/linux/kernfs.h           |   6 +
 include/linux/psi.h              |  10 +
 include/linux/psi_types.h        |  83 ++++-
 kernel/cgroup/cgroup.c           | 119 +++++-
 kernel/sched/psi.c               | 605 ++++++++++++++++++++++++++++---
 8 files changed, 891 insertions(+), 71 deletions(-)

Changes in v3:
- Added smp_mb in the slowpath, as per Peter
- Changed psi_group.polling flag to atomic_t, as per Peter
- Added a comment in the hotpath about implicit smp_wmb in the
chmxchg, as per Johannes
- Minimized line-breaks wherever possible, as per Peter

-- 
2.20.1.321.g9e740568ce-goog
