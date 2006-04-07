Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel8.hp.com (Postfix) with ESMTP id A5DB036EC5
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:31:04 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp2.fc.hp.com (Postfix) with ESMTP id 7F28EAC7A
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:31:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 4C7BE138E39
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:31:04 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 22296-01 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:31:02 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id BC5EE138E38
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:31:01 -0600 (MDT)
Subject: [PATCH 2.6.17-rc1-mm1 0/9] AutoPage Migration - V0.2 - Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:32:26 -0400
Message-Id: <1144441946.5198.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a repost of the auto-migration series against 2.6.17-rc1-mm1.

I will post the rest of the series as responses to this message.

Lee
--------------------------------------------------------------------

AutoPage Migration - V0.2 - 0/9 Overview

V0.2 reworks the patches on 2.6.17-rc1-mm1, including Christoph's 
migration code reorg, moving much of the migration mechanism to 
mm/migrate.c  Also, some of the individual patches address comments
from Christoph and others on the V0.1 series.

----------------

We have seen some workloads suffer decreases in performance on NUMA
platforms when the Linux scheduler moves the tasks away from their initial
memory footprint.  Some users--e.g., HPC--are motivated by this to go to
great lengths to ensure that tasks start up and stay on specific nodes.
2.6.16+ includes memory migration mechanisms that will allow these users
to move memory along with their tasks--either manually or under control
of a load scheduling program--in response to changing demands on the
resourses.

Other users--e.g., "Enterprise" applications--would prefer that the system
just "do the right thing" in this respect.  One possible approach would
be to have the system automatically migrate a task's pages when it decides
to move the task to a different node from where it has executed in the
past.  In order to determine whether this approach would provide any 
benefit, we need working code to measure.

So, ....

This series of patches hooks up linux 2.6.16+ direct page migration to the
task scheduler. The effect is such that, when load balancing moves a task
to a cpu on a different node from where the task last executed, the task
is notified of this change using the same mechanism to notify a task of
pending signals.  When the task returns to user state, it attempts to
migrate, to the new node, any pages not already on that node in those of
the task's vm areas under control of default policy.

