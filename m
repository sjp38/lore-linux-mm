Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 18E276B00EF
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:57:05 -0400 (EDT)
Received: by werb14 with SMTP id b14so529563wer.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 07:57:03 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v1 0/6] reduce workqueue and timer noise
Date: Thu,  3 May 2012 17:55:56 +0300
Message-Id: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

Timers and work queues both provide a useful way to defer work 
for a later time or a different context. However, when the 
timer or work item runs, it interrupts the CPU it is running on.
This is good if it is doing useful work, but it turns out this 
is not always the case.

This patch set tries to locate and address code paths where work queues
items and timers are scheduled on CPUs where they have no useful work 
to do and adapet them to be more selective.

This includes:

- Introducing helper function to schedule work queue items on a subset
  of CPUs in the system.
- Use the helper function to schedule work items to attempt to drain
  LRUs only on CPUs where there are LRU pages.
- Stop running the per cpu work item that does per-cpu pages reclaim 
  and VM statistics on CPUs that did not have any VM activity for the 
  last second (time frame configurable) and re-start it when VM
  activity is detected.
- Fix a bug that prevented the timer code to to not program the 
  underlying HW timer to fire periodically when no future timer 
  event exists for a CPU

Changelog:

- The vmstat_update patch was changed to use a scapegoat CPU as
  suggested by Christoph Lameter when the patch was previously
  discussed in response to Frederic Weisbecker's adaptive tick 
  patch set.

Also included is a testing only patch, not intdented for mainline,
that turns the clock source watchdog into a config option which
I used while testing the timer code fix change.

The patch was boot tested on 32bit x86 in 8 way SMP and UP VMs.

For you reference, I keep a todo list for these and other noise sources 
at: https://github.com/gby/linux/wiki

The git branched can be fetched from the git repo at 
git@github.com:gby/linux.git on the reduce_workqueue_and_timers_noise_v1 
branch

Gilad Ben-Yossef (6):
  timer: make __next_timer_interrupt explicit about no future event
  workqueue: introduce schedule_on_each_cpu_mask
  workqueue: introduce schedule_on_each_cpu_cond
  mm: make lru_drain selective where it schedules work
  mm: make vmstat_update periodic run conditional
  x86: make clocksource watchdog configurable (not for mainline)

 arch/x86/Kconfig          |    9 +++-
 include/linux/vmstat.h    |    2 +-
 include/linux/workqueue.h |    4 ++
 kernel/time/clocksource.c |    2 +
 kernel/timer.c            |   31 ++++++++++-----
 kernel/workqueue.c        |   73 ++++++++++++++++++++++++++++++----
 mm/swap.c                 |   25 +++++++++++-
 mm/vmstat.c               |   95 ++++++++++++++++++++++++++++++++++++++-------
 8 files changed, 204 insertions(+), 37 deletions(-)

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Tejun Heo <tj@kernel.org>
CC: John Stultz <johnstul@us.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Mike Frysinger <vapier@gentoo.org>
CC: David Rientjes <rientjes@google.com>
CC: Hugh Dickins <hughd@google.com>
CC: Minchan Kim <minchan.kim@gmail.com>
CC: Konstantin Khlebnikov <khlebnikov@openvz.org>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Hakan Akkan <hakanakkan@gmail.com>
CC: Max Krasnyansky <maxk@qualcomm.com>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
