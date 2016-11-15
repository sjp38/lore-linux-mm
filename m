Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39BAC6B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 21:37:05 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so89270114pgd.0
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 18:37:05 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0057.outbound.protection.outlook.com. [104.47.1.57])
        by mx.google.com with ESMTPS id 84si24582039pgg.198.2016.11.14.18.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Nov 2016 18:37:03 -0800 (PST)
Date: Tue, 15 Nov 2016 10:36:50 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v2 0/6] mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161115023646.GA7464@sha-win-210.asiapac.arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <20161114144429.4386e89a2761504bde340032@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
In-Reply-To: <20161114144429.4386e89a2761504bde340032@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

--AqsLC8rIMeq19msA
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline

On Mon, Nov 14, 2016 at 02:44:29PM -0800, Andrew Morton wrote:
> On Mon, 14 Nov 2016 15:07:33 +0800 Huang Shijie <shijie.huang@arm.com> wrote:
> I'm not really seeing a description of the actual bug.  I don't know
> what counter.sh is, there is no copy of counter.sh included in the
> changelogs and there is no description of the kernel error which
> counter.sh demonstrates.
> 
> So can you pleaser send to me a copy of counter.sh as well as a
> suitable description of the kernel error which counter.sh triggers?
> 
Sorry.

The counter.sh is just a wrapper for counter.c.
I append them in the attachment, you can also find them in:
  https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/counters.c
  https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/counters.sh

The description:
 The "counter.sh" test case will fail when we test the ARM64 32M gigantic page.
 The error shows below:

 ----------------------------------------------------------
        ...........................................
	LD_PRELOAD=libhugetlbfs.so shmoverride_unlinked (32M: 64):	PASS
	LD_PRELOAD=libhugetlbfs.so HUGETLB_SHM=yes shmoverride_unlinked (32M: 64):	PASS
	quota.sh (32M: 64):	PASS
	counters.sh (32M: 64):	FAIL mmap failed: Invalid argument
	********** TEST SUMMARY
	*                      32M           
	*                      32-bit 64-bit 
	*     Total testcases:     0     87   
	*             Skipped:     0      0   
	*                PASS:     0     86   
	*                FAIL:     0      1   
	*    Killed by signal:     0      0   
	*   Bad configuration:     0      0   
	*       Expected FAIL:     0      0   
	*     Unexpected PASS:     0      0   
	* Strange test result:     0      0   
	**********
 ----------------------------------------------------------

The failure is caused by:
 1) kernel fails to allocate a gigantic page for the surplus case.
    And the gather_surplus_pages() will return NULL in the end.

 2) The condition checks for some functions are wrong:
     return_unused_surplus_pages()
     nr_overcommit_hugepages_store()
     hugetlb_overcommit_handler()

  
Thanks
Huang Shijie

--AqsLC8rIMeq19msA
Content-Type: application/x-sh
Content-Disposition: attachment; filename="counters.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0A. wrapper-utils.sh=0A=0A# Huge page overcommit was not ava=
ilable until 2.6.24=0Acompare_kvers `uname -r` "2.6.24"=0Aif [ $? -eq 1 ]; =
then=0A	EXP_RC=3D$RC_FAIL=0Aelse=0A	EXP_RC=3D$RC_PASS=0Afi=0A=0Aexec_and_ch=
eck $EXP_RC counters "$@"=0A
--AqsLC8rIMeq19msA
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="counters.c"

/*
 * libhugetlbfs - Easy use of Linux hugepages
 * Copyright (C) 2005-2007 David Gibson & Adam Litke, IBM Corporation.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */
#include <sys/types.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <hugetlbfs.h>
#include "hugetests.h"

/*
 * Test Rationale:
 *
 * The hugetlb pool maintains 4 global counters to track pages as they
 * transition between various states.  Due to the complex relationships between
 * the counters, regressions are likely to occur in the future.  This test
 * performs operations that change the counters in known ways.  It emulates the
 * expected kernel behavior and compares the expected result to the actual
 * values after each operation.
 */

