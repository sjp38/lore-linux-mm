Received: from pygar.sc.orionmulti.com (209-128-98-074.bayarea.net [209.128.98.74])
	by paleosilicon.orionmulti.com (8.12.10/8.12.10) with ESMTP id i4PMeudt032299
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 25 May 2004 15:40:56 -0700
Date: Tue, 25 May 2004 15:40:56 -0700 (PDT)
From: Ron Maeder <rlm@orionmulti.com>
Subject: mmap() > phys mem problem
Message-ID: <Pine.LNX.4.44.0405251523250.18898-100000@pygar.sc.orionmulti.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a diskless x86 box running the 2.6.5rc3 kernel.  I ran a program
which mmap()'d a file that was larger than physical memory over NFS and
then began to write values to it.  The process grew until it was near the
size of phys mem, and then grinded to a halt and other programs, including 
daemons, were exiting when they should have stayed running.

If I run the program on a system that has some swap space, it completes 
without any issue.

It seems as if the OS will not write any dirty pages back to the mmap()'d 
file, and then eventually runs out of memory.

Is this an "undocumented feature" or is this a linux error?  I would
expect pages of the mmap()'d file would get paged back to the original
file. I know this won't be fast, but the performance is not an issue for
this application.

Below is an example that reproduces the problem on a machine without swap.  
If I do an occasional synchronous msync(MS_SYNC) (compiling -DNEVER), the
test case completes fine, while if I use an msync(MS_ASYNC) then other
programs exit as if I did no msync().

Many thanks,

Ron
---------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/sysinfo.h>

#define MAX_UNSIGNED	((unsigned) (~0))
#define	FILE_MODE	(S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)

unsigned
total_ram()
{
    struct sysinfo	info;
    double		my_total_ram;

    if (sysinfo(&info) != 0) {
	perror("sysinfo");
	exit(1);
    }
    my_total_ram = ((double) info.totalram * (double) info.mem_unit);
    if (my_total_ram > (double) MAX_UNSIGNED) {
	fprintf(stderr, "'my_total_ram' too large for 'unsigned' type.");
	exit(1);
    }
    return((unsigned) my_total_ram);
}

int
main()
{
    unsigned	i;
    unsigned	addr_size;
    unsigned	mem_size;
    unsigned	*mem;
    char	swap_filename[20] = "thrash_swap";
    int		swap_filedes;

    mem_size = total_ram();
    mem_size -= (mem_size % sizeof(unsigned));	/* align to 'unsigned' size */
    /* compute the size of the address for 'unsigned' memory accesses */
    addr_size = ((mem_size / sizeof(unsigned)) - 1);

    (void) unlink(swap_filename);
    if ((swap_filedes = open(swap_filename, O_RDWR | O_CREAT | O_TRUNC,
			     FILE_MODE)) == -1) {
	perror("open: Can't open for writing");
	exit(1);
    }
    /* Set size of swap file */
    if (lseek(swap_filedes, (mem_size - 1), SEEK_SET) == (off_t) -1) {
	perror("lseek");
	exit(1);
    }
    if (write(swap_filedes, "", 1) != 1) {
	perror("write");
	exit(1);
    }
    if ((mem = (unsigned *) mmap(0, mem_size, PROT_READ | PROT_WRITE,
				 MAP_FILE | MAP_SHARED, swap_filedes, 0))
	== (unsigned *) -1) {
	perror("mmap");
	exit(1);
    }
    /* for this example just dirty each page. */
    for (i = 0; i < addr_size; i += 1024) {
	mem[i] = 0;
	if ((i & 0xfffff) == 0) {
#ifdef NEVER
	    if (msync(mem, mem_size, MS_SYNC) != 0) {
		perror("msync");
		exit(1);
	    }
#endif
	    printf(".");
	    fflush(stdout);
	}
    }
    if (munmap(mem, mem_size) != 0) {
	perror("munmap");
	exit(1);
    }
    if (close(swap_filedes) != 0) {
	perror("close");
	exit(1);
    }
    if (unlink(swap_filename) != 0) {
	perror("unlink");
	exit(1);
    }
    printf("\n");
    fflush(stdout);
    return(0);
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
