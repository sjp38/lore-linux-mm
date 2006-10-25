Date: Wed, 25 Oct 2006 17:08:06 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 2/3] hugetlb: fix prio_tree unit
Message-ID: <20061025070805.GA9628@localhost.localdomain>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com> <Pine.LNX.4.64.0610250331220.30678@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610250331220.30678@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 25, 2006 at 03:35:41AM +0100, Hugh Dickins wrote:
> hugetlb_vmtruncate_list was misconverted to prio_tree: its prio_tree is
> in units of PAGE_SIZE (PAGE_CACHE_SIZE) like any other, not HPAGE_SIZE
> (whereas its radix_tree is kept in units of HPAGE_SIZE, otherwise slots
> would be absurdly sparse).
> 
> At first I thought the error benign, just calling __unmap_hugepage_range
> on more vmas than necessary; but on 32-bit machines, when the prio_tree
> is searched correctly, it happens to ensure the v_offset calculation won't
> overflow.  As it stood, when truncating at or beyond 4GB, it was liable
> to discard pages COWed from lower offsets; or even to clear pmd entries
> of preceding vmas, triggering exit_mmap's BUG_ON(nr_ptes).

Hugh, I'd like to add a testcase to the libhugetlbfs testsuite which
will trigger this bug, but from the description above I'm not sure
exactly how to tickle it.  Can you give some more details of what
sequence of calls will cause the BUG_ON() to be called.

I've attached the skeleton test I have now, but I'm not sure if it's
even close to what's really required for this.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--W/nzBZO5zC0uMSeA
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="truncate_above_4GB.c"

/*
 * libhugetlbfs - Easy use of Linux hugepages
 * Copyright (C) 2005-2006 David Gibson & Adam Litke, IBM Corporation.
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
#define _LARGEFILE64_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <sys/mman.h>

#include <hugetlbfs.h>

#include "hugetests.h"

/*
 * Test rationale:
 *
 * At one stage, a misconversion of hugetlb_vmtruncate_list to a
 * prio_tree meant that on 32-bit machines, truncates at or above 4GB
 * could truncate lower pages, resulting in BUG_ON()s.
 */
#define RANDOM_CONSTANT	0x1234ABCD
#define FOURGIG ((off64_t)0x100000000ULL)

static void sigbus_handler_fail(int signum, siginfo_t *si, void *uc)
{
	FAIL("Unexpected SIGBUS");
}

static void sigbus_handler_pass(int signum, siginfo_t *si, void *uc)
{
	PASS();
}

int main(int argc, char *argv[])
{
	int hpage_size;
	int fd;
	void *p, *q;
	volatile unsigned int *pi, *qi;
	int err;
	struct sigaction sa_fail = {
		.sa_sigaction = sigbus_handler_fail,
		.sa_flags = SA_SIGINFO,
	};
	struct sigaction sa_pass = {
		.sa_sigaction = sigbus_handler_pass,
		.sa_flags = SA_SIGINFO,
	};

	test_init(argc, argv);

	hpage_size = gethugepagesize();
	if (hpage_size < 0)
		CONFIG("No hugepage kernel support");

	fd = hugetlbfs_unlinked_fd();
	if (fd < 0)
		FAIL("hugetlbfs_unlinked_fd()");

	p = mmap64(NULL, hpage_size, PROT_READ|PROT_WRITE, MAP_PRIVATE,
		 fd, 0);
	if (p == MAP_FAILED)
		FAIL("mmap() offset 0");
	pi = p;
	/* Touch the low page */
	*pi = 0;

	q = mmap64(NULL, hpage_size, PROT_READ|PROT_WRITE, MAP_PRIVATE,
		 fd, FOURGIG);
	if (q == MAP_FAILED)
		FAIL("mmap() offset 4GB");
	qi = q;
	/* Touch the high page */
	*qi = 0;

	err = ftruncate64(fd, FOURGIG);
	if (err)
		FAIL("ftruncate(): %s", strerror(errno));

	err = sigaction(SIGBUS, &sa_fail, NULL);
	if (err)
		FAIL("sigaction() fail");

	*pi;

	err = sigaction(SIGBUS, &sa_pass, NULL);
	if (err)
		FAIL("sigaction() pass");

	*qi;

	/* Should have SIGBUSed above */
	FAIL("Didn't SIGBUS on truncated page.");
}

--W/nzBZO5zC0uMSeA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