extern int errno;

/* Global test configuration */
#define DYNAMIC_SYSCTL "/proc/sys/vm/nr_overcommit_hugepages"
static long saved_nr_hugepages = -1;
static long saved_oc_hugepages = -1;
static long hpage_size;
static int private_resv;

/* State arrays for our mmaps */
#define NR_SLOTS	2
#define SL_SETUP	0
#define SL_TEST		1
static int map_fd[NR_SLOTS];
static char *map_addr[NR_SLOTS];
static unsigned long map_size[NR_SLOTS];
static unsigned int touched[NR_SLOTS];

/* Keep track of expected counter values */
static long prev_total;
static long prev_free;
static long prev_resv;
static long prev_surp;

#define min(a,b) (((a) < (b)) ? (a) : (b))
#define max(a,b) (((a) > (b)) ? (a) : (b))

/* Restore original nr_hugepages */
void cleanup(void) {
	if (hpage_size <= 0)
		return;
	if (saved_nr_hugepages >= 0)
		set_nr_hugepages(hpage_size, saved_nr_hugepages);
	if (saved_oc_hugepages >= 0)
		set_nr_overcommit_hugepages(hpage_size, saved_oc_hugepages);
}

void verify_dynamic_pool_support(void)
{
	saved_oc_hugepages = get_huge_page_counter(hpage_size, HUGEPAGES_OC);
	if (saved_oc_hugepages < 0)
		FAIL("Kernel appears to lack dynamic hugetlb pool support");
	set_nr_overcommit_hugepages(hpage_size, 10);
}

void bad_value(int line, const char *name, long expect, long actual)
{
	if (actual == -1)
		ERROR("%s not found in /proc/meminfo", name);
	else
		FAIL("Line %i: Bad %s: expected %li, actual %li",
			line, name, expect, actual);
}

void verify_counters(int line, long et, long ef, long er, long es)
{
	long t, f, r, s;

	t = get_huge_page_counter(hpage_size, HUGEPAGES_TOTAL);
	f = get_huge_page_counter(hpage_size, HUGEPAGES_FREE);
	r = get_huge_page_counter(hpage_size, HUGEPAGES_RSVD);
	s = get_huge_page_counter(hpage_size, HUGEPAGES_SURP);

	/* Invariant checks */
	if (t < 0 || f < 0 || r < 0 || s < 0)
		ERROR("Negative counter value");
	if (f < r)
		ERROR("HugePages_Free < HugePages_Rsvd");

	/* Check actual values against expected values */
	if (t != et)
		bad_value(line, "HugePages_Total", et, t);

	if (f != ef)
		bad_value(line, "HugePages_Free", ef, f);

	if (r != er)
		bad_value(line, "HugePages_Rsvd", er, r);

	if (s != es)
		bad_value(line, "HugePages_Surp", es, s);

	/* Everything's good.  Update counters */
	prev_total = t;
	prev_free = f;
	prev_resv = r;
	prev_surp = s;
}

/* Memory operations:
 * Each of these has a predefined effect on the counters
 */
#define persistent_huge_pages (et - es)
void _set_nr_hugepages(unsigned long count, int line)
{
	long min_size;
	long et, ef, er, es;

	if (set_nr_hugepages(hpage_size, count))
		FAIL("Cannot set nr_hugepages");

	/* The code below is based on set_max_huge_pages in mm/hugetlb.c */
	es = prev_surp;
	et = prev_total;
	ef = prev_free;
	er = prev_resv;

	/*
	 * Increase the pool size
	 * First take pages out of surplus state.  Then make up the
	 * remaining difference by allocating fresh huge pages.
	 */
	while (es && count > persistent_huge_pages)
		es--;
	while (count > persistent_huge_pages) {
		et++;
		ef++;
	}
	if (count >= persistent_huge_pages)
		goto out;

	/*
	 * Decrease the pool size
	 * First return free pages to the buddy allocator (being careful
	 * to keep enough around to satisfy reservations).  Then place
	 * pages into surplus state as needed so the pool will shrink
	 * to the desired size as pages become free.
	 */
	min_size = max(count, er + et - ef);
	while (min_size < persistent_huge_pages) {
		ef--;
		et--;
	}
	while (count < persistent_huge_pages) {
		es++;
	}

out:
	verify_counters(line, et, ef, er, es);
}
#undef set_nr_hugepages
#define set_nr_hugepages(c) _set_nr_hugepages(c, __LINE__)

