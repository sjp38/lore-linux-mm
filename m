Date: Thu, 14 Sep 2000 14:59:04 +0200
From: Wichert Akkerman <wichert@soil.nl>
Subject: Running out of memory in 1 easy step
Message-ID: <20000914145904.B18741@liacs.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii


I have a small test program that consistently can't allocate more
memory using mmap after 458878 allocations, no matter how much memory
I allocate per call (tried with 8, 80, 800 and 4000 bytes per call):
mmap returns ENOMEM. The machine has plenty memory available (2Gb
and no other processes are running except standard daemons) so there
should be enough memory.

Some added printk statements in mm/mmap.c do_mmap_pgoff() revealed
this happens at the following bit of code:

        /* Obtain the address to map to. we verify (or select) it and ensure
         * that it represents a valid section of the address space.
         */
        if (flags & MAP_FIXED) {
                if (addr & ~PAGE_MASK)
                        return -EINVAL;
        } else {
                addr = get_unmapped_area(addr, len);
                if (!addr) {
                        printk("do_mmap_pgoff: cannot allocate unmapped memory, returning ENOMEM\n");
                        return -ENOMEM;
                }
        }

Silly test program is attached (I didn't write it, so don't punish me for
the ugly code :).

Wichert.

-- 
  _________________________________________________________________
 / Generally uninteresting signature - ignore at your convenience  \
| wichert@liacs.nl                    http://www.liacs.nl/~wichert/ |
| 1024D/2FA3BC2D 576E 100B 518D 2F16 36B0  2805 3CB8 9250 2FA3 BC2D |


--IS0zKkzwUGydFO0o
Content-Type: text/x-csrc
Content-Disposition: attachment; filename="mem3.c"

#include <unistd.h>
#include <sys/mman.h>
  
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
int main(){
  int k;
   unsigned int m,p;
   const int mem=800000000;
   int len;
   double **dptr;

   m=sizeof(double)+sizeof(double*);
   len=mem/m;
printf("Will allocate %d bytes in %d blocks\n", mem, len);
   dptr = (double **) malloc(sizeof(double*)*len) ;
   for(k=0; k<len; k++) {
     dptr[k] = (double *) mmap(NULL, 500*sizeof(double), PROT_READ|PROT_WRITE, (MAP_PRIVATE|MAP_ANONYMOUS), -1, 0);
     if(dptr[k]==MAP_FAILED) {
	printf("Allocation error: %s\n", strerror(errno));
       printf("k: %d\n",k);
       printf("Alloc Null\n");
getchar();
       exit(-1);
     }
     *(dptr[k]) = rand();
   }
   for(k=len-1; k>=0; k--) {
     printf("value: %d",*(dptr[k]));
   }
   fprintf(stderr,"k=%d mem=%d MB\n",k,mem/1000000);
   exit (0);
 }


--IS0zKkzwUGydFO0o--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
