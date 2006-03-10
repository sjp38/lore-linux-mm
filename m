Received: from mailrelay01.cce.cpqcorp.net (compaqcce.compaq.com [16.47.68.171])
	by ccerelbas03.cce.hp.com (Postfix) with ESMTP id 1C5C034003
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:33:37 -0600 (CST)
Received: from anw.zk3.dec.com (alpha.zk3.dec.com [16.140.128.4])
	by mailrelay01.cce.cpqcorp.net (Postfix) with ESMTP id A6EDD52E6
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:33:36 -0600 (CST)
Subject: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:33:14 -0500
Message-Id: <1142019195.5204.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

AutoPage Migration - V0.1 - 0/8 Overview

We have seen some workloads suffer decreases in performance on NUMA
platforms when the Linux scheduler moves the tasks away from their initial
memory footprint.  Some users--e.g., HPC--are motivated by this to go to
great lengths to ensure that tasks start up and stay on specific nodes.
2.6.16 includes memory migration mechanisms that will allow these users
to move memory along with their tasks--either manually or under control
of a load scheduling program--in response to changing demands on the
resources.

Other users--e.g., "Enterprise" applications--would prefer that the system
just "do the right thing" in this respect.  One possible approach would
be to have the system automatically migrate a tasks pages when it decides
to move the task to a different node from where it has executed in the
past.  One can debate [and we DO, at length] whether this would improve
the performance or not.  But, why not provide a patch and measure the
effects for various policies?  I.e., "show me the code."

So, ....

This series of patches hooks up linux 2.6.16 direct page migration to the
task scheduler. The effect is such that, when load balancing moves a task
to a cpu on a different node from where the task last executed, the task
is notified of this change using the same mechanism to notify a task of
pending signals.  When the task returns to user state, it attempts to
migrate any pages in those of its vm areas under control of default
policy that are not already on the new node to the new node.

