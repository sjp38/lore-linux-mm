Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EC5E060021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 19:39:22 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS0dJxY029896
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 09:39:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C42B45DD6F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 09:39:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 151B245DE4F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 09:39:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C82B1DB803A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 09:39:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C6531DB803E
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 09:39:15 +0900 (JST)
Date: Mon, 28 Dec 2009 09:36:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-Id: <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1261915391.15854.31.camel@laptop>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	<1261915391.15854.31.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Dec 2009 13:03:11 +0100
Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, 2009-12-25 at 10:51 +0900, KAMEZAWA Hiroyuki wrote:
> >  /*
> > + * Returns vma which contains given address. This scans rb-tree in speculative
> > + * way and increment a reference count if found. Even if vma exists in rb-tree,
> > + * this function may return NULL in racy case. So, this function cannot be used
> > + * for checking whether given address is valid or not.
> > + */
> > +struct vm_area_struct *
> > +find_vma_speculative(struct mm_struct *mm, unsigned long addr)
> > +{
> > +       struct vm_area_struct *vma = NULL;
> > +       struct vm_area_struct *vma_tmp;
> > +       struct rb_node *rb_node;
> > +
> > +       if (unlikely(!mm))
> > +               return NULL;;
> > +
> > +       rcu_read_lock();
> > +       rb_node = rcu_dereference(mm->mm_rb.rb_node);
> > +       vma = NULL;
> > +       while (rb_node) {
> > +               vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> > +
> > +               if (vma_tmp->vm_end > addr) {
> > +                       vma = vma_tmp;
> > +                       if (vma_tmp->vm_start <= addr)
> > +                               break;
> > +                       rb_node = rcu_dereference(rb_node->rb_left);
> > +               } else
> > +                       rb_node = rcu_dereference(rb_node->rb_right);
> > +       }
> > +       if (vma) {
> > +               if ((vma->vm_start <= addr) && (addr < vma->vm_end)) {
> > +                       if (!atomic_inc_not_zero(&vma->refcnt))
> 
> And here you destroy pretty much all advantage of having done the
> lockless lookup ;-)
> 
Hmm ? for single-thread apps ? This patch's purpose is not for lockless
lookup, it's just a part of work. My purpose is avoiding false-sharing.

2.6.33-rc2's score of the same test program is here.

    75.42%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irqsav
            |
            --- _raw_spin_lock_irqsave
               |
               |--49.13%-- __down_read_trylock
               |          down_read_trylock
               |          do_page_fault
               |          page_fault
               |          0x400950
               |          |
               |           --100.00%-- (nil)
               |
               |--46.92%-- __up_read
               |          up_read
               |          |
               |          |--99.99%-- do_page_fault
               |          |          page_fault
               |          |          0x400950
               |          |          (nil)
               |           --0.01%-- [...]

Most of time is used for up/down read.

Here is a comparison between
 - page fault by 8 threads on one vma
 - page fault by 8 threads on 8 vma on x86-64.

== one vma ==
# Samples: 1338964273489
#
# Overhead          Command             Shared Object  Symbol
# ........  ...............  ........................  ......
#
    26.90%  multi-fault-all  [kernel]                  [k] clear_page_c
            |
            --- clear_page_c
                __alloc_pages_nodemask
                handle_mm_fault
                do_page_fault
                page_fault
                0x400940
               |
                --100.00%-- (nil)

    20.65%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
            |
            --- _raw_spin_lock
               |
               |--85.07%-- free_pcppages_bulk
               |          free_hot_cold_page

    ....<snip>
    3.94%  multi-fault-all  [kernel]                  [k] find_vma_speculative
            |
            --- find_vma_speculative
               |
               |--99.40%-- do_page_fault
               |          page_fault
               |          0x400940
               |          |
               |           --100.00%-- (nil)
               |
                --0.60%-- page_fault
                          0x400940
                          |
                           --100.00%-- (nil)
==

== 8 vma ==
    27.98%  multi-fault-all  [kernel]                  [k] clear_page_c
            |
            --- clear_page_c
                __alloc_pages_nodemask
                handle_mm_fault
                do_page_fault
                page_fault
                0x400950
               |
                --100.00%-- (nil)

    21.91%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
            |
            --- _raw_spin_lock
               |
               |--77.01%-- free_pcppages_bulk
               |          free_hot_cold_page
               |          __pagevec_free
               |          release_pages
...<snip>

     0.21%  multi-fault-all  [kernel]                  [k] find_vma_speculative
            |
            --- find_vma_speculative
               |
               |--87.50%-- do_page_fault
               |          page_fault
               |          0x400950
               |          |
               |           --100.00%-- (nil)
               |
                --12.50%-- page_fault
                          0x400950
                          |
                           --100.00%-- (nil)
==
Yes, this atomic_inc_unless adds some overhead. But this isn't as bad as
false sharing in mmap_sem. Anyway, as Minchan pointed out, this code contains
bug. I consider this part again.


> The idea is to let the RCU lock span whatever length you need the vma
> for, the easy way is to simply use PREEMPT_RCU=y for now, 

I tried to remove his kind of reference count trick but I can't do that
without synchronize_rcu() somewhere in unmap code. I don't like that and
use this refcnt.

> the hard way
> is to also incorporate the drop-mmap_sem on blocking patches from a
> while ago.
> 
"drop-mmap_sem if block" is no help for this false-sharing problem.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
