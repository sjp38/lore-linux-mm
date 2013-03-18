Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A62976B0027
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 17:44:47 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id 3so961954pdj.28
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 14:44:46 -0700 (PDT)
Date: Mon, 18 Mar 2013 17:44:42 -0400
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH v6 1/2] mm: limit growth of 3% hardcoded other user reserve
Message-ID: <20130318214442.GA1441@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

Add user_reserve_kbytes knob.

Limit the growth of the memory reserved for other user
processes to min(3% current process size, user_reserve_pages).

user_reserve_pages defaults to min(3% free pages, 128MB)

I arrived at 128MB by taking the max VSZ of sshd, login,
bash, and top ... then adding the RSS of each.

This only affects OVERCOMMIT_NEVER mode.


Background

1. user reserve

__vm_enough_memory reserves a hardcoded 3% of the current process size
for other applications when overcommit is disabled. This was done so
that a user could recover if they launched a memory hogging process.
Without the reserve, a user would easily run into a message such as:

bash: fork: Cannot allocate memory

2. admin reserve

Additionally, a hardcoded 3% of free memory is reserved for root in
both overcommit 'guess' and 'never' modes. This was intended to prevent
a scenario where root-cant-log-in and perform recovery operations.

Note that this reserve shrinks, and doesn't guarantee a useful reserve.


Motivation

The two hardcoded memory reserves should be updated to account for
current memory sizes.

Also, the admin reserve would be more useful if it didn't shrink too much.

When the current code was originally written, 1GB was considered
"enterprise". Now the 3% reserve can grow to multiple GB on large
memory systems, and it only needs to be a few hundred MB at most to
enable a user or admin to recover a system with an unwanted memory
hogging process.

I've found that reducing these reserves is especially beneficial
for a specific type of application load:

 * single application system
 * one or few processes (e.g. one per core)
 * allocating all available memory
 * not initializing every page immediately
 * long running

I've run scientific clusters with this sort of load. A long running job
sometimes failed many hours (weeks of CPU time) into a calculation.
They weren't initializing all of their memory immediately, and they
weren't using calloc, so I put systems into overcommit 'never' mode.
These clusters run diskless and have no swap.

However, with the current reserves, a user wishing to allocate as much
memory as possible to one process may be prevented from using, for
example, almost 2GB out of 32GB.

The effect is less, but still significant when a user starts a job
with one process per core. I have repeatedly seen a set of processes
requesting the same amount of memory fail because one of them could
not allocate the amount of memory a user would expect to be able to
allocate. For example, Message Passing Interfce (MPI) processes, one
per core. And it is similar for other parallel programming frameworks.

Changing this reserve code will make the overcommit never mode more
useful by allowing applications to allocate nearly all of the
available memory.

Also, the new admin_reserve_kbytes will be safer than the current
behavior since the hardcoded 3% of available memory reserve can shrink
to something useless in the case where applications have grabbed all
available memory.


Risks

* "bash: fork: Cannot allocate memory"

  The downside of the first patch-- which creates a tunable user reserve
  that is only used in overcommit 'never' mode--is that an admin can set
  it so low that a user may not be able to kill their process, even if
  they already have a shell prompt.

  Of course, a user can get in the same predicament with the current 3%
  reserve--they just have to launch processes until 3% becomes negligible.

* root-cant-log-in problem

  The second patch, adding the tunable rootuser_reserve_pages, allows
  the admin to shoot themselves in the foot by setting it too small.
  They can easily get the system into a state where root-can't-log-in.

  However, the new admin_reserve_kbytes will be safer than the current
  behavior since the hardcoded 3% of available memory reserve can shrink
  to something useless in the case where applications have grabbed all
  available memory.


Alternatives

 * Memory cgroups provide a more flexible way to limit application memory.

   Not everyone wants to set up cgroups or deal with their overhead.

 * We could create a fourth overcommit mode which provides smaller reserves.

   The size of useful reserves may be drastically different depending
   on the whether the system is embedded or enterprise.

 * Force users to initialize all of their memory or use calloc.

   Some users don't want/expect the system to overcommit when they malloc.
   Overcommit 'never' mode is for this scenario, and it should work well.

