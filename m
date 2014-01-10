Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3643A6B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 04:52:26 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so1919316eaj.21
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 01:52:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si8934463eeo.170.2014.01.10.01.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 01:52:25 -0800 (PST)
Date: Fri, 10 Jan 2014 10:52:22 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH V4] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
Message-ID: <20140110095222.GE26378@quack.suse.cz>
References: <1389295490-28707-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <20140110083656.GC26378@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110083656.GC26378@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, jack@suse.cz, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 10-01-14 09:36:56, Jan Kara wrote:
> On Fri 10-01-14 00:54:50, Raghavendra K T wrote:
> > We limit the number of readahead pages to 4k.
> > 
> > max_sane_readahead returns zero on the cpu having no local memory
> > node. Fix that by returning a sanitized number of pages viz.,
> > minimum of (requested pages, 4k, number of local free pages)
> > 
> > Result:
> > fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
> > 32GB* 4G RAM  numa machine ( 12 iterations) yielded
> > 
> > kernel       Avg        Stddev
> > base         7.264      0.56%
> > patched      7.285      1.14%
>   OK, looks good to me. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>
  Hum, while doing some other work I've realized there may be still a
problem hiding with the 16 MB limitation. E.g. the dynamic linker is
doing MADV_WILLNEED on the shared libraries. If the library (or executable)
is larger than 16 MB, then it may cause performance problems since access
is random in nature and we don't really know which part of the file do we
need first.

I'm not sure what others think about this but I'm now more inclined to a
bit more careful and introduce the 16 MB limit only for the NUMA case. I.e.
something like:

	unsigned long local_free_page;
	int nid;

	nid = numa_node_id();
	if (node_present_pages(nid)) {
		/*
		 * We sanitize readahead size depending on free memory in
		 * the local node.
		 */
		local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
				  + node_page_state(nid, NR_FREE_PAGES);
		return min(nr, local_free_page / 2);
	}
	/*
	 * Readahead onto remote memory is better than no readahead when local
	 * numa node does not have memory. We limit the readahead to 4k
	 * pages though to avoid trashing page cache.
	 */
	return min(nr, MAX_REMOTE_READAHEAD);

								Honza

> > Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> > ---
> >  mm/readahead.c | 20 ++++++++++++++++++--
> >  1 file changed, 18 insertions(+), 2 deletions(-)
> > 
> > V4:  incorporated 16MB limit suggested by Linus for readahead and
> > fixed transitioning to large readahead anomaly pointed by Andrew Morton with
> > Honza's suggestion.
> > 
> > Test results shows no significant overhead with the current changes.
> > 
> > (Do I have to break patches into two??)
> > 
> > Suggestions/Comments please let me know.
> > 
> > diff --git a/mm/readahead.c b/mm/readahead.c
> > index 7cdbb44..2f561a0 100644
> > --- a/mm/readahead.c
> > +++ b/mm/readahead.c
> > @@ -237,14 +237,30 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
> >  	return ret;
> >  }
> >  
> > +#define MAX_REMOTE_READAHEAD   4096UL
> >  /*
> >   * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
> >   * sensible upper limit.
> >   */
> >  unsigned long max_sane_readahead(unsigned long nr)
> >  {
> > -	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> > -		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
> > +	unsigned long local_free_page;
> > +	unsigned long sane_nr;
> > +	int nid;
> > +
> > +	nid = numa_node_id();
> > +	sane_nr = min(nr, MAX_REMOTE_READAHEAD);
> > +
> > +	local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
> > +			  + node_page_state(nid, NR_FREE_PAGES);
> > +
> > +	/*
> > +	 * Readahead onto remote memory is better than no readahead when local
> > +	 * numa node does not have memory. We sanitize readahead size depending
> > +	 * on free memory in the local node but limiting to 4k pages.
> > +	 */
> > +	return node_present_pages(nid) ?
> > +				min(sane_nr, local_free_page / 2) : sane_nr;
> >  }
> >  
> >  /*
> > -- 
> > 1.7.11.7
> > 
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
