Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3927E2803FE
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 19:43:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v82so9942161pgb.5
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 16:43:42 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id h5si97921pfg.403.2017.09.05.16.43.39
        for <linux-mm@kvack.org>;
        Tue, 05 Sep 2017 16:43:40 -0700 (PDT)
Date: Wed, 6 Sep 2017 09:42:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20170905234256.GP17782@dastard>
References: <CABXGCsOL+_OgC0dpO1+Zeg=iu7ryZRZT4S7k-io8EGB0ZRgZGw@mail.gmail.com>
 <20170903074306.GA8351@infradead.org>
 <20170904014353.GG10621@dastard>
 <20170904022002.GD4671@magnolia>
 <20170904121452.GC1761@quack2.suse.cz>
 <20170904223648.GH10621@dastard>
 <20170905161734.GA25379@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170905161734.GA25379@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Christoph Hellwig <hch@infradead.org>, =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 05, 2017 at 06:17:34PM +0200, Jan Kara wrote:
> On Tue 05-09-17 08:36:48, Dave Chinner wrote:
> > On Mon, Sep 04, 2017 at 02:14:52PM +0200, Jan Kara wrote:
> > > > Seems like a reasonable revert/change, but given that ext3 was killed
> > > > off long ago, is it even still the case that the mm can feed releasepage
> > > > a dirty clean page?  If that is the case, then isn't it time to fix the
> > > > mm too?
> > > 
> > > Yes, ->releasepage() can still get PageDirty page. Whether the page can or
> > > cannot be reclaimed is still upto filesystem to decide.
> > 
> > Yes, and so we have to handle it.  For all I know right now we could
> > be chasing single bit memory error/corruptions....
> 
> Possibly, although I'm not convinced - as I've mentioned I've seen exact
> same assertion failure in XFS on our SLE12-SP2 kernel (4.4 based) in one of
> customers setup. And I've seen two or three times ext4 barfing for exactly
> same reason - buffers stripped from dirty page.

Yeah, we're chasing ghosts at the moment. :/

[....]
> > > Now XFS shouldn't
> > > really end up freeing such page - either because those delalloc / unwritten
> > > checks trigger or because try_to_free_buffers() refuses to free dirty
> > > buffers.
> > 
> > Except if the dirty page has come through the block_invalidation()
> > path, because all the buffers on the page have been invalidated and
> > cleaned. i.e. we've already removed BH_Dirty, BH_Delay and
> > BH_unwritten from all the buffer heads, so invalidated dirty pages
> > will run right through buffers will be removed.
> > 
> > Every caller to ->releasepage() - except the invalidatepage path and
> > the than the bufferhead stripper - checks PageDirty *after* the
> > ->releasepage call and return without doing anything because they
> > aren't supposed to be releasing dirty pages. So if XFS has decided
> > the page can be released, but a mapping invalidation call then notes
> > the page is dirty, it won't invalidate the pagei but it will have
> > had the bufferheads stripped. That's another possible vector, and
> > one that explicit checking of the page dirty flag will avoid.
> 
> Are you speaking about the PageDirty check in __remove_mapping()? I agree
> that checking PageDirty in releasepage would narrow that window for
> corruption although won't close it completely - there are places in the
> kernel that call set_page_dirty() without page lock held and can thus race
> with page invalidation. But I didn't find how any such callsite could race
> to cause what we are observing...

I was referring to invalidate_complete_page2() - I didn't look down
the __remove_mapping() path after I found the first example in
icp2....

> > Hence my question about XFS being able to cancel the page dirty flag
> > before calling block_invalidation() so that we can untangle the mess
> > where we can't tell the difference between a "must release a dirty
> > invalidated page because we've already invalidated the bufferheads"
> > context and the other "release page only if not dirty" caller
> > context?
> 
> Yeah, I agree that if you add cancel_dirty_page() into
> xfs_vm_invalidatepage() before calling block_invalidatepage() and then bail
> on dirty page in xfs_vm_releasepage(), things should work as well and they
> would be more robust.

Ok, I'll put together a patch to do that. Thanks Jan!

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
