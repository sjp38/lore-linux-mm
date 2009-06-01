Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C46A6B00A9
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:11:30 -0400 (EDT)
Date: Mon, 1 Jun 2009 20:51:47 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090601185147.GT1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090601120537.GF5018@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090601120537.GF5018@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, Jun 01, 2009 at 02:05:38PM +0200, Nick Piggin wrote:
> On Thu, May 28, 2009 at 03:45:20PM +0200, Andi Kleen wrote:
> > On Thu, May 28, 2009 at 02:08:54PM +0200, Nick Piggin wrote:
> > > Then the data can not have been consumed, by DMA or otherwise? What
> > 
> > When the data was consumed we get a different machine check
> > (or a different error if it was consumed by a IO device)
> > 
> > This code right now just handles the case of "CPU detected a page is broken
> > is wrong, but hasn't consumed it yet"
> 
> OK. Out of curiosity, how often do you expect to see uncorrectable ECC
> errors?

That's a difficult question. It depends on a lot of factors, e.g. 
how much memory you have (but memory sizes are growing all the time), 
how many machines you have (large clusters tend to turn infrequent errors 
into frequent ones), how well your cooling and power supply works etc.

I can't give you a single number at this point, sorry.

> > > > > > +	/*
> > > > > > +	 * remove_from_page_cache assumes (mapping && !mapped)
> > > > > > +	 */
> > > > > > +	if (page_mapping(p) && !page_mapped(p)) {
> > > > > > +		remove_from_page_cache(p);
> > > > > > +		page_cache_release(p);
> > > > > > +	}
> > > > > 
> > > > > remove_mapping would probably be a better idea. Otherwise you can
> > > > > probably introduce pagecache removal vs page fault races whi
> > > > > will make the kernel bug.
> > > > 
> > > > Can you be more specific about the problems?
> > > 
> > > Hmm, actually now that we hold the page lock over __do_fault (at least
> > > for pagecache pages), this may not be able to trigger the race I was
> > > thinking of (page becoming mapped). But I think still it is better
> > > to use remove_mapping which is the standard way to remove such a page.
> > 
> > I had this originally, but Fengguang redid it because there was
> > trouble with the reference count. remove_mapping always expects it to
> > be 2, which we cannot guarantee.
> 
> OK, but it should still definitely use truncate code.

It does -- see other email.

> 
> > > > > > +	if (mapping) {
> > > > > > +		/*
> > > > > > +		 * Truncate does the same, but we're not quite the same
> > > > > > +		 * as truncate. Needs more checking, but keep it for now.
> > > > > > +		 */
> > > > > 
> > > > > What's different about truncate? It would be good to reuse as much as possible.
> > > > 
> > > > Truncating removes the block on disk (we don't). Truncating shrinks
> > > > the end of the file (we don't). It's more "temporal hole punch"
> > > > Probably from the VM point of view it's very similar, but it's
> > > > not the same.
> > > 
> > > Right, I just mean the pagecache side of the truncate. So you should
> > > use truncate_inode_pages_range here.
> > 
> > Why?  I remember I was trying to use that function very early on but
> > there was some problem.  For once it does its own locking which
> > would conflict with ours.
> 
> Just extract the part where it has the page locked into a common
> function.

That doesn't do some stuff we want to do, like try_to_release_buffers
And there's the page count problem with remove_mapping

That could be probably fixed, but to be honest I'm uncomfortable
fiddling with truncate internals.


>  
> 
> > Is there anything concretely wrong with the current code?
> 
> 
> /*
>  * Truncate does the same, but we're not quite the same
>  * as truncate. Needs more checking, but keep it for now.
>  */
> 
> I guess that it duplicates this tricky truncate code and also
> says it is different (but AFAIKS it is doing exactly the same
> thing).

It's not, there are various differences (like the reference count)

> > > Well, the dirty data has never been corrupted before (ie. the data
> > > in pagecache has been OK). It was just unable to make it back to
> > > backing store. So a program could retry the write/fsync/etc or
> > > try to write the data somewhere else.
> > 
> > In theory it could, but in practice it is very unlikely it would.
> 
> very unlikely to try rewriting the page again or taking evasive
> action to save the data somewhere else? I think that's a bold
> assumption.
> 
> At the very least, having a prompt "IO error, check your hotplug
> device / network connection / etc and try again" I don't think
> sounds unreasonable at all.

I'm not sure what you're suggesting here. Are you suggesting
corrupted dirty page should return a different errno than a traditional 
IO error?

I don't think having a different errno for this would be a good
idea. Programs expect EIO on IO error and not something else.
And from the POV of the program it's an IO error.

Or are you suggesting there should be a mechanism where
an application could query about more details about a given
error it retrieved before? I think the later would be useful
in some cases, but probably hard to implement. Definitely
out of scope for this effort.

> > > Just seems overengineered. We could rewrite any if/switch statement like
> > > that (and actually the compiler probably will if it is beneficial).
> > 
> > The reason I like it is that it separates the functions cleanly,
> > without that there would be a dispatcher from hell. Yes it's a bit
> > ugly that there is a lot of manual bit checking around now too,
> > but as you go into all the corner cases originally clean code
> > always tends to get more ugly (and this is a really ugly problem)
> 
> Well... it is just writing another dispatcher from hell in a
> different way really, isn't it? How is it so much better than
> a simple switch or if/elseif/else statement?

switch () wouldn't work, it relies on the order.

if () would work, but it would be larger and IMHO much harder
to read than the table. I prefer the table, which is a reasonably
clean mechanism to do that.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
