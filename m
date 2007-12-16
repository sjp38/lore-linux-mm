Date: Sun, 16 Dec 2007 21:55:20 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
Message-ID: <20071216215519.GA7710@csn.ul.ie>
References: <47618B0B.8020203@rtr.ca> <20071213195350.GH10104@kernel.dk> <20071213200219.GI10104@kernel.dk> <476190BE.9010405@rtr.ca> <20071213200958.GK10104@kernel.dk> <20071213140207.111f94e2.akpm@linux-foundation.org> <1197584106.3154.55.camel@localhost.localdomain> <20071213142935.47ff19d9.akpm@linux-foundation.org> <20071215010940.GB28613@csn.ul.ie> <20071214180206.e0325503.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071214180206.e0325503.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, jens.axboe@oracle.com, liml@rtr.ca, lkml@rtr.ca, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

> > Just using cp to read the file is enough to cause problems but I included
> > a very basic program below that produces the BUG_ON checks. Is this a known
> > issue or am I using the interface incorrectly?
> 
> I'd say you're using it correctly but you've found a hitherto unknown bug. 
> On i386 highmem machines with CONFIG_HIGHPTE (at least) pte_offset_map()
> takes kmap_atomic(), so pagemap_pte_range() can't do copy_to_user() as it
> presently does.
> 
> Drat.
> 
> Still, that shouldn't really disrupt the testing which you're doing.  You
> could disable CONFIG_HIGHPTE to shut it up.
> 

Yes, that did the trick. Using pagemap, it was trivial to show that the
2.6.24-rc5-mm1 kernel was placing pages in reverse physical order like
the following output shows

b:  32763 v:   753091 p:    65559 . 65558 contig: 1
b:  32764 v:   753092 p:    65558 . 65557 contig: 1
b:  32765 v:   753093 p:    65557 . 65556 contig: 1
b:  32766 v:   753094 p:    65556 . 65555 contig: 1
b:  32767 v:   753095 p:    65555 . 65555 contig: 1

p: is the PFN of the page v: is the page offset within an anonymous
mapping and b: is the number of non-contiguous blocks in the anonymous
mapping. With the patch applied, it looks more like;

b:   1232 v:   752964 p:    58944 ................ 87328 contig: 15
b:   1233 v:   752980 p:    87328 ................ 91200 contig: 15
b:   1234 v:   752996 p:    91200 ................ 40272 contig: 15
b:   1235 v:   753012 p:    40272 ................ 85664 contig: 15
b:   1236 v:   753028 p:    85664 ................ 87312 contig: 15

so mappings are using contiguous pages again. This was the final test
program I used in case it's of any interest.

Thanks

/*
 * showcontiguous.c
 *
 * Use the /proc/pid/pagemap interface to give an indication of how contiguous
 * physical memory is in an anonymous virtual memory mapping
 */
#include <stdio.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/types.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAPSIZE (128*1048576)
#define PM_ENTRY_BYTES sizeof(__u64)

int main(int argc, char **argv)
{
	int pagemap_fd;
	unsigned long *anonmapping;
	__u64 pagemap_entry = 0ULL;

	unsigned long vpfn, ppfn, ppfn_last;
	int block_number = 0;
	int contig_count = 1;
	size_t mmap_offset;
	int pagesize = getpagesize();

	if (sizeof(pagemap_entry) < PM_ENTRY_BYTES) {
		printf("ERROR: Failed assumption on size of pagemap_entry\n");
		exit(EXIT_FAILURE);
	}

	/* Open the pagemap interface */
	pagemap_fd = open("/proc/self/pagemap", O_RDONLY);
	if (pagemap_fd == -1) {
		perror("fopen");
		exit(EXIT_FAILURE);
	}

	/* Create an anonymous mapping */
	anonmapping = mmap(NULL, MAPSIZE,
			PROT_READ|PROT_WRITE,
			MAP_PRIVATE|MAP_ANONYMOUS|MAP_POPULATE,
			-1, 0);
	if (anonmapping == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}

	/* Work out the VPN the mapping is at and seek to it in pagemap */
	vpfn = ((unsigned long)anonmapping) / pagesize;
	mmap_offset = lseek(pagemap_fd, vpfn * PM_ENTRY_BYTES, SEEK_SET);
	if (mmap_offset == -1) {
		perror("fseek");
		exit(EXIT_FAILURE);
	}
	ppfn_last = 0;

	/* Read the PFN of each page in the mapping */
	for (mmap_offset = 0; mmap_offset < MAPSIZE; mmap_offset += pagesize) {
		vpfn = ((unsigned long)anonmapping + mmap_offset) / pagesize;

		if (read(pagemap_fd, &pagemap_entry, PM_ENTRY_BYTES) == 0) {
			perror("fread");
			exit(EXIT_FAILURE);
		}

		ppfn = (unsigned long)pagemap_entry;
		if (ppfn == ppfn_last + 1) {
			printf(".");
			contig_count++;
		} else {
			printf(" %lu contig: %d\nb: %6d v: %8lu p: %8lu .",
				ppfn, contig_count,
				block_number, vpfn, ppfn);
			contig_count = 1;
			block_number++;
		}
		ppfn_last = ppfn;
	}
	printf(" %lu config: %d\n", ppfn, contig_count);

	close(pagemap_fd);
	munmap(anonmapping, MAPSIZE);
	exit(EXIT_SUCCESS);
}
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
