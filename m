Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC51D6B0275
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:55:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y138so6028124wme.7
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 01:55:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy3si7149118wjb.293.2016.10.27.01.55.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 01:55:08 -0700 (PDT)
Date: Thu, 27 Oct 2016 10:48:03 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/5] mm: workingset: radix tree subtleties & single-page
 file refaults
Message-ID: <20161027084803.GA19743@quack2.suse.cz>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
 <CA+55aFzRZCt-t_HJ_40mkuvR4qXj71BoW-Tt6hYOKNpT2yj6cw@mail.gmail.com>
 <20161024184739.GB2125@cmpxchg.org>
 <20161026092107.GC11086@quack2.suse.cz>
 <20161026181509.GA15221@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161026181509.GA15221@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Wed 26-10-16 14:15:09, Johannes Weiner wrote:
> On Wed, Oct 26, 2016 at 11:21:07AM +0200, Jan Kara wrote:
> > On Mon 24-10-16 14:47:39, Johannes Weiner wrote:
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Date: Mon, 17 Oct 2016 09:00:04 -0400
> > > Subject: [PATCH] mm: workingset: restore single-page file refault tracking
> > > 
> > > Currently, we account shadow entries in the page cache in the upper
> > > bits of the radix_tree_node->count, behind the back of the radix tree
> > > implementation. Because the radix tree code has no awareness of them,
> > > we have to prevent shadow entries from going through operations where
> > > the tree implementation relies on or modifies node->count: extending
> > > and shrinking the tree from and to a single direct root->rnode entry.
> > > 
> > > As a consequence, we cannot store shadow entries for files that only
> > > have index 0 populated, and thus cannot detect refaults from them,
> > > which in turn degrades the thrashing compensation in LRU reclaim.
> > > 
> > > Another consequence is that we rely on subtleties throughout the radix
> > > tree code, such as the node->count != 1 check in the shrinking code,
> > > which is meant to exclude multi-entry nodes but also skips nodes with
> > > only one shadow entry since they are accounted in the upper bits. This
> > > is error prone, and has in fact caused the bug fixed in d3798ae8c6f3
> > > ("mm: filemap: don't plant shadow entries without radix tree node").
> > > 
> > > To fix this, this patch moves the shadow counter from the upper bits
> > > of node->count into the new node->exceptional counter, where all
> > > exceptional entries are explicitely tracked by the radix tree.
> > > node->count then counts all tree entries again, including shadows.
> > > 
> > > Switching from a magic node->count to accounting exceptional entries
> > > natively in the radix tree code removes the fragile subtleties
> > > mentioned above. It also allows us to store shadow entries for
> > > single-page files again, as the radix tree recognizes exceptional
> > > entries when extending the tree from the root->rnode singleton, and
> > > thus restore refault detection and thrashing compensation for them.
> > 
> > I like this solution.
> 
> Thanks Jan.
> 
> > Just one suggestion: I think radix_tree_replace_slot() can now do
> > the node counter update on its own and that would save us having to
> > do quite a bit of accounting outside of the radix tree code itself
> > and it would be less prone to bugs (forgotten updates of a
> > counter). What do you think?
> 
> This would be nice indeed, but it's bigger surgery. We need the node
> in the context of existing users that do slot lookup and replacement,
> which is easier for individual lookups, and harder for gang lookups
> (e.g. drivers/sh/intc/virq.c::intc_subgroup_map). And they'd all get
> more complicated, AFAICS, without even using exceptional entries.

Hum, I agree. But actually looking at e.g. the usage of
radix_tree_replace_slot() in mm/khugepaged.c I think this is even buggy
when replacing a slot referencing a page with NULL without updating
node->count. It is in the error bail-out path so I'm not surprised we did
not stumble over it.

So a relatively easy solution looks like: Create new function like
radix_tree_replace_node_slot() taking both node & slot and updating the
accounting information as needed. Make this function WARN if node is NULL
and accounting information should be updated. Make original
radix_tree_replace_slot() a wrapper around radix_tree_replace_node_slot()
passing NULL as node.

This should provide safe accounting info updates without forcing all users
to work with node pointers...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
