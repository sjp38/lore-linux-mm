Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 724076B01FD
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 10:36:30 -0400 (EDT)
Date: Tue, 22 Jun 2010 22:36:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622143624.GA5477@localhost>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
 <20100621233628.GL3828@quack.suse.cz>
 <20100622054409.GP7869@dastard>
 <20100621231416.904c50c7.akpm@linux-foundation.org>
 <20100622100924.GQ7869@dastard>
 <20100622131745.GB3338@quack.suse.cz>
 <20100622135234.GA11561@localhost>
 <1277215254.1875.706.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1277215254.1875.706.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hch@infradead.org" <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 10:00:54PM +0800, Peter Zijlstra wrote:
> On Tue, 2010-06-22 at 21:52 +0800, Wu Fengguang wrote:
> > #include <stdio.h> 
> > 
> > typedef struct {
> >         int counter;
> > } atomic_t;
> > 
> > static inline int atomic_dec_and_test(atomic_t *v)
> > {      
> >         unsigned char c;
> > 
> >         asm volatile("lock; decl %0; sete %1"
> >                      : "+m" (v->counter), "=qm" (c)
> >                      : : "memory");
> >         return c != 0;
> > }
> > 
> > int main(void)
> > { 
> >         atomic_t i;
> > 
> >         i.counter = 100000000;
> > 
> >         for (; !atomic_dec_and_test(&i);)
> >                 ;
> > 
> >         return 0;
> > } 
> 
> This test utterly fails to stress the concurrency, you want to create
> nr_cpus threads and then pound the global variable. Then compare it
> against the per-cpu-counter variant.

I mean to test an atomic value that is mainly visited by one single CPU.

It sounds not reasonable for the IO completion IRQs to land randomly
on every CPU in the system.. when the IOs are submitted mostly by a
dedicated thread and to one single BDI (but yes, the BDI may be some
"compound" device).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