The new user and admin reserve tunables are simple to use, with low
overhead compared to cgroups. The patches preserve current behavior where
3% of memory is less than 128MB, except that the admin reserve doesn't
shrink to an unusable size under pressure. The code allows admins to tune
for embedded and enterprise usage.


FAQ

 * How is the root-cant-login problem addressed?
   What happens if admin_reserve_pages is set to 0?

   Root is free to shoot themselves in the foot by setting
   admin_reserve_kbytes too low.

   On x86_64, the minimum useful reserve is:
     8MB for overcommit 'guess'
   128MB for overcommit 'never'

   admin_reserve_pages defaults to min(3% free memory, 8MB)

   So, anyone switching to 'never' mode needs to adjust
   admin_reserve_pages.

 * How do you calculate a minimum useful reserve?

   A user or the admin needs enough memory to login and perform
   recovery operations, which includes, at a minimum:

   sshd or login + bash (or some other shell) + top (or ps, kill, etc.)

   For overcommit 'guess', we can sum resident set sizes (RSS).
   On x86_64 this is about 8MB.

   For overcommit 'never', we can take the max of their virtual sizes (VSZ)
   and add the sum of their RSS.
   On x86_64 this is about 128MB.

 * What happens if user_reserve_pages is set to 0?

   Note, this only affects overcomitt 'never' mode.

   Then a user will be able to allocate all available memory minus
   admin_reserve_kbytes.

   However, they will easily see a message such as:

   "bash: fork: Cannot allocate memory"

   And they won't be able to recover/kill their application.
   The admin should be able to recover the system if
   admin_reserve_kbytes is set appropriately.

 * What's the difference between overcommit 'guess' and 'never'?

   "Guess" allows an allocation if there are enough free + reclaimable
   pages. It has a hardcoded 3% of free pages reserved for root.

   "Never" allows an allocation if there is enough swap + a configurable
   percentage (default is 50) of physical RAM. It has a hardcoded 3% of
   free pages reserved for root, like "Guess" mode. It also has a
   hardcoded 3% of the current process size reserved for additional
   applications.

 * Why is overcommit 'guess' not suitable even when an app eventually
   writes to every page? It takes free pages, file pages, available
   swap pages, reclaimable slab pages into consideration. In other words,
   these are all pages available, then why isn't overcommit suitable?

   Because it only looks at the present state of the system. It
   does not take into account the memory that other applications have
   malloced, but haven't initialized yet. It overcommits the system.


Test Summary

There was little change in behavior in the default overcommit 'guess' 
mode with swap enabled before and after the patch. This was expected.

Systems run most predictably (i.e. no oom kills) in overcommit 'never' 
mode with swap enabled. This also allowed the most memory to be allocated 
to a user application.

Overcommit 'guess' mode without swap is a bad idea. It is easy to
crash the system. None of the other tested combinations crashed.
This matches my experience on the Roadrunner supercomputer.

Without the tunable user reserve, a system in overcommit 'never' mode 
and without swap does not allow the admin to recover, although the 
admin can.

With the new tunable reserves, a system in overcommit 'never' mode 
and without swap can be configured to:

1. maximize user-allocatable memory, running close to the edge of
recoverability

2. maximize recoverability, sacrificing allocatable memory to 
ensure that a user cannot take down a system


Test Description

Fedora 18 VM - 4 x86_64 cores, 5725MB RAM, 4GB Swap

System is booted into multiuser console mode, with unnecessary services 
turned off. Caches were dropped before each test.

Hogs are user memtester processes that attempt to allocate all free memory
as reported by /proc/meminfo

In overcommit 'never' mode, memory_ratio=100


Test Results

3.9.0-rc1-mm1