This behavior is disabled by default, but can be enabled by writing non-
zero to /sys/kernel/migration/auto_migrate_enable.  Furthermore, to prevent
thrashing, a second sysctl, auto_migrate_interval, has been implemented.
The load balancer will not move a task to a different node if it has move
to a new node in the last auto_migrate_interval seconds.  [User interface
is in seconds; internally it's in HZ.]  The idea is to give the task time
to ammortize the cost of the migration by giving it time to benefit from
local references to the page.

The controls, enable/disable and interval, will enable performance testing
of this mechanism to help decide whether it is worth inclusion.  Note: providing
these controls does not presuppose that these will be twiddled by human
administrators/users.  They may be useful to user space workload management
daemons or such...

The Patches:

Patches 01-06 apply to 2.6.17-rc1-mm1 with or without the previously
posted "migrate-on-fault" patches.   Most of my recent testing has
been done with this series layered on the "migrate-on-fault" patches.
So, some fixup may be necessary to apply the series directly to 
2.6.17-rc1-mm1 or beyond.
Patch 07 requires that the migrate-on-fault patches be applied first,
including the mbind/MPOL_MF_LAZY patch.

automigrate-01-prepare-mempolicy-for-automigrate.patch

	This patch adds the function auto_migrate_task_memory() to
	mempolicy.c.  In V0.2, this function sets up a call to
	migrate_to_node() with the appropriate [mempolicy internal]
	flags for auto-migration.  This addresses Christoph's comment
	about code duplication.

	This patch also modifies the vma_migratable() function, called
	from check_range(), to reject VMAs that don't have default
	policy when auto-migrating.

	Note that this mechanism uses non-aggressive migration--i.e.,
	MPOL_MF_MOVE rather than MPOL_MF_MOVE_ALL.  Therefore, it gives
	up rather easily.  E.g., anon pages still shared, copy-on-write,
	between ancestors and descendants will not be migrated.

automigrate-02-add-auto_migrate_enable-sysctl.patch

	This patch adds the infrastructure for the /sys/kernel/migration
	group as well as the auto_migrate_enable control.
	V02 of this series adds the control infrastructure to the new
	mm/migrate.c source file.

	TODO:  extract the basic control infrastructure for use by the
	migrate-on-fault series...

automigrate-03.0-check-notify-migrate-pending.patch

	The patch adds a static inline function to
	include/linux/auto-migrate.h for the schedule to check for
	internode migration and notify the task [by setting the
	TIF_NOTIFY_RESUME thread info flag], if the task is migrating
	to a new node and auto-migration is enabled.

	The header also includes the function check_migrate_pending()
	that the task will call when returning to user state when it notices
	TIF_NOTIFY_RESUME set.  Both of these functions become a null macro
	when MIGRATION is not configured.

automigrate-03.1-ia64-check-notify-migrate-pending.patch

	This patch adds the call to the check_migrate_pending() to the
	ia64 specific do_notify_resume_user() function.  Note that this
	is the same mechanism used to deliver signals and perfmon events
	to a task.  I have tested this patch on a 4-node, 16-cpu ia64 
	platform.

automigrate-03.2-x86_64-check-notify-migrate-pending.patch

	This patch adds the call to check_migrate_pending() to the x86_64
	specific do_notify_resume() function.  This is just an example
	for an arch other than ia64.  I have tested automigrate on a
	4-socket/dual-core Opteron platform.

	V0.2:  fixed auto-migrate.h header include

automigrate-04-hook-sched-internode-migration.patch

	This patch hooks the calls to check_internode_migration() into
	the scheduler [kernel/sched.c] in places where the scheduler
	sets a new cpu for the task--i.e., just before calls to
	set_task_cpu().  Because these are in migration paths, that are
	already relatively "heavy-weight", they don't add overhead to
	scheduler fast paths.  And, they become empty or constant
	macros when MIGRATION is not configured in.

	V0.2:  don't check/notify task of internode migration in 
	migrate_task() when migrating in exec() path.  Pointed out
	by Kamezawa Hiroyuki.

automigrate-05-add-internode-migration-hysteresis.patch

	This patch adds the auto_migrate_interval control to the
	/sys/kernel/migration group, and adds a function to the
	auto-migrate.h header--too_soon_for_internode_migration()--to
	check whether it's too soon for another internode migration.
	This function becomes a macro that evaluates to "false" [0],
	when MIGRATION is not configured.

	This check is added to try_to_wake_up() and can_migrate_task() to
	override internode migrations if the last one was less than
	auto_migrate_interval seconds [HZ] ago.

automigrate-06-max-mapcount-control.patch

	This patch adds an additional control:  migrate_max_mapcount.
	mempolicy.c:migrate_page_add() has been modified to allow
	pages with a mapcount <= this value to be migrated. The
	default of 1 results in the same behavior as without this
	patch.  Use of this patch will allow experimentation and
	measurement of the effect of different mapcount thresholds
	on workload performance.

automigrate-07-hook-to-migrate-on-fault.patch

	This patch, which requires the migrate-on-fault capability,
	hooks automigration up to migrate-on-fault, with an additional
	control--/sys/kernel/migration/auto_migrate_lazy--to enable
	it.

TESTING:

I have tested this patch on a 16-cpu/4-node/32GB HP rx8620 [ia64] platform
and a 4 socket/dual-core/8GB HP Proliant dl585 Opteron platform with
everyone's favorite benchmark [kernel builds].   Patch seems stable.
Performance results for Opteron reported below.

I have also tested on ia64 with the McAlpin Streams benchmark.  These
results were reported previously:

http://marc.theaimsgroup.com/?l=linux-mm&m=114237540231833&w=4

Kernel builds [after make mrproper+make defconfig]
on 2.6.16-mm2 on dl585.  Times are avg of 10 runs.
Entire kernel source likely held in page cache.

No auto-migrate patches:

	40.69 real  226.40 user  41.77 system

With auto-migration patches, auto_migrate disabled:

	40.52 real  227.21 user  42.19 system

With auto-migration patches, auto_migrate enabled,
direct [!lazy]:

	40.90 real  227.10 user  42.45 system

With patch; auto-migration + lazy enabled:

	41.43 real  228.74 user  43.97 system

As mentioned in previous posting of this series, the compiler
don't run long enough to amortize the cost of migrating the
pages.  But see the McAlpin Streams results linked above.
Also, the defconfig runs on x86_64 don't run all that long, 
anyway.  So, I tried allmodconfig builds.  The results are,
uh, interesting.  These are representative results from half
a dozen runs each.

no auto-migration patches:

	290 real  1740 user  344 system

	one run @ 316 real:  +26sec from typical

with patches; auto-migration disabled:

	287 real  1738 user  346 system

	basically the same as w/o patches.
	real and user slightly lower, system slightly higher.  

with patches;  auto-migration+lazy enabled:
	
	310s real  1800s user   386s system

	user and system times fairly consistent.
	did see 2 runs with real time +27sec from the typical runs,
	as I did with no patches.  System is running multiuser, so
	some daemon may jump in occasionally.

	In these runs, the cost of migrating pages really starts to
	impact the runtime.  Note that, on an Opteron, every
	inter-[phys]cpu task migration is an inter-node migration.
	I see LOTS more internode migrations and resulting triggering
	of page migrations in a kernel build on the Opteron platform
	than on the 16-cpu, 4-node ia64 platform--not that this is at
	all surprising.  E.g., from instrumented runs:


                               ia64        Opteron
inter-node task migrations     2109           4058
pages unmapped for migration   9898         163627
anon migration faults          3208          62518
attempt migrate misplaced page 3007          44973
actually migrate misplaced pg  3007          44968



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
