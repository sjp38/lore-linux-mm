Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 05B386B0055
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 15:20:10 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id n7EJKDFg019895
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 20:20:14 +0100
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz37.hot.corp.google.com with ESMTP id n7EJKAoh003860
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 12:20:10 -0700
Received: by pxi12 with SMTP id 12so399758pxi.22
        for <linux-mm@kvack.org>; Fri, 14 Aug 2009 12:20:10 -0700 (PDT)
Date: Fri, 14 Aug 2009 12:20:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] Add MAP_HUGETLB example V3
In-Reply-To: <b3a3235077fb708c541463042f41c33c834a204f.1250258125.git.ebmunson@us.ibm.com>
Message-ID: <alpine.DEB.2.00.0908141219200.12472@chino.kir.corp.google.com>
References: <cover.1250258125.git.ebmunson@us.ibm.com> <d2e4f6625a147c1ef6cb26de66849875f57a8155.1250258125.git.ebmunson@us.ibm.com> <cf4bcaaa502168605af7b556bb4e8110033c44e6.1250258125.git.ebmunson@us.ibm.com>
 <b3a3235077fb708c541463042f41c33c834a204f.1250258125.git.ebmunson@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, mtk.manpages@gmail.com, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, 14 Aug 2009, Eric B Munson wrote:

> This patch adds an example of how to use the MAP_HUGETLB flag to the
> vm documentation directory and a reference to the example in
> hugetlbpage.txt.
> 
> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

Adding Randy Dunlap to the cc.


> ---
> Changes from V2:
>  Rebase to newest linux-2.6 tree
>  Fix comment in example referencing MAP_LARGEPAGE
>  Move example code to its own file
>  Update hugetlbpage.txt with MAP_HUGETLB information and example reference
>  Add map_hugetlb.c to 00-INDEX
> 
> Changes from V1:
>  Rebase to newest linux-2.6 tree
>  Change MAP_LARGEPAGE to MAP_HUGETLB to match flag name in huge page shm
> 
>  Documentation/vm/00-INDEX        |    2 +
>  Documentation/vm/hugetlbpage.txt |   14 ++++---
>  Documentation/vm/map_hugetlb.c   |   77 ++++++++++++++++++++++++++++++++++++++
>  3 files changed, 87 insertions(+), 6 deletions(-)
>  create mode 100644 Documentation/vm/map_hugetlb.c
> 
> diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
> index 2f77ced..aabd973 100644
> --- a/Documentation/vm/00-INDEX
> +++ b/Documentation/vm/00-INDEX
> @@ -20,3 +20,5 @@ slabinfo.c
>  	- source code for a tool to get reports about slabs.
>  slub.txt
>  	- a short users guide for SLUB.
> +map_hugetlb.c
> +	- an example program that uses the MAP_HUGETLB mmap flag.
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> index ea8714f..6a8feab 100644
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -146,12 +146,14 @@ Regular chown, chgrp, and chmod commands (with right permissions) could be
>  used to change the file attributes on hugetlbfs.
>  
>  Also, it is important to note that no such mount command is required if the
> -applications are going to use only shmat/shmget system calls.  Users who
> -wish to use hugetlb page via shared memory segment should be a member of
> -a supplementary group and system admin needs to configure that gid into
> -/proc/sys/vm/hugetlb_shm_group.  It is possible for same or different
> -applications to use any combination of mmaps and shm* calls, though the
> -mount of filesystem will be required for using mmap calls.
> +applications are going to use only shmat/shmget system calls or mmap with
> +MAP_HUGETLB.  Users who wish to use hugetlb page via shared memory segment
> +should be a member of a supplementary group and system admin needs to
> +configure that gid into /proc/sys/vm/hugetlb_shm_group.  It is possible for
> +same or different applications to use any combination of mmaps and shm*
> +calls, though the mount of filesystem will be required for using mmap calls
> +without MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB see
> +map_hugetlb.c.
>  
>  *******************************************************************
>  
> diff --git a/Documentation/vm/map_hugetlb.c b/Documentation/vm/map_hugetlb.c
> new file mode 100644
> index 0000000..e2bdae3
> --- /dev/null
> +++ b/Documentation/vm/map_hugetlb.c
> @@ -0,0 +1,77 @@
> +/*
> + * Example of using hugepage memory in a user application using the mmap
> + * system call with MAP_HUGETLB flag.  Before running this program make
> + * sure the administrator has allocated enough default sized huge pages
> + * to cover the 256 MB allocation.
> + *
> + * For ia64 architecture, Linux kernel reserves Region number 4 for hugepages.
> + * That means the addresses starting with 0x800000... will need to be
> + * specified.  Specifying a fixed address is not required on ppc64, i386
> + * or x86_64.
> + */
> +#include <stdlib.h>
> +#include <stdio.h>
> +#include <unistd.h>
> +#include <sys/mman.h>
> +#include <fcntl.h>
> +
> +#define LENGTH (256UL*1024*1024)
> +#define PROTECTION (PROT_READ | PROT_WRITE)
> +
> +#ifndef MAP_HUGETLB
> +#define MAP_HUGETLB 0x40
> +#endif
> +
> +/* Only ia64 requires this */
> +#ifdef __ia64__
> +#define ADDR (void *)(0x8000000000000000UL)
> +#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_FIXED)
> +#else
> +#define ADDR (void *)(0x0UL)
> +#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB)
> +#endif
> +
> +void check_bytes(char *addr)
> +{
> +	printf("First hex is %x\n", *((unsigned int *)addr));
> +}
> +
> +void write_bytes(char *addr)
> +{
> +	unsigned long i;
> +
> +	for (i = 0; i < LENGTH; i++)
> +		*(addr + i) = (char)i;
> +}
> +
> +void read_bytes(char *addr)
> +{
> +	unsigned long i;
> +
> +	check_bytes(addr);
> +	for (i = 0; i < LENGTH; i++)
> +		if (*(addr + i) != (char)i) {
> +			printf("Mismatch at %lu\n", i);
> +			break;
> +		}
> +}
> +
> +int main(void)
> +{
> +	void *addr;
> +
> +	addr = mmap(ADDR, LENGTH, PROTECTION, FLAGS, 0, 0);
> +	if (addr == MAP_FAILED) {
> +		perror("mmap");
> +		exit(1);
> +	}
> +
> +	printf("Returned address is %p\n", addr);
> +	check_bytes(addr);
> +	write_bytes(addr);
> +	read_bytes(addr);
> +
> +	munmap(addr, LENGTH);
> +
> +	return 0;
> +}
> -- 
> 1.6.3.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