Overcommit | Swap | Hogs | MB Got/Wanted | OOMs | User Recovery | Admin Recovery
----------   ----   ----   -------------   ----   -------------   --------------
guess        yes    1      5432/5432       no     yes             yes
guess        yes    4      5444/5444       1      yes             yes
guess        no     1      5302/5449       no     yes             yes
guess        no     4      -               crash  no              no

never        yes    1      5460/5460       1      yes             yes
never        yes    4      5460/5460       1      yes             yes
never        no     1      5218/5432       no     no              yes
never        no     4      5203/5448       no     no              yes

3.9.0-rc1-mm1-tunablereserves

User and Admin Recovery show their respective reserves, if applicable.

Overcommit | Swap | Hogs | MB Got/Wanted | OOMs | User Recovery | Admin Recovery
----------   ----   ----   -------------   ----   -------------   --------------
guess        yes    1      5419/5419       no     - yes           8MB yes
guess        yes    4      5436/5436       1      - yes           8MB yes
guess        no     1      5440/5440       *      - yes           8MB yes
guess        no     4      -               crash  - no            8MB no

* process would successfully mlock, then the oom killer would pick it

never        yes    1      5446/5446       no     10MB yes        20MB yes
never        yes    4      5456/5456       no     10MB yes        20MB yes
never        no     1      5387/5429       no     128MB no        8MB barely
never        no     1      5323/5428       no     226MB barely    8MB barely
never        no     1      5323/5428       no     226MB barely    8MB barely

never        no     1      5359/5448       no     10MB no         10MB barely

never        no     1      5323/5428       no     0MB no          10MB barely
never        no     1      5332/5428       no     0MB no          50MB yes
never        no     1      5293/5429       no     0MB no          90MB yes

never        no     1      5001/5427       no     230MB yes       338MB yes
never        no     4*     4998/5424       no     230MB yes       338MB yes

* more memtesters were launched, able to allocate approximately another 100MB

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

---

Patch Changelog

v6:
 * Rebased onto v3.9-rc1-mmotm-2013-03-07-15-45

 * Replace user_reserve_pages with user_reserve_kbytes

 * Replace admin_reserve_pages with admin_reserve_kbytes

 * Increase verbosity of patch changelog

 * Add background, motivation, risks, alternatives, and testing

 * Add Alan Cox's example of sparse arrays to the
   documentation of the 'always' overcommit mode

 * Add note in overcommit_memory documentation that
   user_reserve_kbytes affects 'never' mode

 * Improve wording of user_reserve_kbytes documentation

 * Clearly document risk of root-cant-log-in
   in admin_reserve_kbytes documentation

v5:
 * Change nontunable k in min(3% process size, k) into
   user_reserve_pages knob

 * user_reserve_pages defaults to min(3% free pages, 128MB)
   previous k=8MB wasn't enough for OVERCOMMIT_NEVER mode
   and 128MB worked when I tested it

 * 128MB from taking max VSZ of sshd, login, bash, and top
   and adding the RSS of each

 v5 discussion:
  * Request for more complete changelog with detailed motivation,
    problems, alternatives, and discussion. -Andrew Morton

  * How is the root-cant-login problem addressed?
  * What happens if user_reserve_pages is set to 0?
  * What happens if admin_reserve_pages is set to 0?
  * Clearly describe risks in documentation
    -Andrew Morton

    As long as  admin_reserve_pages is set to at least 8MB for
    OVERCOMMIT_GUESS or above 128MB for OVERCOMMIT_NEVER, I was able to
    log in as root and kill processes. The root-cant-log-in problem
    cannot be hit if user_reserve_pages is set to 0 because that
    reserve only exists in OVERCOMMIT_NEVER mode.

  * Exported interfaces which deal in "pages" are considered harmful.
    PAGE_SIZE can vary by a factor of 16 depending upon config (ie:
    architecture). The risk is that a setup script which works nicely on
    4k x86_64 will waste memory when executed on a 64k PAGE_SIZE powerpc
    box. A smart programmer will recognize this and will adapt the setting
    using getpagesize(2), but if we define these things in "bytes" rather
    than "pages" then dumb programmers can use it too.
    -Andrew Morton

