Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD286B006E
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 11:35:12 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id p9so882852lbv.5
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 08:35:11 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id lm5si2562505lac.87.2014.10.17.08.35.09
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 08:35:09 -0700 (PDT)
Date: Fri, 17 Oct 2014 15:35:01 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <289646725.10903.1413560101974.JavaMail.zimbra@efficios.com>
In-Reply-To: <20141016194815.GD11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <1411677218-29146-5-git-send-email-matthew.r.wilcox@intel.com> <20141016091136.GC19075@thinkos.etherlink> <20141016194815.GD11522@wil.cx>
Subject: Re: [PATCH v11 04/21] mm: Allow page fault handlers to perform the
 COW
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

----- Original Message -----
> From: "Matthew Wilcox" <willy@linux.intel.com>
> To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> Cc: "Matthew Wilcox" <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
> linux-kernel@vger.kernel.org
> Sent: Thursday, October 16, 2014 9:48:15 PM
> Subject: Re: [PATCH v11 04/21] mm: Allow page fault handlers to perform the COW
> 
> On Thu, Oct 16, 2014 at 11:12:22AM +0200, Mathieu Desnoyers wrote:
> > On 25-Sep-2014 04:33:21 PM, Matthew Wilcox wrote:
[...]
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index 8981cc8..0a47817 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -208,6 +208,7 @@ struct vm_fault {
> > >  	pgoff_t pgoff;			/* Logical page offset based on vma */
> > >  	void __user *virtual_address;	/* Faulting virtual address */
> > >  
> > > +	struct page *cow_page;		/* Handler may choose to COW */
> > 
> > The page fault handler being very much performance sensitive, I'm
> > wondering if it would not be better to move cow_page near the end of
> > struct vm_fault, so that the "page" field can stay on the first
> > cache line.
> 
> I think your mental arithmetic has an "off by double" there:
> 
> struct vm_fault {
>         unsigned int               flags;                /*     0     4 */
> 
>         /* XXX 4 bytes hole, try to pack */
> 
>         long unsigned int          pgoff;                /*     8     8 */
>         void *                     virtual_address;      /*    16     8 */
>         struct page *              cow_page;             /*    24     8 */
>         struct page *              page;                 /*    32     8 */
>         long unsigned int          max_pgoff;            /*    40     8 */
>         pte_t *                    pte;                  /*    48     8 */
> 
>         /* size: 56, cachelines: 1, members: 7 */
>         /* sum members: 52, holes: 1, sum holes: 4 */
>         /* last cacheline: 56 bytes */
> };

Although it's pretty much always true that recent architectures L2 cache
lines are 64 bytes, I was more thinking about L1 cache lines, which are,
at least on moderately old Intel Pentium HW, 32 bytes in size (AFAIK
Pentium II and III).

It remains to be seen whether we care about performance that much on this
kind of HW though.

> 
> > > @@ -2000,6 +2000,7 @@ static int do_page_mkwrite(struct vm_area_struct
> > > *vma, struct page *page,
> > >  	vmf.pgoff = page->index;
> > >  	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> > >  	vmf.page = page;
> > > +	vmf.cow_page = NULL;
> > 
> > Could we add a FAULT_FLAG_COW_PAGE to vmf.flags, so we don't have to set
> > cow_page to NULL in the common case (when it is not used) ?
> 
> I don't think we're short on bits, so I'm not opposed.  Any MM people
> want to weigh in before I make this change?

Well since new HW seem to have standardized on 64-bytes L1 cache lines
(recent Intel and ARM Cortex A7 and A15), perhaps it's not worth it. However
I'd be curious if there are other architectures out there we care about
performance-wise that still have 32-byte cache lines.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
