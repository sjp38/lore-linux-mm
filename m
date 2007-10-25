Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PJN8N4031953
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 15:23:08 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PJN7bl042054
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:23:07 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PJN68a006776
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:23:07 -0600
Subject: Re: RFC/POC Make Page Tables Relocatable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 12:23:02 -0700
Message-Id: <1193340182.24087.54.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 14:44 -0400, Ross Biro wrote:
> On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> > > This would almost work, but to do it properly, you find you'll need
> > > some more locks and a couple of extra pointers and such.
> >
> > Could you be specific?
> 
> Well to go quickly from an arbitrary page that happens to be part of a
> page table to the appropriate mm to get a lock, I had to store a
> pointer to the mm.

Hold on a sec there.  You don't *have* to. :)

With the pagetable page you can go examine ptes.  From the ptes, you can
get the 'struct page' for the mapped page.  From there, you can get the
anon_vma and at least the list of mms that _could_ map the page.  You
get virtual addresses from the linear_page_index() or offset in the
mapping from page->index and vma->vm_pgoff and vm_start.  That should
make the search a bit more reasonable.

Slow, yes.  But, we're already talking about reclaim paths here.  

> Then I also needed to know where the particular
> page fit into the page table tree.  Once I had those, it turned out I
> needed a spinlock to protect them to deallocate the page with out
> racing against the relocation.  I think I could have used the ptl lock
> struct page, but I wasn't really clear on it when I started.
> 
> So I needed 2 pointers which I could have squeezed into struct page
> somewhere, but then what about when I needed a third or forth pointer
> to make something else work well?

I think you started out with the assumption that we needed out of page
metadata and then started adding more reasons that we needed it.  I
seriously doubt that you really and truly *NEED* four new fields in
'struct page'. :)

My guys says that this is way too complicated to be pursued in this
form.  But, don't listen to me.  You don't have to convince _me_.

If you want to pursue this, I'd concentrate on breaking your patch up in
to manageable pieces.  Don't forget diffstats at the top of your patch,
too.  If I were to start breaking this patch up, I'd probably start with
these things, but probably not in this order.  If you do it right,
you'll end up with even more pieces than this.

1. add support to slab for object relocation
2. add support to slab for object metadata
3. allocate pte pages from the slab (yet again)
4. add metadata for pagetable pages (this can be distinct from the other
   patches, and a simple implementation might just stick it in 'struct
   page' to make it easy to review at first)
5. add and use walk_page_table_*() functions
6. add need_flush tracking to the mm
7. add minimum base page size requirements to the slab
8. add relocation handles
9. your test module
10. rcu for freeing pagetables and tlb flushing
11. actual pagetable relocation code

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
