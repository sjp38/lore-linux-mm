Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 11A376B005D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:40:28 -0400 (EDT)
Date: Tue, 2 Jun 2009 15:40:24 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602134024.GA19390@wotan.suse.de>
References: <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org> <20090602120042.GB1392@wotan.suse.de> <20090602124757.GG1065@one.firstfloor.org> <20090602125713.GG1392@wotan.suse.de> <20090602132538.GK1065@one.firstfloor.org> <20090602132441.GC6262@wotan.suse.de> <20090602134126.GM1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602134126.GM1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 03:41:26PM +0200, Andi Kleen wrote:
> On Tue, Jun 02, 2009 at 03:24:41PM +0200, Nick Piggin wrote:
> > On Tue, Jun 02, 2009 at 03:25:38PM +0200, Andi Kleen wrote:
> > > The reason this code double checks is that someone could have 
> > > a reference (remember we can come in any time) we cannot kill immediately.
> > 
> > Can't kill what? The page is gone from pagecache. It may remain
> > other kernel references, but I don't see why this code will
> > consider this as a failure (and not, for example, a raised error
> > count).
> 
> It's a failure because the page was still used and not successfully
> isolated.

But you're predicating success on page_count, so there can be
other users anyway. You do check page_count later and emit
a different message in this case, but even that isn't enough
to tell you if it has no more users.

I wouldn't have thought it's worth the complication, but
there is nothing preventing you using my truncate function
and also keeping this error check to test afterwards.
 

> > +        * remove_from_page_cache assumes (mapping && !mapped)
> > +        */
> > +       if (page_mapping(p) && !page_mapped(p)) {
> 
> Ok you're right. That one is not needed. I will remove it.
> 
> > > 
> > > User page tables was on the todo list, these are actually relatively
> > > easy. The biggest issue is to detect them.
> > > 
> > > Metadata would likely need file system callbacks, which I would like to 
> > > avoid at this point.
> > 
> > So I just don't know why you argue the point that you have lots
> > of large holes left.
> 
> I didn't argue that. My point was just that I currently don't have
> data what holes are the worst on given workloads. If I figure out at
> some point that writeback pages are a significant part of some important
> workload I would be interested in tackling them.
> That said I think that's unlikely, but I'm not ruling it out.

Well, it sounds like maybe there is a sane way to do them with your
IO interception... but anyway let's not worry about this right
now ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
