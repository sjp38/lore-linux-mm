Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7R4hQwH009614 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 13:43:26 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7R4hP0B031744 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 13:43:25 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail505.fjmail.jp.fujitsu.com (fjmail505-0.fjmail.jp.fujitsu.com [10.59.80.104]) by s4.gw.fujitsu.co.jp (8.12.11)
	id i7R4hO3J017696 for <linux-mm@kvack.org>; Fri, 27 Aug 2004 13:43:24 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail505.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I33000IT94BL6@fjmail505.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri, 27 Aug 2004 13:43:24 +0900 (JST)
Date: Fri, 27 Aug 2004 13:48:34 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
In-reply-to: <412E8009.3080508@jp.fujitsu.com>
Message-id: <412EBD22.2090508@jp.fujitsu.com>
MIME-version: 1.0
Content-type: multipart/mixed; boundary="------------030804060106030604050102"
References: <412DD1AA.8080408@jp.fujitsu.com>
 <1093535402.2984.11.camel@nighthawk> <412E6CC3.8060908@jp.fujitsu.com>
 <20040826171840.4a61e80d.akpm@osdl.org> <412E8009.3080508@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030804060106030604050102
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Hi,
I testd set_bit()/__set_bit() ops, atomic and non atomic ops, on my Xeon.
I think this test is not perfect, but shows some aspect of pefromance of atomic ops.

Program:
the program touches memory in tight loop, using atomic and non-atomic set_bit().
memory size is 512k, L2 cache size.
I attaches it in this mail, but it is configured to my Xeon and looks ugly :).


My CPU:
from /proc/cpuinfo
vendor_id       : GenuineIntel
cpu family      : 15
model           : 2
model name      : Intel(R) XEON(TM) MP CPU 1.90GHz
stepping        : 2
cpu MHz         : 1891.582
cache size      : 512 KBCPU     : Intel Xeon 1.8GHz

Result:
[root@kanex2 atomic]# nice -10 ./test-atomics
score 0 is            64011 note: cache hit, no atomic
score 1 is           543011 note: cache hit, atomic
score 2 is           303901 note: cache hit, mixture
score 3 is           344261 note: cache miss, no atomic
score 4 is          1131085 note: cache miss, atomic
score 5 is           593443 note: cache miss, mixture
score 6 is           118455 note: cache hit, dependency, noatomic
score 7 is           416195 note: cache hit, dependency, mixture

smaller score is better.
score 0-2 shows set_bit/__set_bit performance during good cache hit rate.
score 3-5 shows set_bit/__set_bit performance during bad cache hit rate.
score 6-7 shows set_bit/__set_bit performance during good cache hit
but there is data dependency on each access in the tight loop.

To Dave:
cost of prefetch() is not here, because I found it is very sensitive to
what is done in the loop and difficult to measure in this program.
I found cost of calling prefetch is a bit high, I'll measure whether
prefetch() in buddy allocator is good or bad again.

I think this result shows I should use non-atomic ops when I can.

Thanks.
Kame

Hiroyuki KAMEZAWA wrote:
> 
> 
> Okay, I'll do more test and if I find atomic ops are slow,
> I'll add __XXXPagePrivate() macros.
> 
> ps. I usually test codes on Xeon 1.8G x 2 server.
> 
> -- Kame
> 
> Andrew Morton wrote:
> 
>> Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>>> In the previous version, I used 
>>> SetPagePrivate()/ClearPagePrivate()/PagePrivate().
>>> But these are "atomic" operation and looks very slow.
>>> This is why I doesn't used these macros in this version.
>>>
>>> My previous version, which used set_bit/test_bit/clear_bit, shows 
>>> very bad performance
>>> on my test, and I replaced it.
>>
>>
>>
>> That's surprising.  But if you do intend to use non-atomic bitops then
>> please add __SetPagePrivate() and __ClearPagePrivate()
> 
> 


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--------------030804060106030604050102
Content-Type: text/plain;
 name="test-atomics.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="test-atomics.c"

#include <stdio.h>
#include <sys/mman.h>

/* Note: this program is written for Xeon */

/*
 *   Stolen from Linux.
 *
 */
