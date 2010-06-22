Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EDEC26B01E9
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 10:03:25 -0400 (EDT)
Date: Tue, 22 Jun 2010 16:02:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622140258.GE3338@quack.suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
 <20100621233628.GL3828@quack.suse.cz>
 <20100622054409.GP7869@dastard>
 <20100621231416.904c50c7.akpm@linux-foundation.org>
 <20100622100924.GQ7869@dastard>
 <20100622131745.GB3338@quack.suse.cz>
 <20100622135234.GA11561@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622135234.GA11561@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Tue 22-06-10 21:52:34, Wu Fengguang wrote:
> >   On the other hand I think we will have to come up with something
> > more clever than what I do now because for some huge machines with
> > nr_cpu_ids == 256, the error of the counter is 256*9*8 = 18432 so that's
> > already unacceptable given the amounts we want to check (like 1536) -
> > already for nr_cpu_ids == 32, the error is the same as the difference we
> > want to check.  I think we'll have to come up with some scheme whose error
> > is not dependent on the number of cpus or if it is dependent, it's only a
> > weak dependency (like a logarithm or so).
> >   Or we could rely on the fact that IO completions for a bdi won't happen on
> > all CPUs and thus the error would be much more bounded. But I'm not sure
> > how much that is true or not.
> 
> Yes the per CPU counter seems tricky. How about plain atomic operations? 
> 
> This test shows that atomic_dec_and_test() is about 4.5 times slower
> than plain i-- in a 4-core CPU. Not bad.
> 
> Note that
> 1) we can avoid the atomic operations when there are no active waiters
> 2) most writeback will be submitted by one per-bdi-flusher, so no worry
>    of cache bouncing (this also means the per CPU counter error is
>    normally bounded by the batch size)
  Yes, writeback will be submitted by one flusher thread but the question
is rather where the writeback will be completed. And that depends on which
CPU that particular irq is handled. As far as my weak knowledge of HW goes,
this very much depends on the system configuration (i.e., irq affinity and
other things).

> 3) the cost of atomic inc/dec will be weakly related to core numbers
>    but never socket numbers (based on 2), so won't scale too bad

								Honza

> ---
> $ perf stat ./atomic
> 
>  Performance counter stats for './atomic':
> 
>          903.875304  task-clock-msecs         #      0.998 CPUs 
>                  76  context-switches         #      0.000 M/sec
>                   0  CPU-migrations           #      0.000 M/sec
>                  98  page-faults              #      0.000 M/sec
>          3011186459  cycles                   #   3331.418 M/sec
>          1608926490  instructions             #      0.534 IPC  
>           301481656  branches                 #    333.543 M/sec
>               94932  branch-misses            #      0.031 %    
>               88687  cache-references         #      0.098 M/sec
>                1286  cache-misses             #      0.001 M/sec
> 
>         0.905576197  seconds time elapsed
> 
> $ perf stat ./non-atomic
> 
>  Performance counter stats for './non-atomic':
> 
>          215.315814  task-clock-msecs         #      0.996 CPUs 
>                  18  context-switches         #      0.000 M/sec
>                   0  CPU-migrations           #      0.000 M/sec
>                  99  page-faults              #      0.000 M/sec
>           704358635  cycles                   #   3271.281 M/sec
>           303445790  instructions             #      0.431 IPC  
>           100574889  branches                 #    467.104 M/sec
>               39323  branch-misses            #      0.039 %    
>               36064  cache-references         #      0.167 M/sec
>                 850  cache-misses             #      0.004 M/sec
> 
>         0.216175521  seconds time elapsed
> 
> 
> --------------------------------------------------------------------------------
> $ cat atomic.c 
> #include <stdio.h> 
> 
> typedef struct {
>         int counter;
> } atomic_t;
> 
> static inline int atomic_dec_and_test(atomic_t *v)
> {      
>         unsigned char c;
> 
>         asm volatile("lock; decl %0; sete %1"
>                      : "+m" (v->counter), "=qm" (c)
>                      : : "memory");
>         return c != 0;
> }
> 
> int main(void)
> { 
>         atomic_t i;
> 
>         i.counter = 100000000;
> 
>         for (; !atomic_dec_and_test(&i);)
>                 ;
> 
>         return 0;
> }
> 
> --------------------------------------------------------------------------------
> $ cat non-atomic.c 
> #include <stdio.h> 
> 
> int main(void)
> { 
>         int i;
> 
>         for (i = 100000000; i; i--)
>                 ;
> 
>         return 0;
> }
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