void _map(int s, int hpages, int flags, int line)
{
	long et, ef, er, es;

	map_fd[s] = hugetlbfs_unlinked_fd();
	if (map_fd[s] < 0)
		CONFIG("Unable to open hugetlbfs file: %s", strerror(errno));
	map_size[s] = hpages * hpage_size;
	map_addr[s] = mmap(NULL, map_size[s], PROT_READ|PROT_WRITE, flags,
				map_fd[s], 0);
	if (map_addr[s] == MAP_FAILED)
		FAIL("mmap failed: %s", strerror(errno));
	touched[s] = 0;

	et = prev_total;
	ef = prev_free;
	er = prev_resv;
	es = prev_surp;

	/*
	 * When using MAP_SHARED, a reservation will be created to guarantee
	 * pages to the process.  If not enough pages are available to
	 * satisfy the reservation, surplus pages are added to the pool.
	 * NOTE: This code assumes that the whole mapping needs to be
	 * reserved and hence, will not work with partial reservations.
	 *
	 * If the kernel supports private reservations, then MAP_PRIVATE
	 * mappings behave like MAP_SHARED at mmap time.  Otherwise,
	 * no counter updates will occur.
	 */
	if ((flags & MAP_SHARED) || private_resv) {
		unsigned long shortfall = 0;
		if (hpages + prev_resv > prev_free)
			shortfall = hpages - prev_free + prev_resv;
		et += shortfall;
		ef = prev_free + shortfall;
		er = prev_resv + hpages;
		es = prev_surp + shortfall;
	}

	verify_counters(line, et, ef, er, es);
}
#define map(s, h, f) _map(s, h, f, __LINE__)

void _unmap(int s, int hpages, int flags, int line)
{
	long et, ef, er, es;
	unsigned long i;

	munmap(map_addr[s], map_size[s]);
	close(map_fd[s]);
	map_fd[s] = -1;
	map_addr[s] = NULL;
	map_size[s] = 0;

	et = prev_total;
	ef = prev_free;
	er = prev_resv;
	es = prev_surp;

	/*
	 * When a VMA is unmapped, the instantiated (touched) pages are
	 * freed.  If the pool is in a surplus state, pages are freed to the
	 * buddy allocator, otherwise they go back into the hugetlb pool.
	 * NOTE: This code assumes touched pages have only one user.
	 */
	for (i = 0; i < touched[s]; i++) {
		if (es) {
			et--;
			es--;
		} else
			ef++;
	}

	/*
	 * mmap may have created some surplus pages to accomodate a
	 * reservation.  If those pages were not touched, then they will
	 * not have been freed by the code above.  Free them here.
	 */
	if ((flags & MAP_SHARED) || private_resv) {
		int unused_surplus = min(hpages - touched[s], es);
		et -= unused_surplus;
		ef -= unused_surplus;
		er -= hpages - touched[s];
		es -= unused_surplus;
	}

	verify_counters(line, et, ef, er, es);
}
#define unmap(s, h, f) _unmap(s, h, f, __LINE__)

