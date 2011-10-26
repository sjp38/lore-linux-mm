Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E246F6B002D
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 01:47:24 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p9Q5lLqS026255
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 22:47:22 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by hpaq14.eem.corp.google.com with ESMTP id p9Q5l6Bs025421
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 22:47:20 -0700
Received: by pzk4 with SMTP id 4so5007951pzk.10
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 22:47:18 -0700 (PDT)
Date: Tue, 25 Oct 2011 22:47:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com> <20111025090956.GA10797@suse.de> <alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com> <CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1796313805-1319608037=:18661"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1796313805-1319608037=:18661
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 25 Oct 2011, Colin Cross wrote:

> > On Tue, 25 Oct 2011, Mel Gorman wrote:
> >
> >> That said, it will be difficult to remember why checking __GFP_NOFAIL in
> >> this case is necessary and someone might "optimitise" it away later. It
> >> would be preferable if it was self-documenting. Maybe something like
> >> this? (This is totally untested)
> >>
> >
> > __GFP_NOFAIL _should_ be optimized away in this case because all he's
> > passing is __GFP_WAIT | __GFP_NOFAIL.  That doesn't make any sense unless
> > all you want to do is livelock.
> 
> __GFP_NOFAIL is not set in the case that I care about.  If my change
> is hit, no forward progress has been made, so I agree it should not
> honor __GFP_NOFAIL.
> 

I was responding to Mel's comment, not your case.

> > __GFP_NOFAIL doesn't mean the page allocator would infinitely loop in all
> > conditions.  That's why GFP_ATOMIC | __GFP_NOFAIL actually fails, and I
> > would argue that __GFP_WAIT | __GFP_NOFAIL should fail as well since it's
> > the exact same condition except doesn't have access to the extra memory
> > reserves.
> >
> > Suspend needs to either set __GFP_NORETRY to avoid the livelock if it's
> > going to disable all means of memory reclaiming or freeing in the page
> > allocator.  Or, better yet, just make it GFP_NOWAIT.
> >
> 
> It would be nice to give compaction and the slab shrinker a chance to
> recover a few pages, both methods will work fine in suspend.

Ok, so __GFP_NORETRY it is.  Just make sure that when 
pm_restrict_gfp_mask() masks off __GFP_IO and __GFP_FS that it also sets 
__GFP_NORETRY even though the name of the function no longer seems 
appropriate anymore.

> GFP_NOWAIT will prevent them from ever running, and __GFP_NORETRY will
> give up even if they are making progress but haven't recovered enough
> pages.
> 

These are all order-3 or smaller allocations where fragmentation isn't a 
big issue.  If a call into direct compaction or reclaim fails to reclaim 
that small amount of contiguous memory, what makes you believe that a 
second call will?
--397155492-1796313805-1319608037=:18661--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
