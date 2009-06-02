Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B87B05F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:46:24 -0400 (EDT)
Date: Tue, 2 Jun 2009 15:19:37 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602131937.GB6262@wotan.suse.de>
References: <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090601120537.GF5018@wotan.suse.de> <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de> <20090602123450.GF1065@one.firstfloor.org> <20090602123720.GF1392@wotan.suse.de> <20090602125538.GH1065@one.firstfloor.org> <20090602130306.GA6262@wotan.suse.de> <20090602132002.GJ1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602132002.GJ1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 03:20:02PM +0200, Andi Kleen wrote:
> On Tue, Jun 02, 2009 at 03:03:06PM +0200, Nick Piggin wrote:
> > > > > > I'm suggesting that EIO is traditionally for when the data still
> > > > > > dirty in pagecache and was not able to get back to backing
> > > > > > store. Do you deny that?
> > > > > 
> > > > > Yes. That is exactly the case when memory-failure triggers EIO
> > > > > 
> > > > > Memory error on a dirty file mapped page.
> > > > 
> > > > But it is no longer dirty, and the problem was not that the data
> > > > was unable to be written back.
> > > 
> > > Sorry I don't understand. What do you mean with "no longer dirty"
> > > 
> > > Of course it's still dirty, just has to be discarded because it's 
> > > corrupted.
> > 
> > The pagecache location is no longer dirty. Userspace only cares
> > about pagecache locations and their contents, not the page that
> > was once there and has now been taken out.
> 
> Sorry, but that just sounds wrong to me. User space has no clue
> about the page cache, it just wants to know that the write it just

Umm, pagecache location is inode,offset, which is exactly what
userspace cares about, and they obviously know there can be a
writeback cache there because that's why fsync exists.


> did didn't reach the disk. And that's what happened and
> what we report here.

I didn't reach the disk and the dirty data was destroyed and
will be recreated from some unknown (to userspace) state 
from the filesystem. If you can't see how this is different
to the rest of our EIO conditions, then I can't spell it out
any simpler.


> > > A new errno? Or something else? If yes what precisely?
> > 
> > Yeah a new errno would be nice. Precisely one to say that the
> > memory was corrupted.
> 
> Ok.  I firmly think a new errno is a bad idea because I don't
> want to explain to a lot of people how to fix their applications.
> Compatibility is important.

Fair enough, maybe EIO is the best option, but I just want
people to think about it.

 
> > > No it's not fine if they would handle EIO. e.g. consider
> > > a sophisticated database which likely has sophisticated
> > > IO error mechanisms too (e.g. only abort the current commit)
> > 
> > Umm, if it is a generic "this failed, we can abort" then why
> > would not this be the default case. The issue is if it does
> > something differnet specifically for EIO, and specifically
> > assuming the pagecache is still valid and dirty.
> 
> How would it make such an assumption?

I guess either way you have to make assumptions that the
app uses errno in a particular way.

 
> I assume that if an application does something with EIO it 
> can either retry a few times or give up. Both is ok here.

That's exactly the case where it is not OK, because the
dirty page was now removed from pagecache, so the subsequent
fsync is going to succeed and the app will think its dirty
data has hit disk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