void _touch(int s, int hpages, int flags, int line)
{
	long et, ef, er, es;
	int nr;
	char *c;

	for (c = map_addr[s], nr = hpages;
			hpages && c < map_addr[s] + map_size[s];
			c += hpage_size, nr--)
		*c = (char) (nr % 2);
	/*
	 * Keep track of how many pages were touched since we can't easily
	 * detect that from user space.
	 * NOTE: Calling this function more than once for a mmap may yield
	 * results you don't expect.  Be careful :)
	 */
	touched[s] = max(touched[s], hpages);

	/*
	 * Shared (and private when supported) mappings and consume resv pages
	 * that were previously allocated. Also deduct them from the free count.
	 *
	 * Unreserved private mappings may need to allocate surplus pages to
	 * satisfy the fault.  The surplus pages become part of the pool
	 * which could elevate total, free, and surplus counts.  resv is
	 * unchanged but free must be decreased.
	 */
	if (flags & MAP_SHARED || private_resv) {
		et = prev_total;
		ef = prev_free - hpages;
		er = prev_resv - hpages;
		es = prev_surp;
	} else {
		if (hpages + prev_resv > prev_free)
			et = prev_total + (hpages - prev_free + prev_resv);
		else
			et = prev_total;
		er = prev_resv;
		es = prev_surp + et - prev_total;
		ef = prev_free - hpages + et - prev_total;
	}
	verify_counters(line, et, ef, er, es);
}
#define touch(s, h, f) _touch(s, h, f, __LINE__)

void run_test(char *desc, int base_nr)
{
	verbose_printf("%s...\n", desc);
	set_nr_hugepages(base_nr);

	/* untouched, shared mmap */
	map(SL_TEST, 1, MAP_SHARED);
	unmap(SL_TEST, 1, MAP_SHARED);

	/* untouched, private mmap */
	map(SL_TEST, 1, MAP_PRIVATE);
	unmap(SL_TEST, 1, MAP_PRIVATE);

	/* touched, shared mmap */
	map(SL_TEST, 1, MAP_SHARED);
	touch(SL_TEST, 1, MAP_SHARED);
	unmap(SL_TEST, 1, MAP_SHARED);

	/* touched, private mmap */
	map(SL_TEST, 1, MAP_PRIVATE);
	touch(SL_TEST, 1, MAP_PRIVATE);
	unmap(SL_TEST, 1, MAP_PRIVATE);

	/* Explicit resizing during outstanding surplus */
	/* Consume surplus when growing pool */
	map(SL_TEST, 2, MAP_SHARED);
	set_nr_hugepages(max(base_nr, 1));

	/* Add pages once surplus is consumed */
	set_nr_hugepages(max(base_nr, 3));

	/* Release free huge pages first */
	set_nr_hugepages(max(base_nr, 2));

	/* When shrinking beyond committed level, increase surplus */
	set_nr_hugepages(base_nr);

	/* Upon releasing the reservation, reduce surplus counts */
	unmap(SL_TEST, 2, MAP_SHARED);

	verbose_printf("OK.\n");
}

