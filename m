Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 269546B006E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 15:49:01 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so3824017pdi.38
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 12:49:00 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pq9si9443096pac.125.2014.10.16.12.48.59
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 12:49:00 -0700 (PDT)
Date: Thu, 16 Oct 2014 15:48:15 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 04/21] mm: Allow page fault handlers to perform the
 COW
Message-ID: <20141016194815.GD11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-5-git-send-email-matthew.r.wilcox@intel.com>
 <20141016091136.GC19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016091136.GC19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 11:12:22AM +0200, Mathieu Desnoyers wrote:
> On 25-Sep-2014 04:33:21 PM, Matthew Wilcox wrote:
> > Currently COW of an XIP file is done by first bringing in a read-only
> > mapping, then retrying the fault and copying the page.  It is much more
> > efficient to tell the fault handler that a COW is being attempted (by
> > passing in the pre-allocated page in the vm_fault structure), and allow
> > the handler to perform the COW operation itself.
> > 
> > The handler cannot insert the page itself if there is already a read-only
> > mapping at that address, so allow the handler to return VM_FAULT_LOCKED
> > and set the fault_page to be NULL.  This indicates to the MM code that
> > the i_mmap_mutex is held instead of the page lock.
> 
> Why test the value of fault_page pointer rather than just test return
> flags to detect in which state the callee left i_mmap_mutex ?

Maybe my changelog isn't clear enough to a non-mm expert.  Which would
include me.  Usually page fault handlers return with the page lock
held and VM_FAULT_LOCKED set.  This patch adds the ability to return
with VM_FAULT_LOCKED set and a NULL page.  This indicates to the VM the
new possibility that the i_mmap_mutex is held instead of the page lock
(since there is no page, we cannot possibly be holding the page lock).

But we have to hold some kind of lock here, or we run the risk of a
truncate operation coming in and removing the page from the file that we
just found.  The i_mmap_mutex is not ideal (since it may become heavily
contended), but it does fix the race, and some people have interesting
ideas on how to fix the scalability problem.

> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 8981cc8..0a47817 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -208,6 +208,7 @@ struct vm_fault {
> >  	pgoff_t pgoff;			/* Logical page offset based on vma */
> >  	void __user *virtual_address;	/* Faulting virtual address */
> >  
> > +	struct page *cow_page;		/* Handler may choose to COW */
> 
> The page fault handler being very much performance sensitive, I'm
> wondering if it would not be better to move cow_page near the end of
> struct vm_fault, so that the "page" field can stay on the first
> cache line.

I think your mental arithmetic has an "off by double" there:

struct vm_fault {
        unsigned int               flags;                /*     0     4 */

        /* XXX 4 bytes hole, try to pack */

        long unsigned int          pgoff;                /*     8     8 */
        void *                     virtual_address;      /*    16     8 */
        struct page *              cow_page;             /*    24     8 */
        struct page *              page;                 /*    32     8 */
        long unsigned int          max_pgoff;            /*    40     8 */
        pte_t *                    pte;                  /*    48     8 */

        /* size: 56, cachelines: 1, members: 7 */
        /* sum members: 52, holes: 1, sum holes: 4 */
        /* last cacheline: 56 bytes */
};

> > @@ -2000,6 +2000,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
> >  	vmf.pgoff = page->index;
> >  	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> >  	vmf.page = page;
> > +	vmf.cow_page = NULL;
> 
> Could we add a FAULT_FLAG_COW_PAGE to vmf.flags, so we don't have to set
> cow_page to NULL in the common case (when it is not used) ?

I don't think we're short on bits, so I'm not opposed.  Any MM people
want to weigh in before I make this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
