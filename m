Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 2B4A86B0068
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 12:14:46 -0400 (EDT)
Date: Mon, 1 Oct 2012 18:14:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Virtual huge zero page
Message-ID: <20121001161437.GB18051@redhat.com>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120929134811.GC26989@redhat.com>
 <20120929143006.GC4110@tassilo.jf.intel.com>
 <20120929143737.GF26989@redhat.com>
 <20121001134948.GA5812@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121001134948.GA5812@otc-wbsnb-06>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On Mon, Oct 01, 2012 at 04:49:48PM +0300, Kirill A. Shutemov wrote:
> On Sat, Sep 29, 2012 at 04:37:37PM +0200, Andrea Arcangeli wrote:
> > But I agree we need to verify it before taking a decision, and that
> > the numbers are better than theory, or to rephrase it "let's check the
> > theory is right" :)
> 
> Okay, microbenchmark:
> 
> % cat test_memcmp.c 
> #include <assert.h>
> #include <stdlib.h>
> #include <string.h>
> 
> #define MB (1024ul * 1024ul)
> #define GB (1024ul * MB)
> 
> int main(int argc, char **argv)
> {
>         char *p;
>         int i;
> 
>         posix_memalign((void **)&p, 2 * MB, 8 * GB);
>         for (i = 0; i < 100; i++) {
>                 assert(memcmp(p, p + 4*GB, 4*GB) == 0);
>                 asm volatile ("": : :"memory");
>         }
>         return 0;
> }
> 
> huge zero page (initial implementation):
> 
>  Performance counter stats for './test_memcmp' (5 runs):
> 
>       32356.272845 task-clock                #    0.998 CPUs utilized            ( +-  0.13% )
>                 40 context-switches          #    0.001 K/sec                    ( +-  0.94% )
>                  0 CPU-migrations            #    0.000 K/sec                  
>              4,218 page-faults               #    0.130 K/sec                    ( +-  0.00% )
>     76,712,481,765 cycles                    #    2.371 GHz                      ( +-  0.13% ) [83.31%]
>     36,279,577,636 stalled-cycles-frontend   #   47.29% frontend cycles idle     ( +-  0.28% ) [83.35%]
>      1,684,049,110 stalled-cycles-backend    #    2.20% backend  cycles idle     ( +-  2.96% ) [66.67%]
>    134,355,715,816 instructions              #    1.75  insns per cycle        
>                                              #    0.27  stalled cycles per insn  ( +-  0.10% ) [83.35%]
>     13,526,169,702 branches                  #  418.039 M/sec                    ( +-  0.10% ) [83.31%]
>          1,058,230 branch-misses             #    0.01% of all branches          ( +-  0.91% ) [83.36%]
> 
>       32.413866442 seconds time elapsed                                          ( +-  0.13% )
> 
> virtual huge zero page (the second implementation):
> 
>  Performance counter stats for './test_memcmp' (5 runs):
> 
>       30327.183829 task-clock                #    0.998 CPUs utilized            ( +-  0.13% )
>                 38 context-switches          #    0.001 K/sec                    ( +-  1.53% )
>                  0 CPU-migrations            #    0.000 K/sec                  
>              4,218 page-faults               #    0.139 K/sec                    ( +-  0.01% )
>     71,964,773,660 cycles                    #    2.373 GHz                      ( +-  0.13% ) [83.35%]
>     31,191,284,231 stalled-cycles-frontend   #   43.34% frontend cycles idle     ( +-  0.40% ) [83.32%]
>        773,484,474 stalled-cycles-backend    #    1.07% backend  cycles idle     ( +-  6.61% ) [66.67%]
>    134,982,215,437 instructions              #    1.88  insns per cycle        
>                                              #    0.23  stalled cycles per insn  ( +-  0.11% ) [83.32%]
>     13,509,150,683 branches                  #  445.447 M/sec                    ( +-  0.11% ) [83.34%]
>          1,017,667 branch-misses             #    0.01% of all branches          ( +-  1.07% ) [83.32%]
> 
>       30.381324695 seconds time elapsed                                          ( +-  0.13% )
> 
> On Westmere-EX virtual huge zero page is ~6.7% faster.

Great test thanks!

So the cache benefit is quite significant, and the TLB gains don't
offset the cache loss of the physical zero page. My call was wrong...

I get the same results as you did.

Now let's tweak the benchmark to test a "seeking" workload more
favorable to the physical 2M page by stressing the TLB.


===
#include <assert.h>
#include <stdlib.h>
#include <string.h>

