Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 947FC6B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:39:00 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id w8so29237868qac.1
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:39:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q67si40447007qgd.39.2015.02.24.13.38.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 13:38:59 -0800 (PST)
Date: Tue, 24 Feb 2015 16:13:33 -0500
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: readahead: get back a sensible upper limit
Message-ID: <20150224211332.GI19014@t510.redhat.com>
References: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com>
 <alpine.DEB.2.10.1502241245530.3855@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1502241245530.3855@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, jweiner@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, loberman@redhat.com, lwoodman@redhat.com, raghavendra.kt@linux.vnet.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Feb 24, 2015 at 12:50:20PM -0800, David Rientjes wrote:
> On Tue, 24 Feb 2015, Rafael Aquini wrote:
> 
> > commit 6d2be915e589 ("mm/readahead.c: fix readahead failure for memoryless NUMA
> > nodes and limit readahead pages")[1] imposed 2 mB hard limits to readahead by 
> > changing max_sane_readahead() to sort out a corner case where a thread runs on 
> > amemoryless NUMA node and it would have its readahead capability disabled.
> > 
> > The aforementioned change, despite fixing that corner case, is detrimental to
> > other ordinary workloads that memory map big files and rely on readahead() or
> > posix_fadvise(WILLNEED) syscalls to get most of the file populating system's cache.
> > 
> > Laurence Oberman reports, via https://bugzilla.redhat.com/show_bug.cgi?id=1187940,
> > slowdowns up to 3-4 times when changes for mentioned commit [1] got introduced in
> > RHEL kenrel. We also have an upstream bugzilla opened for similar complaint:
> > https://bugzilla.kernel.org/show_bug.cgi?id=79111
> > 
> > This patch brings back the old behavior of max_sane_readahead() where we used to
> > consider NR_INACTIVE_FILE and NR_FREE_PAGES pages to derive a sensible / adujstable
> > readahead upper limit. This patch also keeps the 2 mB ceiling scheme introduced by
> > commit [1] to avoid regressions on CONFIG_HAVE_MEMORYLESS_NODES systems,
> > where numa_mem_id(), by any buggy reason, might end up not returning
> > the 'local memory' for a memoryless node CPU.
> > 
> > Reported-by: Laurence Oberman <loberman@redhat.com>
> > Tested-by: Laurence Oberman <loberman@redhat.com>
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> > ---
> >  mm/readahead.c | 8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/readahead.c b/mm/readahead.c
> > index 9356758..73f934d 100644
> > --- a/mm/readahead.c
> > +++ b/mm/readahead.c
> > @@ -203,6 +203,7 @@ out:
> >  	return ret;
> >  }
> >  
> > +#define MAX_READAHEAD   ((512 * 4096) / PAGE_CACHE_SIZE)
> >  /*
> >   * Chunk the readahead into 2 megabyte units, so that we don't pin too much
> >   * memory at once.
> > @@ -217,7 +218,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
> >  	while (nr_to_read) {
> >  		int err;
> >  
> > -		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
> > +		unsigned long this_chunk = MAX_READAHEAD;
> >  
> >  		if (this_chunk > nr_to_read)
> >  			this_chunk = nr_to_read;
> > @@ -232,14 +233,15 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
> >  	return 0;
> >  }
> >  
> > -#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
> >  /*
> >   * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
> >   * sensible upper limit.
> >   */
> >  unsigned long max_sane_readahead(unsigned long nr)
> >  {
> > -	return min(nr, MAX_READAHEAD);
> > +	return min(nr, max(MAX_READAHEAD,
> > +			  (node_page_state(numa_mem_id(), NR_INACTIVE_FILE) +
> > +			   node_page_state(numa_mem_id(), NR_FREE_PAGES)) / 2));
> >  }
> >  
> >  /*
> 
> I think Linus suggested avoiding the complexity here regarding any 
> heuristics involving the per-node memory state, specifically in 
> http://www.kernelhub.org/?msg=413344&p=2, and suggested the MAX_READAHEAD 
> size.
>

The problem I think that thread skipped is that we were already shipping
readaheads on chunks of 2mB to the I/O system -- take a look on
force_page_cache_readahead(), and the 2 mB hard ceiling Raghavendra
patch introduced ended up capping all readahead activity to 2mB regardless the 
system memory state. 

By doing so it ended up affecting all users of force_page_cache_readahead(),
like readahead(2) and posix_fadvise(2). At that time, Raghavendra was
able to report tangible gains for readahead on NUMA layouts where some
nodes are memoryless and no one else reported measurable losses due to
the change. 

Unfortunately, we now have people complaining about losses, for ordinary 
workloads, that are as tangible as those gains reported for the original
corner case. That's why I think the right thing we should do here is to
partially revert that change, to get the old behaviour back without
loosing the hard ceiling scheme it introduced for corner cases.

Regards,

-- Rafael

> If we are to go forward with this revert, then I believe the change to 
> numa_mem_id() will fix the memoryless node issue as pointed out in that 
> thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
