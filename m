Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 613EA6B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 20:26:25 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so507262eek.36
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 17:26:24 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id x41si27951639eee.180.2014.03.03.17.26.23
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 17:26:24 -0800 (PST)
Date: Tue, 4 Mar 2014 03:26:13 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
Message-ID: <20140304012613.GB21508@node.dhcp.inet.fi>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20140303151611.5671eebb74cedb99aa5396c8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140303151611.5671eebb74cedb99aa5396c8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>

On Mon, Mar 03, 2014 at 03:16:11PM -0800, Andrew Morton wrote:
> On Thu, 27 Feb 2014 21:53:46 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > The patch introduces new vm_ops callback ->map_pages() and uses it for
> > mapping easy accessible pages around fault address.
> > 
> > On read page fault, if filesystem provides ->map_pages(), we try to map
> > up to FAULT_AROUND_PAGES pages around page fault address in hope to
> > reduce number of minor page faults.
> > 
> > We call ->map_pages first and use ->fault() as fallback if page by the
> > offset is not ready to be mapped (cold page cache or something).
> >
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> >
> > ...
> >
> > @@ -571,6 +576,9 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> >  		pte = pte_mkwrite(pte);
> >  	return pte;
> >  }
> > +
> > +void do_set_pte(struct vm_area_struct *vma, unsigned long address,
> > +		struct page *page, pte_t *pte, bool write, bool anon);
> >  #endif
> >  
> >  /*
> 
> lguest made a dubious naming decision:
> 
> drivers/lguest/page_tables.c:890: error: conflicting types for 'do_set_pte'
> include/linux/mm.h:593: note: previous declaration of 'do_set_pte' was here
> 
> I'll rename lguest's do_set_pte() to do_guest_set_pte() as a
> preparatory patch.

Thanks.

> btw, do_set_pte() could really do with some documentation.  It's not a
> trivial function and it does a lot of stuff.  It's exported to other
> compilation units and we should explain the what, the why and
> particularly the locking preconditions.

Like this?
