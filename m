Message-ID: <BAY109-F296EA35064E4776924411690C90@phx.gbl>
From: "Chip Kerchner" <timberdogsw2@hotmail.com>
Subject: Problems with hugepage read speed
Date: Mon, 18 Dec 2006 13:57:11 -0800
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  I recently added hugepage support to my program and am seeing a strange 
behavior.  When I write data to a hugepage, I am seeing about a 100% 
improvement versus normal pages.  But when I read data from a hugepage, I am 
seeing anywhere from 15-35% decrease in speed versus normal
pages.  I was wondering if anyone can help me resolve this problem or at 
least point me to someone that can?

I am running my tests on a Woodcrest machine (Core Duo).  I have setup my 
machine to have 1024 hugepage pages, each of which is 2MB.

Here is my info:

uname -a
Linux woodcrest 2.6.9-34.ELsmp #1 SMP Fri Feb 24 16:56:28 EST 2006
x86_64 x86_64 x86_64 GNU/Linux

grep -i huge /proc/meminfo
23:HugePages_Total:  1024
24:HugePages_Free:   1024
25:Hugepagesize:     2048 kB

Here is my program in question:

#define HUGE_PAGE_SIZE (2048 * 1024)

  if (1) {
     void **memPtr;
     size_t size;

     memPtr = NULL;

     /* Handle hugepage size requests */
     if (grpId & P3HUGEMEM_ID) {
        int shmid;

        size = (size + HUGE_PAGE_SIZE - 1) & -HUGE_PAGE_SIZE;
        if ((shmid = shmget(IPC_PRIVATE, size, (SHM_HUGETLB | IPC_CREAT | 
SHM_R | SHM_W))) != -1) {
           memPtr = shmat(shmid, (void *)SHM_ADDR, SHM_RND);
           if (memPtr == (void **)(-1)) {
              memPtr = NULL;
           }

           shmctl(shmid, IPC_RMID, NULL);
        }

        if (0 != errno) {
//            printf("errno %d %ld\n", errno, size);
//            shmdt((const void *)memPtr);
           errno = 0;
           memPtr = NULL;
           grpId &= ~P3HUGEMEM_ID;
        }

#if 1
        if (NULL != memPtr) {
           printf("SUCCESS!!! %p\n", memPtr);
           {
              ticks p3ticks;
              char *ptr;
              void **newPtr, **readPtr;
              int i;

              p3ticks = getticks();
              memset(memPtr, 0, size);
              p3ticks = getticks() - p3ticks;
              printf("Huge   write ticks %12llu size = %9ld\n", p3ticks, 
size);
              newPtr = memalign(align, size);
              p3ticks = getticks();
              memset(newPtr, 0, size);
              p3ticks = getticks() - p3ticks;
              printf("Normal write ticks %12llu size = %9ld\n", p3ticks, 
size);
              free(newPtr);
              readPtr = malloc(size);
              ptr = (char *)readPtr;
              for (i = 0; i < size; i++) {
                 *ptr++ = (char)(rand() & 0xff);
              }
              p3ticks = getticks();
              memcpy(readPtr, memPtr, size);
              p3ticks = getticks() - p3ticks;
              printf("Huge   read  ticks %12llu size = %9ld\n", p3ticks, 
size);
              free(readPtr);
              newPtr = memalign(align, size);
              readPtr = malloc(size);
              ptr = (char *)readPtr;
              for (i = 0; i < size; i++) {
                 *ptr++ = (char)(rand() & 0xff);
              }
              p3ticks = getticks();
              memcpy(readPtr, newPtr, size);
              p3ticks = getticks() - p3ticks;
              printf("Normal read  ticks %12llu size = %9ld\n", p3ticks, 
size);
              free(newPtr);
              free(readPtr);
           }
        }
#endif
     }

     if (NULL == memPtr) {
        memPtr = memalign(align, size);
     }

Here is the output to my program:

SUCCESS!!! 0x2a9a000000
Huge   write ticks      6513570 size =   6291456
Normal write ticks     12884967 size =   6291456
Huge   read  ticks     11098737 size =   6291456
Normal read  ticks      8490375 size =   6291456
SUCCESS!!! 0x2ac8800000
Huge   write ticks     47046024 size =  35651584
Normal write ticks     73629720 size =  35651584
Huge   read  ticks     71786745 size =  35651584
Normal read  ticks     61150383 size =  35651584

I also tried another experiment in which I disabled hugepages and instead
used "normal" shared memory.

//         if ((shmid = shmget(IPC_PRIVATE, size, (SHM_HUGETLB | IPC_CREAT | 
SHM_R | SHM_W))) != -1) {
        if ((shmid = shmget(IPC_PRIVATE, size, (IPC_CREAT | SHM_R | SHM_W))) 
!= -1) {

Here is the output of my run:

SUCCESS!!! 0x2a9972b000
Huge   write ticks     15128199 size =   6291456
Normal write ticks     13281534 size =   6291456
Huge   read  ticks     11150388 size =   6291456
Normal read  ticks      8560305 size =   6291456

So it seems that shared memory is slower both for reads and writes (by
about 20%).  That would imply that hugepages have a problem/bug with its
shared memory approach (at least for 2.6.9).  I posted my original email

Chip Kerchner

_________________________________________________________________
Dave vs. Carl: The Insignificant Championship Series.  Who will win? 
http://clk.atdmt.com/MSN/go/msnnkwsp0070000001msn/direct/01/?href=http://davevscarl.spaces.live.com/?icid=T001MSN38C07001

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
