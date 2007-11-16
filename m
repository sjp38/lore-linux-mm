Date: Thu, 15 Nov 2007 16:27:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
Message-Id: <20071115162706.4b9b9e2a.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, apw@shadowen.org, mel@skynet.ie, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Nov 2007 11:52:47 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> The discussion of the RFC for this and Mel's measurements indicate that 
> there may not be too much of a point left to having separate lists for 
> hot and cold pages (see http://marc.info/?t=119492914200001&r=1&w=2). I 
> think it is worth taking into mm for further testing. This version is 
> against 2.6.24-rc2-mm1.
> 
> 
> Page allocator: Get rid of the list of cold pages
> 
> We have repeatedly discussed if the cold pages still have a point. There is
> one way to join the two lists: Use a single list and put the cold pages at the
> end and the hot pages at the beginning. That way a single list can serve for
> both types of allocations.

Well.  The whole per-cpu-pages thing was a very marginal benefit - I
wibbled for months before merging it.  So the effects of simplifying the
lists will be hard to measure.

The test which per-cpu-pages helped most was one which sits in a loop
extending and truncating a file by 32k - per-cpu-pages sped that up by a
lot (3x, iirc) because with per-cpu-pages it's always getting the same
pages on each CPU and they're cache-hot.

<goes archeological for a bit>

OK, it's create-delete.c from ext3-tools, duplicated below.  It would be
nice if someone(tm) could check that this patch doesn't hurt this test.

I'd suggest running one instance per cpu with various values of "size".

/*
 */

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/signal.h>
#include <sys/stat.h>

int verbose;
char *progname;

void usage(void)
{
	fprintf(stderr, "Usage: %s [-v] [-nN] [-s size] filename\n", progname);
	fprintf(stderr, "      -v:         Verbose\n"); 
	fprintf(stderr, "     -nN:         Run N iterations\n"); 
	fprintf(stderr, "     -s size:     Size of file\n"); 
	exit(1);
}

int main(int argc, char *argv[])
{
	int c;
	int fd;
	int niters = -1;
	int size = 16 * 4096;
	char *filename;
	char *buf;

	progname = argv[0];
	while ((c = getopt(argc, argv, "vn:s:")) != -1) {
		switch (c) {
		case 'n':
			niters = strtol(optarg, NULL, 10);
			break;
		case 's':
			size = strtol(optarg, NULL, 10);
			break;
		case 'v':
			verbose++;
			break;
		}
	}

	if (optind == argc)
		usage();
	filename = argv[optind++];
	if (optind != argc)
		usage();
	buf = malloc(size);
	if (buf == 0) {
		perror("nomem");
		exit(1);
	}
	fd = creat(filename, 0666);
	if (fd < 0) {
		perror("creat");
		exit(1);
	}
	while (niters--) {
		if (lseek(fd, 0, SEEK_SET)) {
			perror("lseek");
			exit(1);
		}
		if (write(fd, buf, size) != size) {
			perror("write");
			exit(1);
		}
		if (ftruncate(fd, 0)) {
			perror("ftruncate");
			exit(1);
		}
	}
	exit(0);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
