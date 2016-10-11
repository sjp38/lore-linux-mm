Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5E06B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 17:57:08 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n3so20489253lfn.5
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:57:08 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id x24si3155074lfb.64.2016.10.11.14.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 14:57:06 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id b75so5394813lfg.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:57:06 -0700 (PDT)
Date: Wed, 12 Oct 2016 00:57:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 14/41] filemap: allocate huge page in
 page_cache_read(), if allowed
Message-ID: <20161011215704.GD27110@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-15-kirill.shutemov@linux.intel.com>
 <20161011161545.GN6952@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011161545.GN6952@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Oct 11, 2016 at 06:15:45PM +0200, Jan Kara wrote:
> On Thu 15-09-16 14:54:56, Kirill A. Shutemov wrote:
> > This patch adds basic functionality to put huge page into page cache.
> > 
> > At the moment we only put huge pages into radix-tree if the range covered
> > by the huge page is empty.
> > 
> > We ignore shadow entires for now, just remove them from the tree before
> > inserting huge page.
> > 
> > Later we can add logic to accumulate information from shadow entires to
> > return to caller (average eviction time?).
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  include/linux/fs.h      |   5 ++
> >  include/linux/pagemap.h |  21 ++++++-
> >  mm/filemap.c            | 148 +++++++++++++++++++++++++++++++++++++++++++-----
> >  3 files changed, 157 insertions(+), 17 deletions(-)
> > 
> ...
> > @@ -663,16 +663,55 @@ static int __add_to_page_cache_locked(struct page *page,
> >  	page->index = offset;
> >  
> >  	spin_lock_irq(&mapping->tree_lock);
> > -	error = page_cache_tree_insert(mapping, page, shadowp);
> > +	if (PageTransHuge(page)) {
> > +		struct radix_tree_iter iter;
> > +		void **slot;
> > +		void *p;
> > +
> > +		error = 0;
> > +
> > +		/* Wipe shadow entires */
> > +		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, offset) {
> > +			if (iter.index >= offset + HPAGE_PMD_NR)
> > +				break;
> > +
> > +			p = radix_tree_deref_slot_protected(slot,
> > +					&mapping->tree_lock);
> > +			if (!p)
> > +				continue;
> > +
> > +			if (!radix_tree_exception(p)) {
> > +				error = -EEXIST;
> > +				break;
> > +			}
> > +
> > +			mapping->nrexceptional--;
> > +			rcu_assign_pointer(*slot, NULL);
> 
> I think you also need something like workingset_node_shadows_dec(node)
> here. It would be even better if you used something like
> clear_exceptional_entry() to have the logic in one place (you obviously
> need to factor out only part of clear_exceptional_entry() first).

Good point. Will do.

> > +		}
> > +
> > +		if (!error)
> > +			error = __radix_tree_insert(&mapping->page_tree, offset,
> > +					compound_order(page), page);
> > +
> > +		if (!error) {
> > +			count_vm_event(THP_FILE_ALLOC);
> > +			mapping->nrpages += HPAGE_PMD_NR;
> > +			*shadowp = NULL;
> > +			__inc_node_page_state(page, NR_FILE_THPS);
> > +		}
> > +	} else {
> > +		error = page_cache_tree_insert(mapping, page, shadowp);
> > +	}
> 
> And I'd prefer to have this logic moved to page_cache_tree_insert() because
> logically it IMHO belongs there - it is a simply another case of handling
> of radix tree used for page cache.

Okay.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
