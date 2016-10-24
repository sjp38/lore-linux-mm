Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51DD26B026E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:47:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y138so37456260wme.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:47:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p73si13641655wmb.127.2016.10.24.11.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:47:46 -0700 (PDT)
Date: Mon, 24 Oct 2016 14:47:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] mm: workingset: radix tree subtleties & single-page
 file refaults
Message-ID: <20161024184739.GB2125@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
 <CA+55aFzRZCt-t_HJ_40mkuvR4qXj71BoW-Tt6hYOKNpT2yj6cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzRZCt-t_HJ_40mkuvR4qXj71BoW-Tt6hYOKNpT2yj6cw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Wed, Oct 19, 2016 at 11:16:30AM -0700, Linus Torvalds wrote:
> On Wed, Oct 19, 2016 at 10:24 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >
> > These patches make the radix tree code explicitely support and track
> > such special entries, to eliminate the subtleties and to restore the
> > thrash detection for single-page files.
> 
> Ugh. I'm not a huge fan. The patches may be good and be a cleanup in
> one respect, but they make one of my least favorite parts of the radix
> tree code worse.
> 
> The radix tree "tag" thing is really horribly confusing, and part of
> it is that there are two totally different "tags": the externally
> visible tags (separate array), and the magical internal tags (low bits
> of the node pointers that tag the pointers as internal or exceptional
> entries).
>
> And I think this series actually makes things even *more* complicated,
> because now the radix tree itself uses one magical entry in the
> externally visible tags for its own internal logic. So now it's
> *really* messed up - the external tags aren't entirely external any
> more.
> 
> Maybe I'm mis-reading it, and I'm just confused by the radix tree
> implementation? But if so, it's just another sign of just how
> confusing things are.

No, I think you're right. This is no good.

As I see it, the main distinction between the "tags" tags and the
lower bits in the entry pointers is that the former recurse down to
the root, and so they make lookup by tag very efficient (e.g. find
dirty pages to sync), whereas the pointer bits are cheaper when we
specifically operate on entries anyway and branch out to different
behavior depending on the type of entry (truncate a cache range,
extend tree, descend tree).

My patch violated that by adding a recursively-set "lookup" tag for
the single purpose of distinguishing entry types in root->rnode.

How about this instead: given that we already mark the shadow entries
exceptional, and the exceptional bit is part of the radix tree API,
can we just introduce a node->exceptional counter for those entries
and have the radix tree code assist us with that instead? It adds the
counting for non-shadow exceptional entries as well (shmem swap slots,
and DAX non-page entries), unfortunately, but this is way cleaner. It
also makes mapping->nrexceptional and node->exceptional consistent in
DAX (Jan, could you please double check the accounting there?)

What do you think? Lightly tested patch below.

> The external tag array itself is also somewhat nasty, in that it
> spreads out the tag bits for one entry maximally (ie different bits
> are in different words) so you can't even clear them together. I know
> why - it makes both iterating over a specific tag and any_tag_set()
> simpler, but it does seem confusing to me how we spread out the data
> almost maximally.
> 
> I really would love to see somebody take a big look at the two
> different tagging methods. If nothing else, explain it to me.
> 
> Because maybe this series is all great, and my objection is just that
> it makes it even harder for me to understand the code.
> 
> For example, could we do this simplification:
> 
>  - get rid of RADIX_TREE_TAG_LONGS entirely
>  - get rid of CONFIG_BASE_SMALL entirely
>  - just say that the tag bitmap is one unsigned long
>  - so RADIX_TREE_MAP_SIZE is just BITS_PER_LONG
> 
> and then at least we'd get rid of the double array and the confusion
> about loops that are actually almost never loops. Because right now
> RADIX_TREE_TAG_LONGS is usually 1, but is 2 if you're a 32-bit
> platform with !CONFIG_BASE_SMALL. So you need those loops, but it all
> looks almost entirely pointless.

AFAICS, !BASE_SMALL is the default unless you de-select BASE_FULL in
EXPERT, so that would cut the radix tree node in half on most 32 bit
setups and would more than double the tree nodes we have to allocate
(two where we had one, plus the additional intermediate levels).

The extra code sucks, but is that a cost we'd be willing to pay?

---
