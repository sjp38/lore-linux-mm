Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B4B60900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:17:32 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5MIsb6a021022
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 14:54:37 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5MJGXSd448342
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:16:46 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5MJGUJ6023572
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 13:16:30 -0600
Message-ID: <4E023F61.8080904@linux.vnet.ibm.com>
Date: Wed, 22 Jun 2011 14:15:45 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: frontswap/zcache: xvmalloc discussion
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>

Dan, Nitin,

I have been experimenting with the frontswap v4 patches and the latest 
zcache in the mainline drivers/staging.  There is a particular issue I'm 
seeing when using pages of different compressibilities.

When the pages compress to less than PAGE_SIZE/2, I get good compression 
and little external fragmentation in the xvmalloc pool.  However, when 
the pages have a compressed size greater than PAGE_SIZE/2, it is a very 
different story.  Basically, because xvmalloc allocations can't span 
multiple pool pages, grow_pool() is called on each allocation, reducing 
the effective compression (total_pages_in_frontswap / 
total_pages_in_xvmalloc_pool) to 0 and drastically increasing external 
fragmentation to up to 50%.

The likelihood that the size of a compressed page is greater than 
PAGE_SIZE/2 is high, considering that lzo1x-1 sacrifices compressibility 
for speed.  In my experiments, pages of English text only compressed to 
75% of their original size with 1zo1x-1.

In order to calculate the effective compression of frontswap, you need 
the number of pages stored by frontswap, provided by frontswap's 
curr_pages sysfs attribute, and the number of pages in the xvmalloc 
pool.  There isn't a sysfs attribute for this, so I made a patch that 
creates a new zv_pool_pages_count attribute for zcache that provides 
this value (patch is in a follow-up message).  I have also included my 
simple test program at the end of this email.  It just allocates and 
stores random pages of from a text file (in my case, a text file of Moby 
Dick).

The real problem here is compressing pages of size x and storing them in 
a pool that has "chunks", if you will, also of size x, where allocations 
can't span multiple chunks.  Ideally, I'd like to address this issue by 
expanding the size of the xvmalloc pool chunks from one page to four 
pages (I can explain why four is a good number, just didn't want to make 
this note too long).

After a little playing around, I've found this isn't entirely trivial to 
do because of the memory mapping implications; more specifically the use 
of kmap/kunamp in the xvmalloc and zcache layers.  I've looked into 
using vmap to map multiple pages into a linear address space, but it 
seems like there is a lot of memory overhead in doing that.

Do you have any feedback on this issue or suggestion solution?

-- 
Seth Jennings
Linux on Power Virtualization
IBM Linux Technology Center

=================
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define SIZE_OF_PAGE_IN_BYTES 4096
#define NUM_OF_PAGES_PER_MB (1024*1024/SIZE_OF_PAGE_IN_BYTES)

void usage();

int
main(int argc, char * argv[])
{
	int mbs, numpages, i;
	char *mypage;
	int rc, len, pos;
	FILE *textfile;

	if(argc < 3)
	{
		printf("usage: %s numMBs file\n",argv[0]);
		return 1;
	}

	mbs = atoi(argv[1]);
	numpages = NUM_OF_PAGES_PER_MB * mbs;

	printf("Allocating %d MB (%d pages) of data...\n",mbs,numpages);

	textfile = fopen(argv[2],"r");

	if(textfile == NULL)
	{
		perror("failed to open text file");
		exit(1);
	}

	/* get file length */
	fseek(textfile,0,SEEK_END);
	len = ftell(textfile);
	
	for (i=0; i < numpages; i++) {
		if(!(i%100))
		{
			if(i)
				printf("\033[F\033[J");
			printf("%d numpages allocated\n", i);
		}

		mypage = malloc(SIZE_OF_PAGE_IN_BYTES);
		if(!mypage)
		{
			perror("malloc()");
			return 1;
		}

		/* start at (pusedo) random location in file */
		pos = rand() % (len - SIZE_OF_PAGE_IN_BYTES);
		fseek(textfile,pos,SEEK_SET);
		rc = fread(mypage,SIZE_OF_PAGE_IN_BYTES,1,textfile);
		if(!rc)
		{
			perror("read()");
			return 1;
		}
	}

	printf("complete\n\npress any key to end program");
	getchar();

	return 0;
}
=================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
