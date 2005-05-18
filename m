From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17035.25471.122512.658772@gargle.gargle.HOWL>
Date: Wed, 18 May 2005 11:47:11 -0400
Subject: Re: [PATCH] Avoiding mmap fragmentation - clean rev
In-Reply-To: <200505172228.j4HMSkg28528@unix-os.sc.intel.com>
References: <E4BA51C8E4E9634993418831223F0A49291F06E1@scsmsx401.amr.corp.intel.com>
	<200505172228.j4HMSkg28528@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Wolfgang Wander' <wwc@rentec.com>, =?ISO-8859-1?Q?Herv=E9?= Piedvache <herve@elma.fr>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org, to@kvack.org, Herve@kvack.org, added@kvack.orgto@kvack.org, encourage@kvack.org, him@kvack.orgto@kvack.org, test@kvack.org, ken's@kvack.org, patch@kvack.org, against@kvack.org, his@kvack.org, large@kvack.org, memory@kvack.org, application@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W writes:
 > This patch tries to solve address space fragmentation issue brought
 > up by Wolfgang where fragmentation is so severe that application
 > would fail on 2.6 kernel.  Looking a bit deep into the issue, we
 > found that a lot of fragmentation were caused by suboptimal algorithm
 > in the munmap code path.  For example, as people pointed out that
 > when a series of munmap occurs, the free_area_cache would point to
 > last vma that was freed, ignoring its surrounding and not performing
 > any coalescing at all, thus artificially create more holes in the
 > virtual address space than necessary.  However, all the information
 > needed to perform coalescing are actually already there.  This patch
 > put that data in use so we will prevent artificial fragmentation.
 > 
 > This patch covers both bottom-up and top-down topology.  For bottom-up
 > topology, free_area_cache points to prev->vm_end. And for top-down,
 > free_area_cache points to next->vm_start.  The results are very promising,
 > it passes the test case that Wolfgang posted and I have tested it on a
 > variety of x86, x86_64, ia64 machines.
 > 

Hi Ken,

I have to retract my earlier statement partially.  While this patch
does address the problems with munmap's tendency to fragment the maps
areas, the issue it does not address, namely the lack of concentrating
smaller requests towards the base is indeed important to us.

With your patch the two large applications that triggered the
fragmentation issue do still fail. So we still have a regression from
2.4 kernels to 2.6 with this fix.

So I'd vote (hope it counts ;-) to either include your munmap
improvements into my earlier avoiding-fragmentation-fix or use
my (admittedly more complex) patch instead.

I will append both a test case and the (nearly) final
/proc/self/maps status of our failing application (cleansed slightly)

First the test case:

Compile via

gcc -static leakme4.c -o leakme4.c

----------------------------------------------------------------------
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <sys/mman.h>

/* logging helper function:
 *  print the request type (add or remove mmaps)
 *  and dump /proc/self/maps while counting the
 *  mapped areas between 0x10000000 and 0xf0000000
 */

void
dumpselfmaps(char w, void* p, size_t l, int printmaps)
{
  int f,i;
  int c;
  int crs = 0;
  static int count = 0;
  static size_t totsize = 0;
  char buf[65536];
  if( w == '-' )
    totsize -= l;
  else if( w == '+' )
    totsize += l;
  if( w ) {
    printf(" ------ %d %c %p-%p (%p / %p) -------", count++,
	   w, p, ((char*)p)+l, (char*)l, (char*)totsize);
  } else {
    printf(" ------ %d -------", count++);
  }
  if( printmaps )
    putchar('\n');
  fflush(stdout);
  f = open( "/proc/self/maps", O_RDONLY );

  while( (c = read( f, buf, sizeof(buf))) > 0 ) {
    if( printmaps )
      write( 1, buf, c);
    for( i = 0; i < c-1; ++i )
      if( buf[i] == '\n' &&
	  buf[i+1] != '0'  &&
	  buf[i+1] != 'f')
	++crs;
  }
  printf( "Total allocated areas: %d\n", crs );
  fflush(stdout);
  close(f);
}

