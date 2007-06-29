Date: Fri, 29 Jun 2007 04:33:17 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC] fsblock
Message-ID: <20070629023316.GC6091@wotan.suse.de>
References: <20070624014528.GA17609@wotan.suse.de> <20070626030640.GM989688@sgi.com> <46808E1F.1000509@yahoo.com.au> <20070626092309.GF31489@sgi.com> <20070626123449.GM14224@think.oraclecorp.com> <20070627053245.GA6033@wotan.suse.de> <20070627115056.GW14224@think.oraclecorp.com> <20070627223548.GS989688@sgi.com> <20070628024443.GB6038@wotan.suse.de> <20070628122031.GF5313@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070628122031.GF5313@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: David Chinner <dgc@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 28, 2007 at 08:20:31AM -0400, Chris Mason wrote:
> On Thu, Jun 28, 2007 at 04:44:43AM +0200, Nick Piggin wrote:
> > 
> > That's true but I don't think an extent data structure means we can
> > become too far divorced from the pagecache or the native block size
> > -- what will end up happening is that often we'll need "stuff" to map
> > between all those as well, even if it is only at IO-time.
> 
> I think the fundamental difference is that fsblock still does:
> mapping_info = page->something, where something is attached on a per
> page basis.  What we really want is mapping_info = lookup_mapping(page),
> where that function goes and finds something stored on a per extent
> basis, with extra bits for tracking dirty and locked state.
> 
> Ideally, in at least some of the cases the dirty and locked state could
> be at an extent granularity (streaming IO) instead of the block
> granularity (random IO).
> 
> In my little brain, even block based filesystems should be able to take
> advantage of this...but such things are always easier to believe in
> before the coding starts.

Now I wouldn't for a minute deny that at least some of the block
information would be well to store in extent/tree format (if XFS 
does it it must be good!).

And yes, I'm sure filesystems with even basic block based allocation
could get a reasonable ratio of blocks to extents.

However I think it is fundamentally another layer or at least
more complexity... fsblocks uses the existing pagecache mapping as
(much of) the data structure and uses the existing pagecache locking
for the locking. And it fundamentally just provides a block access
and IO layer into the pagecache for the filesystem, which I think will
often be needed anyway.

But that said, I would like to see a generic extent mapping layer
sitting between fsblock and the filesystem (I might even have a crack
at it myself)... and I could be proven completely wrong and it may be
that fsblock isn't required at all after such a layer goes in. So I
will try to keep all the APIs extent based.

The first thing I actually looked at for "get_blocks" was for the
filesystem to build up a tree of mappings itself, completely unconnected
from the pagecache. It just ended up being a little more work and
locking but the idea isn't insane :)


> > One issue I have with the current nobh and mpage stuff is that it
> > requires multiple calls into get_block (first to prepare write, then
> > to writepage), it doesn't allow filesystems to attach resources
> > required for writeout at prepare_write time, and it doesn't play nicely
> > with buffers in general. (not to mention that nobh error handling is
> > buggy).
> > 
> > I haven't done any mpage-like code for fsblocks yet, but I think they
> > wouldn't be too much trouble, and wouldn't have any of the above
> > problems...
> 
> Could be, but the fundamental issue of sometimes pages have mappings
> attached and sometimes they don't is still there.  The window is
> smaller, but non-zero.

The aim for fsblocks is that any page under IO will always have fsblocks,
which I hope is going to make this easy. In the fsblocks patch I sent out
there is a window (with mmapped pages), however that's a bug wich can be
fixed rather than a fundamental problem. So writepages will be less problem.

Readpages may indeed be more efficient and block mapping with extents than
individual fsblocks (or it could be, if it were an extent based API itself).

Well I don't know. Extents are always going to have benefits, but I don't
know if it means the fsblock part could go away completely. I'll keep
it in mind though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
