Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 974E66B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 13:23:10 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oAUIN793018707
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:23:07 -0800
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by wpaz24.hot.corp.google.com with ESMTP id oAUIMnFH019312
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:23:06 -0800
Received: by pzk26 with SMTP id 26so1052852pzk.21
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:23:06 -0800 (PST)
Date: Tue, 30 Nov 2010 10:22:58 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
In-Reply-To: <20101129152500.000c380b.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1011300939520.6633@tigran.mtv.corp.google.com>
References: <AANLkTinbqG7sXxf82wc516snLoae1DtCWjo+VtsPx2P3@mail.gmail.com> <20101122154754.e022d935.akpm@linux-foundation.org> <AANLkTi=AiJ1MekBXZbVj3f2pBtFe52BtCxtbRq=u-YOR@mail.gmail.com> <20101129152500.000c380b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-2?Q?Robert_=A6wi=EAcki?= <robert@swiecki.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010, Andrew Morton wrote:
> On Tue, 23 Nov 2010 15:55:31 +0100
> Robert  wi cki <robert@swiecki.net> wrote:
> > >> [25142.286531] kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
> > >
> > > That's
> > >
> > >        BUG_ON(page_mapped(page));
> > >
> > > in  remove_from_page_cache().  That state is worth a BUG().
> 
> At a guess I'd say that another thread came in and established a
> mapping against a page in the to-be-truncated range while
> vmtruncate_range() was working on it.  In fact I'd be suspecting that
> the mapping was established after truncate_inode_page() ran its
> page_mapped() test.

It looks that way, but I don't see how it can be: the page is locked
before calling truncate_inode_page() and unlocked after it: and the
page (certainly in this tmpfs case, perhaps not for every filesystem)
cannot be faulted into an address space without holding its page lock.

Either we've made a change somewhere, and are now dropping and retaking
page lock in a way which exposes this bug?  Or truncate_inode_page()'s
unmap_mapping_range() call is somehow missing the page it's called for?

I guess the latter is the more likely: maybe the truncate_count/restart
logic isn't working properly.  I'll try to check over that again later -
but will be happy if someone else beats me to it.

> +       /*
> +        * unmap_mapping_range is called twice, first simply for efficiency
> +        * so that truncate_inode_pages does fewer single-page unmaps. However
> +        * after this first call, and before truncate_inode_pages finishes,
> +        * it is possible for private pages to be COWed, which remain after
> +        * truncate_inode_pages finishes, hence the second unmap_mapping_range
> +        * call must be made for correctness.
> +	 /*
> 
> Later, some twirp deleted the damn comment.  Why'd we do that?  It
> still seems to be valid.
> 
> If this _is_ still valid, and the first call to unmap_mapping_range() is
> really just a best-effort performance thing which won't reliably clear
> all the mappings then perhaps the BUG_ON(page_mapped(page)) assertion
> in __remove_from_page_cache() is simply bogus.

No, I believe the first call to unmap_mapping_range() is sufficient to
deal correctly with all page cache pages (and Robert's issue is certainly
with a page cache page).  The second call to unmap_mapping_range() is to
mop up private copied-on-write copies of page cache pages: being separate
pages, the page locking is not adequate to deal with them as thoroughly,
but standards still require them to be removed (SIGBUS beyond EOF).

> 
> We don't appear to have mmap_sem coverage around here, perhaps for
> lock-ordering reasons.  I suspect we'll be struggling to plug all holes
> here without that coverage.

I think any help from mmap_sem here would be deceptive: another mm,
with another mmap_sem, could equally operate on the pages of this file,
and presumably introduce the same condition.  i_mmap_lock and page lock
should already be handling it.

> 
> Fortunately the comment over madvise_remove() says it's tmpfs-only, so
> we can blame Hugh :)

Glad to be of service!  But wish I could work out what's happening.

> 
> hm, I found the lost comment.  It somehow wandered over into
> truncate_pagecache(), but is still relevant at the vmtruncate_range()
> site.

Yes, it is indeed a helpful comment.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
