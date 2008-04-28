Message-ID: <4815E932.1040903@cybernetics.com>
Date: Mon, 28 Apr 2008 11:11:46 -0400
From: Tony Battersby <tonyb@cybernetics.com>
MIME-Version: 1.0
Subject: 2.6.24 regression: deadlock on coredump of big process
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Here is a program that can deadlock any kernel from 2.6.24-rc1 to
current (2.6.25-git11).  The deadlock happens due to oom during a
coredump of a large process with multiple threads.

git-bisect reveals the following patch as the culprit:

commit 557ed1fa2620dc119adb86b34c614e152a629a80
Author: Nick Piggin <npiggin@suse.de>
Date:   Tue Oct 16 01:24:40 2007 -0700

    remove ZERO_PAGE

    The commit b5810039a54e5babf428e9a1e89fc1940fabff11 contains the note

      A last caveat: the ZERO_PAGE is now refcounted and managed with rmap
      (and thus mapcounted and count towards shared rss).  These writes to
      the struct page could cause excessive cacheline bouncing on big
      systems.  There are a number of ways this could be addressed if it is
      an issue.

    And indeed this cacheline bouncing has shown up on large SGI systems.
    There was a situation where an Altix system was essentially livelocked
    tearing down ZERO_PAGE pagetables when an HPC app aborted during startup.
    This situation can be avoided in userspace, but it does highlight the
    potential scalability problem with refcounting ZERO_PAGE, and corner
    cases where it can really hurt (we don't want the system to livelock!).

    There are several broad ways to fix this problem:
    1. add back some special casing to avoid refcounting ZERO_PAGE
    2. per-node or per-cpu ZERO_PAGES
    3. remove the ZERO_PAGE completely

    I will argue for 3. The others should also fix the problem, but they
    result in more complex code than does 3, with little or no real benefit
    that I can see.

    Why? Inserting a ZERO_PAGE for anonymous read faults appears to be a
    false optimisation: if an application is performance critical, it would
    not be doing many read faults of new memory, or at least it could be
    expected to write to that memory soon afterwards. If cache or memory use
    is critical, it should not be working with a significant number of
    ZERO_PAGEs anyway (a more compact representation of zeroes should be
    used).

    As a sanity check -- mesuring on my desktop system, there are never many
    mappings to the ZERO_PAGE (eg. 2 or 3), thus memory usage here should not
    increase much without it.

    When running a make -j4 kernel compile on my dual core system, there are
    about 1,000 mappings to the ZERO_PAGE created per second, but about 1,000
    ZERO_PAGE COW faults per second (less than 1 ZERO_PAGE mapping per second
    is torn down without being COWed). So removing ZERO_PAGE will save 1,000
    page faults per second when running kbuild, while keeping it only saves
    less than 1 page clearing operation per second. 1 page clear is cheaper
    than a thousand faults, presumably, so there isn't an obvious loss.

    Neither the logical argument nor these basic tests give a guarantee of no
    regressions. However, this is a reasonable opportunity to try to remove
    the ZERO_PAGE from the pagefault path. If it is found to cause regressions,
    we can reintroduce it and just avoid refcounting it.

    The /dev/zero ZERO_PAGE usage and TLB tricks also get nuked.  I don't see
    much use to them except on benchmarks.  All other users of ZERO_PAGE are
    converted just to use ZERO_PAGE(0) for simplicity. We can look at
    replacing them all and maybe ripping out ZERO_PAGE completely when we are
    more satisfied with this solution.

    Signed-off-by: Nick Piggin <npiggin@suse.de>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus "snif" Torvalds <torvalds@linux-foundation.org>


I have verified that 2.6.24.5 with the above patch reverted coredumps
successfully instead of deadlocking.  The patch doesn't revert cleanly
on 2.6.25, so I didn't test that.

Before finding the above patch with git-bisect, I tested Daniel
Phillips' bio throttling patch
(http://zumastor.googlecode.com/svn/trunk/ddsnap/patches/2.6.24.2/bio.throttle.patch),
but it didn't prevent the deadlock.

I am testing on a simple 32-bit x86 system with Pentium 4 CPU, 256 MB
DRAM, a IDE hard drive, and an ext3 filesystem.  The software is a bare-
bones embedded environment; I am not running X, device-mapper, RAID, or
anything fancy.  I am not using any network file systems.  The system
has no swap space, and in fact swap support is disabled in the kernel
configuration.

When the kernel is deadlocked, I can switch VTs using Alt-<function key>.
When typing characters on the keyboard, the characters are printed to the
screen if I am on the VT that the core-dumping program was using, but
keypresses on other VTs do not show up.  The system is basically unusable.

If I let the kernel write the core file to disk directly (the default
behavior), then pressing Alt-SysRq-I to kill all tasks and free up some
memory will un-deadlock the coredump for a short while, but then it
deadlocks again.  If I pipe the core file to a program
(via /proc/sys/kernel/core_pattern) which doesn't write it to disk
(e.g. cat > /dev/null), then the kernel still deadlocks, but Alt-SysRq-I
kills the program and breaks the pipe, which un-deadlocks the system and
allows me to log back in.

Below is the program that triggers the deadlock; compile with
-D_REENTRANT -lpthread.

Tony Battersby
Cybernetics

---------------------------------------------------------------------

#include <sys/time.h>
#include <sys/resource.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>
#include <assert.h>

static void allow_coredump(void)
{
   struct rlimit rlim;

   rlim.rlim_cur = RLIM_INFINITY;
   rlim.rlim_max = RLIM_INFINITY;
   if (setrlimit(RLIMIT_CORE, &rlim))
      {
      perror("setrlimit");
      exit(EXIT_FAILURE);
      }
}

static void *thread_func(void *arg)
{
   for (;;)
      {
      sleep(100);
      }
   return NULL;
}

static void spawn_threads(int n_threads)
{
   pthread_attr_t thread_attr;
   int i;

   pthread_attr_init(&thread_attr);
   printf("spawn %d threads\n", n_threads);
   for (i = 0; i < n_threads; i++)
      {
      pthread_t thread;

      if (pthread_create(&thread, &thread_attr, &thread_func, NULL))
         {
         perror("pthread_create");
         exit(EXIT_FAILURE);
         }
      }
   sleep(1);
}

static size_t get_max_malloc_len(void)
{
   size_t min = 1;
   size_t max = ~((size_t) 0);

   do
      {
      size_t len = min + (max - min) / 2;
      void *ptr;

      ptr = malloc(len);
      if (ptr == NULL)
         {
         max = len - 1;
         }
      else
         {
         free(ptr);
         min = len + 1;
         }
      } while (min < max);

   return min;
}

static void malloc_all_but_x_mb(unsigned free_mb)
{
   size_t len = get_max_malloc_len();
   void *ptr;

   assert(len > free_mb << 20);
   len -= free_mb << 20;

   printf("allocate %u MB\n", len >> 20);
   ptr = malloc(len);
   assert(ptr != NULL);

   /* if this triggers the oom killer, then use a larger free_mb */
   memset(ptr, 0xab, len);
}

static void trigger_segfault(void)
{
   printf("trigger segfault\n");
   *(int *) 0 = 0;
}

int main(int argc, char *argv[])
{
   allow_coredump();
   malloc_all_but_x_mb(16);
   spawn_threads(10);
   trigger_segfault();
   return 0;
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
