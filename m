Date: Mon, 24 Mar 2003 14:12:05 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] anobjrmap 2/6 mapping
Message-Id: <20030324141205.5a4eae0e.akpm@digeo.com>
In-Reply-To: <1048534712.1907.398.camel@sisko.scot.redhat.com>
References: <Pine.LNX.4.44.0303202310440.2743-100000@localhost.localdomain>
	<Pine.LNX.4.44.0303202312560.2743-100000@localhost.localdomain>
	<20030320224832.0334712d.akpm@digeo.com>
	<1048534712.1907.398.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> wrote:
>
> Hi,
> 
> On Fri, 2003-03-21 at 06:48, Andrew Morton wrote:
> 
> > It goes BUG in try_to_free_buffers().
> > 
> > We really should fix this up for other reasons, probably by making ext3's
> > per-page truncate operations wait on commit, and be more aggressive about
> > pulling the page's buffers off the transaction at truncate time.
> 
> Ouch.

But this is specifically for the case where truncate finds the page's buffers
are attached to the committing transaction.

At present we just give up; this can result in an alarming number of pages
floating about on the LRU with no references at all except for their buffers.
These pages cause the overcommit accounting to make grossly wrong decisions.

I have a patch in -mm which liberates the pages when the commit has
completed, but I don't like it - that freeing really should happen in the
context of the truncate, not at some time in the future.  Doing it this way
means that the pages are either pagecache or free, and there is not a time
window in which they are simply AWOL.

> > The same thing _could_ happen with other filesystems; not too sure about
> > that.
> 
> XFS used to have synchronous truncates, for similar sorts of reasons. 
> It was dog slow for unlinks.  They worked pretty hard to fix that; I'd
> really like to avoid adding extra synchronicity to ext3 in this case.

I doubt it will matter much - usually the pages will be attached to the
current transaction and we just zap them (I think - the "memory leak" isn't
too hard to trigger).

I haven't looked too closely lately, but I think journal_unmap_buffer() is
being a bit silly - if it sees the buffer is on the committing transaction it
just gives up.  But it doesn't need to do that for ordered-data buffers.  We
could just grab journal_datalist_lock and pull those buffers off the
transaction even during commit.

> Pulling buffers off the transaction more aggressively would certainly be
> worth looking at.  Trouble is, if a truncate transaction on disk gets
> interrupted by a crash, you really do have to be able to undo it, so you
> simply don't have the luxury of throwing the buffers away until a commit
> has occurred (unless you're in writeback mode.)

For metadata, yes.  But for ordered-data pages this doesn't matter.

btw, I have a vague feeling that I've forgotten something here, but I've
forgotten what it was.  I'll have a play with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
