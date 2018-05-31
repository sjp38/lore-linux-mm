Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C05966B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 07:59:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x21-v6so12540179pfn.23
        for <linux-mm@kvack.org>; Thu, 31 May 2018 04:59:44 -0700 (PDT)
Received: from ipmail02.adl2.internode.on.net (ipmail02.adl2.internode.on.net. [150.101.137.139])
        by mx.google.com with ESMTP id s26-v6si3070776pgo.298.2018.05.31.04.59.41
        for <linux-mm@kvack.org>;
        Thu, 31 May 2018 04:59:42 -0700 (PDT)
Date: Thu, 31 May 2018 21:59:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 11/13] iomap: add an iomap-based readpage and readpages
 implementation
Message-ID: <20180531115938.GM10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-12-hch@lst.de>
 <20180530234557.GI10363@dastard>
 <20180531061315.GB31350@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180531061315.GB31350@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 31, 2018 at 08:13:15AM +0200, Christoph Hellwig wrote:
> On Thu, May 31, 2018 at 09:45:57AM +1000, Dave Chinner wrote:
> > sentence ends with a ".". :)
> 
> Ok.  This was intended to point to the WARN_ON calls below, but a "."
> is fine with me, too.
> 
> > 
> > > +	WARN_ON_ONCE(pos != page_offset(page));
> > > +	WARN_ON_ONCE(plen != PAGE_SIZE);
> > > +
> > > +	if (iomap->type != IOMAP_MAPPED || pos >= i_size_read(inode)) {
> > 
> > In what situation do we get a read request completely beyond EOF?
> > (comment, please!)
> 
> This is generally to cover a racing read beyond EOF.  That being said
> I'd have to look up if it can really happen for blocksize == pagesize.
> 
> All this becomes moot once small block size support is added, so I think
> I'd rather skip the comment and research here for now.

OK.

> > > +	if (ctx.bio) {
> > > +		submit_bio(ctx.bio);
> > > +		WARN_ON_ONCE(!ctx.cur_page_in_bio);
> > > +	} else {
> > > +		WARN_ON_ONCE(ctx.cur_page_in_bio);
> > > +		unlock_page(page);
> > > +	}
> > > +	return 0;
> > 
> > Hmmm. If we had an error from iomap_apply, shouldn't we be returning
> > it here instead just throwing it away? some ->readpage callers
> > appear to ignore the PageError() state on return but do expect
> > errors to be returned.
> 
> Both mpage_readpage and block_read_full_page always return 0, so for
> now I'd like to stay compatible to them.  Might be worth a full audit
> later.
> 
> > > +	loff_t pos = page_offset(list_entry(pages->prev, struct page, lru));
> > > +	loff_t last = page_offset(list_entry(pages->next, struct page, lru));
> > > +	loff_t length = last - pos + PAGE_SIZE, ret = 0;
> > 
> > Two lines, please.
> 
> I really like it that way, though..

Except for the fact most peoples eyes are trained for one line per
declaration and one variable assignment per line. I don't care about
an extra line of code or two, but it's so easy to lose a declaration
of a short variable in all those long declarations and initialisers.
I found myself asking several times through these patchsets "now
where was /that/ variable declared/initialised?".  That's why I'm
asking for it to be changed.

> > > +done:
> > > +	if (ctx.bio)
> > > +		submit_bio(ctx.bio);
> > > +	if (ctx.cur_page) {
> > > +		if (!ctx.cur_page_in_bio)
> > > +			unlock_page(ctx.cur_page);
> > > +		put_page(ctx.cur_page);
> > > +	}
> > > +	WARN_ON_ONCE(!ret && !list_empty(ctx.pages));
> > 
> > What error condition is this warning about?
> 
> Not finishing all pages without an error.  Which wasn't too hard to get
> wrong given the arance readpages calling convention.

It's crusty old code like this that make me realise why we have so
many problems with IO error reporting - instead of fixing error
propagation problems when we come across them,  we just layer more
crap on top with some undocumented warnings for good measure.

Not really happy about it. Please add comments explaining the crap
you're adding to work around the crappy error propagation issues.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
