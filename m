Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 310E16B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 02:36:53 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p12-v6so228889pfn.0
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 23:36:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f5-v6sor232031pgs.87.2018.10.22.23.36.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 23:36:51 -0700 (PDT)
Date: Mon, 22 Oct 2018 23:36:48 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181023063648.GB22110@joelaf.mtv.corp.google.com>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181020001145.GA243578@joelaf.mtv.corp.google.com>
 <20181022145006.ga2n3hjtkc2pqhub@pc636>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022145006.ga2n3hjtkc2pqhub@pc636>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Mon, Oct 22, 2018 at 04:50:06PM +0200, Uladzislau Rezki wrote:
> On Fri, Oct 19, 2018 at 05:11:45PM -0700, Joel Fernandes wrote:
> > On Fri, Oct 19, 2018 at 07:35:36PM +0200, Uladzislau Rezki (Sony) wrote:
> > > Objective
> > > ---------
> > > Initiative of improving vmalloc allocator comes from getting many issues
> > > related to allocation time, i.e. sometimes it is terribly slow. As a result
> > > many workloads which are sensitive for long (more than 1 millisecond) preemption
> > > off scenario are affected by that slowness(test cases like UI or audio, etc.).
> > > 
> > > The problem is that, currently an allocation of the new VA area is done over
> > > busy list iteration until a suitable hole is found between two busy areas.
> > > Therefore each new allocation causes the list being grown. Due to long list
> > > and different permissive parameters an allocation can take a long time on
> > > embedded devices(milliseconds).
> > 
> > I am not super familiar with the vmap allocation code, it has been some
> > years. But I have 2 comments:
> > 
> > (1) It seems the issue you are reporting is the walking of the list in
> > alloc_vmap_area().
> > 
> > Can we not solve this by just simplifying the following code?
> > 
> > 	/* from the starting point, walk areas until a suitable hole is found
> > 	 */
> > 	while (addr + size > first->va_start && addr + size <= vend) {
> > 		if (addr + cached_hole_size < first->va_start)
> > 			cached_hole_size = first->va_start - addr;
> > 		addr = ALIGN(first->va_end, align);
> > 		if (addr + size < addr)
> > 			goto overflow;
> > 
> > 		if (list_is_last(&first->list, &vmap_area_list))
> > 			goto found;
> > 
> > 		first = list_next_entry(first, list);
> > 	}
> > 
> > Instead of going through the vmap_area_list, can we not just binary search
> > the existing address-sorted vmap_area_root rbtree to find a hole? If yes,
> > that would bring down the linear search overhead. If not, why not?
> >
> vmap_area_root rb-tree is used for fast access to vmap_area knowing
> the address(any va_start). That is why we use the tree. To use that tree
> in order to check holes will require to start from the left most node or
> specified "vstart" and move forward by rb_next(). What is much slower
> than regular(list_next_entry O(1)) access in this case. 

Ah, sorry. Don't know what I was thinking, you are right.  By the way the
binder driver does something similar too for buffer allocations, maintains an
rb tree of free areas:
https://github.com/torvalds/linux/blob/master/drivers/android/binder_alloc.c#L415

> > (2) I am curious, do you have any measurements of how much time
> > alloc_vmap_area() is taking? You mentioned it takes milliseconds but I was
> > wondering if you had more finer grained function profiling measurements. And
> > also any data on how big are the lists at the time you see this issue.
> > 
> Basically it depends on how much or heavily your system uses vmalloc
> allocations. I was using CONFIG_DEBUG_PREEMPT with an extra patch. See it
> here: ftp://vps418301.ovh.net/incoming/0001-tracing-track-preemption-disable-callers.patch
> 
> As for list size. It can be easily thousands.

Understood. I will go through your patches more in the coming days, thanks!

 - Joel
