Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CDA586B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 20:26:10 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so59625771pad.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 17:26:10 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l7si14375717pac.212.2016.06.15.17.26.09
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 17:26:09 -0700 (PDT)
Date: Thu, 16 Jun 2016 09:26:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160616002617.GM17127@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <20160530013926.GB8683@bbox>
 <20160531000117.GB18314@bbox>
 <575E7F0B.8010201@linux.vnet.ibm.com>
 <20160615023249.GG17127@bbox>
 <5760F970.7060805@linux.vnet.ibm.com>
MIME-Version: 1.0
In-Reply-To: <5760F970.7060805@linux.vnet.ibm.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On Wed, Jun 15, 2016 at 12:15:04PM +0530, Anshuman Khandual wrote:
> On 06/15/2016 08:02 AM, Minchan Kim wrote:
> > Hi,
> > 
> > On Mon, Jun 13, 2016 at 03:08:19PM +0530, Anshuman Khandual wrote:
> >> > On 05/31/2016 05:31 AM, Minchan Kim wrote:
> >>> > > @@ -791,6 +921,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >>> > >  	int rc = -EAGAIN;
> >>> > >  	int page_was_mapped = 0;
> >>> > >  	struct anon_vma *anon_vma = NULL;
> >>> > > +	bool is_lru = !__PageMovable(page);
> >>> > >  
> >>> > >  	if (!trylock_page(page)) {
> >>> > >  		if (!force || mode == MIGRATE_ASYNC)
> >>> > > @@ -871,6 +1002,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >>> > >  		goto out_unlock_both;
> >>> > >  	}
> >>> > >  
> >>> > > +	if (unlikely(!is_lru)) {
> >>> > > +		rc = move_to_new_page(newpage, page, mode);
> >>> > > +		goto out_unlock_both;
> >>> > > +	}
> >>> > > +
> >> > 
> >> > Hello Minchan,
> >> > 
> >> > I might be missing something here but does this implementation support the
> >> > scenario where these non LRU pages owned by the driver mapped as PTE into
> >> > process page table ? Because the "goto out_unlock_both" statement above
> >> > skips all the PTE unmap, putting a migration PTE and removing the migration
> >> > PTE steps.
> > You're right. Unfortunately, it doesn't support right now but surely,
> > it's my TODO after landing this work.
> > 
> > Could you share your usecase?
> 
> Sure.

Thanks a lot!

> 
> My driver has privately managed non LRU pages which gets mapped into user space
> process page table through f_ops->mmap() and vmops->fault() which then updates
> the file RMAP (page->mapping->i_mmap) through page_add_file_rmap(page). One thing

Hmm, page_add_file_rmap is not exported function. How does your driver can use it?
Do you use vm_insert_pfn?
What type your vma is? VM_PFNMMAP or VM_MIXEDMAP?

I want to make dummy driver to simulate your case.
It would be very helpful to implement/test pte-mapped non-lru page
migration feature. That's why I ask now.

> to note here is that the page->mapping eventually points to struct address_space
> (file->f_mapping) which belongs to the character device file (created using mknod)
> which we are using for establishing the mmap() regions in the user space.
> 
> Now as per this new framework, all the page's are to be made __SetPageMovable before
> passing the list down to migrate_pages(). Now __SetPageMovable() takes *new* struct
> address_space as an argument and replaces the existing page->mapping. Now thats the
> problem, we have lost all our connection to the existing file RMAP information. This

We could change __SetPageMovable doesn't need mapping argument.
Instead, it just marks PAGE_MAPPING_MOVABLE into page->mapping.
For that, user should take care of setting page->mapping earlier than
marking the flag.

> stands as a problem when we try to migrate these non LRU pages which are PTE mapped.
> The rmap_walk_file() never finds them in the VMA, skips all the migrate PTE steps and
> then the migration eventually fails.
> 
> Seems like assigning a new struct address_space to the page through __SetPageMovable()
> is the source of the problem. Can it take the existing (file->f_mapping) as an argument
We can set existing file->f_mapping under the page_lock.

> in there ? Sure, but then can we override file system generic ->isolate(), ->putback(),

I don't get it. Why does it override file system generic functions?

> ->migratepages() functions ? I dont think so. I am sure, there must be some work around
> to fix this problem for the driver. But we need to rethink this framework from supporting
> these mapped non LRU pages point of view.
> 
> I might be missing something here, feel free to point out.
> 
> - Anshuman
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