/* map helper function - unmap and log request */

void* mymmap( size_t len) {
  void *m1 = mmap(0, len, PROT_READ|PROT_WRITE,
		  MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
  dumpselfmaps('+', m1, len, 0);
  if( m1 == (void*)-1)
    printf("ERROR allocating %p bytes\n", (void*)len);
  return m1;
}

/* unmap helper function - unmap and log request */
void mymunmap( void* m1, size_t len )
{
  munmap( m1, len);
  dumpselfmaps('-', m1, len, 0);
}

void
aLLocator()
{
#define k1 128
#define k2 64
  char *maps[k1];
  char *naps[k2];
  int i;
  /* allocate k1 maps of size 0x100000 */
  for( i = 0; i < k1; ++i ) 
    maps[i] = mymmap(0x100000);

  /* free every second of them - creating k1/2 holes */
  for( i = 0; i < k1; i += 2 )
    mymunmap( maps[i], 0x100000);

  /* now fill the holes with alternating 0x1000/0x100000 maps */
  for( i = 0; i < k1; i += 2 )
    maps[i] = mymmap((i & 4) ? 0x100000 : 0x1000);

  /* request some more memory of size 0x100000 */
  for( i = 0; i < k2; ++i)
    naps[i] = mymmap(0x100000);
}

int main() {
  aLLocator();
  dumpselfmaps(0,0,0,1);
  /* don't clean up ;-) */
  return 0;
}


----------------------------------------------------------------------

The output for various kernels looks like


2.4.21
[...]
08048000-080a3000 r-xp 00000000 00:82 15992029   /home/wwc/tmp/leakme4
080a3000-080a5000 rwxp 0005b000 00:82 15992029   /home/wwc/tmp/leakme4
080a5000-080c7000 rwxp 00000000 00:00 0
55555000-55575000 rwxp 00000000 00:00 0
55655000-5f656000 rwxp 00100000 00:00 0
fffec000-ffffe000 rwxp fffffffffffef000 00:00 0
Total allocated areas: 2
-------------------------

2.6.12-rc4-no-caching (removing all references to free-area-cache)
08048000-080a3000 r-xp 00000000 00:42 15992029                           /home/wwc/tmp/leakme4
080a3000-080a5000 rwxp 0005b000 00:42 15992029                           /home/wwc/tmp/leakme4
080a5000-080c7000 rwxp 080a5000 00:00 0 
55555000-55575000 rwxp 55555000 00:00 0 
55655000-5f656000 rwxp 55655000 00:00 0 
fffec000-ffffe000 rwxp fffec000 00:00 0 
ffffe000-fffff000 ---p 00000000 00:00 0 
Total allocated areas: 2
-------------------------

2.6.11.10
[...]
08048000-080a3000 r-xp 00000000 00:5a 15992029                           /home/wwc/tmp/leakme4
080a3000-080a5000 rwxp 0005b000 00:5a 15992029                           /home/wwc/tmp/leakme4
080a5000-080c7000 rwxp 080a5000 00:00 0 
55555000-55557000 rwxp 55555000 00:00 0 
55655000-55b58000 rwxp 55655000 00:00 0 
55c56000-56158000 rwxp 55c56000 00:00 0 
56256000-56758000 rwxp 56256000 00:00 0 
56856000-56d58000 rwxp 56856000 00:00 0 
56e56000-57358000 rwxp 56e56000 00:00 0 
57456000-57958000 rwxp 57456000 00:00 0 
57a56000-57f58000 rwxp 57a56000 00:00 0 
58056000-58558000 rwxp 58056000 00:00 0 
58656000-58b58000 rwxp 58656000 00:00 0 
58c56000-59158000 rwxp 58c56000 00:00 0 
59256000-59758000 rwxp 59256000 00:00 0 
59856000-59d58000 rwxp 59856000 00:00 0 
59e56000-5a358000 rwxp 59e56000 00:00 0 
5a456000-5a958000 rwxp 5a456000 00:00 0 
5aa56000-5af58000 rwxp 5aa56000 00:00 0 
5b056000-60556000 rwxp 5b056000 00:00 0 
fffec000-ffffe000 rwxp fffec000 00:00 0 
ffffe000-fffff000 ---p 00000000 00:00 0 
Total allocated areas: 17
-------------------------

2.6.12-rc4-mm2
[...]
08048000-080a3000 r-xp 00000000 00:18 15992029                           /home/wwc/tmp/leakme4
080a3000-080a5000 rwxp 0005b000 00:18 15992029                           /home/wwc/tmp/leakme4
080a5000-080c7000 rwxp 080a5000 00:00 0                                  [heap]
55555000-55575000 rwxp 55555000 00:00 0 
55655000-5f656000 rwxp 55655000 00:00 0 
fffeb000-ffffe000 rwxp fffeb000 00:00 0                                  [stack]
ffffe000-fffff000 r-xp ffffe000 00:00 0 
Total allocated areas: 2
-------------------------

2.6.12-rc4-ken
[...]
08048000-080a3000 r-xp 00000000 00:18 15992029                           /home/wwc/tmp/leakme4
080a3000-080a5000 rwxp 0005b000 00:18 15992029                           /home/wwc/tmp/leakme4
080a5000-080c7000 rwxp 080a5000 00:00 0                                  [heap]
55655000-55758000 rwxp 55655000 00:00 0 
55856000-55d58000 rwxp 55856000 00:00 0 
55e56000-56358000 rwxp 55e56000 00:00 0 
56456000-56958000 rwxp 56456000 00:00 0 
56a56000-56f58000 rwxp 56a56000 00:00 0 
57056000-57558000 rwxp 57056000 00:00 0 
57656000-57b58000 rwxp 57656000 00:00 0 
57c56000-58158000 rwxp 57c56000 00:00 0 
58256000-58758000 rwxp 58256000 00:00 0 
58856000-58d58000 rwxp 58856000 00:00 0 
58e56000-59358000 rwxp 58e56000 00:00 0 
59456000-59958000 rwxp 59456000 00:00 0 
59a56000-59f58000 rwxp 59a56000 00:00 0 
5a056000-5a558000 rwxp 5a056000 00:00 0 
5a656000-5ab58000 rwxp 5a656000 00:00 0 
5ac56000-5b158000 rwxp 5ac56000 00:00 0 
5b256000-60656000 rwxp 5b256000 00:00 0 
fffe8000-ffffe000 rwxp fffe8000 00:00 0                                  [stack]
ffffe000-fffff000 r-xp ffffe000 00:00 0 
Total allocated areas: 17
-------------------------



Now the promised /proc/self/maps of our failing application.

08048000-08150000 r-xp 00000000 00:1a 16956478                           /path/to/executable
08150000-0817a000 rwxp 00107000 00:1a 16956478                           /path/to/executable
0817a000-55554000 rwxp 0817a000 00:00 0                                  [heap]
55555000-5556b000 r-xp 00000000 08:03 239049                             /path/to/a/shared/library.so
5556b000-5556d000 rwxp 00015000 08:03 239049                             /path/to/a/shared/library.so
5556d000-5556e000 rwxp 5556d000 00:00 0 
5556e000-55692000 r-xp 00000000 00:1a 2128297                            /path/to/a/shared/library.so
55692000-556c5000 rwxp 00123000 00:1a 2128297                            /path/to/a/shared/library.so
556c5000-556c9000 rwxp 556c5000 00:00 0 
556c9000-55783000 r-xp 00000000 00:1a 21710615                           /path/to/a/shared/library.so
55783000-557ac000 rwxp 000b9000 00:1a 21710615                           /path/to/a/shared/library.so
557ac000-557b1000 rwxp 557ac000 00:00 0 
557b1000-55841000 r-xp 00000000 00:1a 2128296                            /path/to/a/shared/library.so
55841000-55866000 rwxp 0008f000 00:1a 2128296                            /path/to/a/shared/library.so
55866000-5586a000 rwxp 55866000 00:00 0 
5586a000-5593e000 r-xp 00000000 00:1a 2128288                            /path/to/a/shared/library.so
5593e000-55967000 rwxp 000d3000 00:1a 2128288                            /path/to/a/shared/library.so
55967000-5596b000 rwxp 55967000 00:00 0 
5596b000-55d91000 r-xp 00000000 00:1a 2128303                            /path/to/a/shared/library.so
55d91000-55e3b000 rwxp 00425000 00:1a 2128303                            /path/to/a/shared/library.so
55e3b000-55e49000 rwxp 55e3b000 00:00 0 
55e49000-5633d000 r-xp 00000000 00:1a 7798634                            /path/to/a/shared/library.so
5633d000-56432000 rwxp 004f3000 00:1a 7798634                            /path/to/a/shared/library.so
56432000-56440000 rwxp 56432000 00:00 0 
56440000-565fb000 r-xp 00000000 00:1a 7798638                            /path/to/a/shared/library.so
565fb000-56659000 rwxp 001ba000 00:1a 7798638                            /path/to/a/shared/library.so
56659000-56664000 rwxp 56659000 00:00 0 
56664000-567a8000 r-xp 00000000 00:1a 7798640                            /path/to/a/shared/library.so
567a8000-567f3000 rwxp 00143000 00:1a 7798640                            /path/to/a/shared/library.so
567f3000-567fc000 rwxp 567f3000 00:00 0 
567fc000-568c0000 r-xp 00000000 00:1a 7798636                            /path/to/a/shared/library.so
568c0000-568ed000 rwxp 000c3000 00:1a 7798636                            /path/to/a/shared/library.so
568ed000-568f0000 rwxp 568ed000 00:00 0 
568f0000-570a1000 r-xp 00000000 00:1a 7798632                            /path/to/a/shared/library.so
570a1000-571ee000 rwxp 007b0000 00:1a 7798632                            /path/to/a/shared/library.so
571ee000-5720f000 rwxp 571ee000 00:00 0 
5720f000-57349000 r-xp 00000000 00:1a 7798642                            /path/to/a/shared/library.so
57349000-57390000 rwxp 00139000 00:1a 7798642                            /path/to/a/shared/library.so
57390000-57395000 rwxp 57390000 00:00 0 
57395000-576b9000 r-xp 00000000 00:1a 7798628                            /path/to/a/shared/library.so
576b9000-57771000 rwxp 00323000 00:1a 7798628                            /path/to/a/shared/library.so
57771000-57779000 rwxp 57771000 00:00 0 
57779000-57c1c000 r-xp 00000000 00:1a 7798630                            /path/to/a/shared/library.so
57c1c000-57d4b000 rwxp 004a2000 00:1a 7798630                            /path/to/a/shared/library.so
57d4b000-57d59000 rwxp 57d4b000 00:00 0 
57d59000-57de4000 r-xp 00000000 00:1a 2128293                            /path/to/a/shared/library.so
57de4000-57e02000 rwxp 0008a000 00:1a 2128293                            /path/to/a/shared/library.so
57e02000-57e04000 rwxp 57e02000 00:00 0 
57e04000-57e22000 r-xp 00000000 00:1a 21710611                           /path/to/a/shared/library.so
57e22000-57e2a000 rwxp 0001d000 00:1a 21710611                           /path/to/a/shared/library.so
57e2a000-57f07000 r-xp 00000000 00:1a 7798626                            /path/to/a/shared/library.so
57f07000-57f30000 rwxp 000dc000 00:1a 7798626                            /path/to/a/shared/library.so
57f30000-57f35000 rwxp 57f30000 00:00 0 
57f35000-57f43000 r-xp 00000000 00:1a 31756329                           /path/to/a/shared/library.so
57f43000-57f44000 rwxp 0000d000 00:1a 31756329                           /path/to/a/shared/library.so
57f44000-57f48000 r-xp 00000000 00:1a 31756327                           /path/to/a/shared/library.so
57f48000-57f49000 rwxp 00003000 00:1a 31756327                           /path/to/a/shared/library.so
57f49000-580da000 r-xp 00000000 00:1a 11310621                           /path/to/a/shared/library.so
580da000-58128000 rwxp 00190000 00:1a 11310621                           /path/to/a/shared/library.so
58128000-58185000 rwxp 58128000 00:00 0 
58185000-581fc000 r-xp 00000000 00:1a 29224039                           /path/to/a/shared/library.so
581fc000-58215000 rwxp 00076000 00:1a 29224039                           /path/to/a/shared/library.so
58215000-58216000 rwxp 58215000 00:00 0 
58216000-5826a000 r-xp 00000000 00:1a 3169412                            /path/to/a/shared/library.so
5826a000-5827b000 rwxp 00053000 00:1a 3169412                            /path/to/a/shared/library.so
5827b000-5827c000 rwxp 5827b000 00:00 0 
5827c000-58332000 r-xp 00000000 00:1a 3169410                            /path/to/a/shared/library.so
58332000-58359000 rwxp 000b5000 00:1a 3169410                            /path/to/a/shared/library.so
58359000-58392000 rwxp 58359000 00:00 0 
58392000-583a1000 r-xp 00000000 00:1a 12088170                           /path/to/a/shared/library.so
583a1000-583a2000 rwxp 0000e000 00:1a 12088170                           /path/to/a/shared/library.so
583a2000-583f8000 rwxp 583a2000 00:00 0 
583f8000-58475000 r-xp 00000000 00:1a 12088172                           /path/to/a/shared/library.so
58475000-58489000 rwxp 0007c000 00:1a 12088172                           /path/to/a/shared/library.so
58489000-584c5000 r-xp 00000000 00:1a 16147984                           /path/to/a/shared/library.so
584c5000-584d3000 rwxp 0003b000 00:1a 16147984                           /path/to/a/shared/library.so
584d3000-58679000 r-xp 00000000 00:1a 16147982                           /path/to/a/shared/library.so
58679000-586ea000 rwxp 001a5000 00:1a 16147982                           /path/to/a/shared/library.so
586ea000-586fa000 rwxp 586ea000 00:00 0 
586fa000-587db000 r-xp 00000000 00:1a 16147990                           /path/to/a/shared/library.so
587db000-5880a000 rwxp 000e0000 00:1a 16147990                           /path/to/a/shared/library.so
5880a000-5946b000 rwxp 5880a000 00:00 0 
5946b000-59527000 r-xp 00000000 00:1a 16147988                           /path/to/a/shared/library.so
59527000-5954f000 rwxp 000bb000 00:1a 16147988                           /path/to/a/shared/library.so
5954f000-59554000 rwxp 5954f000 00:00 0 
59554000-596ec000 r-xp 00000000 00:1a 13771393                           /path/to/a/shared/library.so
596ec000-59746000 rwxp 00197000 00:1a 13771393                           /path/to/a/shared/library.so
59746000-59752000 rwxp 59746000 00:00 0 
59752000-598b5000 r-xp 00000000 00:1a 13771391                           /path/to/a/shared/library.so
598b5000-5991e000 rwxp 00162000 00:1a 13771391                           /path/to/a/shared/library.so
5991e000-59931000 rwxp 5991e000 00:00 0 
59931000-59abe000 r-xp 00000000 00:1a 13771389                           /path/to/a/shared/library.so
59abe000-59b34000 rwxp 0018c000 00:1a 13771389                           /path/to/a/shared/library.so
59b34000-59b47000 rwxp 59b34000 00:00 0 
59b47000-59bd7000 r-xp 00000000 00:1a 16147978                           /path/to/a/shared/library.so
59bd7000-59bf0000 rwxp 0008f000 00:1a 16147978                           /path/to/a/shared/library.so
59bf0000-59bf1000 rwxp 59bf0000 00:00 0 
59bf1000-59d07000 r-xp 00000000 00:1a 16147976                           /path/to/a/shared/library.so
59d07000-59d3a000 rwxp 00115000 00:1a 16147976                           /path/to/a/shared/library.so
59d3a000-59d3e000 rwxp 59d3a000 00:00 0 
59d3e000-5a06f000 r-xp 00000000 00:1a 16147974                           /path/to/a/shared/library.so
5a06f000-5a136000 rwxp 00330000 00:1a 16147974                           /path/to/a/shared/library.so
5a136000-5a153000 rwxp 5a136000 00:00 0 
5a153000-5a34e000 r-xp 00000000 00:1a 13771395                           /path/to/a/shared/library.so
5a34e000-5a3ce000 rwxp 001fa000 00:1a 13771395                           /path/to/a/shared/library.so
5a3ce000-5a3e3000 rwxp 5a3ce000 00:00 0 
5a3e3000-5a474000 r-xp 00000000 00:1a 15113829                           /path/to/a/shared/library.so
5a474000-5a48f000 rwxp 00090000 00:1a 15113829                           /path/to/a/shared/library.so
5a48f000-5a491000 rwxp 5a48f000 00:00 0 
5a491000-5a590000 r-xp 00000000 00:1a 23488398                           /path/to/a/shared/library.so
5a590000-5a5d1000 rwxp 000fe000 00:1a 23488398                           /path/to/a/shared/library.so
5a5d1000-5a5f5000 rwxp 5a5d1000 00:00 0 
5a5f5000-5a616000 r-xp 00000000 00:1a 23488402                           /path/to/a/shared/library.so
5a616000-5a621000 rwxp 00020000 00:1a 23488402                           /path/to/a/shared/library.so
5a621000-5a622000 rwxp 5a621000 00:00 0 
5a642000-5a67b000 r-xp 00000000 08:03 239102                             /path/to/a/shared/library.so
5a67b000-5a687000 rwxp 00038000 08:03 239102                             /path/to/a/shared/library.so
5a687000-5a689000 r-xp 00000000 08:03 239058                             /path/to/a/shared/library.so
5a689000-5a68b000 rwxp 00001000 08:03 239058                             /path/to/a/shared/library.so
5a68b000-5a6ac000 r-xp 00000000 08:03 239076                             /path/to/a/shared/library.so
5a6ac000-5a6ae000 rwxp 00020000 08:03 239076                             /path/to/a/shared/library.so
5a6ae000-5a7bd000 r-xp 00000000 08:03 239075                             /path/to/a/shared/library.so
5a7bd000-5a7be000 ---p 0010f000 08:03 239075                             /path/to/a/shared/library.so
5a7be000-5a7bf000 r-xp 0010f000 08:03 239075                             /path/to/a/shared/library.so
5a7bf000-5a7c2000 rwxp 00110000 08:03 239075                             /path/to/a/shared/library.so
5a7c2000-5a7c6000 rwxp 5a7c2000 00:00 0 
5a7c6000-5e163000 r-xs 00000000 00:1f 9351804                            /path/to/a/shared/library.so
5e163000-5fdb4000 rwxp 5e163000 00:00 0 
60061000-6475d000 rwxp 60061000 00:00 0 
6475f000-64861000 rwxp 6475f000 00:00 0 
64880000-64a80000 rwxp 64880000 00:00 0 
64aa3000-64ea3000 rwxp 64aa3000 00:00 0 
64f0c000-660ba000 rwxp 64f0c000 00:00 0 
66101000-6643f000 rwxp 66101000 00:00 0 
66528000-66728000 rwxp 66528000 00:00 0 
667f5000-669f5000 rwxp 667f5000 00:00 0 
66acf000-66fcf000 rwxp 66acf000 00:00 0 
67085000-67585000 rwxp 67085000 00:00 0 
67639000-67939000 rwxp 67639000 00:00 0 
67bf1000-67df1000 rwxp 67bf1000 00:00 0 
67ecd000-6c878000 rwxp 67ecd000 00:00 0 
6c953000-6cf53000 rwxp 6c953000 00:00 0 
6d033000-6da33000 rwxp 6d033000 00:00 0 
6da4d000-6df36000 rwxp 6da4d000 00:00 0 
6e005000-6e205000 rwxp 6e005000 00:00 0 
6e2e1000-6e6e1000 rwxp 6e2e1000 00:00 0 
6e7ca000-6f4ec000 rwxp 6e7ca000 00:00 0 
6f94a000-6fb4a000 rwxp 6f94a000 00:00 0 
6fc25000-70125000 rwxp 6fc25000 00:00 0 
701db000-705db000 rwxp 701db000 00:00 0 
708bb000-709bb000 rwxp 708bb000 00:00 0 
70a47000-71347000 rwxp 70a47000 00:00 0 
71569000-71769000 rwxp 71569000 00:00 0 
71a55000-71b55000 rwxp 71a55000 00:00 0 
720b0000-72841000 rwxp 720b0000 00:00 0 
7291c000-72b1c000 rwxp 7291c000 00:00 0 
72ead000-733a2000 rwxp 72ead000 00:00 0 
73697000-7398c000 rwxp 73697000 00:00 0 
739f4000-7456f000 rwxp 739f4000 00:00 0 
747f1000-74ff1000 rwxp 747f1000 00:00 0 
75582000-75dff000 rwxp 75582000 00:00 0 
76135000-76c14000 rwxp 76135000 00:00 0 
76f09000-77a2b000 rwxp 76f09000 00:00 0 
77ac3000-77cc3000 rwxp 77ac3000 00:00 0 
77fac000-7858d000 rwxp 77fac000 00:00 0 
7860a000-793ff000 rwxp 7860a000 00:00 0 
79407000-798fc000 rwxp 79407000 00:00 0 
799bd000-7a2bd000 rwxp 799bd000 00:00 0 
7a5a9000-7a895000 rwxp 7a5a9000 00:00 0 
7ae02000-7bc10000 rwxp 7ae02000 00:00 0 
7befb000-7c48c000 rwxp 7befb000 00:00 0 
7c781000-7cd12000 rwxp 7c781000 00:00 0 
7d274000-7d84c000 rwxp 7d274000 00:00 0 
7daad000-7e327000 rwxp 7daad000 00:00 0 
7e672000-7f4d6000 rwxp 7e672000 00:00 0 
7f6cd000-7fcb7000 rwxp 7f6cd000 00:00 0 
7ff7a000-8050b000 rwxp 7ff7a000 00:00 0 
807f6000-80aeb000 rwxp 807f6000 00:00 0 
80de0000-810d5000 rwxp 80de0000 00:00 0 
8131f000-818f1000 rwxp 8131f000 00:00 0 
81be6000-81edb000 rwxp 81be6000 00:00 0 
820e9000-831f5000 rwxp 820e9000 00:00 0 
834ea000-8400c000 rwxp 834ea000 00:00 0 
84294000-84b73000 rwxp 84294000 00:00 0 
850a3000-869dc000 rwxp 850a3000 00:00 0 
86c78000-86f6d000 rwxp 86c78000 00:00 0 
86f8d000-87282000 rwxp 86f8d000 00:00 0 
87809000-87afe000 rwxp 87809000 00:00 0 
8801b000-8af85000 rwxp 8801b000 00:00 0 
8b27a000-8b80b000 rwxp 8b27a000 00:00 0 
8baec000-8bde1000 rwxp 8baec000 00:00 0 
8bde4000-8e475000 rwxp 8bde4000 00:00 0 
8e76a000-8ecfb000 rwxp 8e76a000 00:00 0 
8f021000-8f8a7000 rwxp 8f021000 00:00 0 
8fb9c000-906be000 rwxp 8fb9c000 00:00 0 
906d5000-90cbf000 rwxp 906d5000 00:00 0 
90f8a000-91810000 rwxp 90f8a000 00:00 0 
91b05000-91dfa000 rwxp 91b05000 00:00 0 
92107000-923fc000 rwxp 92107000 00:00 0 
93146000-9343b000 rwxp 93146000 00:00 0 
936d7000-93cc1000 rwxp 936d7000 00:00 0 
93cf0000-942da000 rwxp 93cf0000 00:00 0 
94526000-94b10000 rwxp 94526000 00:00 0 
94da4000-9591f000 rwxp 94da4000 00:00 0 
969bf000-9729e000 rwxp 969bf000 00:00 0 
9782f000-97b24000 rwxp 9782f000 00:00 0 
97cd6000-9b0d6000 rwxp 97cd6000 00:00 0 
9b944000-9ba44000 rwxp 9b944000 00:00 0 
9bd30000-9c605000 rwxp 9bd30000 00:00 0 
9cb83000-9d16d000 rwxp 9cb83000 00:00 0 
9d448000-9d733000 rwxp 9d448000 00:00 0 
9da20000-9e2ff000 rwxp 9da20000 00:00 0 
9e5f4000-9e8e9000 rwxp 9e5f4000 00:00 0 
9ebde000-9f16f000 rwxp 9ebde000 00:00 0 
9f464000-9f9f5000 rwxp 9f464000 00:00 0 
9fcea000-a080c000 rwxp 9fcea000 00:00 0 
a9466000-a99f7000 rwxp a9466000 00:00 0 
aa573000-aa85e000 rwxp aa573000 00:00 0 
ad2d8000-ad5cd000 rwxp ad2d8000 00:00 0 
ad864000-ae143000 rwxp ad864000 00:00 0 
b762a000-b7bbb000 rwxp b762a000 00:00 0 
ba610000-bb729000 rwxp ba610000 00:00 0 
c108b000-c1380000 rwxp c108b000 00:00 0 
c1974000-c1f05000 rwxp c1974000 00:00 0 
c378f000-c3d20000 rwxp c378f000 00:00 0 
c4015000-c45a6000 rwxp c4015000 00:00 0 
c5125000-c56b6000 rwxp c5125000 00:00 0 
cfadd000-d006e000 rwxp cfadd000 00:00 0 
d2b3c000-d30cd000 rwxp d2b3c000 00:00 0 
d365e000-d3f3d000 rwxp d365e000 00:00 0 
da180000-dace7000 rwxp da180000 00:00 0 
db00c000-db38f000 rwxp db00c000 00:00 0 
db922000-dc203000 rwxp db922000 00:00 0 
dc4f8000-dca89000 rwxp dc4f8000 00:00 0 
e6eb4000-e7445000 rwxp e6eb4000 00:00 0 
e7447000-f1e01000 rwxp e7447000 00:00 0 
f486f000-f5da7000 rwxp f486f000 00:00 0 
fffd5000-ffffe000 rwxp fffd5000 00:00 0                                  [stack]
ffffe000-fffff000 r-xp ffffe000 00:00 0 

The application fails with a request for 250MB but still had more
than 1GB of memory distributed over the various holes.  All
maps are allocated via standard malloc/free calls which glibc
translates into brk/mmap calls.

                    Wolfgang
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
