Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id BF4B46B006C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 04:10:42 -0500 (EST)
Date: Wed, 21 Nov 2012 17:10:02 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Problem in Page Cache Replacement
Message-ID: <20121121091002.GA10255@localhost>
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com>
 <20121120182500.GH1408@quack.suse.cz>
 <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com>
 <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com>
 <50AC9220.70202@gmail.com>
 <20121121090204.GA9064@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121121090204.GA9064@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: metin d <metdos@yahoo.com>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Nov 21, 2012 at 05:02:04PM +0800, Fengguang Wu wrote:
> On Wed, Nov 21, 2012 at 04:34:40PM +0800, Jaegeuk Hanse wrote:
> > Cc Fengguang Wu.
> > 
> > On 11/21/2012 04:13 PM, metin d wrote:
> > >>   Curious. Added linux-mm list to CC to catch more attention. If you run
> > >>echo 1 >/proc/sys/vm/drop_caches does it evict data-1 pages from memory?
> > >I'm guessing it'd evict the entries, but am wondering if we could run any more diagnostics before trying this.
> > >
> > >We regularly use a setup where we have two databases; one gets used frequently and the other one about once a month. It seems like the memory manager keeps unused pages in memory at the expense of frequently used database's performance.
> 
> > >My understanding was that under memory pressure from heavily
> > >accessed pages, unused pages would eventually get evicted. Is there
> > >anything else we can try on this host to understand why this is
> > >happening?
> 
> We may debug it this way.

Better to add a step

0) run 'page-types -r' to get an initial view of the page cache
   status.

Thanks,
Fengguang

> 1) run 'fadvise data-2 0 0 dontneed' to drop data-2 cached pages
>    (please double check via /proc/vmstat whether it does the expected work)
> 
> 2) run 'page-types -r' with root, to view the page status for the
>    remaining pages of data-1
> 
> The fadvise tool comes from Andrew Morton's ext3-tools. (source code attached)
> Please compile them with options "-Dlinux -I. -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE"
> 
> page-types can be found in the kernel source tree tools/vm/page-types.c
> 
> Sorry that sounds a bit twisted.. I do have a patch to directly dump
> page cache status of a user specified file, however it's not
> upstreamed yet.
> 
> Thanks,
> Fengguang
> 
> > >On Tue 20-11-12 09:42:42, metin d wrote:
> > >>I have two PostgreSQL databases named data-1 and data-2 that sit on the
> > >>same machine. Both databases keep 40 GB of data, and the total memory
> > >>available on the machine is 68GB.
> > >>
> > >>I started data-1 and data-2, and ran several queries to go over all their
> > >>data. Then, I shut down data-1 and kept issuing queries against data-2.
> > >>For some reason, the OS still holds on to large parts of data-1's pages
> > >>in its page cache, and reserves about 35 GB of RAM to data-2's files. As
> > >>a result, my queries on data-2 keep hitting disk.
> > >>
> > >>I'm checking page cache usage with fincore. When I run a table scan query
> > >>against data-2, I see that data-2's pages get evicted and put back into
> > >>the cache in a round-robin manner. Nothing happens to data-1's pages,
> > >>although they haven't been touched for days.
> > >>
> > >>Does anybody know why data-1's pages aren't evicted from the page cache?
> > >>I'm open to all kind of suggestions you think it might relate to problem.
> > >   Curious. Added linux-mm list to CC to catch more attention. If you run
> > >echo 1 >/proc/sys/vm/drop_caches
> > >   does it evict data-1 pages from memory?
> > >
> > >>This is an EC2 m2.4xlarge instance on Amazon with 68 GB of RAM and no
> > >>swap space. The kernel version is:
> > >>
> > >>$ uname -r
> > >>3.2.28-45.62.amzn1.x86_64
> > >>Edit:
> > >>
> > >>and it seems that I use one NUMA instance, if  you think that it can a problem.
> > >>
> > >>$ numactl --hardware
> > >>available: 1 nodes (0)
> > >>node 0 cpus: 0 1 2 3 4 5 6 7
> > >>node 0 size: 70007 MB
> > >>node 0 free: 360 MB
> > >>node distances:
> > >>node   0
> > >>    0:  10

