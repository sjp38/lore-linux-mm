Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 027B06B0038
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 05:51:31 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g187so40509929itc.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 02:51:30 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id o131si1813702itd.23.2016.11.16.02.51.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 02:51:30 -0800 (PST)
Date: Wed, 16 Nov 2016 11:51:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 01/21] mm: Join struct fault_env and vm_fault
Message-ID: <20161116105132.GR3142@twins.programming.kicks-ass.net>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-2-git-send-email-jack@suse.cz>
 <20161115215021.GA23021@node>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161115215021.GA23021@node>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 16, 2016 at 12:50:21AM +0300, Kirill A. Shutemov wrote:
> On Fri, Nov 04, 2016 at 05:24:57AM +0100, Jan Kara wrote:
> > Currently we have two different structures for passing fault information
> > around - struct vm_fault and struct fault_env. DAX will need more
> > information in struct vm_fault to handle its faults so the content of
> > that structure would become event closer to fault_env. Furthermore it
> > would need to generate struct fault_env to be able to call some of the
> > generic functions. So at this point I don't think there's much use in
> > keeping these two structures separate. Just embed into struct vm_fault
> > all that is needed to use it for both purposes.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> I'm not necessary dislike this, but I remember Peter had objections before
> when I proposed something similar.
> 
> Peter?

My objection was that it would be a layering violation. The 'filesystem'
shouldn't know about page-tables, all it should do is return a page
matching a specific offset.

So fault_env manages the core vm parts and has the page-table bits in,
vm_fault manages the filesystem interface and gets us a page given an
offset.

Now, I'm entirely out of touch wrt DAX, so I've not idea what that
needs/wants.

> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index a92c8d73aeaf..657eb69eb87e 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -292,10 +292,16 @@ extern pgprot_t protection_map[16];
> >   * pgoff should be used in favour of virtual_address, if possible.
> >   */
> >  struct vm_fault {
> > +	struct vm_area_struct *vma;	/* Target VMA */
> >  	unsigned int flags;		/* FAULT_FLAG_xxx flags */
> >  	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
> >  	pgoff_t pgoff;			/* Logical page offset based on vma */
> > +	unsigned long address;		/* Faulting virtual address */
> > +	void __user *virtual_address;	/* Faulting virtual address masked by
> > +					 * PAGE_MASK */
> > +	pmd_t *pmd;			/* Pointer to pmd entry matching
> > +					 * the 'address'
> > +					 */
> >  
> >  	struct page *cow_page;		/* Handler may choose to COW */
> >  	struct page *page;		/* ->fault handlers should return a

Egads, horrific commenting style that :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
