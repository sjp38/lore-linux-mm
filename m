Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3486B0193
	for <linux-mm@kvack.org>; Thu, 14 May 2009 06:52:43 -0400 (EDT)
Date: Thu, 14 May 2009 11:53:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090514105326.GA11770@csn.ul.ie>
References: <bug-13302-10286@http.bugzilla.kernel.org/> <20090513130846.d463cc1e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090513130846.d463cc1e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 01:08:46PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> (Please read this ^^^^ !)
> 
> On Wed, 13 May 2009 19:54:10 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=13302
> > 
> >            Summary: "bad pmd" on fork() of process with hugepage shared
> >                     memory segments attached
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.29.1
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: starlight@binnacle.cx
> >         Regression: Yes
> > 
> > 
> > Kernel reports "bad pmd" errors when process with hugepage
> > shared memory segments attached executes fork() system call.
> > Using vfork() avoids the issue.
> > 
> > Bug also appears in RHEL5 2.6.18-128.1.6.el5 and causes
> > leakage of huge pages.
> > 
> > Bug does not appear in RHEL4 2.6.9-78.0.13.ELsmp.
> > 
> > See bug 12134 for an example of the errors reported
> > by 'dmesg'.
> > 

This seems familiar and I believe it couldn't be reproduced the last time
and then the problem reporter went away. We need a reproduction case so
I modified on of the libhugetlbfs tests to do what I think you described
above. However, it does not trigger the problem for me on x86 or x86-64
running 2.6.29.1.

starlight@binnacle.cz, can you try the reproduction steps on your system
please? If it reproduces, can you send me your .config please? If it
does not reproduce, can you look at the test program and tell me what
it's doing different to your reproduction case?

1. wget http://heanet.dl.sourceforge.net/sourceforge/libhugetlbfs/libhugetlbfs-2.3.tar.gz
2. tar -zxf libhugetlbfs-2.3.tar.gz
3. cd libhugetlbfs-2.3
4. wget http://www.csn.ul.ie/~mel/shm-fork.c (program is below for reference)
5. mv shm-fork.c tests/
6. make
7. ./obj/hugeadm --create-global-mounts
8. ./obj/hugeadm --pool-pages-min 2M:20
	(Adjust pagesize of 2M if necessary. If x86 and not 2M, tell me
	and send me your .config)
9. ./tests/obj32/shm-fork 10 2

On my two systems, I saw something like

# ./tests/obj32/shm-fork 10 2
Starting testcase "./tests/obj32/shm-fork", pid 3527
Requesting 4194304 bytes for each test
Spawning children glibc_fork:..........glibc_fork
Spawning children glibc_vfork:..........glibc_vfork
Spawning children sys_fork:..........sys_fork
PASS

Test program I used is below and is a modified version of what's in
libhugetlbfs. It does not compile standalone. The steps it takes are

1. Gets the hugepage size
2. Calls shmget() to create a suitably large shared memory segment
3. Creates a requested number of children
4.   Each child attaches to the share memory segment
5.     Each child creates a grandchild
6.   The child and grandchildren write the segment
7.   The grandchild exists, the child waits for the grandchild
8.   The child detaches and exists
9. The parent waits for the child to exit

It does this for glibc fork, glibc vfork and a direct call to the system
call fork().

Thanks

==== CUT HERE ====

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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <syscall.h>
#include <sys/types.h>
#include <sys/shm.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <hugetlbfs.h>
#include "hugetests.h"

#define P "shm-fork"
#define DESC \
	"* Test shared memory behavior when multiple threads are attached  *\n"\
	"* to a segment.  A segment is created and then children are       *\n"\
	"* spawned which attach, write, read (verify), and detach from the *\n"\
	"* shared memory segment.                                          *"

extern int errno;

/* Global Configuration */
static int nr_hugepages;
static int numprocs;
static int shmid = -1;

#define MAX_PROCS 200
#define BUF_SZ 256

#define GLIBC_FORK  0
#define GLIBC_VFORK 1
#define SYS_FORK    2
static char *testnames[] = { "glibc_fork", "glibc_vfork", "sys_fork" };

