Message-ID: <002b01c28bf0$751a3960$760010ac@edumazet>
From: "dada1" <dada1@cosmosbay.com>
References: <Pine.LNX.4.44L.0211132239370.3817-100000@imladris.surriel.com> <08a601c28bbb$2f6182a0$760010ac@edumazet> <20021114141310.A25747@infradead.org>
Subject: Re: [patch] remove hugetlb syscalls
Date: Thu, 14 Nov 2002 16:13:56 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Benjamin LaHaise <bcrl@redhat.com>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Thanks Christoph

If I asked, this is because I tried the obvious and it doesnt work.

# cat /proc/version
Linux version 2.5.47 (root@whatever.com) (gcc version 3.2) #10 Tue Nov 12
11:27:43 CET 2002
# cat /proc/sys/vm/nr_hugepages
4
# cat /proc/meminfo | grep Huge
HugePages_Total:     4
HugePages_Free:      4
Hugepagesize:     4096 kB
# mount | grep huge
whocares on /huge type hugetlbfs (rw)
# cat huge.c
#include <unistd.h>
#include <asm/unistd.h>
#include <errno.h>
#include <stdio.h>
#include <sys/mman.h>

#ifndef __NR_sys_alloc_hugepages
# define __NR_sys_alloc_hugepages 250
#endif

#define BIGSZ (4*1024*1024)

_syscall5(void *, sys_alloc_hugepages, int, key, unsigned long, addr,
size_t, len, int, prot, int, flag)

main(argc, argv)
int argc ;
char  *argv[] ;
{
char *ptr ;
int c ;
int fd = -1 ;
int nbp = 1 ;
while ((c = getopt(argc, argv, "n:f:")) != EOF) {
    switch (c) {
        case 'n':
            nbp = atoi(optarg) ; break ;
        case 'f' :
            fd = open(optarg, 2) ; break ;
        }
    }
if (fd != -1) {
    ftruncate(fd, nbp*BIGSZ) ;
    ptr = mmap(0, nbp*BIGSZ, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0) ;
        if (ptr == (char *)-1)
                ptr = mmap(0, nbp*BIGSZ, PROT_READ|PROT_WRITE, MAP_PRIVATE,
fd, 0) ;
    }
else
    ptr = sys_alloc_hugepages(0, 0, nbp*BIGSZ, PROT_READ|PROT_WRITE, 0) ;

printf("alloc %d 4Mo pages ptr=%p errno=%d\n", nbp, ptr, errno) ;

pause() ;
}

# ./huge   # (using the syscall)
alloc 1 4Mo pages ptr=0x40400000 errno=0
^C
# ls -l /huge/BIG
-rw-r--r--    1 root     root      4194304 Nov 14 15:57 /huge/BIG
# ./huge -f /huge/BIG  (using mmap)
./huge -f /huge/BIG
alloc 1 4Mo pages ptr=0xffffffff errno=22
^C
# strace ...
open("/huge/BIG", O_RDWR)               = 3
ftruncate(3, 4194304)                   = 0
mmap2(NULL, 4194304, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = -1 EINVAL
(Invalid argument)
mmap2(NULL, 4194304, PROT_READ|PROT_WRITE, MAP_PRIVATE, 3, 0) = -1 EINVAL
(Invalid argument)


Not a trivial task it seems. The syscall is very easy.. sorry.

Thanks


From: "Christoph Hellwig" <hch@infradead.org>
> On Thu, Nov 14, 2002 at 09:52:33AM +0100, dada1 wrote:
> > I beg to differ.
> >
> > I already use the syscalls.
>
> For what?
>
> > How one is supposed to use hugetlbfs ? That's not documented.
>
> mount -t hugetlbfs whocares /huge
>
> fd = open("/huge/nose", ..)
>
> mmap(.., fd, ..)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
