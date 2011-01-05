Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BA4BD6B0088
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 23:52:44 -0500 (EST)
Date: Tue, 4 Jan 2011 23:52:42 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <907929848.134962.1294203162923.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110104105214.GA10759@tiehlicka.suse.cz>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> On Tue 04-01-11 05:21:46, CAI Qian wrote:
> >
> > > > 3) overcommit 2gb hugepages.
> > > > mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE,
> > > > MAP_SHARED,
> > > > 3, 0) = -1 ENOMEM (Cannot allocate memory)
> > >
> > > Hmm, you are trying to reserve/mmap a lot of memory (17179869182
> > > 1GB
> > > huge pages).
> > That is strange - the test code merely did this,
> > addr = mmap(ADDR, 2<<30, PROTECTION, FLAGS, fd, 0);
> 
> Didn't you want 1<<30 instead?
No, it was expecting to use both the allocate + overcommited 1GB pages.

> > > Are you sure that you are not changing the value by the /sys
> > > interface
> > > somewhere (there is no check for the value so you can set
> > > what-ever
> > > value you like)? I fail to see any mmap code path which would
> > > change
> > > this value.
> > I could double-check here, but it is not important if the fact is
> > that
> > overcommit is not supported for 1GB pages.
> 
> What is the complete test case?
Here is the reproducer I was using. The trick to reproduce this is to run at the end.

echo "" >/proc/sys/vm/nr_overcommit_hugepages

CAI Qian

---------------------
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/mount.h>
#include <sys/shm.h>
#include <sys/ipc.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <ctype.h>

#define PROTECTION		(PROT_READ | PROT_WRITE)

#define ADDR (void *)(0x0UL)
#define FLAGS (MAP_SHARED)

static void setup(void);
static void cleanup(void);
static void overcommit(void);

int main(int argc, char *argv[])
{
	setup();
	overcommit();
	cleanup();

	return 0;
}

static void overcommit(void)
{
	void *addr = NULL;
	int fd = -1;
	char s[BUFSIZ];

	snprintf(s, BUFSIZ, "/mnt/hugemmap05/file");
	fd = open(s, O_CREAT | O_RDWR, 0755);
	if (fd == -1)
		perror("open");

	addr = mmap(ADDR, 2UL<<30, PROTECTION, FLAGS, fd, 0);
	if (addr == MAP_FAILED) {
		perror("mmap");
		cleanup();
	}
	close(fd);
	unlink(s);
}

static void cleanup(void)
{
	system("echo "" >/proc/sys/vm/nr_overcommit_hugepages");
	system("umount /mnt/hugemmap05");
	exit(1);
}

static void setup(void)
{
	system("echo 1 >/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages");
	system("mkdir /mnt/hugemmap05");
	system("mount none -t hugetlbfs /mnt/hugemmap05");
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
