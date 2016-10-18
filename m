Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 375416B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 13:32:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h24so37822pfh.0
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 10:32:58 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p70si19796571pfa.217.2016.10.18.10.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 10:32:57 -0700 (PDT)
Date: Tue, 18 Oct 2016 11:32:55 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 12/20] mm: Factor out common parts of write fault handling
Message-ID: <20161018173255.GA26584@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-13-git-send-email-jack@suse.cz>
 <20161017220851.GA26960@linux.intel.com>
 <20161018105000.GQ3359@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018105000.GQ3359@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Oct 18, 2016 at 12:50:00PM +0200, Jan Kara wrote:
> On Mon 17-10-16 16:08:51, Ross Zwisler wrote:
> > On Tue, Sep 27, 2016 at 06:08:16PM +0200, Jan Kara wrote:
> > > Currently we duplicate handling of shared write faults in
> > > wp_page_reuse() and do_shared_fault(). Factor them out into a common
> > > function.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > ---
> > >  mm/memory.c | 78 +++++++++++++++++++++++++++++--------------------------------
> > >  1 file changed, 37 insertions(+), 41 deletions(-)
> > > 
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 63d9c1a54caf..0643b3b5a12a 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -2063,6 +2063,41 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
> > >  }
> > >  
> > >  /*
> > > + * Handle dirtying of a page in shared file mapping on a write fault.
> > > + *
> > > + * The function expects the page to be locked and unlocks it.
> > > + */
> > > +static void fault_dirty_shared_page(struct vm_area_struct *vma,
> > > +				    struct page *page)
> > > +{
> > > +	struct address_space *mapping;
> > > +	bool dirtied;
> > > +	bool page_mkwrite = vma->vm_ops->page_mkwrite;
> > 
> > I think you may need to pass in a 'page_mkwrite' parameter if you don't want
> > to change behavior.  Just checking to see of vma->vm_ops->page_mkwrite is
> > non-NULL works fine for this path:
> > 
> > do_shared_fault()
> > 	fault_dirty_shared_page()
> > 
> > and for
> > 
> > wp_page_shared()
> > 	wp_page_reuse()
> > 		fault_dirty_shared_page()
> > 
> > But for these paths:
> > 
> > wp_pfn_shared()
> > 	wp_page_reuse()
> > 		fault_dirty_shared_page()
> > 
> > and
> > 
> > do_wp_page()
> > 	wp_page_reuse()
> > 		fault_dirty_shared_page()
> > 
> > we unconditionally pass 0 for the 'page_mkwrite' parameter, even though from
> > the logic in wp_pfn_shared() especially you can see that
> > vma->vm_ops->pfn_mkwrite() must be defined some of the time.
> 
> The trick which makes this work is that for fault_dirty_shared_page() to be
> called at all, you have to set 'dirty_shared' argument to wp_page_reuse()
> and that does not happen from wp_pfn_shared() and do_wp_page() paths. So
> things work as they should. If you look somewhat later into the series,
> the patch "mm: Move part of wp_page_reuse() into the single call site"
> cleans this up to make things more obvious.
> 
> 								Honza

Ah, cool, that makes sense.

You can add:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