v4:
 * Rebased onto v3.8-mmotm-2013-03-01-15-50

 * No longer assumes 4kb pages

 * Code duplicated for nommu

 v4 discussion:
  * "Please add changelog, otherwise it's for other guys to review."
    -Simon Jeons

    Sorry, I'll be sure to include one in the future. And it
    looks like I do need a v5 ... I think this needs to
    be tunable like the admin reserve. The user_reserve_pages default
    certainly needs to be higher since this reserve is only for
    OVERCOMMIT_NEVER mode and 8MB is too little to allow
    the user to recover. I was thinking of OVERCOMMIT_GUESS
    mode when I chose that size.

v3:
 * New patch summary because it wasn't unique
   New is "mm: limit growth of 3% hardcoded other user reserve"
   Old was "mm: tuning hardcoded reserve memory"

 * "bash: fork: Cannot allocate memory"

    First patch limits growth of other user reserve to
    min(3% process size, k) as Alan Cox suggested.

    I chose k=2000 pages to allow recovery with sshd or login, bash,
    and top or kill. Of course, memory will still be exhausted eventually.

    I had simply removed the reserve previously, but that caused forks
    to fail easily. This allows a user to recover similar to the
    simple 3% reserve, but allows a single process to allocate more
    memory.

  * root-cant-log-in

    Add an admin_reserve_pages knob to allow admins of large memory
    systems running with overcommit disabled to change the hardcoded
    memory reserve to something other than 3%.

    admin_reserve_pages is initialized to min(3% free pages, k) similar
    to what Alan suggested for the other user reserve.

    k=2000 pages should allow the admin to spawn new sshd, bash, and top
    to recover if necessary. This reserve doesn't shrink like the other
    user reserve.

