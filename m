Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A99046B0253
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 06:01:06 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so21826532wme.4
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 03:01:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h194si6757945wmd.115.2016.11.16.03.01.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Nov 2016 03:01:05 -0800 (PST)
Date: Wed, 16 Nov 2016 12:01:01 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/21] mm: Join struct fault_env and vm_fault
Message-ID: <20161116110101.GE21785@quack2.suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-2-git-send-email-jack@suse.cz>
 <20161115215021.GA23021@node>
 <20161116105132.GR3142@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161116105132.GR3142@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 16-11-16 11:51:32, Peter Zijlstra wrote:
> On Wed, Nov 16, 2016 at 12:50:21AM +0300, Kirill A. Shutemov wrote:
> > On Fri, Nov 04, 2016 at 05:24:57AM +0100, Jan Kara wrote:
> > > Currently we have two different structures for passing fault information
> > > around - struct vm_fault and struct fault_env. DAX will need more
> > > information in struct vm_fault to handle its faults so the content of
> > > that structure would become event closer to fault_env. Furthermore it
> > > would need to generate struct fault_env to be able to call some of the
> > > generic functions. So at this point I don't think there's much use in
> > > keeping these two structures separate. Just embed into struct vm_fault
> > > all that is needed to use it for both purposes.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > 
> > I'm not necessary dislike this, but I remember Peter had objections before
> > when I proposed something similar.
> > 
> > Peter?
> 
> My objection was that it would be a layering violation. The 'filesystem'
> shouldn't know about page-tables, all it should do is return a page
> matching a specific offset.
> 
> So fault_env manages the core vm parts and has the page-table bits in,
> vm_fault manages the filesystem interface and gets us a page given an
> offset.
> 
> Now, I'm entirely out of touch wrt DAX, so I've not idea what that
> needs/wants.

Yeah, DAX does not have 'struct page' for its pages so it directly installs
PFNs in the page tables. As a result it needs to know about page tables and
stuff. Now I've abstracted knowledge about that into helper functions back
in mm/ but still we need to pass the information through the ->fault handler
into those helpers and vm_fault structure is simply natural for that.
So far we have tried to avoid that but the result was not pretty (special
return codes from DAX ->fault handlers essentially leaking information
about DAX internal locking into mm/ code to direct generic mm code to do
the right thing for DAX).

								Honza

> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index a92c8d73aeaf..657eb69eb87e 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -292,10 +292,16 @@ extern pgprot_t protection_map[16];
> > >   * pgoff should be used in favour of virtual_address, if possible.
> > >   */
> > >  struct vm_fault {
> > > +	struct vm_area_struct *vma;	/* Target VMA */
> > >  	unsigned int flags;		/* FAULT_FLAG_xxx flags */
> > >  	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
> > >  	pgoff_t pgoff;			/* Logical page offset based on vma */
> > > +	unsigned long address;		/* Faulting virtual address */
> > > +	void __user *virtual_address;	/* Faulting virtual address masked by
> > > +					 * PAGE_MASK */
> > > +	pmd_t *pmd;			/* Pointer to pmd entry matching
> > > +					 * the 'address'
> > > +					 */
> > >  
> > >  	struct page *cow_page;		/* Handler may choose to COW */
> > >  	struct page *page;		/* ->fault handlers should return a
> 
> Egads, horrific commenting style that :-)
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