#define ADDR (*(volatile long *) addr)
/*
 * set_bit - Atomically set a bit in memory
 * @nr: the bit to set
 * @addr: the address to start counting from
 *
 * This function is atomic and may not be reordered.  See __set_bit()
 * if you do not require the atomic guarantees.
 *
 * Note: there are no guarantees that this function will not be reordered
 * on non x86 architectures, so if you are writting portable code,
 * make sure not to rely on its reordering guarantees.
 *
	 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 */

static inline void set_bit(int nr, volatile unsigned long * addr)
{
        __asm__ __volatile__( "lock ;"
                "btsl %1,%0"
			      :"=m" (ADDR)
			      :"Ir" (nr));
}


/**
 * __set_bit - Set a bit in memory
 * @nr: the bit to set
 * @addr: the address to start counting from
 *
 * Unlike set_bit(), this function is non-atomic and may be reordered.
 * If it's called on the same region of memory simultaneously, the effect
 * may be that only one operation succeeds.
 */
static inline void __set_bit(int nr, volatile unsigned long * addr)
{
        __asm__(
                "btsl %1,%0"
                :"=m" (ADDR)
                :"Ir" (nr));
}


#define rdtsc(low,high) \
     __asm__ __volatile__("rdtsc" : "=a" (low), "=d" (high))

/*
 *  Test params.
 *
 */

#define CACHESIZE     (512 * 1024) /* L2 cache size */
#define LCACHESIZE    CACHESIZE/sizeof(long)
#define PAGESIZE    4096
#define LPAGESIZE   PAGESIZE/sizeof(long)
#define MAX_TRY     (100)

#define NOCACHEMISS_NOATOMIC 0
#define NOCACHEMISS_ATOMIC   1
#define NOCACHEMISS_MIXTURE  2
#define NOATOMIC             3
#define ATOMIC               4
#define MIXTURE              5
#define NOATOMIC_DEPEND      6
#define MIXTURE_DEPEND       7
#define NR_OPS               8

char message[NR_OPS][64]={
	"cache hit, no atomic",
	"cache hit, atomic",
	"cache hit, mixture",
	"cache miss, no atomic",
	"cache miss, atomic",
	"cache miss, mixture",
	"cache hit, dependency, noatomic",
	"cache hit, dependency, mixture"
};
	
#define LINESIZE      128    /* L2 line size */
#define LLINESIZE     LINESIZE/sizeof(long)



/*
 *  function for preparing cache status
 */
void hot_cache(char *buffer,int size)
{
	memset(buffer,0,size);
	return;
}

void cold_cache(char *buffer,int size)
{
	unsigned long *addr;
	int i;
	addr = malloc(size);
	memset(addr,0,size);
	return;
}

#define prefetch(addr) \
            __asm__ __volatile__ ("prefetcht0 %0":: "m" (addr))



