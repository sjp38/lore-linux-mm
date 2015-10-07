Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DDCF66B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 17:39:51 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so32442858pac.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 14:39:51 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id xt5si60741942pbb.217.2015.10.07.14.39.50
        for <linux-mm@kvack.org>;
        Wed, 07 Oct 2015 14:39:51 -0700 (PDT)
Date: Wed, 7 Oct 2015 15:39:30 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 1/2] Revert "mm: take i_mmap_lock in
 unmap_mapping_range() for DAX"
Message-ID: <20151007213930.GA11743@linux.intel.com>
References: <1444170529-12814-1-git-send-email-ross.zwisler@linux.intel.com>
 <1444170529-12814-2-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4ikrVqYc4QxAaZiPMc4awh6h6WG0kP5nH=ZnuNTJVDwiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ikrVqYc4QxAaZiPMc4awh6h6WG0kP5nH=ZnuNTJVDwiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Wed, Oct 07, 2015 at 09:19:28AM -0700, Dan Williams wrote:
> On Tue, Oct 6, 2015 at 3:28 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
<snip>
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 9cb2747..5ec066f 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2426,10 +2426,17 @@ void unmap_mapping_range(struct address_space *mapping,
> >         if (details.last_index < details.first_index)
> >                 details.last_index = ULONG_MAX;
> >
> > -       i_mmap_lock_write(mapping);
> > +
> > +       /*
> > +        * DAX already holds i_mmap_lock to serialise file truncate vs
> > +        * page fault and page fault vs page fault.
> > +        */
> > +       if (!IS_DAX(mapping->host))
> > +               i_mmap_lock_write(mapping);
> >         if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
> >                 unmap_mapping_range_tree(&mapping->i_mmap, &details);
> > -       i_mmap_unlock_write(mapping);
> > +       if (!IS_DAX(mapping->host))
> > +               i_mmap_unlock_write(mapping);
> >  }
> >  EXPORT_SYMBOL(unmap_mapping_range);
> 
> What about cases where unmap_mapping_range() is called without an fs
> lock?  For the get_user_pages() and ZONE_DEVICE implementation I'm
> looking to call truncate_pagecache() from the driver shutdown path to
> revoke usage of the struct page's that were allocated by
> devm_memremap_pages().
> 
> Likely I'm introducing a path through unmap_mapping_range() that does
> not exist today, but I don't like that unmap_mapping_range() with this
> change is presuming a given locking context.  It's not clear to me how
> this routine is safe when it optionally takes i_mmap_lock_write(), at
> a minimum this needs documenting, and possibly assertions if the
> locking assumptions are violated.

Yep, this is very confusing - these changes were undone by the second revert
in the series (they were done and then undone by separate patches, both of
which are getting reverted).  After the series is applied in total
unmap_mapping_range() takes the locks unconditionally:

		/* DAX uses i_mmap_lock to serialise file truncate vs page fault */
		i_mmap_lock_write(mapping);
		if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
			unmap_mapping_range_tree(&mapping->i_mmap, &details);
		i_mmap_unlock_write(mapping);
	}
	EXPORT_SYMBOL(unmap_mapping_range);

Yes, I totally agree this is confusing - I'll just bit the bullet, collapse
the two reverts together and call it "dax locking fixes" or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
