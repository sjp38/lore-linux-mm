Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAB2C6B000D
	for <linux-mm@kvack.org>; Wed, 30 May 2018 04:13:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k27-v6so14100806wre.23
        for <linux-mm@kvack.org>; Wed, 30 May 2018 01:13:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c7-v6si4475098eda.138.2018.05.30.01.13.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 01:13:57 -0700 (PDT)
Date: Wed, 30 May 2018 10:13:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 05/11] filesystem-dax: set page->index
Message-ID: <20180530081356.mohu6fx22fzd7fxb@quack2.suse.cz>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152699999778.24093.18007971664703285330.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180523084030.dvv4jbvsnzrsaz6q@quack2.suse.cz>
 <CAPcyv4gUM7Br3XONOVkNCg-mvR5U8QLq+OOc54cLpP61LXhJXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gUM7Br3XONOVkNCg-mvR5U8QLq+OOc54cLpP61LXhJXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, linux-xfs <linux-xfs@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>

On Tue 29-05-18 18:38:41, Dan Williams wrote:
> On Wed, May 23, 2018 at 1:40 AM, Jan Kara <jack@suse.cz> wrote:
> > On Tue 22-05-18 07:39:57, Dan Williams wrote:
> >> In support of enabling memory_failure() handling for filesystem-dax
> >> mappings, set ->index to the pgoff of the page. The rmap implementation
> >> requires ->index to bound the search through the vma interval tree. The
> >> index is set and cleared at dax_associate_entry() and
> >> dax_disassociate_entry() time respectively.
> >>
> >> Cc: Jan Kara <jack@suse.cz>
> >> Cc: Christoph Hellwig <hch@lst.de>
> >> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> >> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> >> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >> ---
> >>  fs/dax.c |   11 ++++++++---
> >>  1 file changed, 8 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/fs/dax.c b/fs/dax.c
> >> index aaec72ded1b6..2e4682cd7c69 100644
> >> --- a/fs/dax.c
> >> +++ b/fs/dax.c
> >> @@ -319,18 +319,22 @@ static unsigned long dax_radix_end_pfn(void *entry)
> >>       for (pfn = dax_radix_pfn(entry); \
> >>                       pfn < dax_radix_end_pfn(entry); pfn++)
> >>
> >> -static void dax_associate_entry(void *entry, struct address_space *mapping)
> >> +static void dax_associate_entry(void *entry, struct address_space *mapping,
> >> +             struct vm_area_struct *vma, unsigned long address)
> >>  {
> >> -     unsigned long pfn;
> >> +     unsigned long size = dax_entry_size(entry), pfn, index;
> >> +     int i = 0;
> >>
> >>       if (IS_ENABLED(CONFIG_FS_DAX_LIMITED))
> >>               return;
> >>
> >> +     index = linear_page_index(vma, address & ~(size - 1));
> >>       for_each_mapped_pfn(entry, pfn) {
> >>               struct page *page = pfn_to_page(pfn);
> >>
> >>               WARN_ON_ONCE(page->mapping);
> >>               page->mapping = mapping;
> >> +             page->index = index + i++;
> >>       }
> >>  }
> >
> > Hum, this just made me think: How is this going to work with XFS reflink?
> > In fact is not the page->mapping association already broken by XFS reflink?
> > Because with reflink we can have two or more mappings pointing to the same
> > physical blocks (i.e., pages in DAX case)...
> 
> Good question. I assume we are ok in the non-DAX reflink case because
> rmap of failing / poison pages is only relative to the specific page
> cache page for a given inode in the reflink. However, DAX would seem
> to break this because we only get one shared 'struct page' for all
> possible mappings of the physical file block. I think this means for
> iterating over the rmap of "where is this page mapped" would require
> iterating over the other "sibling" inodes that know about the given
> physical file block.
> 
> As far as I can see reflink+dax would require teaching kernel code
> paths that ->mapping may not be a singular relationship. Something
> along the line's of what Jerome was presenting at LSF to create a
> special value to indicate, "call back into the filesystem (or the page
> owner)" to perform this operation.
> 
> In the meantime the kernel crashes when userspace accesses poisoned
> pmem via DAX. I assume that reworking rmap for the dax+reflink case
> should not block dax poison handling? Yell if you disagree.

The thing is, up until get_user_pages() vs truncate series ("fs, dax: use
page->mapping to warn if truncate collides with a busy page" in
particular), DAX was perfectly fine with reflinks since we never needed
page->mapping. Now this series adds even page->index dependency which makes
life for rmap with reflinks even harder. So if nothing else we should at
least make sure reflinked filesystems cannot be mounted with dax mount
option for now and seriously start looking into how to implement rmap with
reflinked files for DAX because this noticeably reduces its usefulness.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