int main(int argc, char ** argv)
{
	int base_nr;

	test_init(argc, argv);
	hpage_size = check_hugepagesize();
	saved_nr_hugepages = get_huge_page_counter(hpage_size, HUGEPAGES_TOTAL);
	verify_dynamic_pool_support();
	check_must_be_root();

	if ((private_resv = kernel_has_private_reservations()) == -1)
		FAIL("kernel_has_private_reservations() failed\n");

	/*
	 * This test case should require a maximum of 3 huge pages.
	 * Run through the battery of tests multiple times, with an increasing
	 * base pool size.  This alters the circumstances under which surplus
	 * pages need to be allocated and increases the corner cases tested.
	 */
	for (base_nr = 0; base_nr <= 3; base_nr++) {
		verbose_printf("Base pool size: %i\n", base_nr);
		/* Run the tests with a clean slate */
		run_test("Clean", base_nr);

		/* Now with a pre-existing untouched, shared mmap */
		map(SL_SETUP, 1, MAP_SHARED);
		run_test("Untouched, shared", base_nr);
		unmap(SL_SETUP, 1, MAP_SHARED);

		/* Now with a pre-existing untouched, private mmap */
		map(SL_SETUP, 1, MAP_PRIVATE);
		run_test("Untouched, private", base_nr);
		unmap(SL_SETUP, 1, MAP_PRIVATE);

		/* Now with a pre-existing touched, shared mmap */
		map(SL_SETUP, 1, MAP_SHARED);
		touch(SL_SETUP, 1, MAP_SHARED);
		run_test("Touched, shared", base_nr);
		unmap(SL_SETUP, 1, MAP_SHARED);

		/* Now with a pre-existing touched, private mmap */
		map(SL_SETUP, 1, MAP_PRIVATE);
		touch(SL_SETUP, 1, MAP_PRIVATE);
		run_test("Touched, private", base_nr);
		unmap(SL_SETUP, 1, MAP_PRIVATE);
	}

	PASS();
}

--AqsLC8rIMeq19msA
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="libhugetlbfs.error.txt"

