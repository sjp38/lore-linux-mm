Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 34CB26B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:48:26 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so2375660pab.23
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:48:25 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id n8si2757019pax.73.2014.02.06.15.48.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 15:48:24 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so2404167pab.1
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:48:24 -0800 (PST)
Date: Thu, 6 Feb 2014 15:48:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com>
 <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Feb 2014, Andrew Morton wrote:

> On Thu, 6 Feb 2014 14:58:21 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
> > > > +#define MAX_REMOTE_READAHEAD   4096UL
> > > >  /*
> > > >   * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
> > > >   * sensible upper limit.
> > > >   */
> > > >  unsigned long max_sane_readahead(unsigned long nr)
> > > >  {
> > > > -	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> > > > -		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
> > > > +	unsigned long local_free_page;
> > > > +	int nid;
> > > > +
> > > > +	nid = numa_node_id();
> > 
> > If you're intending this to be cached for your calls into 
> > node_page_state() you need nid = ACCESS_ONCE(numa_node_id()).
> 
> ugh.  That's too subtle and we didn't even document it.
> 
> We could put the ACCESS_ONCE inside numa_node_id() I assume but we
> still have the same problem as smp_processor_id(): the numa_node_id()
> return value is wrong as soon as you obtain it if running preemptibly. 
> 
> We could plaster Big Fat Warnings all over the place or we could treat
> numa_node_id() and derivatives in the same way as smp_processor_id()
> (which is a huge pain).  Or something else, but we've left a big hand
> grenade here and Raghavendra won't be the last one to pull the pin?
> 

Normally it wouldn't matter because there's no significant downside to it 
racing, things like mempolicies which use numa_node_id() extensively would 
result in, oops, a page allocation on the wrong node.

This stands out to me, though, because you're expecting the calculation to 
be correct for a specific node.

The patch is still wrong, though, it should just do

	int node = ACCESS_ONCE(numa_mem_id());
	return min(nr, (node_page_state(node, NR_INACTIVE_FILE) +
		        node_page_state(node, NR_FREE_PAGES)) / 2);

since we want to readahead based on the cpu's local node, the comment 
saying we're reading ahead onto "remote memory" is wrong since a 
memoryless node has local affinity to numa_mem_id().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
