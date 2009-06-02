Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E14FF6B005D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:47:42 -0400 (EDT)
Date: Tue, 2 Jun 2009 15:47:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602134739.GA26982@wotan.suse.de>
References: <20090601120537.GF5018@wotan.suse.de> <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de> <20090602123450.GF1065@one.firstfloor.org> <20090602123720.GF1392@wotan.suse.de> <20090602125538.GH1065@one.firstfloor.org> <20090602130306.GA6262@wotan.suse.de> <20090602132002.GJ1065@one.firstfloor.org> <20090602131937.GB6262@wotan.suse.de> <20090602134610.GO1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602134610.GO1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 03:46:10PM +0200, Andi Kleen wrote:
> On Tue, Jun 02, 2009 at 03:19:37PM +0200, Nick Piggin wrote:
> > > I assume that if an application does something with EIO it 
> > > can either retry a few times or give up. Both is ok here.
> > 
> > That's exactly the case where it is not OK, because the
> > dirty page was now removed from pagecache, so the subsequent
> > fsync is going to succeed and the app will think its dirty
> > data has hit disk.
> 
> Ok that's a fair point -- that's a hole in my scheme. I don't
> know of a good way to fix it though. Do you?
> 
> I suspect adding a new errno would break more cases than fixing
> them.

Right, I wasn't too serious about the new errno (although maybe
others have opinions about the feasibility of that?). Because
I just don't know the full consequences.

I was kind of thinking about we could SIGKILL them as they try
to access it or fsync it. But then the question is how long to
keep SIGKILLing? At one end of the scale you could do stupid
and simple and have another error flag in the mapping to do
the SIGKILL just once for the next read/write/fsync etc. Or
at the other end, you keep the page in the pagecache and
poisoned, and kill everyone until the page is explicitly truncated
by userspace. I don't really know...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
