Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id E68036B0036
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 17:28:48 -0400 (EDT)
Received: by mail-qc0-f201.google.com with SMTP id o22so877103qcr.4
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 14:28:47 -0700 (PDT)
Subject: + mm-replace-hardcoded-3%-with-admin_reserve_pages-knob.patch added to -mm tree
From: akpm@linux-foundation.org
Date: Wed, 27 Mar 2013 14:28:47 -0700
Message-Id: <20130327212847.5ED6531C166@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org
Cc: agshew@gmail.com, linux-mm@kvack.org


The patch titled
     Subject: mm: replace hardcoded 3% with admin_reserve_pages knob
has been added to the -mm tree.  Its filename is
     mm-replace-hardcoded-3%-with-admin_reserve_pages-knob.patch

Before you just go and hit "reply", please:
   a) Consider who else should be cc'ed
   b) Prefer to cc a suitable mailing list as well
   c) Ideally: find the original patch on the mailing list and do a
      reply-to-all to that, adding suitable additional cc's

*** Remember to use Documentation/SubmitChecklist when testing your code ***

The -mm tree is included into linux-next and is updated
there every 3-4 working days

------------------------------------------------------
From: Andrew Shewmaker <agshew@gmail.com>
Subject: mm: replace hardcoded 3% with admin_reserve_pages knob

Add an admin_reserve_kbytes knob to allow admins to change the hardcoded
memory reserve to something other than 3%, which may be multiple gigabytes
on large memory systems.  Only about 8MB is necessary to enable recovery
in the default mode, and only a few hundred MB are required even when
overcommit is disabled.

This affects OVERCOMMIT_GUESS and OVERCOMMIT_NEVER.

admin_reserve_kbytes is initialized to min(3% free pages, 8MB)

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
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/sysctl/vm.txt |   30 ++++++++++++++++++++++++++++++
 kernel/sysctl.c             |    8 ++++++++
 mm/mmap.c                   |   30 ++++++++++++++++++++++++++----
 mm/nommu.c                  |   30 ++++++++++++++++++++++++++----
 4 files changed, 90 insertions(+), 8 deletions(-)

diff -puN Documentation/sysctl/vm.txt~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob
+++ a/Documentation/sysctl/vm.txt
@@ -18,6 +18,7 @@ files can be found in mm/swap.c.
 
 Currently, these files are in /proc/sys/vm:
 
+- admin_reserve_kbytes
 - block_dump
 - compact_memory
 - dirty_background_bytes
@@ -59,6 +60,35 @@ Currently, these files are in /proc/sys/
 
 ==============================================================
 
+admin_reserve_kbytes
+
+The amount of free memory in the system that should be reserved for users
+with the capability cap_sys_admin.
+
+admin_reserve_kbytes defaults to min(3% of free pages, 8MB)
+
+That should provide enough for the admin to log in and kill a process,
+if necessary, under the default overcommit 'guess' mode.
+
+Systems running under overcommit 'never' should increase this to account
+for the full Virtual Memory Size of programs used to recover. Otherwise,
+root may not be able to log in to recover the system.
+
+How do you calculate a minimum useful reserve?
+
+sshd or login + bash (or some other shell) + top (or ps, kill, etc.)
+
+For overcommit 'guess', we can sum resident set sizes (RSS).
+On x86_64 this is about 8MB.
+
+For overcommit 'never', we can take the max of their virtual sizes (VSZ)
+and add the sum of their RSS.
+On x86_64 this is about 128MB.
+
+Changing this takes effect whenever an application requests memory.
+
+==============================================================
+
 block_dump
 
 block_dump enables block I/O debugging when set to a nonzero value. More
diff -puN kernel/sysctl.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob kernel/sysctl.c
--- a/kernel/sysctl.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob
+++ a/kernel/sysctl.c
@@ -98,6 +98,7 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern unsigned long sysctl_user_reserve_kbytes;
+extern unsigned long sysctl_admin_reserve_kbytes;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1437,6 +1438,13 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+	{
+		.procname	= "admin_reserve_kbytes",
+		.data		= &sysctl_admin_reserve_kbytes,
+		.maxlen		= sizeof(sysctl_admin_reserve_kbytes),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
 	{ }
 };
 
