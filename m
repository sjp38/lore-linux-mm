Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1125F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:46:24 -0400 (EDT)
Date: Tue, 2 Jun 2009 14:19:40 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602121940.GD1392@wotan.suse.de>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601140553.GA1979@localhost> <20090601144050.GA12099@wotan.suse.de> <20090602111407.GA17234@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602111407.GA17234@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 07:14:07PM +0800, Wu Fengguang wrote:
> On Mon, Jun 01, 2009 at 10:40:51PM +0800, Nick Piggin wrote:
> > But you just said that you try to intercept the IO. So the underlying
> > data is not necessarily corrupt. And even if it was then what if it
> > was reinitialized to something else in the meantime (such as filesystem
> > metadata blocks?) You'd just be introducing worse possibilities for
> > coruption.
> 
> The IO interception will be based on PFN instead of file offset, so it
> won't affect innocent pages such as your example of reinitialized data.

OK, if you could intercept the IO so it never happens at all, yes
of course that could work.


> poisoned dirty page == corrupt data      => process shall be killed
> poisoned clean page == recoverable data  => process shall survive
> 
> In the case of dirty hwpoison page, if we reload the on disk old data
> and let application proceed with it, it may lead to *silent* data
> corruption/inconsistency, because the application will first see v2
> then v1, which is illogical and hence may mess up its internal data
> structure.

Right, but how do you prevent that? There is no way to reconstruct the
most updtodate data because it was destroyed.

 
> > You will need to demonstrate a *big* advantage before doing crazy things
> > with writeback ;)
> 
> OK. We can do two things about poisoned writeback pages:
> 
> 1) to stop IO for them, thus avoid corrupted data to hit disk and/or
>    trigger further machine checks

1b) At which point, you invoke the end-io handlers, and the page is
no longer writeback.

> 2) to isolate them from page cache, thus preventing possible
>    references in the writeback time window

And then this is possible because you aren't violating mm
assumptions due to 1b. This proceeds just as the existing
pagecache mce error handler case which exists now.

 
> > > Now it's obvious that reusing more code than truncate_complete_page()
> > > is not easy (or natural).
> > 
> > Just lock the page and wait for writeback, then do the truncate
> > work in another function. In your case if you've already unmapped
> > the page then it won't try to unmap again so no problem.
> > 
> > Truncating from pagecache does not change ->index so you can
> > move the loop logic out.
> 
> Right. So effectively the reusable function is exactly
> truncate_complete_page(). As I said this reuse is not a big gain.

Anyway, we don't have to argue about it. I already send a patch
because it was so hard to do, so let's move past this ;)


> > > Yes it's kind of insane.  I'm interested in reasoning it out though.

Well with the IO interception (I missed this point), then it seems
maybe no longer so insane. We could see how it looks.


> > I guess it is a good idea to start simple.
> 
> Agreed.
> 
> > Considering that there are so many other types of pages that are
> > impossible to deal with or have holes, then I very strongly doubt
> > it will be worth so much complexity for closing the gap from 90%
> > to 90.1%. But we'll see.
> 
> Yes, the plan is to first focus on the more important cases.

Great.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
