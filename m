Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABB860021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 07:03:39 -0500 (EST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 27 Dec 2009 13:03:11 +0100
Message-ID: <1261915391.15854.31.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-12-25 at 10:51 +0900, KAMEZAWA Hiroyuki wrote:
>  /*
> + * Returns vma which contains given address. This scans rb-tree in speculative
> + * way and increment a reference count if found. Even if vma exists in rb-tree,
> + * this function may return NULL in racy case. So, this function cannot be used
> + * for checking whether given address is valid or not.
> + */
> +struct vm_area_struct *
> +find_vma_speculative(struct mm_struct *mm, unsigned long addr)
> +{
> +       struct vm_area_struct *vma = NULL;
> +       struct vm_area_struct *vma_tmp;
> +       struct rb_node *rb_node;
> +
> +       if (unlikely(!mm))
> +               return NULL;;
> +
> +       rcu_read_lock();
> +       rb_node = rcu_dereference(mm->mm_rb.rb_node);
> +       vma = NULL;
> +       while (rb_node) {
> +               vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> +
> +               if (vma_tmp->vm_end > addr) {
> +                       vma = vma_tmp;
> +                       if (vma_tmp->vm_start <= addr)
> +                               break;
> +                       rb_node = rcu_dereference(rb_node->rb_left);
> +               } else
> +                       rb_node = rcu_dereference(rb_node->rb_right);
> +       }
> +       if (vma) {
> +               if ((vma->vm_start <= addr) && (addr < vma->vm_end)) {
> +                       if (!atomic_inc_not_zero(&vma->refcnt))

And here you destroy pretty much all advantage of having done the
lockless lookup ;-)

The idea is to let the RCU lock span whatever length you need the vma
for, the easy way is to simply use PREEMPT_RCU=y for now, the hard way
is to also incorporate the drop-mmap_sem on blocking patches from a
while ago.

> +                               vma = NULL;
> +               } else
> +                       vma = NULL;
> +       }
> +       rcu_read_unlock();
> +       return vma;
> +} 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