#define CHILD_FAIL(thread, fmt, ...) \
	do { \
		verbose_printf("Thread %d (pid=%d) FAIL: " fmt, \
			       thread, getpid(), __VA_ARGS__); \
		exit(1); \
	} while (0)

void cleanup(void)
{
	remove_shmid(shmid);
}

static void do_child(int thread, unsigned long size, int testtype)
{
	volatile char *shmaddr;
	int j, k;
	int pid, status;

	verbose_printf(".");
	for (j=0; j<5; j++) {
		shmaddr = shmat(shmid, 0, SHM_RND);
		if (shmaddr == MAP_FAILED)
			CHILD_FAIL(thread, "shmat() failed: %s",
				   strerror(errno));

		/* Create even more children to double up the work */
		switch (testtype) {
			case GLIBC_FORK:
				if ((pid = fork()) < 0)
					FAIL("glibc_fork(): %s", strerror(errno));
				break;
			case GLIBC_VFORK:
				if ((pid = vfork()) < 0)
					FAIL("glibc_vfork(): %s", strerror(errno));
				break;
			case SYS_FORK:
				if ((pid = syscall(__NR_fork)) < 0)
					FAIL("sys_fork(): %s", strerror(errno));
				break;
			default:
				FAIL("Test type %d not implemented\n", testtype);
		}

		/* Child and parent access the shared area */
		for (k=0;k<size;k++)
			shmaddr[k] = (char) (k);
		for (k=0;k<size;k++)
			if (shmaddr[k] != (char)k)
				CHILD_FAIL(thread, "Index %d mismatch", k);

		/* Children exits */
		if (pid == 0)
			exit(0);
		
		/* Parent waits for child and detaches */
		waitpid(pid, &status, 0);
		if (shmdt((const void *)shmaddr) != 0)
			CHILD_FAIL(thread, "shmdt() failed: %s",
				   strerror(errno));
	}
	exit(0);
}

static void do_test(unsigned long size, int testtype)
{
	int wait_list[MAX_PROCS];
	int i;
	int pid, status;
	char *testname = testnames[testtype];

	if ((shmid = shmget(2, size, SHM_HUGETLB|IPC_CREAT|SHM_R|SHM_W )) < 0)
		FAIL("shmget(): %s", strerror(errno));

	verbose_printf("Spawning children %s:", testname);
	for (i=0; i<numprocs; i++) {
		switch (testtype) {
			case GLIBC_FORK:
				if ((pid = fork()) < 0)
					FAIL("glibc_fork(): %s", strerror(errno));
				break;
			case GLIBC_VFORK:
				if ((pid = vfork()) < 0)
					FAIL("glibc_vfork(): %s", strerror(errno));
				break;
			case SYS_FORK:
				if ((pid = syscall(__NR_fork)) < 0)
					FAIL("sys_fork(): %s", strerror(errno));
				break;
			default:
				FAIL("Test type %d not implemented\n", testtype);
		}

		if (pid == 0)
			do_child(i, size, testtype);

		wait_list[i] = pid;
	}

	for (i=0; i<numprocs; i++) {
		waitpid(wait_list[i], &status, 0);
		if (WEXITSTATUS(status) != 0)
			FAIL("Thread %d (pid=%d) failed", i, wait_list[i]);

		if (WIFSIGNALED(status))
			FAIL("Thread %d (pid=%d) received unhandled signal",
			     i, wait_list[i]);
	}
	printf("%s\n", testname);
}

int main(int argc, char ** argv)
{
	unsigned long size;
	long hpage_size;

	test_init(argc, argv);

	if (argc < 3)
		CONFIG("Usage:  %s <# procs> <# pages>", argv[0]);

	numprocs = atoi(argv[1]);
	nr_hugepages = atoi(argv[2]);

	if (numprocs > MAX_PROCS)
		CONFIG("Cannot spawn more than %d processes", MAX_PROCS);

	check_hugetlb_shm_group();

	hpage_size = check_hugepagesize();
        size = hpage_size * nr_hugepages;

	verbose_printf("Requesting %lu bytes for each test\n", size);
	do_test(size, GLIBC_FORK);
	do_test(size, GLIBC_VFORK);
	do_test(size, SYS_FORK);
	PASS();
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
