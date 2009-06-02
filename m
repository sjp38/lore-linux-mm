Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 549E35F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:29:50 -0400 (EDT)
Date: Tue, 2 Jun 2009 15:03:06 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602130306.GA6262@wotan.suse.de>
References: <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090601120537.GF5018@wotan.suse.de> <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de> <20090602123450.GF1065@one.firstfloor.org> <20090602123720.GF1392@wotan.suse.de> <20090602125538.GH1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602125538.GH1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 02:55:38PM +0200, Andi Kleen wrote:
> On Tue, Jun 02, 2009 at 02:37:20PM +0200, Nick Piggin wrote:
> > Because I don't see any difference (see my previous patch). I
> > still don't know what it is supposed to be doing differently.
> > So if you reinvent your own that looks close enough to truncate
> > to warrant a comment to say /* this is close to truncate but
> > not quite */, then yes I insist that you say exactly why it is
> > not quite like truncate ;)
> 
> I will just delete that comment because it apparently causes so 
> much confusion.

And replace it with something that actually clears up the
confusion.


> > > > I'm suggesting that EIO is traditionally for when the data still
> > > > dirty in pagecache and was not able to get back to backing
> > > > store. Do you deny that?
> > > 
> > > Yes. That is exactly the case when memory-failure triggers EIO
> > > 
> > > Memory error on a dirty file mapped page.
> > 
> > But it is no longer dirty, and the problem was not that the data
> > was unable to be written back.
> 
> Sorry I don't understand. What do you mean with "no longer dirty"
> 
> Of course it's still dirty, just has to be discarded because it's 
> corrupted.

The pagecache location is no longer dirty. Userspace only cares
about pagecache locations and their contents, not the page that
was once there and has now been taken out.

 
> > > > And I think the application might try to handle the case of a
> > > > page becoming corrupted differently. Do you deny that?
> > > 
> > > You mean a clean file-mapped page? In this case there is no EIO,
> > > memory-failure just drops the page and it is reloaded.
> > > 
> > > If the page is dirty we trigger EIO which as you said above is the 
> > > right reaction.
> > 
> > No I mean the difference between the case of dirty page unable to
> > be written to backing sotre, and the case of dirty page becoming
> > corrupted.
> 
> Nick, I have really a hard time following you here.
> 
> What exactly do you want? 
> 
> A new errno? Or something else? If yes what precisely?

Yeah a new errno would be nice. Precisely one to say that the
memory was corrupted.

 
> I currently don't see any sane way to report this to the application
> through write().  That is because adding a new errno for something
> is incredibly hard and often impossible, and that's certainly
> the case here.
> 
> The application can detect it if it maps the 
> shared page and waits for a SIGBUS, but not through write().
> 
> But I doubt there will be really any apps that do anything differently
> here anyways. A clever app could retry a few times if it still
> has a copy of the data, but that might even make sense on normal
> IO errors (e.g. on a SAN).

I'm sure some of the ones that really care would.


> > They would presumably exit or do some default thing, which I
> > think would be fine.
> 
> No it's not fine if they would handle EIO. e.g. consider
> a sophisticated database which likely has sophisticated
> IO error mechanisms too (e.g. only abort the current commit)

Umm, if it is a generic "this failed, we can abort" then why
would not this be the default case. The issue is if it does
something differnet specifically for EIO, and specifically
assuming the pagecache is still valid and dirty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
