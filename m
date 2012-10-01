Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 036266B0071
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 13:17:54 -0400 (EDT)
Date: Mon, 1 Oct 2012 20:18:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/3] Virtual huge zero page
Message-ID: <20121001171828.GB20915@shutemov.name>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120929134811.GC26989@redhat.com>
 <20120929143006.GC4110@tassilo.jf.intel.com>
 <20120929143737.GF26989@redhat.com>
 <20121001134948.GA5812@otc-wbsnb-06>
 <20121001161437.GB18051@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121001161437.GB18051@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On Mon, Oct 01, 2012 at 06:14:37PM +0200, Andrea Arcangeli wrote:
> On Mon, Oct 01, 2012 at 04:49:48PM +0300, Kirill A. Shutemov wrote:
> > On Sat, Sep 29, 2012 at 04:37:37PM +0200, Andrea Arcangeli wrote:
> > > But I agree we need to verify it before taking a decision, and that
> > > the numbers are better than theory, or to rephrase it "let's check the
> > > theory is right" :)
> > 
> > Okay, microbenchmark:
> > 
> > % cat test_memcmp.c 
> > #include <assert.h>
> > #include <stdlib.h>
> > #include <string.h>
> > 
> > #define MB (1024ul * 1024ul)
> > #define GB (1024ul * MB)
> > 
> > int main(int argc, char **argv)
> > {
> >         char *p;
> >         int i;
> > 
> >         posix_memalign((void **)&p, 2 * MB, 8 * GB);
> >         for (i = 0; i < 100; i++) {
> >                 assert(memcmp(p, p + 4*GB, 4*GB) == 0);
> >                 asm volatile ("": : :"memory");
> >         }
> >         return 0;
> > }
> > 
> > huge zero page (initial implementation):
> > 
> >  Performance counter stats for './test_memcmp' (5 runs):
> > 
> >       32356.272845 task-clock                #    0.998 CPUs utilized            ( +-  0.13% )
> >                 40 context-switches          #    0.001 K/sec                    ( +-  0.94% )
> >                  0 CPU-migrations            #    0.000 K/sec                  
> >              4,218 page-faults               #    0.130 K/sec                    ( +-  0.00% )
> >     76,712,481,765 cycles                    #    2.371 GHz                      ( +-  0.13% ) [83.31%]
> >     36,279,577,636 stalled-cycles-frontend   #   47.29% frontend cycles idle     ( +-  0.28% ) [83.35%]
> >      1,684,049,110 stalled-cycles-backend    #    2.20% backend  cycles idle     ( +-  2.96% ) [66.67%]
> >    134,355,715,816 instructions              #    1.75  insns per cycle        
> >                                              #    0.27  stalled cycles per insn  ( +-  0.10% ) [83.35%]
> >     13,526,169,702 branches                  #  418.039 M/sec                    ( +-  0.10% ) [83.31%]
> >          1,058,230 branch-misses             #    0.01% of all branches          ( +-  0.91% ) [83.36%]
> > 
> >       32.413866442 seconds time elapsed                                          ( +-  0.13% )
> > 
> > virtual huge zero page (the second implementation):
> > 
> >  Performance counter stats for './test_memcmp' (5 runs):
> > 
> >       30327.183829 task-clock                #    0.998 CPUs utilized            ( +-  0.13% )
> >                 38 context-switches          #    0.001 K/sec                    ( +-  1.53% )
> >                  0 CPU-migrations            #    0.000 K/sec                  
> >              4,218 page-faults               #    0.139 K/sec                    ( +-  0.01% )
> >     71,964,773,660 cycles                    #    2.373 GHz                      ( +-  0.13% ) [83.35%]
> >     31,191,284,231 stalled-cycles-frontend   #   43.34% frontend cycles idle     ( +-  0.40% ) [83.32%]
> >        773,484,474 stalled-cycles-backend    #    1.07% backend  cycles idle     ( +-  6.61% ) [66.67%]
> >    134,982,215,437 instructions              #    1.88  insns per cycle        
> >                                              #    0.23  stalled cycles per insn  ( +-  0.11% ) [83.32%]
> >     13,509,150,683 branches                  #  445.447 M/sec                    ( +-  0.11% ) [83.34%]
> >          1,017,667 branch-misses             #    0.01% of all branches          ( +-  1.07% ) [83.32%]
> > 
> >       30.381324695 seconds time elapsed                                          ( +-  0.13% )
> > 
> > On Westmere-EX virtual huge zero page is ~6.7% faster.
> 
> Great test thanks!
> 
> So the cache benefit is quite significant, and the TLB gains don't
> offset the cache loss of the physical zero page. My call was wrong...
> 
> I get the same results as you did.
> 
> Now let's tweak the benchmark to test a "seeking" workload more
> favorable to the physical 2M page by stressing the TLB.
> 
> 
> ===
> #include <assert.h>
> #include <stdlib.h>
> #include <string.h>
> 
> #define MB (1024ul * 1024ul)
> #define GB (1024ul * MB)
> 
> int main(int argc, char **argv)
> {
> 	char *p;
> 	int i;
> 
> 	posix_memalign((void **)&p, 2 * MB, 8 * GB);
> 	for (i = 0; i < 1000; i++) {
> 		char *_p = p;
> 		while (_p < p+4*GB) {
> 			assert(*_p == *(_p+4*GB));
> 			_p += 4096;
> 			asm volatile ("": : :"memory");
> 		}
> 	}
> 	return 0;
> }

