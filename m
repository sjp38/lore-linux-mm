Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D716280300
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 18:36:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d8so3056521pgt.1
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 15:36:54 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id t1si5729869pgs.562.2017.09.04.15.36.51
        for <linux-mm@kvack.org>;
        Mon, 04 Sep 2017 15:36:52 -0700 (PDT)
Date: Tue, 5 Sep 2017 08:36:48 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20170904223648.GH10621@dastard>
References: <CABXGCsOL+_OgC0dpO1+Zeg=iu7ryZRZT4S7k-io8EGB0ZRgZGw@mail.gmail.com>
 <20170903074306.GA8351@infradead.org>
 <20170904014353.GG10621@dastard>
 <20170904022002.GD4671@magnolia>
 <20170904121452.GC1761@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170904121452.GC1761@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Christoph Hellwig <hch@infradead.org>, =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 04, 2017 at 02:14:52PM +0200, Jan Kara wrote:
> On Sun 03-09-17 19:20:02, Darrick J. Wong wrote:
> > [add jan kara to cc]
> > 
> > On Mon, Sep 04, 2017 at 11:43:53AM +1000, Dave Chinner wrote:
> > > On Sun, Sep 03, 2017 at 12:43:06AM -0700, Christoph Hellwig wrote:
> > > > On Sun, Sep 03, 2017 at 09:22:17AM +0500, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> > > > > [281502.961248] ------------[ cut here ]------------
> > > > > [281502.961257] kernel BUG at fs/xfs/xfs_aops.c:853!
> > > > 
> > > > This is:
> > > > 
> > > > 	bh = head = page_buffers(page);
> > > > 
> > > > Which looks odd and like some sort of VM/writeback change might
> > > > have triggered that we get a page without buffers, despite always
> > > > creating buffers in iomap_begin/end and page_mkwrite.
> > > 
> > > Pretty sure this can still happen when buffer_heads_over_limit comes
> > > true. In that case, shrink_active_list() will attempt to strip
> > > the bufferheads off the page even if it's a dirty page. i.e. this
> > > code:
> > > 
> > >                 if (unlikely(buffer_heads_over_limit)) {
> > >                         if (page_has_private(page) && trylock_page(page)) {
> > >                                 if (page_has_private(page))
> > >                                         try_to_release_page(page, 0);
> > >                                 unlock_page(page);
> > >                         }
> > >                 }
> > > 
> > > 
> > > There was some discussion about this a while back, the consensus was
> > > that it is a mm bug, but nobody wanted to add a PageDirty check
> > > to try_to_release_page() and so nothing ended up being done about
> > > it in the mm/ subsystem. Instead, filesystems needed to avoid it
> > > if it was a problem for them. Indeed, we fixed it in the filesystem
> > > in 4.8:
> > > 
> > > 99579ccec4e2 xfs: skip dirty pages in ->releasepage()
> > > 
> > > diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> > > index 3ba0809e0be8..6135787500fc 100644
> > > --- a/fs/xfs/xfs_aops.c
> > > +++ b/fs/xfs/xfs_aops.c
> > > @@ -1040,6 +1040,20 @@ xfs_vm_releasepage(
> > >  
> > >         trace_xfs_releasepage(page->mapping->host, page, 0, 0);
> > >  
> > > +       /*
> > > +        * mm accommodates an old ext3 case where clean pages might not have had
> > > +        * the dirty bit cleared. Thus, it can send actual dirty pages to
> > > +        * ->releasepage() via shrink_active_list(). Conversely,
> > > +        * block_invalidatepage() can send pages that are still marked dirty
> > > +        * but otherwise have invalidated buffers.
> > > +        *
> > > +        * We've historically freed buffers on the latter. Instead, quietly
> > > +        * filter out all dirty pages to avoid spurious buffer state warnings.
> > > +        * This can likely be removed once shrink_active_list() is fixed.
> > > +        */
> > > +       if (PageDirty(page))
> > > +               return 0;
> > > +
> > >         xfs_count_page_state(page, &delalloc, &unwritten);
> > > 
> > > But looking at the current code, the comment is still mostly there
> > > but the PageDirty() check isn't.
> > > 
> > > <sigh>
> > > 
> > > In 4.10, this was done:
> > > 
> > > commit 0a417b8dc1f10b03e8f558b8a831f07ec4c23795
> > > Author: Jan Kara <jack@suse.cz>
> > > Date:   Wed Jan 11 10:20:04 2017 -0800
> > > 
> > >     xfs: Timely free truncated dirty pages
> > >     
> > >     Commit 99579ccec4e2 "xfs: skip dirty pages in ->releasepage()" started
> > >     to skip dirty pages in xfs_vm_releasepage() which also has the effect
> > >     that if a dirty page is truncated, it does not get freed by
> > >     block_invalidatepage() and is lingering in LRU list waiting for reclaim.
> > >     So a simple loop like:
> > >     
> > >     while true; do
> > >             dd if=/dev/zero of=file bs=1M count=100
> > >             rm file
> > >     done
> > >     
> > >     will keep using more and more memory until we hit low watermarks and
> > >     start pagecache reclaim which will eventually reclaim also the truncate
> > >     pages. Keeping these truncated (and thus never usable) pages in memory
> > >     is just a waste of memory, is unnecessarily stressing page cache
> > >     reclaim, and reportedly also leads to anonymous mmap(2) returning ENOMEM
> > >     prematurely.
> > >     
> > >     So instead of just skipping dirty pages in xfs_vm_releasepage(), return
> > >     to old behavior of skipping them only if they have delalloc or unwritten
> > >     buffers and fix the spurious warnings by warning only if the page is
> > >     clean.
> > >     
> > >     CC: stable@vger.kernel.org
> > >     CC: Brian Foster <bfoster@redhat.com>
> > >     CC: Vlastimil Babka <vbabka@suse.cz>
> > >     Reported-by: Petr Ti? 1/2 ma <petr.tuma@d3s.mff.cuni.cz>
> > >     Fixes: 99579ccec4e271c3d4d4e7c946058766812afdab
> > >     Signed-off-by: Jan Kara <jack@suse.cz>
> > >     Reviewed-by: Brian Foster <bfoster@redhat.com>
> > >     Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > > 
> > > 
> > > So, yeah, we reverted the fix for a crash rather than trying to fix
> > > the adverse behaviour caused by invalidation of a dirty page.
> > > 
> > > e.g. why didn't we simply clear the PageDirty flag in
> > > xfs_vm_invalidatepage()?  The page is being invalidated - it's
> > > contents will never get written back - so having delalloc or
> > > unwritten extents over that page at the time it is invalidated is a
> > > bug and the original fix would have triggered warnings about
> > > this....
> > 
> > Seems like a reasonable revert/change, but given that ext3 was killed
> > off long ago, is it even still the case that the mm can feed releasepage
> > a dirty clean page?  If that is the case, then isn't it time to fix the
> > mm too?
> 
> Yes, ->releasepage() can still get PageDirty page. Whether the page can or
> cannot be reclaimed is still upto filesystem to decide.

Yes, and so we have to handle it.  For all I know right now we could
be chasing single bit memory error/corruptions....

IIRC, the only place that can remove bufferheads from the page is
->releasepage, so we need to catch this case and warn about it
there. If the page is being overwritten, then the delalloc/unwritten
warnings in xfs_vm_releasepage() won't fire, and so if the buffers
are clean (for whatever reason) they'll silently get removed from
the dirty page. And then we'll die a horrible death in ->writepages
shortly afterwards, just like has been reported.

> Now XFS shouldn't
> really end up freeing such page - either because those delalloc / unwritten
> checks trigger or because try_to_free_buffers() refuses to free dirty
> buffers.

Except if the dirty page has come through the block_invalidation()
path, because all the buffers on the page have been invalidated and
cleaned. i.e. we've already removed BH_Dirty, BH_Delay and
BH_unwritten from all the buffer heads, so invalidated dirty pages
will run right through buffers will be removed.

Every caller to ->releasepage() - except the invalidatepage path and
the than the bufferhead stripper - checks PageDirty *after* the
->releasepage call and return without doing anything because they
aren't supposed to be releasing dirty pages. So if XFS has decided
the page can be released, but a mapping invalidation call then notes
the page is dirty, it won't invalidate the pagei but it will have
had the bufferheads stripped. That's another possible vector, and
one that explicit checking of the page dirty flag will avoid.

IOWs, the only legal path to releasing dirty pages is the
->invalidatepage path.  Which, BTW, has another ext3 hack in it to
handle it's journalling bogosities. truncate_complete_page():

        if (page_has_private(page))
                do_invalidatepage(page, 0, PAGE_SIZE);

        /*
         * Some filesystems seem to re-dirty the page even after
         * the VM has canceled the dirty bit (eg ext3 journaling).
         * Hence dirty accounting check is placed after invalidation.
         */
        cancel_dirty_page(page);

Which has seems to tie into the hacks in try_to_free_buffers() to
handle ext3 cleaning buffers without cleaning the page. i.e. after
buffer invalidation, ext3 can still dirty pages. This whole path is
is effectively tainted by ext3 journalling hacks.

Hence my question about XFS being able to cancel the page dirty flag
before calling block_invalidation() so that we can untangle the mess
where we can't tell the difference between a "must release a dirty
invalidated page because we've already invalidated the bufferheads"
context and the other "release page only if not dirty" caller
context?

> So I'm not seeing how XFS could end up wrongly removing buffers
> from under a dirty page as Dave suggests.

Neither can I, but here we are again with a dirty page in the wrong
state being passed to XFS from the memory reclaim code and no idea
how we got here. We need to explicitly handle this case so the next
time writepage falls over with no bufferheads on a page we know
whether it had been released inappropriately by some other callpath.

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
