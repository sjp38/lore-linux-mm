Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA24808
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 10:05:39 -0500
Date: Tue, 1 Dec 1998 15:03:41 GMT
Message-Id: <199812011503.PAA18144@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Update shared mappings
In-Reply-To: <Pine.LNX.3.96.981130204515.498H-100000@dragon.bogus>
References: <199811301352.NAA03313@dax.scot.redhat.com>
	<Pine.LNX.3.96.981130204515.498H-100000@dragon.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko.Calusic@CARNet.hr, Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 30 Nov 1998 21:02:05 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

>> The only reason that this patch works in its current state is that
>> exit_mmap() skips the down(&mm->mmap_sem).  It can safely do so only

> I guess you have not read the patch well...

I think I have: I can reliably deadlock machines with this patch.

> Stephen I can' t see the obvious deadlocking you are tolking about. The
> mmap semphore can be held for many processes but not two times for the
> same one and never for the current one. The code should work fine also
> with CLONE_VM. I have no pending bug reports btw. 

No.  When you scan vmas to update, you down() the semaphore on their
mm.  You skip the current vma, sure, but it is quite possible to have
the same inode mapped more than once in a mm.  If that happens, then
you *will* deadlock (I've got a console window open right now on a test
machine which is deadlocked in msync).

> Let me know if the code still need fixing. A proggy that trigger the bug
> would be helpful btw ;)

OK, see below.

--Stephen

----------------------------------------------------------------
/*
 * wmem.c
 * 
 * Test msync of shared write mappings
 * 
 * (C) Stephen C. Tweedie, 1998
 */

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/fcntl.h>

void try(const char *where, int why)
{
	if (why) {
		perror(where);
		exit(1);
	}
}

int pagesize;

int main(int argc, char *argv[])
{
	int fd;
	int err;
	char * map1, * map2;
	
	pagesize = getpagesize();
	
	fd = open("/tmp/testfile", O_RDWR|O_CREAT, 0666);
	try ("open", fd < 0);
	
	ftruncate(fd, pagesize);
	
	map1 = mmap(0, pagesize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	try ("mmap", map1 == MAP_FAILED);
	
	map2 = mmap(0, pagesize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	try ("mmap", map2 == MAP_FAILED);
	
	map1[0] = 0;
	map1[100] = 0;
	
	err = msync(map1, pagesize, 0);
	try ("msync", err < 0);
	
	err = msync(map2, pagesize, 0);
	try ("msync", err < 0);

	exit(0);
}
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
