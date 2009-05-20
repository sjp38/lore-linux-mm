Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DB4A26B005A
	for <linux-mm@kvack.org>; Wed, 20 May 2009 07:34:58 -0400 (EDT)
Date: Wed, 20 May 2009 12:35:25 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090520113525.GA4409@csn.ul.ie>
References: <6.2.5.6.2.20090515145151.03a55298@binnacle.cx>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Content-Disposition: inline
In-Reply-To: <6.2.5.6.2.20090515145151.03a55298@binnacle.cx>
Sender: owner-linux-mm@kvack.org
To: starlight@binnacle.cx
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Fri, May 15, 2009 at 02:53:27PM -0400, starlight@binnacle.cx wrote:
> Here's another possible clue:
> 
> I tried the first 'tcbm' testcase on a 2.6.27.7
> kernel that was hanging around from a few months
> ago and it breaks it 100% of the time.
> 
> Completely hoses huge memory.  Enough "bad pmd"
> errors to fill the kernel log.
> 

So I investigated what's wrong with 2.6.27.7. The problem is a race between
exec() and the handling of mlock()ed VMAs but I can't see where. The normal
teardown of pages is applied to a shared memory segment as if VM_HUGETLB
was not set.

This was fixed between 2.6.27 and 2.6.28 but apparently by accident during the
introduction of CONFIG_UNEVITABLE_LRU. This patchset made a number of changes
to how mlock()ed are handled but I didn't spot which was the relevant change
that fixed the problem and reverse bisecting didn't help. I've added two people
that were working on the unevictable LRU patches to see if they spot something.

For context, the two attached files are used to reproduce a problem
where bad pmd messages are scribbled all over the console on 2.6.27.7.
Do something like

echo 64 > /proc/sys/vm/nr_hugepages
mount -t hugetlbfs none /mnt
sh ./test-tcbm.sh

I did confirm that it didn't matter to 2.6.29.1 if CONFIG_UNEVITABLE_LRU is
set or not.  It's possible the race it still there but I don't know where
it is.

Any ideas where the race might be?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--W/nzBZO5zC0uMSeA
Content-Type: text/x-csrc; charset=iso-8859-15
Content-Disposition: attachment; filename="tcbm.c"

#include <errno.h>
#include <fcntl.h>
#include <memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sched.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <sys/resource.h>
#include <sys/mman.h>

#define LARGE_SHARED_SEGMENT_KEY	0x12345600
#define LARGE_SHARED_SEGMENT_SIZE	((size_t)0x40000000)
#define LARGE_SHARED_SEGMENT_ADDR	((void *)0x40000000)

#define SMALL_SHARED_SEGMENT_KEY	0x12345601
#define SMALL_SHARED_SEGMENT_SIZE	((size_t)0x20000000)
#define SMALL_SHARED_SEGMENT_ADDR	((void *)0x94000000)

#define NUM_SMALL_BUFFERS		50

char *helper_program = "echo";
char *helper_args[] = { "-n", ".", NULL };

void child_signal_handler(const int unused)
{
	int errno_save;
	pid_t dead_pid;
	int dead_status;

	errno_save = errno;

	do {
		dead_pid = waitpid(-1, &dead_status, WNOHANG);
		if (dead_pid == -1) {
			if (errno == ECHILD)
				break;
			perror("waitpid");
			exit(EXIT_FAILURE);
		}
	} while (dead_pid != 0);

	errno = errno_save;
	return;
}

int rabbits(void)
{
	int sched_policy;
	int pid;

	pid = fork();
	if (pid != 0)
		return 0;

	sched_policy = sched_getscheduler(0);
	if (sched_policy == -1)
		perror("sched_getscheduler");

	/* Set the childs policy to SCHED_OTHER */
	if (sched_policy != SCHED_OTHER) {
		struct sched_param sched;
		memset(&sched, 0, sizeof(sched));
		sched.sched_priority = 0;
		if (sched_setscheduler(0, SCHED_OTHER, &sched) != 0)
			perror("sched_setscheduler");
	}

	/* Set the priority of the process */
	errno = 0;
	const int nice = getpriority(PRIO_PROCESS, 0);
	if (errno != 0)
		perror("getpriority");
	if (nice < -10)
		if (setpriority(PRIO_PROCESS, 0, -10) != 0)
			perror("setpriority");

	/* Launch helper program */
	execvp(helper_program, helper_args);
	perror("execvp");
	exit(EXIT_FAILURE);
}

