Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D35E06B0055
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:33:13 -0400 (EDT)
Date: Tue, 2 Jun 2009 15:20:02 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602132002.GJ1065@one.firstfloor.org>
References: <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090601120537.GF5018@wotan.suse.de> <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de> <20090602123450.GF1065@one.firstfloor.org> <20090602123720.GF1392@wotan.suse.de> <20090602125538.GH1065@one.firstfloor.org> <20090602130306.GA6262@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602130306.GA6262@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 03:03:06PM +0200, Nick Piggin wrote:
> > > > > I'm suggesting that EIO is traditionally for when the data still
> > > > > dirty in pagecache and was not able to get back to backing
> > > > > store. Do you deny that?
> > > > 
> > > > Yes. That is exactly the case when memory-failure triggers EIO
> > > > 
> > > > Memory error on a dirty file mapped page.
> > > 
> > > But it is no longer dirty, and the problem was not that the data
> > > was unable to be written back.
> > 
> > Sorry I don't understand. What do you mean with "no longer dirty"
> > 
> > Of course it's still dirty, just has to be discarded because it's 
> > corrupted.
> 
> The pagecache location is no longer dirty. Userspace only cares
> about pagecache locations and their contents, not the page that
> was once there and has now been taken out.

Sorry, but that just sounds wrong to me. User space has no clue
about the page cache, it just wants to know that the write it just
did didn't reach the disk. And that's what happened and
what we report here.

Retries can make sense in some cases, but in these cases the
user space should do it in other EIO cases too.

> > > > > And I think the application might try to handle the case of a
> > > > > page becoming corrupted differently. Do you deny that?
> > > > 
> > > > You mean a clean file-mapped page? In this case there is no EIO,
> > > > memory-failure just drops the page and it is reloaded.
> > > > 
> > > > If the page is dirty we trigger EIO which as you said above is the 
> > > > right reaction.
> > > 
> > > No I mean the difference between the case of dirty page unable to
> > > be written to backing sotre, and the case of dirty page becoming
> > > corrupted.
> > 
> > Nick, I have really a hard time following you here.
> > 
> > What exactly do you want? 
> > 
> > A new errno? Or something else? If yes what precisely?
> 
> Yeah a new errno would be nice. Precisely one to say that the
> memory was corrupted.

Ok.  I firmly think a new errno is a bad idea because I don't
want to explain to a lot of people how to fix their applications.
Compatibility is important.

> > I currently don't see any sane way to report this to the application
> > through write().  That is because adding a new errno for something
> > is incredibly hard and often impossible, and that's certainly
> > the case here.
> > 
> > The application can detect it if it maps the 
> > shared page and waits for a SIGBUS, but not through write().
> > 
> > But I doubt there will be really any apps that do anything differently
> > here anyways. A clever app could retry a few times if it still
> > has a copy of the data, but that might even make sense on normal
> > IO errors (e.g. on a SAN).
> 
> I'm sure some of the ones that really care would.

Even if they would there would be still old binaries around.
Compatibility is important.

> 
> 
> > > They would presumably exit or do some default thing, which I
> > > think would be fine.
> > 
> > No it's not fine if they would handle EIO. e.g. consider
> > a sophisticated database which likely has sophisticated
> > IO error mechanisms too (e.g. only abort the current commit)
> 
> Umm, if it is a generic "this failed, we can abort" then why
> would not this be the default case. The issue is if it does
> something differnet specifically for EIO, and specifically
> assuming the pagecache is still valid and dirty.

How would it make such an assumption?

I assume that if an application does something with EIO it 
can either retry a few times or give up. Both is ok here.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
