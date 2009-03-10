Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E8F296B004D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 09:13:02 -0400 (EDT)
Date: Tue, 10 Mar 2009 21:11:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310131155.GA9654@localhost>
References: <20090307220055.6f79beb8@mjolnir.ossman.eu> <20090309013742.GA11416@localhost> <20090309020701.GA381@localhost> <20090309084045.2c652fbf@mjolnir.ossman.eu> <20090309142241.GA4437@localhost> <20090309160216.2048e898@mjolnir.ossman.eu> <20090310024135.GA6832@localhost> <20090310081917.GA28968@localhost> <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Content-Disposition: inline
In-Reply-To: <20090310122210.GA8415@localhost>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 10, 2009 at 08:22:10PM +0800, Wu Fengguang wrote:
> On Tue, Mar 10, 2009 at 11:55:23AM +0200, Pierre Ossman wrote:
> > On Tue, 10 Mar 2009 16:19:17 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > 
> > > Here is the initial patch and tool for finding the missing pages.
> > > 
> > > In the following example, the pages with no flags set is kind of too
> > > many (1816MB), but hopefully your missing pages will have PG_reserved
> > > or other flags set ;-)
> > > 
> > > # ./page-types
> > > L:locked E:error R:referenced U:uptodate D:dirty L:lru A:active S:slab W:writeback x:reclaim B:buddy r:reserved c:swapcache b:swapbacked
> > >  
> > 
> > Thanks. I'll have a look in a bit. Right now I'm very close to a
> > complete bisect. It is just ftrace commits left though, so I'm somewhat
> > sceptical that it is correct. ftrace isn't even turned on in the
> > kernels I've been testing.
> > 
> > The remaining commits are ec1bb60bb..6712e299.

Another tool to show the page locations with specified flags:

# ./page-areas 0x20000 | head
    offset      len         KB
        11        1        4KB
        13        3       12KB
        17        7       28KB
        25        1        4KB
        31        1        4KB
        33       31      124KB
        65       63      252KB
       129       15       60KB
       145        7       28KB

If we run eatmem or the following commands to take up free memory,
the missing pages will show up :-)

        dd if=/dev/zero of=/tmp/s bs=1M count=1 seek=1024
        cp /tmp/s /dev/null

Thanks,
Fengguang

--BXVAT5kNtrzKuDFl
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="page-areas.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <sys/fcntl.h>

/* copied from kpageflags_read() */
enum {
	KPF_LOCKED,	/*  0 */
	KPF_ERROR,	/*  1 */
	KPF_REFERENCED,	/*  2 */
	KPF_UPTODATE,	/*  3 */
	KPF_DIRTY,	/*  4 */
	KPF_LRU,	/*  5 */
	KPF_ACTIVE,	/*  6 */
	KPF_SLAB,	/*  7 */
	KPF_WRITEBACK,	/*  8 */
	KPF_RECLAIM,	/*  9 */
	KPF_BUDDY,	/* 10 */
	KPF_RESERVED,	/* 11 */
	KPF_SWAPCACHE,	/* 12 */
	KPF_SWAPBACKED,	/* 13 */
        KPF_PRIVATE,    /* 14 */
        KPF_PRIVATE2,   /* 15 */
        KPF_NOPAGE,     /* 16 */
        KPF_NOFLAGS,    /* 17 */
	KPF_NUM
};
#define KPF_BYTES	8

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static char *page_flag_names[] = {
	[KPF_LOCKED]		= "L:locked",
	[KPF_ERROR]		= "E:error",
	[KPF_REFERENCED]	= "R:referenced",
	[KPF_UPTODATE]		= "U:uptodate",
	[KPF_DIRTY]		= "D:dirty",
	[KPF_LRU]		= "l:lru",
	[KPF_ACTIVE]		= "A:active",
	[KPF_SLAB]		= "S:slab",
	[KPF_WRITEBACK]		= "W:writeback",
	[KPF_RECLAIM]		= "x:reclaim",
	[KPF_BUDDY]		= "B:buddy",
	[KPF_RESERVED]		= "r:reserved",
	[KPF_SWAPBACKED]	= "b:swapbacked",
	[KPF_SWAPCACHE]		= "c:swapcache",
	[KPF_PRIVATE]		= "P:private",
	[KPF_PRIVATE2]		= "p:private_2",
	[KPF_NOPAGE]		= "N:nopage",
	[KPF_NOFLAGS]		= "n:noflags",
};

static unsigned long page_count[(1 << KPF_NUM)];
static unsigned long nr_pages;
static uint64_t kpageflags[KPF_BYTES * (8<<20)];

char *page_flag_name(uint64_t flags)
{
	int i;
	static char buf[64];

	for (i = 0; i < ARRAY_SIZE(page_flag_names); i++)
		buf[i] = (flags & (1 << i)) ? page_flag_names[i][0] : '_';

	return buf;
}

char *page_flag_longname(uint64_t flags)
{
	int i, n;
	static char buf[1024];

	for (i = 0, n = 0; i < ARRAY_SIZE(page_flag_names); i++)
		if (flags & (1<<i))
		       n += snprintf(buf + n, sizeof(buf) - n, "%s,",
				       page_flag_names[i] + 2);
	if (n)
		n--;
	buf[n] = '\0';

	return buf;
}

static unsigned long pages2kb(unsigned long pages)
{
	return (pages * getpagesize()) >> 10;
}

static void add_index(unsigned long index)
{
	static unsigned long offset, len;

	if (index == offset + len)
		len++;
	else {
		if (len)
			printf("%10lu %8lu %8luKB\n", offset, len, pages2kb(len));
		offset = index;
		len = 1;
	}
}

static void usage(const char *prog)
{
	printf("Usage: %s page_flags\n", prog);
}

int main(int argc, char *argv[])
{
	static char kpageflags_name[] = "/proc/kpageflags";
	unsigned long match_flags;
	unsigned long i;
	int fd;

	if (argc < 2) {
		usage(argv[0]);
		exit(1);
	}

	match_flags = strtol(argv[1], 0, 16);
	/* printf("pages with flags 0x%lx:\n", match_flags); */

	fd = open(kpageflags_name, O_RDONLY);
	if (fd < 0) {
		perror(kpageflags_name);
		exit(1);
	}

	nr_pages = read(fd, kpageflags, sizeof(kpageflags));
	if (nr_pages <= 0) {
		perror(kpageflags_name);
		exit(2);
	}
	if (nr_pages % KPF_BYTES != 0) {
		fprintf(stderr, "%s: partial read: %lu bytes\n",
				argv[0], nr_pages);
		exit(3);
	}
	nr_pages = nr_pages / KPF_BYTES;

	printf("    offset      len         KB\n");
	for (i = 0; i < nr_pages; i++) {
		if ((kpageflags[i] & match_flags) == match_flags)
			add_index(i);
	}
	add_index(0);

	return 0;
}

--BXVAT5kNtrzKuDFl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
