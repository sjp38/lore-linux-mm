Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EFEA6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 15:46:24 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k12so52329197lfb.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 12:46:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r204si4354173wmg.79.2016.09.09.12.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 12:46:22 -0700 (PDT)
Date: Fri, 9 Sep 2016 15:42:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [fuse-devel] Kernel panic under load
Message-ID: <20160909194239.GA16056@cmpxchg.org>
References: <CAB3-ZyQ4Mbj2g6b6Zt4pGLhE7ew9O==rNbUgAaPLYSwdRK3Czw@mail.gmail.com>
 <CAJfpeguMfoK+foKxUeSLOw0aD=U+ya6BgpRm2XnFfKx3w2Nfpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpeguMfoK+foKxUeSLOw0aD=U+ya6BgpRm2XnFfKx3w2Nfpg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Antonio SJ Musumeci <trapexit@spawn.link>, fuse-devel <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Miklos,

On Fri, Sep 09, 2016 at 04:32:49PM +0200, Miklos Szeredi wrote:
> On Fri, Sep 9, 2016 at 3:34 PM, Antonio SJ Musumeci <trapexit@spawn.link> wrote:
> > https://gist.github.com/bauruine/3bc00075c4d0b5b3353071d208ded30f
> > https://github.com/trapexit/mergerfs/issues/295
> >
> > I've some users which are having issues with my filesystem where the
> > system's load increases and then the kernel panics.
> >
> > Has anyone seen this before?
> 
> Quite possibly this is caused by fuse, but the BUG is deep in mm
> territory and I have zero clue about what it means.
> 
> Hannes,  can you please look a the above crash in mm/workingset.c?

The MM maintains a reclaimable list of page cache tree nodes that have
gone empty (all pages evicted) except for the shadow entries reclaimed
pages leave behind. When faulting a regular page back into such a node
the code in page_cache_tree_insert() removes it from the list again:

		workingset_node_pages_inc(node);
		/*
		 * Don't track node that contains actual pages.
		 *
		 * Avoid acquiring the list_lru lock if already
		 * untracked.  The list_empty() test is safe as
		 * node->private_list is protected by
		 * mapping->tree_lock.
		 */
		if (!list_empty(&node->private_list))
			list_lru_del(&workingset_shadow_nodes,
				     &node->private_list);

The BUG_ON() triggers when we later walk the reclaimable list and find
a radix tree node that has actual pages in it. This could happen when
pages are inserted into a mapping without using add_to_page_cache and
related functions. Does that maybe ring a bell?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