int main(int argc, const char** argv, const char** envp)
{
	struct sched_param sched;
	struct sigaction sas_child;
	int i;

	/* Set the round robin scheduler */
	memset(&sched, 0, sizeof(sched));
	sched.sched_priority = 26;
	if (sched_setscheduler(0, SCHED_RR, &sched) != 0) {
		perror("sched_setscheduler(SCHED_RR, 26)");
		return 1;
	}

	/* Set a signal handler for children exiting */
	memset(&sas_child, 0, sizeof(sas_child));
	sas_child.sa_handler = child_signal_handler;
	if (sigaction(SIGCHLD, &sas_child, NULL) != 0) {
		perror("sigaction(SIGCHLD)");
		return 1;
	}

	/* Create a large shared memory segment */
	int seg1id = shmget(LARGE_SHARED_SEGMENT_KEY,
				LARGE_SHARED_SEGMENT_SIZE,
				IPC_CREAT|SHM_HUGETLB|0640);
	if (seg1id == -1) {
		perror("shmget(LARGE_SEGMENT)");
		return 1;
	}

	/* Attach at the 16GB offset */
	void* seg1adr = shmat(seg1id, LARGE_SHARED_SEGMENT_ADDR, 0);
	if (seg1adr == (void*)-1) {
		perror("shmat(LARGE_SEGMENT)");
		return 1;
	}

	/* Initialise the start of the segment and mlock it */
	memset(seg1adr, 0xFF, LARGE_SHARED_SEGMENT_SIZE/2);
	if (mlock(seg1adr, LARGE_SHARED_SEGMENT_SIZE) != 0) {
		perror("mlock(LARGE_SEGMENT)");
		return 1;
	}

	/* Create a second smaller segment */
	int seg2id = shmget(SMALL_SHARED_SEGMENT_KEY,
				SMALL_SHARED_SEGMENT_SIZE,
				IPC_CREAT|SHM_HUGETLB|0640);
	if (seg2id == -1) {
		perror("shmget(SMALL_SEGMENT)");
		return 1;
	}

	/* Attach small segment */
	void *seg2adr = shmat(seg2id, SMALL_SHARED_SEGMENT_ADDR, 0);
	if (seg2adr == (void*) -1) {
		perror("shmat(SMALL_SEGMENT)");
		return 1;
	}

	/* Initialise all of small segment and mlock */
	memset(seg2adr, 0xFF, (size_t) SMALL_SHARED_SEGMENT_SIZE);
/*
	if (mlock(seg2adr, (size_t) SMALL_SHARED_SEGMENT_SIZE) != 0) {
		perror("mlock(SMALL_SEGMENT)");
		return 1;
	}
*/

	/* Create a number of approximately 516K buffers */
	for (i = 0; i < NUM_SMALL_BUFFERS; i++) {
		void* mmtarg = mmap(NULL, 528384,
				PROT_READ|PROT_WRITE,
				MAP_PRIVATE|MAP_ANONYMOUS,
				-1, 0);
		if (mmtarg == (void*) -1) {
			perror("mmap");
			return 1;
		}
	}

	/* Dump maps */
	{
		char buf[4097];
		int bytes;
		int fd = open("/proc/self/maps", O_RDONLY);
		while ((bytes = read(fd, buf, 4096)) > 0) {
			printf("%s", buf);
		}
		close(fd);
	}

	/* Create one child per small buffer */
	for (i = 0; i < NUM_SMALL_BUFFERS; i++) {
		rabbits();
		usleep(500);
	}

	/* Wait until children shut up signalling */
	printf("Waiting for children\n");
	while (sleep(3) != 0);

	/* Detach */
	if (shmdt(seg1adr) == -1)
		perror("shmdt(LARGE_SEGMENT)");
	if (shmdt(seg2adr) == -1)
		perror("shmdt(SMALL_SEGMENT)");
	if (shmctl(seg1id, IPC_RMID, NULL) == -1)
		perror("shmrm(LARGE_SEGMENT)");
	if (shmctl(seg2id, IPC_RMID, NULL) == -1)
		perror("shmrm(SMALL_SEGMENT)");

	printf("Done\n");
	return 0;
}

--W/nzBZO5zC0uMSeA
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-tcbm.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0Acheck_leak() {=0A	HUGEPAGES_TOTAL=3D`grep HugePages_Total:=
 /proc/meminfo | awk '{print $2}'`=0A	HUGEPAGES_FREE=3D`grep HugePages_Free=
: /proc/meminfo | awk '{print $2}'`=0A	if [ $HUGEPAGES_TOTAL !=3D $HUGEPAGE=
S_FREE ]; then=0A		echo Huge pages leaked=0A		exit -1=0A	fi=0A}=0A=0A# set =
to -1 to run forever=0AITERATIONS=3D60=0A=0Aecho $((3192*1048576)) > /proc/=
sys/kernel/shmmax=0Aecho 2000 > /proc/sys/vm/nr_hugepages=0A=0Aecho Buildin=
g test program=0Agcc -Wall tcbm.c -o tcbm || exit -1=0A=0AITER=3D0=0Awhile =
[ $ITER -ne $ITERATIONS ]; do=0A	echo Iteration $ITER=0A	./tcbm || exit=0A	=
check_leak=0A	ITER=3D$((ITER+1))=0Adone=0A
--W/nzBZO5zC0uMSeA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
