Date: Thu, 28 Jun 2007 08:20:31 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [RFC] fsblock
Message-ID: <20070628122031.GF5313@think.oraclecorp.com>
References: <20070624014528.GA17609@wotan.suse.de> <20070626030640.GM989688@sgi.com> <46808E1F.1000509@yahoo.com.au> <20070626092309.GF31489@sgi.com> <20070626123449.GM14224@think.oraclecorp.com> <20070627053245.GA6033@wotan.suse.de> <20070627115056.GW14224@think.oraclecorp.com> <20070627223548.GS989688@sgi.com> <20070628024443.GB6038@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070628024443.GB6038@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: David Chinner <dgc@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 28, 2007 at 04:44:43AM +0200, Nick Piggin wrote:
> On Thu, Jun 28, 2007 at 08:35:48AM +1000, David Chinner wrote:
> > On Wed, Jun 27, 2007 at 07:50:56AM -0400, Chris Mason wrote:
> > > Lets look at a typical example of how IO actually gets done today,
> > > starting with sys_write():
> > > 
> > > sys_write(file, buffer, 1MB)
> > > for each page:
> > >     prepare_write()
> > > 	allocate contiguous chunks of disk
> > >         attach buffers
> > >     copy_from_user()
> > >     commit_write()
> > >         dirty buffers
> > > 
> > > pdflush:
> > >     writepages()
> > >         find pages with contiguous chunks of disk
> > > 	build and submit large bios
> > > 
> > > So, we replace prepare_write and commit_write with an extent based api,
> > > but we keep the dirty each buffer part.  writepages has to turn that
> > > back into extents (bio sized), and the result is completely full of dark
> > > dark corner cases.
> 
> That's true but I don't think an extent data structure means we can
> become too far divorced from the pagecache or the native block size
> -- what will end up happening is that often we'll need "stuff" to map
> between all those as well, even if it is only at IO-time.

I think the fundamental difference is that fsblock still does:
mapping_info = page->something, where something is attached on a per
page basis.  What we really want is mapping_info = lookup_mapping(page),
where that function goes and finds something stored on a per extent
basis, with extra bits for tracking dirty and locked state.

Ideally, in at least some of the cases the dirty and locked state could
be at an extent granularity (streaming IO) instead of the block
granularity (random IO).

In my little brain, even block based filesystems should be able to take
advantage of this...but such things are always easier to believe in
before the coding starts.

> 
> But the point is taken, and I do believe that at least for APIs, extent
> based seems like the best way to go. And that should allow fsblock to
> be replaced or augmented in future without _too_ much pain.
> 
>  
> > Yup - I've been on the painful end of those dark corner cases several
> > times in the last few months.
> > 
> > It's also worth pointing out that mpage_readpages() already works on
> > an extent basis - it overloads bufferheads to provide a "map_bh" that
> > can point to a range of blocks in the same state. The code then iterates
> > the map_bh range a page at a time building bios (i.e. not even using
> > buffer heads) from that map......
> 
> One issue I have with the current nobh and mpage stuff is that it
> requires multiple calls into get_block (first to prepare write, then
> to writepage), it doesn't allow filesystems to attach resources
> required for writeout at prepare_write time, and it doesn't play nicely
> with buffers in general. (not to mention that nobh error handling is
> buggy).
> 
> I haven't done any mpage-like code for fsblocks yet, but I think they
> wouldn't be too much trouble, and wouldn't have any of the above
> problems...

Could be, but the fundamental issue of sometimes pages have mappings
attached and sometimes they don't is still there.  The window is
smaller, but non-zero.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
