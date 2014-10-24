Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id BD34182BDA
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 00:55:33 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so780191pde.8
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 21:55:33 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id yh6si3236118pab.171.2014.10.23.21.55.31
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 21:55:32 -0700 (PDT)
Date: Fri, 24 Oct 2014 13:56:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 0/4] [RFC] slub: Fastpath optimization (especially for RT)
Message-ID: <20141024045630.GD15243@js1304-P5Q-DELUXE>
References: <20141022155517.560385718@linux.com>
 <20141023080942.GA7598@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1410230916090.19494@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1410230916090.19494@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Thu, Oct 23, 2014 at 09:18:29AM -0500, Christoph Lameter wrote:
> On Thu, 23 Oct 2014, Joonsoo Kim wrote:
> 
> > Preemption disable during very short code would cause large problem for RT?
> 
> This is the hotpath and preempt enable/disable adds a significant number
> of cycles.
> 
> > And, if page_address() and virt_to_head_page() remain as current patchset
> > implementation, this would work worse than before.
> 
> Right.
> 
> > I looked at the patchset quickly and found another idea to remove
> > preemption disable. How about just retrieving s->cpu_slab->tid first,
> > before accessing s->cpu_slab, in slab_alloc() and slab_free()?
> > Retrieved tid may ensure that we aren't migrated to other CPUs so that
> > we can remove code for preemption disable.
> 
> You cannot do any of these things because you need the tid from the right
> cpu and the scheduler can prempt you and reschedule you on another
> processor at will. tid and c may be from different per cpu areas.

I found that you said retrieving tid first is sufficient to do
things right in old discussion. :)

https://lkml.org/lkml/2013/1/18/430

Think about following 4 examples.

TID CPU_CACHE CMPX_DOUBLE
1. cpu0 cpu0 cpu0
2. cpu0 cpu0 cpu1
3. cpu0 cpu1 cpu0
4. cpu0 cpu1 cpu1

1) has no problem and will succeed.
2, 4) would be failed due to tid mismatch.
Only complicated case is scenario 3).

In this case, object from cpu1's cpu_cache should be
different with cpu0's, so allocation would be failed.

Only problem of this method is that it's not easy to understand.

Am I missing something?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