diff -puN mm/mmap.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob mm/mmap.c
--- a/mm/mmap.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob
+++ a/mm/mmap.c
@@ -86,6 +86,7 @@ int sysctl_overcommit_memory __read_most
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
+unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
 /*
  * Make sure vm_committed_as in one cacheline and not cacheline shared with
  * other variables. It can be updated by several CPUs frequently.
@@ -165,10 +166,10 @@ int __vm_enough_memory(struct mm_struct
 			free -= totalreserve_pages;
 
 		/*
-		 * Leave the last 3% for root
+		 * Reserve some for root
 		 */
 		if (!cap_sys_admin)
-			free -= free / 32;
+			free -= sysctl_admin_reserve_kbytes  >> (PAGE_SHIFT - 10);
 
 		if (free > pages)
 			return 0;
@@ -179,10 +180,10 @@ int __vm_enough_memory(struct mm_struct
 	allowed = (totalram_pages - hugetlb_total_pages())
 	       	* sysctl_overcommit_ratio / 100;
 	/*
-	 * Leave the last 3% for root
+	 * Reserve some for root
 	 */
 	if (!cap_sys_admin)
-		allowed -= allowed / 32;
+		allowed -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
 	allowed += total_swap_pages;
 
 	/*
@@ -3119,3 +3120,24 @@ int __meminit init_user_reserve(void)
 	return 0;
 }
 module_init(init_user_reserve)
+
+/*
+ * Initialise sysctl_admin_reserve_kbytes.
+ *
+ * The purpose of sysctl_admin_reserve_kbytes is to allow the sys admin
+ * to log in and kill a memory hogging process.
+ *
+ * Systems with more than 256MB will reserve 8MB, enough to recover
+ * with sshd, bash, and top in OVERCOMMIT_GUESS. Smaller systems will
+ * only reserve 3% of free pages by default.
+ */
+int __meminit init_admin_reserve(void)
+{
+	unsigned long free_kbytes;
+
+	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+
+	sysctl_admin_reserve_kbytes = min(free_kbytes / 32, 1UL << 13);
+	return 0;
+}
+module_init(init_admin_reserve)
diff -puN mm/nommu.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob mm/nommu.c
--- a/mm/nommu.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob
+++ a/mm/nommu.c
@@ -65,6 +65,7 @@ int sysctl_overcommit_ratio = 50; /* def
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
+unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
 int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
@@ -1929,10 +1930,10 @@ int __vm_enough_memory(struct mm_struct
 			free -= totalreserve_pages;
 
 		/*
-		 * Leave the last 3% for root
+		 * Reserve some for root
 		 */
 		if (!cap_sys_admin)
-			free -= free / 32;
+			free -= sysctl_admin_reserve_kbytes  >> (PAGE_SHIFT - 10);
 
 		if (free > pages)
 			return 0;
@@ -1942,10 +1943,10 @@ int __vm_enough_memory(struct mm_struct
 
 	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
 	/*
-	 * Leave the last 3% for root
+	 * Reserve some 3% for root
 	 */
 	if (!cap_sys_admin)
-		allowed -= allowed / 32;
+		allowed -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
 	allowed += total_swap_pages;
 
 	/*
@@ -2136,3 +2137,24 @@ int __meminit init_user_reserve(void)
 	return 0;
 }
 module_init(init_user_reserve)
+
+/*
+ * Initialise sysctl_admin_reserve_kbytes.
+ *
+ * The purpose of sysctl_admin_reserve_kbytes is to allow the sys admin
+ * to log in and kill a memory hogging process.
+ *
+ * Systems with more than 256MB will reserve 8MB, enough to recover
+ * with sshd, bash, and top in OVERCOMMIT_GUESS. Smaller systems will
+ * only reserve 3% of free pages by default.
+ */
+int __meminit init_admin_reserve(void)
+{
+	unsigned long free_kbytes;
+
+	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+
+	sysctl_admin_reserve_kbytes = min(free_kbytes / 32, 1UL << 13);
+	return 0;
+}
+module_init(init_admin_reserve)
_

Patches currently in -mm which might be from agshew@gmail.com are

mm-limit-growth-of-3%-hardcoded-other-user-reserve.patch
mm-replace-hardcoded-3%-with-admin_reserve_pages-knob.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
