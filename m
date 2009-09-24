Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2EE6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 06:37:59 -0400 (EDT)
Date: Thu, 24 Sep 2009 12:37:18 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: a patch drop request in -mm
Message-ID: <20090924103718.GA8316@cmpxchg.org>
References: <2f11576a0909210800l639560e4jad6cfc2e7f74538f@mail.gmail.com> <20090921152219.GQ12726@csn.ul.ie> <20090924092903.B648.A69D9226@jp.fujitsu.com> <20090924090923.GA8800@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090924090923.GA8800@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Sep 24, 2009 at 10:09:23AM +0100, Mel Gorman wrote:
> On Thu, Sep 24, 2009 at 09:40:34AM +0900, KOSAKI Motohiro wrote:
> > > On Tue, Sep 22, 2009 at 12:00:51AM +0900, KOSAKI Motohiro wrote:
> > > > Mel,
> > > > 
> > > > Today, my test found following patch makes false-positive warning.
> > > > because, truncate can free the pages
> > > > although the pages are mlock()ed.
> > > > 
> > > > So, I think following patch should be dropped.
> > > > .. or, do you think truncate should clear PG_mlock before free the page?
> > > 
> > > Is there a reason that truncate cannot clear PG_mlock before freeing the
> > > page?
> > 
> > CC to Lee.
> > IIRC, Lee tried it at first. but after some trouble, he decided change free_hot_cold_page().
> > but unfortunately, I don't recall the reason ;-)
> > 
> > Lee, Can you recall it?
> > 
> > 
> > > > Can I ask your patch intention?
> > > 
> > > Locked pages being freed to the page allocator were considered
> > > unexpected and a counter was in place to determine how often that
> > > situation occurred. However, I considered it unlikely that the counter
> > > would be noticed so the warning was put in place to catch what class of
> > > pages were getting freed locked inappropriately. I think a few anomolies
> > > have been cleared up since. Ultimately, it should have been safe to
> > > delete the check.
> > 
> > OK. it seems reasonable. so, I only hope no see linus tree output false-positive warnings.
> > Thus, I propse 
> > 
> >   - don't merge this patch to linus tree
> >   - but, no drop from -mm
> >     it be holded in mm until this issue fixed.
> >   - I'll working on fixing this issue.
> > 
> > I think this is enough fair.
> > 
> 
> I'm afraid I'm just about to run out the door and will be offline until
> Tuesday at the very least. I haven't had the chance to review the patch.
> However, I have no problem with this patch not being merged to Linus's tree
> if it remains in -mm to catch this and other false positives.
> 
> > Hannes, I'm sorry. I haven't review your patch. I'm too busy now. please gime me more
> > sevaral time.
> > 
> 
> It'll be Tuesday at the very earliest before I get a chance to review.

Hugh already pointed out its defects, so the patch as it stands is not
usable.

The problem, if I understood it correctly, is that truncation munlocks
page cache pages but we also unmap (and free) their private COWs,
which can still be mlocked.

So my patch moved the munlocking from truncation to unmap code to make
sure we catch the cows, but for nonlinear unmapping we also want
non-linear munlocking, where my patch is broken.

Perhaps we can do page-wise munlocking in zap_pte_range(), where
zap_details are taken into account.  Hopefully, I will have time on
the weekend to look further into it.

Thanks,
	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
