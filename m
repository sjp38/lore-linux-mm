Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 039646B0037
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 17:58:24 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so2340874pab.10
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 14:58:24 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id sd3si2583531pbb.342.2014.02.06.14.58.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 14:58:23 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so2324137pab.16
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 14:58:22 -0800 (PST)
Date: Thu, 6 Feb 2014 14:58:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Feb 2014, Andrew Morton wrote:

> > --- a/mm/readahead.c
> > +++ b/mm/readahead.c
> > @@ -237,14 +237,32 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
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
> > +	int nid;
> > +
> > +	nid = numa_node_id();

If you're intending this to be cached for your calls into 
node_page_state() you need nid = ACCESS_ONCE(numa_node_id()).

What's the downside of just using numa_mem_id() here instead which is 
usually "local memory to this memoryless node cpu" and forget about 
testing node_present_pages(nid)?

> > +	if (node_present_pages(nid)) {
> > +		/*
> > +		 * We sanitize readahead size depending on free memory in
> > +		 * the local node.
> > +		 */
> > +		local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
> > +				 + node_page_state(nid, NR_FREE_PAGES);
> > +		return min(nr, local_free_page / 2);
> > +	}
> > +	/*
> > +	 * Readahead onto remote memory is better than no readahead when local
> > +	 * numa node does not have memory. We limit the readahead to 4k
> > +	 * pages though to avoid trashing page cache.
> > +	 */
> > +	return min(nr, MAX_REMOTE_READAHEAD);
> >  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