v2:
 * Rebased onto v3.8-mmotm-2013-02-19-17-20

 * Motivation:

   On scientific clusters, systems are generally dedicated to one user.
   Also, overcommit is sometimes disabled in order to prevent a long
   running job from suddenly failing days or weeks into a calculation.
   In this case, a user wishing to allocate as much memory as possible
   to one process may be prevented from using, for example, around 7GB
   out of 128GB.

   The effect is less, but still significant when a user starts a job
   with one process per core. I have repeatedly seen a set of processes
   requesting the same amount of memory fail because one of them could
   not allocate the amount of memory a user would expect to be able to
   allocate.

 * The first patch only affects OVERCOMMIT_NEVER mode, entirely removing
   the 3% reserve for other user processes.

 * The second patch affects both OVERCOMMIT_GUESS and OVERCOMMIT_NEVER
   modes, replacing an additional hardcoded 3% reserve for the root user
   with a tunable knob, rootuser_reserve_pages.

 * rootuser_reserve_pages defaults to 1000

 v2 discussion:
  * Both these patches had the same title.  Please avoid this.
    Documentation/SubmittingPatches section 15 has all the details.

    Sorry. This will be fixed.

  * Documentation/vm/overcommit-accounting says that OVERCOMMIT_ALWAYS is
    "Appropriate for some scientific applications", but doesn't say why.
    You're running a scientific cluster but you're using OVERCOMMIT_NEVER,
    I think?  Is the documentation wrong?

    "Classic example is code using sparse arrays and just relying on the
    virtual memory consisting almost entirely of zero pages." -Alan Cox

    My users would run jobs that appeared to initialize correctly. However,
    they wouldn't write to every page they malloced (and they wouldn't use
    calloc), so I saw jobs failing well into a computation once the
    simulation tried to access a page and the kernel couldn't give it to them.

    I think Roadrunner (http://en.wikipedia.org/wiki/IBM_Roadrunner) was
    the first cluster I put into OVERCOMMIT_NEVER mode. Jobs with
    infeasible memory requirements fail early and the OOM killer
    gets triggered much less often than in guess mode. More often than not
    the OOM killer seemed to kill the wrong thing causing a subtle brokenness.
    Disabling overcommit worked so well during the stabilization and
    early user phases that we did the same with other clusters.

  * Do you mean OVERCOMMIT_NEVER is more suitable for scientific application
    than OVERCOMMIT_GUESS and OVERCOMMIT_ALWAYS? Or should depend on
    workload? Since your users would run jobs that wouldn't write to every
    page they malloced, so why OVERCOMMIT_GUESS is not more suitable for you?

    It depends on the workload. They eventually wrote to every page,
    but not early in the life of the process, so they thought they
    were fine until the simulation crashed.

  * Why overcommit guess is not suitable even they eventually wrote to every
    page? It takes free pages, file pages, available swap pages, reclaimable
    slab pages into consideration. In other words, these are all pages
    available, then why overcommit is not suitable?

    Because the check only looks at the present state of the system. It
    does not take into account the memory that other applications have
    malloced, but haven't initialized yet. It overcommits the system.

  * What's the root difference between overcommit guess and never?

    "Guess" allows an allocation if there are enough free + reclaimable
    pages. It has a hardcoded 3% of free pages reserved for root.

    "Never" allows an allocation if there is enough swap + a configurable
    percentage (default is 50) of physical RAM. It has a hardcoded 3% of
    free pages reserved for root, like "Guess" mode. It also has a
    hardcoded 3% of the current process size reserved for additional
    applications.

  * Should rootuser_reserve_pages be initialized more intelligently?

    rootuser_reserve_pages should scale the initial value according to
    the machine size in some fashion

    I suspect the tunable should nowdays be something related to min(3%,
    someconstant), at the time we did the 3% I think 1GB was an "enterprise
    system" ;) -Alan Cox

  * So what might be the downside for this change? root-cant-log-in?

    With just the first patch that eliminates the other user reserve, root
    still has a 3% of free pages reserve.

    The second patch, adding the tunable rootuser_reserve_pages, allows
    the admin to shoot themselves in the foot and easily get the system
    into a state where they root-can't-log-in.

    This new tunable will be safer than the current behavior since the
    hardcoded 3% reserve shrinks to something useless in the case where
    an application has grabbed all available memory with many processes.

  * "bash: fork: Cannot allocate memory"

    The downside of the first patch, which removes the "other" reserve
    (sorry about the confusing duplicated subject line), is that a user
    may not be able to kill their process, even if they have a shell prompt.
    When testing, I did sometimes get into spot where I attempted to execute
    kill, but got: "bash: fork: Cannot allocate memory". Of course, a
    user can get in the same predicament with the current 3% reserve--they
    just have to launch processes until 3% becomes negligible.

  * Have you actually tested for this scenario and observed the effects?

    "If there *are* observable risks and/or to preserve back-compatibility,
    I guess we could create a fourth overcommit mode which provides the
    headroom which you desire." -Andrew Morton

    When I resubmit the second patch, I'll test both guess and never
    overcommit modes to see what minimum initial values allow root to log in
    and kill a user's memory hogging process.

  * Should we be looking at removing root's 3% from OVERCOMMIT_GUESS
    as well?

    "The 3% reserve was added to the original code *because* users kept hitting
    problems where they couldn't recover." -Alan Cox

  * What is the minimum useful reserve?

    "As an estimate of a useful rootuser_reserve_pages, the rss+share size of
    sshd, bash, and top is about 16MB. Overcommit disabled mode would need
    closer to 360MB for the same processes. On a 128GB box 3% is 3.8GB, so
    the new tunable would still be a win." -Andrew Shewmaker

    "Sorry for my silly, why you mean share size is not consist in rss size?"
    -Ric Mason

    "For some reason I had it in my head that RSS was just the memory
    private to the process and that I needed to add memory shared for
    libraries. So yeah, it looks like 8MB, or 2000 pages should be
    enough of a reserve." -Andrew Shewmaker

v1:
 * Based on 3.8

 * Remove hardcoded 3% other user reserve in OVERCOMMIT_NEVER mode

 * __vm_enough_memory reserves a hardcoded 3% of free memory for other processes
   when overcommit is disabled. However, 3% is becoming excessive as memory sizes
   increase

 * Memory cgroups provide a more flexible way to limit application memory.

 * I've found that reducing this reserve is beneficial in the case where a system
   with overcommit disabled has one primary user that wants to allocate as much
   memory as possible with a just few processes.

 * An additional hardcoded 3% is reserved for root, both when overcommit is enabled
   and when it is disabled. I've made it tunable in private patches, and I plan on
   submitting some version of them, but I can't decide whether a ratio or a byte
   count would be more acceptable. What would people prefer see?
---
 Documentation/sysctl/vm.txt            | 20 +++++++++++++++++++
 Documentation/vm/overcommit-accounting |  8 +++++++-
 kernel/sysctl.c                        |  8 ++++++++
 mm/mmap.c                              | 35 +++++++++++++++++++++++++++++-----
 mm/nommu.c                             | 35 +++++++++++++++++++++++++++++-----
 5 files changed, 95 insertions(+), 11 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 21ad181..494402b 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -53,6 +53,7 @@ Currently, these files are in /proc/sys/vm:
 - percpu_pagelist_fraction
 - stat_interval
 - swappiness
+- user_reserve_kbytes
 - vfs_cache_pressure
 - zone_reclaim_mode
 
@@ -563,6 +564,7 @@ memory until it actually runs out.
 
 When this flag is 2, the kernel uses a "never overcommit"
 policy that attempts to prevent any overcommit of memory.
+Note that user_reserve_kbytes affects this policy.
 
 This feature can be very useful because there are a lot of
 programs that malloc() huge amounts of memory "just-in-case"
@@ -666,6 +668,24 @@ The default value is 60.
 
 ==============================================================
 
+- user_reserve_kbytes
+
+When overcommit_memory is set to 2, "never overommit" mode, reserve 
+min(3% of current process size, user_reserve_kbytes) of free memory. 
+This is intended to prevent a user from starting a single memory hogging 
+process, such that they cannot recover (kill the hog).
+
+user_reserve_kbytes defaults to min(3% of the current process size, 128MB).
+
+If this is reduced to zero, then the user will be allowed to allocate 
+all free memory with a single process, minus admin_reserve_kbytes.
+Any subsequent attempts to execute a command will result in
+"fork: Cannot allocate memory". 
+
+Changing this takes effect whenever an application requests memory.
+
+==============================================================
+
 vfs_cache_pressure
 ------------------
 
diff --git a/Documentation/vm/overcommit-accounting b/Documentation/vm/overcommit-accounting
index 706d7ed..7ec13fa 100644
--- a/Documentation/vm/overcommit-accounting
+++ b/Documentation/vm/overcommit-accounting
@@ -8,7 +8,9 @@ The Linux kernel supports the following overcommit handling modes
 		default.
 
 1	-	Always overcommit. Appropriate for some scientific
-		applications.
+		applications. Classic example is code using sparse arrays 
+		and just relying on the virtual memory consisting almost 
+		entirely of zero pages.
 
 2	-	Don't overcommit. The total address space commit
 		for the system is not permitted to exceed swap + a
@@ -18,6 +20,10 @@ The Linux kernel supports the following overcommit handling modes
 		pages but will receive errors on memory allocation as
 		appropriate.
 
+		Useful for applications that want to guarantee their 
+		memory allocations will be available in the future 
+		without having to initialize every page.
+
 The overcommit policy is set via the sysctl `vm.overcommit_memory'.
 
 The overcommit percentage is set via `vm.overcommit_ratio'.
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index afc1dc6..87df7d1 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -97,6 +97,7 @@
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern unsigned long sysctl_user_reserve_kbytes;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1430,6 +1431,13 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "user_reserve_kbytes",
+		.data		= &sysctl_user_reserve_kbytes,
+		.maxlen		= sizeof(sysctl_user_reserve_kbytes),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
 	{ }
 };
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 49dc7d5..79c4f7a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -33,6 +33,7 @@
 #include <linux/uprobes.h>
 #include <linux/rbtree_augmented.h>
 #include <linux/sched/sysctl.h>
