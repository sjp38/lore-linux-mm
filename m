Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
References: <1142019195.5204.12.camel@localhost.localdomain>
	 <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 13 Mar 2006 12:27:36 -0500
Message-Id: <1142270857.5210.50.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2006-03-11 at 15:41 +0900, KAMEZAWA Hiroyuki wrote:
> Hi, a few comments.

Thanks!

> 
> On Fri, 10 Mar 2006 14:33:14 -0500
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> > Furthermore, to prevent thrashing, a second
> > sysctl, sched_migrate_interval, has been implemented.  The load balancer
> > will not move a task to a different node if it has move to a new node
> > in the last sched_migrate_interval seconds.  [User interface is in
> > seconds; internally it's in HZ.]  The idea is to give the task time to
> > ammortize the cost of the migration by giving it time to benefit from
> > local references to the page.
> I think this HZ should be automatically estimated by the kernel. not by user.

Well, perhaps, eventually...  When we have a feel for what the algorithm
should be.  Perhaps a single value, which might be different for
different platforms, would suffice. I know that for a similar
implementation in Tru64 Unix on Alpha, we settled on a constant value of
30seconds [my current default].  But that was a single architecture OS.
And, this patch series is still "experimental", so I wanted to be able
to measure the effect of this interval w/o having to reboot a new kernel
to change the value.  On my test platform, rebooting takes about 6x as
long as rebuilding the kernel :-(.

> 
> 
> > Kernel builds [after make mrproper+make defconfig]
> > on 2.6.16-rc5-git11 on 16-cpu/4 node/32GB HP rx8620 [ia64].
> > Times taken after a warm-up run.
> > Entire kernel source likely held in page cache.
> > This amplifies the effect of the patches because I
> > can't hide behind disk IO time.
> 
> It looks you added check_internode_migration() in migrate_task().
> migrate_task() is called by sched_migrate_task().
> And....sched_migrate_task() is called by sched_exec().
> (a process can be migrated when exec().)
> In this case, migrate_task_memory() just wastes time..., I think.

You're probably right about wasting time in the exec() case.
migrate_task() is also called from set_cpus_allowed() when changing a
task's cpu affinity.  In this case, I think we want to migrate memory to
follow the task if it moves to a new node.  So, I've added the patch
below to bypass the "check_internode_migration()" when migrate_task() is
called from sched_migrate_task().  

When I first looked at this, I didn't think calling migrate_task_memory
() in the exec case would add too much overhead.  It won't get called
until the task returns to user state in the context of the newly exec'd
image.  At that point, there shouldn't be many private/anon pages
already faulted into the task's pte's.  I agree that any such pages
should be on the correct node and therefore unmapping them, only to
fault the ptes back in on touch, is a waste of time.  However, I did
want to give the task a shot at pulling any "eligible" shared pages [see
answer to your question regarding shared pages below].

So here are the results for kernel builds on 2.6.16-rc6-git1 with and
without the patch below.  All runs have both the auto-migration and
migrate-on-fault patches installed.  I reran a few of each of the tests
posted earlier to establish a new baseline.  Again, this is on a 16-
cpu/4-node/32GB ia64 platform.  I should also mention that I build with
-j32 [2 x nr_cpus].

sched_migrate_memory disabled:

   88.01s real  1041.58s user    95.67s system
   88.45s real  1041.86s user    94.71s system
   88.02s real  1043.03s user    94.18s system
   90.36s real  1041.62s user    95.00s system
   89.59s real  1040.90s user    95.62s system
   -------------------------------------------
   88.89        1041.80          95.04

sched_migrate_memory enabled, lazy [migrate on fault] disabled:

   91.14s real  1040.60s user   104.53s system
   94.01s real  1038.49s user   105.66s system
   90.40s real  1039.60s user   105.70s system
   93.22s real  1039.69s user   105.09s system
   94.11s real  1039.20s user   105.66s system
   -------------------------------------------
   92.58        1039.52         105.33

sched_migrate_memory + sched_migrate_lazy enabled:

   91.53s real  1040.46s user   106.04s system
   93.45s real  1040.49s user   105.67s system
   92.01s real  1041.31s user   104.86s system
   93.65s real  1039.96s user   105.20s system
   91.40s real  1041.92s user   104.96s system
   -------------------------------------------
   92.41        1040.83         105.35

w/ nix memory migration on exec patch:
sched_migrate_memory + sched_migrate_lazy enabled:

   89.30s real  1041.45s user   105.60s system
   89.44s real  1042.53s user   105.24s system
   89.03s real  1043.35s user   104.09s system
   92.37s real  1039.92s user   107.62s system <---?
   93.42s real  1040.00s user   105.86s system
   -------------------------------------------
   90.71        1041.45         105.68
Real time is a little [not significantly] faster than w/o this patch.
But both the user and system times are a little higher.  I think that
the system time would have been better except for the one run with
noticably longer system time.

Same kernel as above with:
sched_migrate_memory + sched_migrate_lazy disabled:

   89.79s real  1041.97s user    96.12s system
   88.27s real  1042.74s user    95.26s system
   91.68s real  1042.17s user    95.94s system
   93.02s real  1040.41s user    96.48s system
   90.72s real  1042.51s user    95.32s system
   -------------------------------------------
   90.70        1041.96          95.82


I ran some instrumented runs, to see how many task/vma/page migrations
occur during the builds.  The numbers are "all over the map", even with
repeated runs on the same kernel.  However, bypassing the check for
internode migration that results in calling migrate_task_memory in the
exec path does seem to decrease the number of such calls:

        Test                     tasks     vmas   pages
16-rc5-git11+autodirect           2230    17137   3629
16-rc5-git11+autolazy             2973    22385   3109

16-rc6-git1+autolazy              2041    15981   7485

16-rc6-git1+autolazy/nixexec      1996    15587   8505
16-rc6-git1+autolazy/nixexec      1946    14927   3019
16-rc6-git1+autolazy/nixexec      2171    16758   8231

tasks = migrate_task_memory calls
vmas  = migrate_vma_to_node calls
pages = [buffer_]migrate_page calls

The first 2 lines are the numbers I reported in the automigration
overview post.  I only took a single measurement on rc6-git1 without the
patch below.  There happened to be a couple of hundred less calls to
migration_task_memory that in the rc5-git-11 cases.  When I added the
patch, 2 of the 3 runs I took [after rebuild/reboot] had less calls to
migrate_task_memory, and fewer calls to migrate_vma_to_node, as well.

Note:  out of all the runs above, I only saw 3 buffer_migrate_page
calls.  I suspect these are shared text/library pages that just happened
to be only mapped into caller's page table at time of scan.

> 
> BTW, what happens against shared pages ?

I have made no changes to the way that 2.6.16-rc* migration code handles
shared pages.  Note that migrate_task_memory()/migrate_vma_to_node()
calls check_range() with the flag MPOL_MF_MOVE.  This will select for
migration pages that are only mapped by the calling task--i.e., only in
the calling task's page tables.  This includes shared pages that are
only mapped by the calling task.  With the current migration code, we
have 2 flags:  '_MOVE and '_MOVE_ALL.  '_MOVE behaves as described
above; '_MOVE_ALL is more aggressive and migrates pages regardless of
the # of mappings.  Christoph says that's primarily for cpusets, but the
migrate_pages() sys call will also use 'MOVE_ALL when invoked as root.
I'm working on another patch to experiment with finer grain control over
this.  I'll add another [temporary ;-)] sysctl to specify the max # of
references to allow when selecting a page for migration.  Then, I'll
measure the effect on various workloads.  

In some of my testing, I've noticed that with the current '_MOVE
semantics, a lot of private, anon pages won't migrate because they're
shared "copy-on-write" between parents and [grand]children.  Perhaps a
threshold > 1 might be appropriate?  I'll post my findings when I have
them.

So, here an experimental patch to nix the check for internode migration
when migrating task on exec:

---------------------------
Bypass check for internode task migration when migrate_task()
is being called in the exec() path.  

I may fold this into the automigrate "hook sched migrate to 
memory migration" [6/8] patch if if proves beneficial.  
It seems like calling migrate_task_memory() on a migration that
occured because of an exec() is a waste of time.  However, it
does give the new task a chance to pull some nominally shared
pages [executable image or libraries] local to itself.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc6-git1/kernel/sched.c
===================================================================
--- linux-2.6.16-rc6-git1.orig/kernel/sched.c	2006-03-13 09:05:17.000000000 -0500
+++ linux-2.6.16-rc6-git1/kernel/sched.c	2006-03-13 09:52:48.000000000 -0500
@@ -865,7 +865,8 @@ typedef struct {
  * The task's runqueue lock must be held.
  * Returns true if you have to wait for migration thread.
  */
-static int migrate_task(task_t *p, int dest_cpu, migration_req_t *req)
+static int migrate_task(task_t *p, int dest_cpu, migration_req_t *req,
+			int execing)
 {
 	runqueue_t *rq = task_rq(p);
 
@@ -874,7 +875,8 @@ static int migrate_task(task_t *p, int d
 	 * it is sufficient to simply update the task's cpu field.
 	 */
 	if (!p->array && !task_running(rq, p)) {
-		check_internode_migration(p, dest_cpu);
+		if (!execing)
+			check_internode_migration(p, dest_cpu);
 		set_task_cpu(p, dest_cpu);
 		return 0;
 	}
@@ -1738,7 +1740,7 @@ static void sched_migrate_task(task_t *p
 		goto out;
 
 	/* force the process onto the specified CPU */
-	if (migrate_task(p, dest_cpu, &req)) {
+	if (migrate_task(p, dest_cpu, &req, 1)) {
 		/* Need to wait for migration thread (might exit: take ref). */
 		struct task_struct *mt = rq->migration_thread;
 		get_task_struct(mt);
@@ -4414,7 +4416,7 @@ int set_cpus_allowed(task_t *p, cpumask_
 	if (cpu_isset(task_cpu(p), new_mask))
 		goto out;
 
-	if (migrate_task(p, any_online_cpu(new_mask), &req)) {
+	if (migrate_task(p, any_online_cpu(new_mask), &req, 0)) {
 		/* Need help from migration thread: drop lock and wait. */
 		task_rq_unlock(rq, &flags);
 		wake_up_process(rq->migration_thread);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
