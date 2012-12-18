Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 9EAD86B002B
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 01:49:20 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id wy7so199008pbc.5
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 22:49:19 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v4 0/3] Support volatile for anonymous range
Date: Tue, 18 Dec 2012 15:47:51 +0900
Message-Id: <1355813274-571-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is still RFC because we need more input from user-space
people and discussion about interface/reclaim policy of volatile
pages and I want to expand this concept to tmpfs volatile range
if it is possbile without big performance drop of anonymous volatile
rnage (Let's define our term. anon volatile VS tmpfs volatile? John?)

NOTE: I didn't consider THP/KSM so for test, you should disable them.

I hope more inputs from user-space allocator people and test patch
with their allocator because it might need design change of arena
management for getting real vaule.

Changelog from v4

 * Add new system call mvolatile/mnovolatile
 * Add sigbus when user try to access volatile range
 * Rebased on v3.7
 * Applied bug fix from John Stultz, Thanks!

Changelog from v3

 * Removing madvise(addr, length, MADV_NOVOLATILE).
 * add vmstat about the number of discarded volatile pages
 * discard volatile pages without promotion in reclaim path

This is based on v3.7

- What's the mvolatile(addr, length)?

  It's a hint that user deliver to kernel so kernel can *discard*
  pages in a range anytime.

- What happens if user access page(ie, virtual address) discarded
  by kernel?

  The user can encounter SIGBUS.

- What should user do for avoding SIGBUS?
  He should call mnovolatie(addr, length) before accessing the range
  which was called by mvolatile.

- What happens if user access page(ie, virtual address) doesn't
  discarded by kernel?

  The user can see old data without page fault.

- What's different with madvise(DONTNEED)?

  System call semantic

  DONTNEED makes sure user always can see zero-fill pages after
  he calls madvise while mvolatile can see old data or encounter
  SIGBUS.

  Internal implementation

  The madvise(DONTNEED) should zap all mapped pages in range so
  overhead is increased linearly with the number of mapped pages.
  Even, if user access zapped pages as write mode, page fault +
  page allocation + memset should be happened.

  The mvolatile just marks the flag in a range(ie, VMA) instead of
  zapping all of pte in the vma so it doesn't touch ptes any more.

- What's the benefit compared to DONTNEED?

  1. The system call overhead is smaller because mvolatile just marks
     the flag to VMA instead of zapping all the page in a range so
     overhead should be very small.

  2. It has a chance to eliminate overheads (ex, zapping pte + page fault
     + page allocation + memset(PAGE_SIZE)) if memory pressure isn't
     severe.

  3. It has a potential to zap all ptes and free the pages if memory
     pressure is severe so reclaim overhead could be disappear - TODO

- Isn't there any drawback?

  Madvise(DONTNEED) doesn't need exclusive mmap_sem so concurrent page
  fault of other threads could be allowed. But m[no]volatile needs
  exclusive mmap_sem so other thread would be blocked if they try to
  access not-yet-mapped pages. That's why I design m[no]volatile
  overhead should be small as far as possible.

  It could suffer from max rss usage increasement because madvise(DONTNEED)
  deallocates pages instantly when the system call is issued while mvoatile
  delays it until memory pressure happens so if memory pressure is severe by
  max rss incresement, system would suffer. First of all, allocator needs
  some balance logic for that or kernel might handle it by zapping pages
  although user calls mvolatile if memory pressure is severe.
  The problem is how we know memory pressure is severe.
  One of solution is to see kswapd is active or not. Another solution is
  Anton's mempressure so allocator can handle it.

- What's for targetting?

  Firstly, user-space allocator like ptmalloc, tcmalloc or heap management
  of virtual machine like Dalvik. Also, it comes in handy for embedded
  which doesn't have swap device so they can't reclaim anonymous pages.
  By discarding instead of swapout, it could be used in the non-swap system.
  For it, we have to age anon lru list although we don't have swap because
  I don't want to discard volatile pages by top priority when memory pressure
  happens as volatile in this patch means "We don't need to swap out because
  user can handle the situation which data are disappear suddenly", NOT
  "They are useless so hurry up to reclaim them". So I want to apply same
  aging rule of nomal pages to them.

  Anonymous page background aging of non-swap system would be a trade-off
  for getting good feature. Even, we had done it two years ago until merge
  [1] and I believe gain of this patch will beat loss of anon lru aging's
  overead once all of allocator start to use madvise.
  (This patch doesn't include background aging in case of non-swap system
  but it's trivial if we decide)

  As another choice, we can zap the range like madvise(DONTNEED) when mvolatile
  is called if we don't have swap space.

- Stupid performance test
  I attach test program/script which are utter crap and I don't expect
  current smart allocator never have done it so we need more practical data
  with real allocator.

  KVM - 8 core, 2G

VOLATILE test
13.16user 7.58system 0:06.04elapsed 343%CPU (0avgtext+0avgdata 2624096maxresident)k
0inputs+0outputs (0major+164050minor)pagefaults 0swaps

DONTNEED test
23.30user 228.92system 0:33.10elapsed 762%CPU (0avgtext+0avgdata 213088maxresident)k
0inputs+0outputs (0major+16384210minor)pagefaults 0swaps

  x86-64 - 12 core, 2G

VOLATILE test
33.38user 0.44system 0:02.87elapsed 1178%CPU (0avgtext+0avgdata 3935008maxresident)k
0inputs+0outputs (0major+245989minor)pagefaults 0swaps

DONTNEED test
28.02user 41.25system 0:05.80elapsed 1192%CPU (0avgtext+0avgdata 387776maxresident)k

[1] 74e3f3c3, vmscan: prevent background aging of anon page in no swap system

Any comments are welcome!

Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Arun Sharma <asharma@fb.com>
Cc: sanjay@google.com
Cc: Paul Turner <pjt@google.com>
CC: David Rientjes <rientjes@google.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Minchan Kim (3):
  Introduce new system call mvolatile
  Discard volatile page
  add PGVOLATILE vmstat count

 arch/x86/syscalls/syscall_64.tbl |    3 +-
 include/linux/mm.h               |    1 +
 include/linux/mm_types.h         |    2 +
 include/linux/rmap.h             |    3 +
 include/linux/syscalls.h         |    2 +
 include/linux/vm_event_item.h    |    2 +-
 mm/Makefile                      |    4 +-
 mm/huge_memory.c                 |    9 +-
 mm/ksm.c                         |    3 +-
 mm/memory.c                      |    2 +
 mm/migrate.c                     |    6 +-
 mm/mlock.c                       |    5 +-
 mm/mmap.c                        |    2 +-
 mm/mvolatile.c                   |  396 ++++++++++++++++++++++++++++++++++++++
 mm/rmap.c                        |   97 +++++++++-
 mm/vmscan.c                      |    4 +
 mm/vmstat.c                      |    1 +
 17 files changed, 527 insertions(+), 15 deletions(-)
 create mode 100644 mm/mvolatile.c

================== 8< =============================

#define _GNU_SOURCE
#include <stdio.h>
#include <pthread.h>
#include <sched.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/syscall.h>

#define SYS_mvolatile 313
#define SYS_mnovolatile 314

#define ALLOC_SIZE (8 << 20)
#define MAP_SIZE  (ALLOC_SIZE * 10)
#define PAGE_SIZE (1 << 12)
#define RETRY 100

pthread_barrier_t barrier;
int mode;
#define VOLATILE_MODE 1

static int mvolatile(void *addr, size_t length)
{
	return syscall(SYS_mvolatile, addr, length);
}

static int mnovolatile(void *addr, size_t length)
{
	return syscall(SYS_mnovolatile, addr, length);
}

void *thread_entry(void *data)
{
	unsigned long i;
	cpu_set_t set;
	int cpu = *(int*)data;
	void *mmap_area;
	int retry = RETRY;

	CPU_ZERO(&set);
	CPU_SET(cpu, &set);
	sched_setaffinity(0, sizeof(set), &set);

	mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
	mmap_area = mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE,
					MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
	if (mmap_area == MAP_FAILED) {
		fprintf(stderr, "Fail to mmap [%d]\n", *(int*)data);
		exit(1);
	}

	pthread_barrier_wait(&barrier);

	while(retry--) {
		if (mode == VOLATILE_MODE) {
			mvolatile(mmap_area, MAP_SIZE);
			for (i = 0; i < MAP_SIZE; i+= ALLOC_SIZE) {
				mnovolatile(mmap_area + i, ALLOC_SIZE);
				memset(mmap_area + i, i, ALLOC_SIZE);
				mvolatile(mmap_area + i, ALLOC_SIZE);
			}
		} else {
			for (i = 0; i < MAP_SIZE; i += ALLOC_SIZE) {
				memset(mmap_area + i, i, ALLOC_SIZE);
				madvise(mmap_area + i, ALLOC_SIZE, MADV_DONTNEED);
			}
		}
	}
	return NULL;
}

int main(int argc, char *argv[])
{
	int i, nr_thread;
	int *data;

	if (argc < 3)
		return 1;

	nr_thread = atoi(argv[1]);
	mode = atoi(argv[2]);

	pthread_t *thread = malloc(sizeof(pthread_t) * nr_thread);
	data = malloc(sizeof(int) * nr_thread);
	pthread_barrier_init(&barrier, NULL, nr_thread);

	for (i = 0; i < nr_thread; i++) {
		data[i] = i;
		if (pthread_create(&thread[i], NULL, thread_entry, &data[i])) {
			perror("Fail to create thread\n");
			exit(1);
		}
	}

	for (i = 0; i < nr_thread; i++) {
		if (pthread_join(thread[i], NULL))
			perror("Fail to join thread\n");
		printf("[%d] thread done\n", i);
	}

	return 0;
}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
