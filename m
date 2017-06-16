Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A77CA4404A3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:45:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b13so51150961pgn.4
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:45:42 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q125si2588026pgq.187.2017.06.16.12.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:45:42 -0700 (PDT)
Date: Fri, 16 Jun 2017 13:45:40 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 3/3] dax: use common 4k zero page for dax mmap reads
Message-ID: <20170616194540.GB20742@linux.intel.com>
References: <20170614172211.19820-1-ross.zwisler@linux.intel.com>
 <20170614172211.19820-4-ross.zwisler@linux.intel.com>
 <20170615145856.GO1764@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615145856.GO1764@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Jun 15, 2017 at 04:58:56PM +0200, Jan Kara wrote:
> On Wed 14-06-17 11:22:11, Ross Zwisler wrote:
> > @@ -216,17 +217,6 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
> >  	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
> >  }
> >  
> > -static void put_locked_mapping_entry(struct address_space *mapping,
> > -				     pgoff_t index, void *entry)
> > -{
> > -	if (!radix_tree_exceptional_entry(entry)) {
> > -		unlock_page(entry);
> > -		put_page(entry);
> > -	} else {
> > -		dax_unlock_mapping_entry(mapping, index);
> > -	}
> > -}
> > -
> 
> The naming becomes asymetric with this. So I'd prefer keeping
> put_locked_mapping_entry() as a trivial wrapper around
> dax_unlock_mapping_entry() unless we can craft more sensible naming / API
> for entry grabbing (and that would be a separate patch anyway).

Sure, that works for me.  I'll fix for v3.

> > -static int dax_load_hole(struct address_space *mapping, void **entry,
> > +static int dax_load_hole(struct address_space *mapping, void *entry,
> >  			 struct vm_fault *vmf)
> >  {
> >  	struct inode *inode = mapping->host;
> > -	struct page *page;
> > -	int ret;
> > -
> > -	/* Hole page already exists? Return it...  */
> > -	if (!radix_tree_exceptional_entry(*entry)) {
> > -		page = *entry;
> > -		goto finish_fault;
> > -	}
> > +	unsigned long vaddr = vmf->address;
> > +	int ret = VM_FAULT_NOPAGE;
> > +	struct page *zero_page;
> > +	void *entry2;
> >  
> > -	/* This will replace locked radix tree entry with a hole page */
> > -	page = find_or_create_page(mapping, vmf->pgoff,
> > -				   vmf->gfp_mask | __GFP_ZERO);
> 
> With this gone, you can also remove the special DAX handling from
> mm/filemap.c: page_cache_tree_insert() and remove from dax.h
> dax_wake_mapping_entry_waiter(), dax_radix_locked_entry() and RADIX_DAX
> definitions. Yay! As a separate patch please.

Oh, yay!  :)  Sure, I'll have this patch for v3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
