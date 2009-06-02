Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 967B25F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:54:30 -0400 (EDT)
Date: Tue, 2 Jun 2009 14:34:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602123450.GF1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090601120537.GF5018@wotan.suse.de> <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602121031.GC1392@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 02:10:31PM +0200, Nick Piggin wrote:
> > > Just extract the part where it has the page locked into a common
> > > function.
> > 
> > That doesn't do some stuff we want to do, like try_to_release_buffers
> > And there's the page count problem with remove_mapping
> > 
> > That could be probably fixed, but to be honest I'm uncomfortable
> > fiddling with truncate internals.
> 
> You're looking at invalidate, which is different. See my
> last patch.

Hmm. 

> 
> > > > Is there anything concretely wrong with the current code?
> > > 
> > > 
> > > /*
> > >  * Truncate does the same, but we're not quite the same
> > >  * as truncate. Needs more checking, but keep it for now.
> > >  */
> > > 
> > > I guess that it duplicates this tricky truncate code and also
> > > says it is different (but AFAIKS it is doing exactly the same
> > > thing).
> > 
> > It's not, there are various differences (like the reference count)
> 
> No. If there are, then it *really* needs better documentation. I
> don't think there are, though.

Better documentation on what? You want a detailed listing in a comment
how it is different from truncate?

To be honest I have some doubts of the usefulness of such a comment
(why stop at truncate and not list the differences to every other
page cache operation? @) but if you're insist (do you?) I can add one.

> I'm suggesting that EIO is traditionally for when the data still
> dirty in pagecache and was not able to get back to backing
> store. Do you deny that?

Yes. That is exactly the case when memory-failure triggers EIO

Memory error on a dirty file mapped page.

> And I think the application might try to handle the case of a
> page becoming corrupted differently. Do you deny that?

You mean a clean file-mapped page? In this case there is no EIO,
memory-failure just drops the page and it is reloaded.

If the page is dirty we trigger EIO which as you said above is the 
right reaction.

> 
> OK, given the range of errors that APIs are defined to return,
> then maybe EIO is the best option. I don't suppose it is possible
> to expand them to return something else?

Expand the syscalls to return other errnos on specific
kinds of IO error?
 
Of course that's possible, but it has the problem that you 
would need to fix all the applications that expect EIO for
IO error. The later I consider infeasible.

> > > > > Just seems overengineered. We could rewrite any if/switch statement like
> > > > > that (and actually the compiler probably will if it is beneficial).
> > > > 
> > > > The reason I like it is that it separates the functions cleanly,
> > > > without that there would be a dispatcher from hell. Yes it's a bit
> > > > ugly that there is a lot of manual bit checking around now too,
> > > > but as you go into all the corner cases originally clean code
> > > > always tends to get more ugly (and this is a really ugly problem)
> > > 
> > > Well... it is just writing another dispatcher from hell in a
> > > different way really, isn't it? How is it so much better than
> > > a simple switch or if/elseif/else statement?
> > 
> > switch () wouldn't work, it relies on the order.
> 
> Order of what?

Order of the bit tests. 

> 
> 
> > if () would work, but it would be larger and IMHO much harder
> > to read than the table. I prefer the table, which is a reasonably
> > clean mechanism to do that.
> 
> OK. Maybe I'll try send a patch to remove it and see how it looks
> sometime. I think it's totally overengineered, but that's just me.

I disagree on that.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