+#include <linux/sysctl.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -84,6 +85,7 @@ EXPORT_SYMBOL(vm_get_page_prot);
 int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
+unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
 /*
  * Make sure vm_committed_as in one cacheline and not cacheline shared with
  * other variables. It can be updated by several CPUs frequently.
@@ -122,7 +124,7 @@ EXPORT_SYMBOL_GPL(vm_memory_committed);
  */
 int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 {
-	unsigned long free, allowed;
+	unsigned long free, allowed, reserve;
 
 	vm_acct_memory(pages);
 
@@ -183,10 +185,13 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		allowed -= allowed / 32;
 	allowed += total_swap_pages;
 
-	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
-	if (mm)
-		allowed -= mm->total_vm / 32;
+	/*
+ 	 * Don't let a single process grow so big a user can't recover
+         */
+	if (mm) {
+		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
+		allowed -= min(mm->total_vm / 32, reserve);
+	}
 
 	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;
@@ -3067,3 +3072,23 @@ void __init mmap_init(void)
 	ret = percpu_counter_init(&vm_committed_as, 0);
 	VM_BUG_ON(ret);
 }
+
+/*
+ * Initialise sysctl_user_reserve_kbytes.
+ *
+ * This is intended to prevent a user from starting a single memory hogging 
+ * process, such that they cannot recover (kill the hog) in OVERCOMMIT_NEVER mode.
+ *
+ * The default value is min(3% of free memory, 128MB) 
+ * 128MB is enough to recover with sshd/login, bash, and top/kill.
+ */
+int __meminit init_user_reserve(void)
+{
+	unsigned long free_kbytes;
+
+	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+
+	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
+	return 0;
+}
+module_init(init_user_reserve)
diff --git a/mm/nommu.c b/mm/nommu.c
index c9c18c1..724e460 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -30,6 +30,7 @@
 #include <linux/syscalls.h>
 #include <linux/audit.h>
 #include <linux/sched/sysctl.h>