#define MB (1024ul * 1024ul)
#define GB (1024ul * MB)

int main(int argc, char **argv)
{
	char *p;
	int i;

	posix_memalign((void **)&p, 2 * MB, 8 * GB);
	for (i = 0; i < 1000; i++) {
		char *_p = p;
		while (_p < p+4*GB) {
			assert(*_p == *(_p+4*GB));
			_p += 4096;
			asm volatile ("": : :"memory");
		}
	}
	return 0;
}
===

results:

virtual zeropage: char comparison seeking in 4G range 1000 times

 Performance counter stats for './zeropage-bench2' (3 runs):

      20624.051801 task-clock                #    0.999 CPUs utilized            ( +-  0.17% )
             1,762 context-switches          #    0.085 K/sec                    ( +-  1.05% )
                 1 CPU-migrations            #    0.000 K/sec                    ( +- 50.00% )
             4,221 page-faults               #    0.205 K/sec                  
    60,182,028,883 cycles                    #    2.918 GHz                      ( +-  0.17% ) [40.00%]
    56,958,431,315 stalled-cycles-frontend   #   94.64% frontend cycles idle     ( +-  0.16% ) [40.02%]
    54,966,753,363 stalled-cycles-backend    #   91.33% backend  cycles idle     ( +-  0.10% ) [40.03%]
     8,606,418,680 instructions              #    0.14  insns per cycle        
                                             #    6.62  stalled cycles per insn  ( +-  0.39% ) [50.03%]
     2,142,535,994 branches                  #  103.885 M/sec                    ( +-  0.20% ) [50.03%]
           115,916 branch-misses             #    0.01% of all branches          ( +-  3.86% ) [50.03%]
     3,209,731,169 L1-dcache-loads           #  155.630 M/sec                    ( +-  0.45% ) [50.01%]
       264,297,418 L1-dcache-load-misses     #    8.23% of all L1-dcache hits    ( +-  0.02% ) [50.00%]
         6,732,362 LLC-loads                 #    0.326 M/sec                    ( +-  0.23% ) [39.99%]
         4,981,319 LLC-load-misses           #   73.99% of all LL-cache hits     ( +-  0.74% ) [39.98%]

      20.649561185 seconds time elapsed                                          ( +-  0.19% )

physical zeropage: char comparison seeking in 4G range 1000 times

 Performance counter stats for './zeropage-bench2' (3 runs):

       2719.512443 task-clock                #    0.999 CPUs utilized            ( +-  0.34% )
               234 context-switches          #    0.086 K/sec                    ( +-  1.00% )
                 0 CPU-migrations            #    0.000 K/sec                  
             4,221 page-faults               #    0.002 M/sec                  
     7,927,948,993 cycles                    #    2.915 GHz                      ( +-  0.17% ) [39.95%]
     4,780,183,162 stalled-cycles-frontend   #   60.30% frontend cycles idle     ( +-  0.58% ) [40.14%]
     2,246,666,029 stalled-cycles-backend    #   28.34% backend  cycles idle     ( +-  3.59% ) [40.19%]
     8,380,516,407 instructions              #    1.06  insns per cycle        
                                             #    0.57  stalled cycles per insn  ( +-  0.13% ) [50.21%]
     2,095,233,526 branches                  #  770.445 M/sec                    ( +-  0.08% ) [50.24%]
            24,586 branch-misses             #    0.00% of all branches          ( +- 11.77% ) [50.19%]
     3,151,778,195 L1-dcache-loads           # 1158.950 M/sec                    ( +-  0.01% ) [50.05%]
     1,051,317,291 L1-dcache-load-misses     #   33.36% of all L1-dcache hits    ( +-  0.02% ) [49.96%]
     1,049,134,961 LLC-loads                 #  385.781 M/sec                    ( +-  0.13% ) [39.92%]
             6,222 LLC-load-misses           #    0.00% of all LL-cache hits     ( +- 35.68% ) [39.93%]

       2.722077632 seconds time elapsed                                          ( +-  0.34% )

NOTE: I used taskset -c 0 in all tests here to reduce the error (this
is also a NUMA system and AutoNUMA wasn't patched in for this test to
avoid the risk of rejects in "git am").

(it would have been prettier if I added the TLB data performance
counters, whatever too late ;)

So in this case the compute time increases 658% with the 2m virtual
page, and the 2M physical page wins by a wide margin.

So my preference is still for the physical zero page even if it wastes
2m-4k RAM and increases the compute time 6% in the worst case.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