Results on my machine:

vitual zeropage:
 Performance counter stats for 'taskset -c 0 ./test_memcmp2' (5 runs):

      27313.891128 task-clock                #    0.998 CPUs utilized            ( +-  0.24% )
                62 context-switches          #    0.002 K/sec                    ( +-  0.61% )
             4,384 page-faults               #    0.160 K/sec                    ( +-  0.01% )
    64,747,374,606 cycles                    #    2.370 GHz                      ( +-  0.24% ) [33.33%]
    61,341,580,278 stalled-cycles-frontend   #   94.74% frontend cycles idle     ( +-  0.26% ) [33.33%]
    56,702,237,511 stalled-cycles-backend    #   87.57% backend  cycles idle     ( +-  0.07% ) [33.33%]
    10,033,724,846 instructions              #    0.15  insns per cycle        
                                             #    6.11  stalled cycles per insn  ( +-  0.09% ) [41.65%]
     2,190,424,932 branches                  #   80.195 M/sec                    ( +-  0.12% ) [41.66%]
         1,028,630 branch-misses             #    0.05% of all branches          ( +-  1.50% ) [41.66%]
     3,302,006,540 L1-dcache-loads
          #  120.891 M/sec                    ( +-  0.11% ) [41.68%]
       271,374,358 L1-dcache-misses
         #    8.22% of all L1-dcache hits    ( +-  0.04% ) [41.66%]
        20,385,476 LLC-load
                 #    0.746 M/sec                    ( +-  1.64% ) [33.34%]
            76,754 LLC-misses
               #    0.38% of all LL-cache hits     ( +-  2.35% ) [33.34%]
     3,309,927,290 dTLB-loads
               #  121.181 M/sec                    ( +-  0.03% ) [33.34%]
     2,098,967,427 dTLB-misses
              #   63.41% of all dTLB cache hits   ( +-  0.03% ) [33.34%]

      27.364448741 seconds time elapsed                                          ( +-  0.24% )

physical zeropage
 Performance counter stats for 'taskset -c 0 ./test_memcmp2' (5 runs):

       3505.727639 task-clock                #    0.998 CPUs utilized            ( +-  0.26% )
                 9 context-switches          #    0.003 K/sec                    ( +-  4.97% )
             4,384 page-faults               #    0.001 M/sec                    ( +-  0.00% )
     8,318,482,466 cycles                    #    2.373 GHz                      ( +-  0.26% ) [33.31%]
     5,134,318,786 stalled-cycles-frontend   #   61.72% frontend cycles idle     ( +-  0.42% ) [33.32%]
     2,193,266,208 stalled-cycles-backend    #   26.37% backend  cycles idle     ( +-  5.51% ) [33.33%]
     9,494,670,537 instructions              #    1.14  insns per cycle        
                                             #    0.54  stalled cycles per insn  ( +-  0.13% ) [41.68%]
     2,108,522,738 branches                  #  601.451 M/sec                    ( +-  0.09% ) [41.68%]
           158,746 branch-misses             #    0.01% of all branches          ( +-  1.60% ) [41.71%]
     3,168,102,115 L1-dcache-loads
          #  903.693 M/sec                    ( +-  0.11% ) [41.70%]
     1,048,710,998 L1-dcache-misses
         #   33.10% of all L1-dcache hits    ( +-  0.11% ) [41.72%]
     1,047,699,685 LLC-load
                 #  298.854 M/sec                    ( +-  0.03% ) [33.38%]
             2,287 LLC-misses
               #    0.00% of all LL-cache hits     ( +-  8.27% ) [33.37%]
     3,166,187,367 dTLB-loads
               #  903.147 M/sec                    ( +-  0.02% ) [33.35%]
         4,266,538 dTLB-misses
              #    0.13% of all dTLB cache hits   ( +-  0.03% ) [33.33%]

       3.513339813 seconds time elapsed                                          ( +-  0.26% )

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
