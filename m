Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 121DA5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:15:16 -0400 (EDT)
Date: Tue, 2 Jun 2009 14:55:38 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602125538.GH1065@one.firstfloor.org>
References: <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090601120537.GF5018@wotan.suse.de> <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de> <20090602123450.GF1065@one.firstfloor.org> <20090602123720.GF1392@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602123720.GF1392@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 02:37:20PM +0200, Nick Piggin wrote:
> Because I don't see any difference (see my previous patch). I
> still don't know what it is supposed to be doing differently.
> So if you reinvent your own that looks close enough to truncate
> to warrant a comment to say /* this is close to truncate but
> not quite */, then yes I insist that you say exactly why it is
> not quite like truncate ;)

I will just delete that comment because it apparently causes so 
much confusion.

> 
>  
> > > I'm suggesting that EIO is traditionally for when the data still
> > > dirty in pagecache and was not able to get back to backing
> > > store. Do you deny that?
> > 
> > Yes. That is exactly the case when memory-failure triggers EIO
> > 
> > Memory error on a dirty file mapped page.
> 
> But it is no longer dirty, and the problem was not that the data
> was unable to be written back.

Sorry I don't understand. What do you mean with "no longer dirty"

Of course it's still dirty, just has to be discarded because it's 
corrupted.

> > > And I think the application might try to handle the case of a
> > > page becoming corrupted differently. Do you deny that?
> > 
> > You mean a clean file-mapped page? In this case there is no EIO,
> > memory-failure just drops the page and it is reloaded.
> > 
> > If the page is dirty we trigger EIO which as you said above is the 
> > right reaction.
> 
> No I mean the difference between the case of dirty page unable to
> be written to backing sotre, and the case of dirty page becoming
> corrupted.

Nick, I have really a hard time following you here.

What exactly do you want? 

A new errno? Or something else? If yes what precisely?

I currently don't see any sane way to report this to the application
through write().  That is because adding a new errno for something
is incredibly hard and often impossible, and that's certainly
the case here.

The application can detect it if it maps the 
shared page and waits for a SIGBUS, but not through write().

But I doubt there will be really any apps that do anything differently
here anyways. A clever app could retry a few times if it still
has a copy of the data, but that might even make sense on normal
IO errors (e.g. on a SAN).

> 
> 
> > > OK, given the range of errors that APIs are defined to return,
> > > then maybe EIO is the best option. I don't suppose it is possible
> > > to expand them to return something else?
> > 
> > Expand the syscalls to return other errnos on specific
> > kinds of IO error?
> >  
> > Of course that's possible, but it has the problem that you 
> > would need to fix all the applications that expect EIO for
> > IO error. The later I consider infeasible.
> 
> They would presumably exit or do some default thing, which I
> think would be fine.

No it's not fine if they would handle EIO. e.g. consider
a sophisticated database which likely has sophisticated
IO error mechanisms too (e.g. only abort the current commit)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