> #include <unistd.h>
> #include <stdlib.h>
> #include <fcntl.h>
> #include <errno.h>
> #include <stdio.h>
> #include <string.h>
> 
> #include "fadvise.h"
> 
> char *progname;
> 
> static void usage(void)
> {
> 	fprintf(stderr, "Usage: %s filename offset length advice [loops]\n", progname);
> 	fprintf(stderr, "      advice: normal sequential willneed noreuse "
> 					"dontneed asyncwrite writewait\n");
> 	exit(1);
> }
> 
> int
> main(int argc, char *argv[])
> {
> 	int c;
> 	int fd;
> 	char *sadvice;
> 	char *filename;
> 	loff_t offset;
> 	unsigned long length;
> 	int advice = 0;
> 	int ret;
> 	int loops = 1;
> 
> 	progname = argv[0];
> 
> 	while ((c = getopt(argc, argv, "")) != -1) {
> 		switch (c) {
> 		}
> 	}
> 
> 	if (optind == argc)
> 		usage();
> 	filename = argv[optind++];
> 
> 	if (optind == argc)
> 		usage();
> 	offset = strtoull(argv[optind++], NULL, 0);
> 
> 	if (optind == argc)
> 		usage();
> 	length = strtol(argv[optind++], NULL, 0);
> 
> 	if (optind == argc)
> 		usage();
> 	sadvice = argv[optind++];
> 
> 	if (optind != argc)
> 		loops = strtol(argv[optind++], NULL, 0);
> 
> 	if (optind != argc)
> 		usage();
> 
> 	if (!strcmp(sadvice, "normal"))
> 		advice = POSIX_FADV_NORMAL;
> 	else if (!strcmp(sadvice, "sequential"))
> 		advice = POSIX_FADV_SEQUENTIAL;
> 	else if (!strcmp(sadvice, "willneed"))
> 		advice = POSIX_FADV_WILLNEED;
> 	else if (!strcmp(sadvice, "noreuse"))
> 		advice = POSIX_FADV_NOREUSE;
> 	else if (!strcmp(sadvice, "dontneed"))
> 		advice = POSIX_FADV_DONTNEED;
> 	else if (!strcmp(sadvice, "asyncwrite"))
> 		advice = LINUX_FADV_ASYNC_WRITE;
> 	else if (!strcmp(sadvice, "writewait"))
> 		advice = LINUX_FADV_WRITE_WAIT;
> 	else
> 		usage();
> 
> 	fd = open(filename, O_RDONLY);
> 	if (fd < 0) {
> 		fprintf(stderr, "%s: cannot open `%s': %s\n",
> 			progname, filename, strerror(errno));
> 		exit(1);
> 	}
> 
> 	while (loops--) {
> 		ret = __posix_fadvise64(fd, offset, length, advice);
> 		if (ret) {
> 			fprintf(stderr, "%s: fadvise() failed: %s\n",
> 				progname, strerror(errno));
> 			exit(1);
> 		}
> 	}
> 	close(fd);
> 	exit(0);
> }

> #include <asm/unistd.h>
> #include <sys/errno.h>
> 
> #ifndef __NR_fadvise64
> #if defined (__i386__)
> #define __NR_fadvise64          250
> #elif defined(__powerpc__)
> #define __NR_fadvise64          233
> #elif defined(__ia64__)
> #define __NR_fadvise64		1234
> #elif defined(__x86_64__)
> #define __NR_fadvise64		221
> #endif
> #endif
> 
> #ifndef LINUX_FADV_ASYNC_WRITE
> #define LINUX_FADV_ASYNC_WRITE 32
> #endif
> 
> #ifndef LINUX_FADV_WRITE_WAIT
> #define LINUX_FADV_WRITE_WAIT 33
> #endif
> 
> #ifndef __x86_64__
> _syscall5(int,fadvise64, int,fd, long,offset_lo,
> 		long,offset_hi, size_t,len, int,advice)
> #endif
> 
> /* Works by luck on ppc32, fails on ppc64 */
> #if defined(__i386__)
> int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
> {
> 	return fadvise64(fd, offset, 0, len, advice);
> }
> 
> int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
> {
> 	return fadvise64(fd, offset, offset >> 32, len, advice);
> }
> #elif defined(__powerpc64__)
> int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
> {
> 	return fadvise64(fd, offset, len, advice);
> }
> 
> int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
> {
> 	return fadvise64(fd, offset, len, advice);
> }
> #elif defined(__powerpc__)
> 
> /* 
>  * long longs are passed in an odd even register pair on ppc32 so
>  * we need to pad before offset
>  *
>  * Note also the glibc syscall() function for ppc has been broken for
>  * 6 argument syscalls until recently (~2.3.1 CVS)
>  */
> #define ppc_fadvise64(fd, offset_hi, offset_lo, len, advice) \
> 	syscall(__NR_fadvise64, fd, 0, offset_hi, offset_lo, len, advice)
> 
> int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
> {
> 	return ppc_fadvise64(fd, 0, offset, len, advice);
> }
> 
> /* big endian, akpm. */
> int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
> {
> 	return ppc_fadvise64(fd, (unsigned int)(offset >> 32),
> 			(unsigned int)(offset & 0xffffffff), len, advice);
> }
> #elif defined(__ia64__)
> int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
> {
> 	return fadvise64(fd, offset, len, advice);
> }
> 
> int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
> {
> 	return fadvise64(fd, offset, len, advice);
> }
> #elif defined(__x86_64__)
> int __posix_fadvise(int fd, off_t offset, size_t len, int advice)
> {
> 	return -1;
> }
> 
> int __posix_fadvise64(int fd, loff_t offset, size_t len, int advice)
> {
> 	return syscall(__NR_fadvise64, fd, offset, len, advice);
> }
> #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
