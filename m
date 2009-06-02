Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 62ECC5F0020
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:04:05 -0400 (EDT)
Date: Tue, 2 Jun 2009 14:37:20 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602123720.GF1392@wotan.suse.de>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org> <20090601120537.GF5018@wotan.suse.de> <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de> <20090602123450.GF1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602123450.GF1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 02:34:50PM +0200, Andi Kleen wrote:
> On Tue, Jun 02, 2009 at 02:10:31PM +0200, Nick Piggin wrote:
> > > It's not, there are various differences (like the reference count)
> > 
> > No. If there are, then it *really* needs better documentation. I
> > don't think there are, though.
> 
> Better documentation on what? You want a detailed listing in a comment
> how it is different from truncate?
> 
> To be honest I have some doubts of the usefulness of such a comment
> (why stop at truncate and not list the differences to every other
> page cache operation? @) but if you're insist (do you?) I can add one.

Because I don't see any difference (see my previous patch). I
still don't know what it is supposed to be doing differently.
So if you reinvent your own that looks close enough to truncate
to warrant a comment to say /* this is close to truncate but
not quite */, then yes I insist that you say exactly why it is
not quite like truncate ;)

 
> > I'm suggesting that EIO is traditionally for when the data still
> > dirty in pagecache and was not able to get back to backing
> > store. Do you deny that?
> 
> Yes. That is exactly the case when memory-failure triggers EIO
> 
> Memory error on a dirty file mapped page.

But it is no longer dirty, and the problem was not that the data
was unable to be written back.


> > And I think the application might try to handle the case of a
> > page becoming corrupted differently. Do you deny that?
> 
> You mean a clean file-mapped page? In this case there is no EIO,
> memory-failure just drops the page and it is reloaded.
> 
> If the page is dirty we trigger EIO which as you said above is the 
> right reaction.

No I mean the difference between the case of dirty page unable to
be written to backing sotre, and the case of dirty page becoming
corrupted.


> > OK, given the range of errors that APIs are defined to return,
> > then maybe EIO is the best option. I don't suppose it is possible
> > to expand them to return something else?
> 
> Expand the syscalls to return other errnos on specific
> kinds of IO error?
>  
> Of course that's possible, but it has the problem that you 
> would need to fix all the applications that expect EIO for
> IO error. The later I consider infeasible.

They would presumably exit or do some default thing, which I
think would be fine. Actually if your code catches them in the
act of manipulating a corrupted page (ie. if it is mmapped),
then it gets a SIGBUS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
