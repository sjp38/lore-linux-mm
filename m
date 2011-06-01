Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3E16F6B0078
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 13:02:37 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p51H2XVi028331
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 10:02:34 -0700
Received: from pvh21 (pvh21.prod.google.com [10.241.210.213])
	by wpaz29.hot.corp.google.com with ESMTP id p51H1nMr015089
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 10:02:32 -0700
Received: by pvh21 with SMTP id 21so213pvh.15
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 10:02:32 -0700 (PDT)
Date: Wed, 1 Jun 2011 10:02:32 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/14] tmpfs: add shmem_read_mapping_page_gfp
In-Reply-To: <20110601004225.GC4433@infradead.org>
Message-ID: <alpine.LSU.2.00.1106010958390.23468@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils> <alpine.LSU.2.00.1105301739080.5482@sister.anvils> <20110601004225.GC4433@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 31 May 2011, Christoph Hellwig wrote:
> > (shmem_read_mapping_page_gfp or shmem_read_cache_page_gfp?  Generally
> > the read_mapping_page functions use the mapping's ->readpage, and the
> > read_cache_page functions use the supplied filler, so I think
> > read_cache_page_gfp was slightly misnamed.)
> 
> What about just shmem_read_page?  It's not using the pagecache, so
> no need for the mapping or cache, and the _gfp really is just a hack
> because the old pagecache APIs didn't allow to pass the gfp flags.
> For a new API there's no need for that.

I am trying to mirror what's already there, and it's conceivable that
we'll find others who want converting from read_mapping_page() to
shmem_read_mapping_page(), so I'd rather keep the similar naming.

The _gfp() thing I'm not very keen on, but can't avoid it for i915.
If anyone else needs something here, it's likely to be without _gfp().

> 
> > +static inline struct page *shmem_read_mapping_page(
> > +				struct address_space *mapping, pgoff_t index)
> > +{
> > +	return shmem_read_mapping_page_gfp(mapping, index,
> > +				mapping_gfp_mask(mapping));
> > +}
> 
> This really shouldn't be in pagemap.h.  For now probably in shmem_fs.h

Okay, I can move it there, if I do the same for those shmem_...()
interfaces currently in linux/mm.h too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
