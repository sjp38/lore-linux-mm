Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 381B36B025B
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 13:09:02 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so16382275pab.0
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 10:09:02 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ps1si59560039pbc.14.2015.11.17.10.09.01
        for <linux-mm@kvack.org>;
        Tue, 17 Nov 2015 10:09:01 -0800 (PST)
Date: Tue, 17 Nov 2015 11:08:58 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 07/11] mm: add find_get_entries_tag()
Message-ID: <20151117180858.GB28024@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-8-git-send-email-ross.zwisler@linux.intel.com>
 <20151116224222.GW19199@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151116224222.GW19199@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Nov 17, 2015 at 09:42:22AM +1100, Dave Chinner wrote:
> On Fri, Nov 13, 2015 at 05:06:46PM -0700, Ross Zwisler wrote:
> > Add find_get_entries_tag() to the family of functions that include
> > find_get_entries(), find_get_pages() and find_get_pages_tag().  This is
> > needed for DAX dirty page handling because we need a list of both page
> > offsets and radix tree entries ('indices' and 'entries' in this function)
> > that are marked with the PAGECACHE_TAG_TOWRITE tag.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  include/linux/pagemap.h |  3 +++
> >  mm/filemap.c            | 61 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 64 insertions(+)
> > 
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index a6c78e0..6fea3be 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -354,6 +354,9 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
> >  			       unsigned int nr_pages, struct page **pages);
> >  unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
> >  			int tag, unsigned int nr_pages, struct page **pages);
> > +unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> > +			int tag, unsigned int nr_entries,
> > +			struct page **entries, pgoff_t *indices);
> >  
> >  struct page *grab_cache_page_write_begin(struct address_space *mapping,
> >  			pgoff_t index, unsigned flags);
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index d5e94fd..89ab448 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1454,6 +1454,67 @@ repeat:
> >  }
> >  EXPORT_SYMBOL(find_get_pages_tag);
> >  
> > +/**
> > + * find_get_entries_tag - find and return entries that match @tag
> > + * @mapping:	the address_space to search
> > + * @start:	the starting page cache index
> > + * @tag:	the tag index
> > + * @nr_entries:	the maximum number of entries
> > + * @entries:	where the resulting entries are placed
> > + * @indices:	the cache indices corresponding to the entries in @entries
> > + *
> > + * Like find_get_entries, except we only return entries which are tagged with
> > + * @tag.
> > + */
> > +unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> > +			int tag, unsigned int nr_entries,
> > +			struct page **entries, pgoff_t *indices)
> > +{
> > +	void **slot;
> > +	unsigned int ret = 0;
> > +	struct radix_tree_iter iter;
> > +
> > +	if (!nr_entries)
> > +		return 0;
> > +
> > +	rcu_read_lock();
> > +restart:
> > +	radix_tree_for_each_tagged(slot, &mapping->page_tree,
> > +				   &iter, start, tag) {
> > +		struct page *page;
> > +repeat:
> > +		page = radix_tree_deref_slot(slot);
> > +		if (unlikely(!page))
> > +			continue;
> > +		if (radix_tree_exception(page)) {
> > +			if (radix_tree_deref_retry(page))
> > +				goto restart;
> 
> That restart condition looks wrong. ret can be non-zero, but we
> start looking from the original start index again, resulting in
> duplicates being added to the return arrays...

This same restart logic is used in all the functions in this family:
find_get_entry() (though the tag is "repeat"), find_get_entries(),
find_get_pages(), find_get_pages_contig() and find_get_pages_tag().

Most don't have it well commented, but there is a good comment in
find_get_pages():

	if (radix_tree_exception(page)) {                               
		if (radix_tree_deref_retry(page)) {                     
			/*                                              
			 * Transient condition which can only trigger   
			 * when entry at index 0 moves out of or back   
			 * to root: none yet gotten, safe to restart.   
			 */                                             
			WARN_ON(iter.index);                            
			goto restart;                                   
		}   

I think the logic is correct, but I'm happy to add this comment in
find_get_entries_tag() if it would make things clearer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