+#include <linux/sysctl.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
@@ -63,6 +64,7 @@ int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
 int sysctl_overcommit_ratio = 50; /* default is 50% */
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
+unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
 int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
@@ -1883,7 +1885,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
  */
 int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 {
-	unsigned long free, allowed;
+	unsigned long free, allowed, reserve;
 
 	vm_acct_memory(pages);
 
@@ -1943,10 +1945,13 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		allowed -= allowed / 32;
 	allowed += total_swap_pages;
 
-	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
-	if (mm)
-		allowed -= mm->total_vm / 32;
+	/* 
+	 * Don't let a single process grow so big a user can't recover
+         */
+	if (mm) {
+		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
+		allowed -= min(mm->total_vm / 32, reserve);
+	}
 
 	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;
@@ -2108,3 +2113,23 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	up_write(&nommu_region_sem);
 	return 0;
 }
+
+/*
+ * Initialise sysctl_user_reserve_kbytes.
+ *
+ * This is intended to prevent a user from starting a single memory hogging 
+ * process, such that they cannot recover (kill the hog) in OVERCOMMIT_NEVER mode.
+ *
+ * The default value is min(3% of free memory, 128MB) 
+ * 128MB is enough to recover with sshd/login, bash, and top/kill.
+ */
+int __meminit init_user_reserve(void)
+{
+	unsigned long free_kbytes;
+
+	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+
+	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
+	return 0;
+}
+module_init(init_user_reserve)
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