int  main(int argc, char *argv[]) 
{
	unsigned long long score[NR_OPS][MAX_TRY];
	unsigned long long average_score[NR_OPS];
	unsigned long *map, *addr;
	struct {
		unsigned long low;
		unsigned long high;
	} start,end;
	int try, i, j;
	unsigned long long lstart,lend;

	map = mmap(NULL, CACHESIZE, PROT_WRITE, MAP_PRIVATE | MAP_ANON, 0, 0);
	
	for(try = 0; try < MAX_TRY; try++) {
		
		/* there is no page fault, cache hit */
		hot_cache((char *)map, CACHESIZE);
		/* No atomic ops case */
		rdtsc(start.low, start.high);
		for(addr = map;addr != map + LCACHESIZE; addr += LLINESIZE * 2) {
			__set_bit(1,map);
			__set_bit(2,map + LLINESIZE);
		}
		rdtsc(end.low, end.high);
		lstart = (unsigned long long)start.high << 32 | start.low;
		lend = (unsigned long long)end.high << 32 | end.low;
		score[NOCACHEMISS_NOATOMIC][try] = lend - lstart;
		
		
		
		/* there is no page fault, small cache miss */
		hot_cache((char *)map, CACHESIZE);
		/* atomic ops case */
		rdtsc(start.low, start.high);
		for(addr = map;addr != map + LCACHESIZE; addr += LLINESIZE * 2) {
			set_bit(1,map);
			set_bit(2,map + LLINESIZE);
		}
		rdtsc(end.low, end.high);
		lstart = (unsigned long long)start.high << 32 | start.low;
		lend = (unsigned long long)end.high << 32 | end.low;
		score[NOCACHEMISS_ATOMIC][try] = lend - lstart;
		
		
		/* there is no page fault, small cache miss */
		hot_cache((char *)map, CACHESIZE);
		/* mixture case */
		rdtsc(start.low, start.high);
		for(addr = map;addr != map + LCACHESIZE; addr += LLINESIZE * 2) {
			__set_bit(1,map);
			set_bit(2,map + LLINESIZE);
		}
		rdtsc(end.low, end.high);
		lstart = (unsigned long long)start.high << 32 | start.low;
		lend = (unsigned long long)end.high << 32 | end.low;
		score[NOCACHEMISS_MIXTURE][try] = lend - lstart;

		
		/* expire cache  */
		cold_cache((char *)map, CACHESIZE);
		/* ATOMIC_ONLY case */
		rdtsc(start.low, start.high);
		for(addr = map; addr != map + LCACHESIZE; addr += LLINESIZE*2){
			__set_bit(1,addr);
			__set_bit(2,addr + LLINESIZE);
		}
		rdtsc(end.low, end.high);
		lstart = (unsigned long long)start.high << 32 | start.low;
		lend = (unsigned long long)end.high << 32 | end.low;
		score[NOATOMIC][try] = lend - lstart;
		

		/* expire cache  */
		cold_cache((char *)map, CACHESIZE);
		/* ATOMIC_ONLY case */
		rdtsc(start.low, start.high);
		for(addr = map; addr != map + LCACHESIZE; addr += LLINESIZE * 2){
			set_bit(1,addr);
			set_bit(2,addr + LLINESIZE);
		}
		rdtsc(end.low, end.high);
		lstart = (unsigned long long)start.high << 32 | start.low;
		lend = (unsigned long long)end.high << 32 | end.low;
		score[ATOMIC][try] = lend - lstart;

		
		/* expire cache  */
		cold_cache((char *)map, CACHESIZE);
		/* MIXTURE case */
		rdtsc(start.low, start.high);
		for(addr = map; addr != map + LCACHESIZE; addr += LLINESIZE * 2){
			__set_bit(1,addr);
			set_bit(2,addr + LLINESIZE);
		}
		rdtsc(end.low, end.high);
		lstart = (unsigned long long)start.high << 32 | start.low;
		lend = (unsigned long long)end.high << 32 | end.low;
		score[MIXTURE][try] = lend - lstart;

                /* hot cache  */
		hot_cache((char *)map, CACHESIZE);
		/* case with dependency */
		rdtsc(start.low, start.high);
		for(addr = map; addr != map + LCACHESIZE; addr += LLINESIZE * 2){
			__set_bit(1,addr);
			__set_bit(2,addr);
		}
		rdtsc(end.low, end.high);
		lstart = (unsigned long long)start.high << 32 | start.low;
		lend = (unsigned long long)end.high << 32 | end.low;
		score[NOATOMIC_DEPEND][try] = lend - lstart;
		
                /* expire cache  */
		hot_cache((char *)map, CACHESIZE);
		/* case with depndency */
		rdtsc(start.low, start.high);
		for(addr = map; addr != map + LCACHESIZE; addr += LLINESIZE * 2){
			__set_bit(1,addr);
			set_bit(2,addr);
		}
		rdtsc(end.low, end.high);
		lstart = (unsigned long long)start.high << 32 | start.low;
		lend = (unsigned long long)end.high << 32 | end.low;
		score[MIXTURE_DEPEND][try] = lend - lstart;
	}
	for(j = 0; j < NR_OPS; j++) {
		average_score[j] = 0;
		for(i = 0; i < try; i++) {
			average_score[j] += score[j][i];
		}
		printf("score %d is %16lld note: %s\n",j,average_score[j]/try,
		       message[j]);
	}

	return ;
	
}

--------------030804060106030604050102--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
