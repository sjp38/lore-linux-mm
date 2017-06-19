Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A71DC6B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:28:46 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d191so127783549pga.15
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:28:46 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u26si8857857pfa.258.2017.06.19.16.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:28:45 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 0/4] percpu: add basic stats and tracepoints to percpu allocator
Date: Mon, 19 Jun 2017 19:28:28 -0400
Message-ID: <20170619232832.27116-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Dennis Zhou <dennisz@fb.com>

There is limited visibility into the percpu memory allocator making it hard to
understand usage patterns. Without these concrete numbers, we are left to
conjecture about the correctness of percpu memory patterns and usage.
Additionally, there is no mechanism to review the correctness/efficiency of the
current implementation.

This patchset address the following:
- Adds basic statistics to reason about the number of allocations over the
  lifetime, allocation sizes, and fragmentation.
- Adds tracepoints to enable better debug capabilities as well as the ability
  to review allocation requests and corresponding decisions.

This patchiest contains the following four patches:
0001-percpu-add-missing-lockdep_assert_held-to-func-pcpu_.patch
0002-percpu-migrate-percpu-data-structures-to-internal-he.patch
0003-percpu-expose-statistics-about-percpu-memory-via-deb.patch
0004-percpu-add-tracepoint-support-for-percpu-memory.patch

0001 adds a missing lockdep_assert_held for pcpu_lock to improve consistency
and safety. 0002 prepares for the following patches by moving the definition of
data structures and exposes previously static variables. 0003 adds percpu
statistics via debugfs. 0004 adds tracepoints to key percpu events: chunk
creation/deletion and area allocation/free/failure.

This patchset is on top of linus#master 1132d5e.

diffstats below:

  percpu: add missing lockdep_assert_held to func pcpu_free_area
  percpu: migrate percpu data structures to internal header
  percpu: expose statistics about percpu memory via debugfs
  percpu: add tracepoint support for percpu memory

 include/trace/events/percpu.h | 125 ++++++++++++++++++++++++
 mm/Kconfig                    |   8 ++
 mm/Makefile                   |   1 +
 mm/percpu-internal.h          | 164 +++++++++++++++++++++++++++++++
 mm/percpu-km.c                |   6 ++
 mm/percpu-stats.c             | 222 ++++++++++++++++++++++++++++++++++++++++++
 mm/percpu-vm.c                |   7 ++
 mm/percpu.c                   |  53 +++++-----
 8 files changed, 563 insertions(+), 23 deletions(-)
 create mode 100644 include/trace/events/percpu.h
 create mode 100644 mm/percpu-internal.h
 create mode 100644 mm/percpu-stats.c

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
