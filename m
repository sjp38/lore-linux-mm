Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id E630F6B0035
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 13:30:34 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ma3so1939094pbc.32
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 10:30:34 -0700 (PDT)
Received: from psmtp.com ([74.125.245.158])
        by mx.google.com with SMTP id gw3si10804475pac.56.2013.10.27.10.30.33
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 10:30:33 -0700 (PDT)
Received: by mail-ie0-f201.google.com with SMTP id u16so1110304iet.0
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 10:30:32 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 0/3] fix unsigned pcp adjustments
Date: Sun, 27 Oct 2013 10:30:14 -0700
Message-Id: <1382895017-19067-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

As of v3.11-9444-g3ea67d0 "memcg: add per cgroup writeback pages accounting"
memcg use of __this_cpu_add(counter, -nr_pages) leads to incorrect statistic
values because the negated nr_pages is not sign extended (counter is long,
nr_pages is unsigned int).  The memcg fix is __this_cpu_sub(counter, nr_pages).
But that doesn't simply work because __this_cpu_sub(counter, nr_pages) was
implemented as __this_cpu_add(counter, -nr_pages) which suffers the same
problem.  Example:
  unsigned int delta = 1
  preempt_disable()
  this_cpu_write(long_counter, 0)
  this_cpu_sub(long_counter, delta)
  preempt_enable()
    
Before this change long_counter on a 64 bit machine ends with value 0xffffffff,
rather than 0xffffffffffffffff.  This is because this_cpu_sub(pcp, delta) boils
down to:
  long_counter = 0 + 0xffffffff

v3.12-rc6 shows that only new memcg code is affected by this problem - the new
mem_cgroup_move_account_page_stat() is the only place where an unsigned
adjustment is used.  All other callers (e.g. shrink_dcache_sb) already use a
signed adjustment, so no problems before v3.12.  Though I did not audit the
stable kernel trees, so there could be something hiding in there.

Patch 1 creates a test module for percpu operations which demonstrates the
__this_cpu_sub() problems.  This patch is independent can be discarded if there
is no interest.

Patch 2 fixes __this_cpu_sub() to work with unsigned adjustments.

Patch 3 uses __this_cpu_sub() in memcg.

An alternative smaller solution is for memcg to use:
  __this_cpu_add(counter, -(int)nr_pages)
admitting that __this_cpu_add/sub() doesn't work with unsigned adjustments.  But
I felt like fixing the core services to prevent this in the future.

Changes from V1:
- more accurate patch titles, patch logs, and test module description now
  referring to per cpu operations rather than per cpu counters.
- move small test code update from patch 2 to patch 1 (where the test is
  introduced).

Greg Thelen (3):
  percpu: add test module for various percpu operations
  percpu: fix this_cpu_sub() subtrahend casting for unsigneds
  memcg: use __this_cpu_sub() to dec stats to avoid incorrect subtrahend
    casting

 arch/x86/include/asm/percpu.h |   3 +-
 include/linux/percpu.h        |   8 +--
 lib/Kconfig.debug             |   9 +++
 lib/Makefile                  |   2 +
 lib/percpu_test.c             | 138 ++++++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c               |   2 +-
 6 files changed, 156 insertions(+), 6 deletions(-)
 create mode 100644 lib/percpu_test.c

-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