zero_filesize_segment (32M: 64):	PASS
test_root (32M: 64):	PASS
meminfo_nohuge (32M: 64):	PASS
gethugepagesize (32M: 64):	PASS
gethugepagesizes (32M: 64):	PASS
HUGETLB_VERBOSE=1 empty_mounts (32M: 64):	PASS
HUGETLB_VERBOSE=1 large_mounts (32M: 64):	PASS
find_path (32M: 64):	PASS
unlinked_fd (32M: 64):	PASS
readback (32M: 64):	PASS
truncate (32M: 64):	PASS
shared (32M: 64):	PASS
mprotect (32M: 64):	PASS
mlock (32M: 64):	PASS
misalign (32M: 64):	PASS
fallocate_basic.sh (32M: 64):	PASS
fallocate_align.sh (32M: 64):	PASS
ptrace-write-hugepage (32M: 64):	PASS
icache-hygiene (32M: 64):	PASS
slbpacaflush (32M: 64):	PASS (inconclusive)
straddle_4GB_static (32M: 64):	PASS
huge_at_4GB_normal_below_static (32M: 64):	PASS
huge_below_4GB_normal_above_static (32M: 64):	PASS
map_high_truncate_2 (32M: 64):	PASS
misaligned_offset (32M: 64):	PASS (inconclusive)
truncate_above_4GB (32M: 64):	PASS
brk_near_huge (32M: 64):	PASS
task-size-overrun (32M: 64):	PASS
stack_grow_into_huge (32M: 64):	PASS
corrupt-by-cow-opt (32M: 64):	PASS
noresv-preserve-resv-page (32M: 64):	PASS
noresv-regarded-as-resv (32M: 64):	PASS
readahead_reserve.sh (32M: 64):	PASS
madvise_reserve.sh (32M: 64):	PASS
fadvise_reserve.sh (32M: 64):	PASS
mremap-expand-slice-collision.sh (32M: 64):	PASS
mremap-fixed-normal-near-huge.sh (32M: 64):	PASS
mremap-fixed-huge-near-normal.sh (32M: 64):	PASS
set shmmax limit to 67108864
shm-perms (32M: 64):	PASS
private (32M: 64):	PASS
fork-cow (32M: 64):	PASS
direct (32M: 64):	PASS
malloc (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so HUGETLB_MORECORE=yes malloc (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so HUGETLB_RESTRICT_EXE=unknown:none HUGETLB_MORECORE=yes malloc (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so HUGETLB_RESTRICT_EXE=unknown:malloc HUGETLB_MORECORE=yes malloc (32M: 64):	PASS
malloc_manysmall (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so HUGETLB_MORECORE=yes malloc_manysmall (32M: 64):	PASS
heapshrink (32M: 64):	PASS
LD_PRELOAD=libheapshrink.so heapshrink (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so HUGETLB_MORECORE=yes heapshrink (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so libheapshrink.so HUGETLB_MORECORE=yes heapshrink (32M: 64):	PASS
LD_PRELOAD=libheapshrink.so HUGETLB_MORECORE_SHRINK=yes HUGETLB_MORECORE=yes heapshrink (32M: 64):	PASS (inconclusive)
LD_PRELOAD=libhugetlbfs.so libheapshrink.so HUGETLB_MORECORE_SHRINK=yes HUGETLB_MORECORE=yes heapshrink (32M: 64):	PASS
HUGETLB_VERBOSE=1 HUGETLB_MORECORE=yes heap-overflow (32M: 64):	PASS
HUGETLB_VERBOSE=0 linkhuge_nofd (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so HUGETLB_VERBOSE=0 linkhuge_nofd (32M: 64):	PASS
linkhuge (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so linkhuge (32M: 64):	PASS
linkhuge_rw (32M: 64):	PASS
HUGETLB_ELFMAP=R linkhuge_rw (32M: 64):	PASS
HUGETLB_ELFMAP=W linkhuge_rw (32M: 64):	PASS
HUGETLB_ELFMAP=RW linkhuge_rw (32M: 64):	PASS
HUGETLB_ELFMAP=no linkhuge_rw (32M: 64):	PASS
HUGETLB_ELFMAP= HUGETLB_MINIMAL_COPY=no linkhuge_rw (32M: 64):	PASS
HUGETLB_ELFMAP=W HUGETLB_MINIMAL_COPY=no linkhuge_rw (32M: 64):	PASS
HUGETLB_ELFMAP=RW HUGETLB_MINIMAL_COPY=no linkhuge_rw (32M: 64):	PASS
HUGETLB_SHARE=0 HUGETLB_ELFMAP=R linkhuge_rw (32M: 64):	PASS
HUGETLB_SHARE=1 HUGETLB_ELFMAP=R linkhuge_rw (32M: 64):	PASS
HUGETLB_SHARE=0 HUGETLB_ELFMAP=W linkhuge_rw (32M: 64):	PASS
HUGETLB_SHARE=1 HUGETLB_ELFMAP=W linkhuge_rw (32M: 64):	PASS
HUGETLB_SHARE=0 HUGETLB_ELFMAP=RW linkhuge_rw (32M: 64):	PASS
HUGETLB_SHARE=1 HUGETLB_ELFMAP=RW linkhuge_rw (32M: 64):	PASS
chunk-overcommit (32M: 64):	PASS
alloc-instantiate-race shared (32M: 64):	PASS
alloc-instantiate-race private (32M: 64):	PASS
truncate_reserve_wraparound (32M: 64):	PASS
truncate_sigbus_versus_oom (32M: 64):	PASS
get_huge_pages (32M: 64):	PASS
shmoverride_linked (32M: 64):	PASS
HUGETLB_SHM=yes shmoverride_linked (32M: 64):	PASS
shmoverride_linked_static (32M: 64):	PASS
HUGETLB_SHM=yes shmoverride_linked_static (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so shmoverride_unlinked (32M: 64):	PASS
LD_PRELOAD=libhugetlbfs.so HUGETLB_SHM=yes shmoverride_unlinked (32M: 64):	PASS
quota.sh (32M: 64):	PASS
counters.sh (32M: 64):	FAIL mmap failed: Invalid argument
********** TEST SUMMARY
*                      32M           
*                      32-bit 64-bit 
*     Total testcases:     0     87   
*             Skipped:     0      0   
*                PASS:     0     86   
*                FAIL:     0      1   
*    Killed by signal:     0      0   
*   Bad configuration:     0      0   
*       Expected FAIL:     0      0   
*     Unexpected PASS:     0      0   
* Strange test result:     0      0   
**********

--AqsLC8rIMeq19msA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
