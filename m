Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DCA376B006E
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 08:29:45 -0400 (EDT)
Date: Tue, 1 Nov 2011 12:29:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111101122940.GC25123@suse.de>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
 <20111025090956.GA10797@suse.de>
 <CAMbhsRR07Gpv-nEAvq8OQmLxkMyL5cASpq1vqQ8qN5ctwnamsQ@mail.gmail.com>
 <20111025112300.GB10797@suse.de>
 <CAOJsxLH54aUjVE3b7queQMOJP1kb+bxtUTAUA=T=N378M5_hJA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJsxLH54aUjVE3b7queQMOJP1kb+bxtUTAUA=T=N378M5_hJA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 10:39:34PM +0300, Pekka Enberg wrote:
> Hi Mel,
> 
> On Tue, Oct 25, 2011 at 2:23 PM, Mel Gorman <mgorman@suse.de> wrote:
> > I see what you mean with GFP_NOIO but there is an important difference
> > between GFP_NOIO and suspend.  A GFP_NOIO low-order allocation currently
> > implies __GFP_NOFAIL as commented on in should_alloc_retry(). If no progress
> > is made, we call wait_iff_congested() and sleep for a bit. As the system
> > is running, kswapd and other process activity will proceed and eventually
> > reclaim enough pages for the GFP_NOIO allocation to succeed. In a running
> > system, GFP_NOIO can stall for a period of time but your patch will cause
> > the allocation to fail. While I expect callers return ENOMEM or handle
> > the situation properly with a wait-and-retry loop, there will be
> > operations that fail that used to succeed. This is why I'd prefer it was
> > a suspend-specific fix unless we know there is a case where a machine
> > livelocks due to a GFP_NOIO allocation looping forever and even then I'd
> > wonder why kswapd was not helping.
> 
> I'm not that happy about your patch because it's going to the
> direction where the page allocator is special-casing for suspension.

Suspend really is a special case. While I'd prefer to avoid special
casing it like this, I prefer it a *lot* more than failing GFP_NOIO
allocations that used to succeed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