This behavior is disabled by default, but can be enabled by writing non-
zero to /sys/kernel/migation/sched_migrate_memory.  [Could call this
"auto_migrate_memory" ?].  Furthermore, to prevent thrashing, a second
sysctl, sched_migrate_interval, has been implemented.  The load balancer
will not move a task to a different node if it has move to a new node
in the last sched_migrate_interval seconds.  [User interface is in
seconds; internally it's in HZ.]  The idea is to give the task time to
ammortize the cost of the migration by giving it time to benefit from
local references to the page.

The controls, enable/disable and interval, will enable performance testing
of this mechanism to help decide whether it is worth inclusion.

The Patches:

Patches 01-05 apply directly to 2.6.16-rc5-git11.  However, they should
also apply on top of the previously posted "migrate-on-fault" patches
with some fuzz/offsets.  Patch 06 requires that the migrate-on-fault
patches be applied first.

automigrate-01-add-migrate_task_memory.patch

	This patch add the function migrate_task_memory() to mempolicy.c
	to migrate vmas with default policy to the new node.  A second
	helper function, migrate_vma_to_node(), does the actual work of
	scanning the vma's address range [check_range] and invoking the
	existing [in 2.6.16-rc*] migrate_pages_to() function for a non-
	empty pagelist.

	Note that this mechanism uses non-aggressive migration--i.e.,
	MPOL_MF_MOVE rather than MPOL_MF_MOVE_ALL.  Therefore, it gives
	up rather easily.  E.g., anon pages still shared, copy-on-write,
	between ancestors and descendants will not be migrated.

automigrate-02-add-sched_migrate_memory-sysctl.patch

	This patch adds the infrastructure for the /sys/kernel/migration
	group as well as the sched_migrate_memory control.  Because we
	have no separate migration source file, I added this to
	mempolicy.c

automigrate-03.0-check-notify-migrate-pending.patch

	This patch adds a minimal <linux/auto-migrate.h> header to interface
	the scheduler to the auto-migration.  The header includes a static
	inline function for the schedule to check for internode migration
	and notify the task [by setting the TIF_NOTIFY_RESUME thread info
	flag], if the task is migrating to a new node and sched_migrate_memory
	is enabled.  The header also includes the function
	check_migrate_pending()
	that the task will call when returning to user state when it notices
	TIF_NOTIFY_RESUME set.  Both of these functions become a null macro
	when MIGRATION is not configured.

	However, note that in 2.6.16-rc*, one cannot deselect MIGRATION when
	building with NUMA configured.

automigrate-03.1-ia64-check-notify-migrate-pending.patch

	This patch adds the call to the check_migrate_pending() to the
	ia64 specific do_notify_resume_user() function.  Note that this
	is the same mechanism used to deliver signals and perfmon events
	to a task.

automigrate-03.2-x86_64-check-notify-migrate-pending.patch

	This patch adds the call to check_migrate_pending() to the x86_64
	specific do_notify_resume() function.  This is just an example
	for an arch other than ia64.  I haven't tested this yet.

automigrate-04-hook-sched-internode-migration.patch

	This patch hooks the calls to check_internode_migration() into
	the scheduler [kernel/sched.c] in places where the scheduler
	sets a new cpu for the task--i.e., just before calls to
	set_task_cpu().  Because these are in migration paths, that are
	already relatively "heavy-weight", they don't add overhead to
	scheduler fast paths.  And, they become empty or constant
	macros when MIGRATION is not configured in.

automigrate-05-add-internode-migration-hysteresis.patch

	This patch adds the sched_migrate_interval control to the
	/sys/kernel/migration group, and adds a function to the auto-migrate.h
	header--too_soon_for_internode_migration()--to check whether it's too
	soon for another internode migration.  This function becomes a macro
	that evaluates to "false" [0], when MIGRATION is not configured.

	This check is added to try_to_wake_up() and can_migrate_task() to
	override internode migrations if the last one was less than
	sched_migrate_interval seconds [HZ] ago.

BONUS PATCH:
automigrate-06-hook-to-migrate-on-fault.patch

	This patch, which requires the migrate-on-fault capability,
	hooks automigration up to migrate-on-fault, with an additional
	control--/sys/kernel/migration/sched_migrate_lazy--to enable
	it.

TESTING:

I have tested this patch on a 16-cpu/4-node HP rx8620 [ia64] platform with
everyone's favorite benchmark.

Kernel builds [after make mrproper+make defconfig]
on 2.6.16-rc5-git11 on 16-cpu/4 node/32GB HP rx8620 [ia64].
Times taken after a warm-up run.
Entire kernel source likely held in page cache.
This amplifies the effect of the patches because I
can't hide behind disk IO time.

No auto-migrate patches:

   88.20s real  1042.56s user    97.26s system
   88.92s real  1042.27s user    98.08s system
   88.40s real  1043.58s user    96.51s system
   91.45s real  1042.46s user    97.07s system
   93.29s real  1040.90s user    96.88s system
   90.15s real  1042.06s user    97.02s system
   90.45s real  1042.75s user    96.98s system
   90.77s real  1041.87s user    98.61s system
   90.21s real  1042.00s user    96.91s system
   88.50s real  1042.23s user    97.30s system
   -------------------------------------------
   90.03s real  1042.26s user    97.26s system - mean
    1.59           0.68           0.62         - std dev'n

With auto-migration patches, sched_migrate_memory disabled:

   88.98s real  1042.28s user    96.88s system
   88.75s real  1042.71s user    97.51s system
   89.42s real  1042.32s user    97.42s system
   87.83s real  1042.92s user    96.06s system
   92.47s real  1041.12s user    95.96s system
   89.14s real  1043.77s user    97.10s system
   88.11s real  1044.04s user    95.16s system
   91.74s real  1042.21s user    96.43s system
   89.36s real  1042.31s user    96.56s system
   88.55s real  1042.50s user    96.25s system
   -------------------------------------------
   89.43s real  1042.61s user    96.53s system - mean
    1.51           0.83           0.72         - std dev'n

With auto-migration patches, sched_migrate_memory enabled:

   90.62s real  1041.64s user   106.80s system
   89.94s real  1042.82s user   105.00s system
   91.34s real  1041.89s user   107.74s system
   90.12s real  1041.77s user   108.01s system
   90.93s real  1042.00s user   106.50s system
   93.97s real  1040.12s user   106.16s system
   90.65s real  1041.87s user   106.81s system
   90.53s real  1041.46s user   106.74s system
   91.84s real  1041.59s user   105.57s system
   90.28s real  1041.69s user   106.64s system
   -------------------------------------------
   91.02s real  1041.68s user   106.597 system - mean
    1.18           0.67           0.90         - std dev'n

Not stellar!.  Insignificant decrease in user time, but
~1% increase in run time  [from the unpatched case] and
~10% increase in system time.  In short, page migration,
and/or the scanning of vm areas for eligible pages, is
expensive and, for this job, the programs don't see
enough benefit from resulting locality to pay for cost
of migration.  Compilers just don't run long enough!

On one instrumented sample auto-direct run:
migrate_task_memory	called  3628 times = #internode migrations
migrate_vma_to_node	called 17137 times = 7.68 vma/task
migrate_page		called  3628 times = 1.62 pages/task

Very few "eligible" pages found in eligible vmas!  Perhaps
we're not being aggressive enough in attempts to migrate.

------------

Now, with the last patch, hooking automigration to
migrate-on-fault:

With auto-migrate + migrate-on-fault patches;
sched_migrate_memory disabled:

   88.02s real  1042.77s user    95.62s system
   91.56s real  1041.05s user    97.50s system
   90.41s real  1040.88s user    98.07s system
   90.41s real  1041.64s user    97.00s system
   89.82s real  1042.45s user    96.35s system
   88.28s real  1042.25s user    96.91s system
   91.51s real  1042.74s user    95.90s system
   93.34s real  1041.72s user    96.07s system
   89.09s real  1041.00s user    97.35s system
   89.44s real  1041.57s user    96.55s system
   -------------------------------------------
   90.19s real  1041.81s user    96.73s system - mean
    1.63           0.71           0.78         - std dev'n

With auto-migrate + migrate-on-fault patches;
sched_migrate_memory and sched_migrate_lazy enabled:

   91.72s real  1039.17s user   108.92s system
   91.02s real  1041.62s user   107.38s system
   91.21s real  1041.84s user   106.63s system
   93.24s real  1039.50s user   107.54s system
   92.64s real  1040.79s user   107.10s system
   92.52s real  1040.79s user   107.14s system
   91.85s real  1039.90s user   108.26s system
   90.58s real  1043.34s user   106.06s system
   92.30s real  1040.88s user   106.64s system
   94.25s real  1039.96s user   106.85s system
   -------------------------------------------
   92.13s real  1040.78 user    107.25 system - mean
    1.10           1.25           0.84        - std dev'n

Also, no win for kernel builds.  Again, slightly less
user time, but even more system and real time [~1sec each]
than the auto+direct run.

On one instrumented sample auto-lazy run:
migrate_task_memory	called  3777 times = #internode migrations
migrate_vma_to_node	called 28586 times = 7.56 vma/task
migrate_page		called  3886 times = 1.02 pages/task

Similar pattern, but a lot more "eligible" vmas; fewer
eligible pages.  More internode migrations.

TODO:

Next week, I'll try some longer running workloads that we know
have suffered from the scheduler moving them away from their
memory--e.g., McAlpin STREAMS.  Will report results when
available.

Maybe also test with more aggressive migration: '_MOVE_ALL.

I'll also move this to the -mm tree, once I port my trace
instrumentation from relayfs to sysfs.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
