Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3076B004D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 18:21:25 -0400 (EDT)
Date: Wed, 18 Mar 2009 15:11:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-Id: <20090318151157.85109100.akpm@linux-foundation.org>
In-Reply-To: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Mar 2009 12:44:08 -0700 Ying Han <yinghan@google.com> wrote:

> We triggered the failure during some internal experiment with
> ftruncate/mmap/write/read sequence. And we found that some pages are
> "lost" after writing to the mmaped file. which in the following test
> cases (count >= 0).
> 
> First we deployed the test cases into group of machines and see about
> >20% failure rate on average. Then, I did couple of experiment to try
> to reproduce it on a single machine. what i found is that:
> 1. add a fsync after write the file, i can not reproduce this issue.
> 2. add memory pressure(mmap/mlock) while run the test in infinite
> loop, the failure is reproduced quickly. ( background flushing ? )
> 
> The "bad pages" count differs each time from one digit to 4,5 digit
> for 128M ftruncated file. and what i also found that the bad page
> number are contiguous for each segment which total bad pages container
> several segments. ext "1-4, 9-20, 48-50" (  batch flushing ? )
> 
> (The failure is reproduced based on 2.6.29-rc8, also happened on
> 2.6.18 kernel. . Here is the simple test case to reproduce it with
> memory pressure. )

Thanks.  This will be a regression - the testing I did back in the days
when I actually wrote stuff would have picked this up.

Perhaps it is a 2.6.17 thing.  Which, IIRC, is when we made the changes to
redirty pages on each write fault.  Or maybe it was something else.

Nick, Peter: I'm in .au at preset, not able to build and run kernels - is
this something you'd have time to look into please?

Given the amount of time for which this bug has existed, I guess it isn't a
2.6.29 blocker, but once we've found out the cause we should have a little
post-mortem to work out how a bug of this nature has gone undetected for so
long.


> #include <sys/mman.h>
> #include <sys/types.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> 
> long kMemSize  = 128 << 20;
> int kPageSize = 4096;
> 
> int main(int argc, char **argv) {
> 	int status;
> 	int count = 0;
> 	int i;
> 	char *fname = "/root/test.mmap";
> 	char *mem;
> 
> 	unlink(fname);
> 	int fd = open(fname, O_CREAT | O_EXCL | O_RDWR, 0600);
> 	status = ftruncate(fd, kMemSize);
> 
> 	mem = mmap(0, kMemSize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
> 	// Fill the memory with 1s.
> 	memset(mem, 1, kMemSize);
> 
> 	for (i = 0; i < kMemSize; i++) {
> 		int byte_good = mem[i] != 0;
> 
> 		if (!byte_good && ((i % kPageSize) == 0)) {
> 			//printf("%d ", i / kPageSize);
> 			count++;
> 		}
> 	}
> 
> 	munmap(mem, kMemSize);
> 	close(fd);
> 	unlink(fname);
> 
> 	if (count > 0) {
> 		printf("Running %d bad page\n", count);
> 		return 1;
> 	}
> 	return 0;
> }
> 
> --Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
