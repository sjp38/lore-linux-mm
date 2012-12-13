Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id AE3046B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 14:06:25 -0500 (EST)
Date: Thu, 13 Dec 2012 14:05:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: vmscan: disregard swappiness shortly before
 going OOM
Message-ID: <20121213190534.GA6317@cmpxchg.org>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-3-git-send-email-hannes@cmpxchg.org>
 <20121213103420.GW1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121213103420.GW1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 13, 2012 at 10:34:20AM +0000, Mel Gorman wrote:
> On Wed, Dec 12, 2012 at 04:43:34PM -0500, Johannes Weiner wrote:
> > When a reclaim scanner is doing its final scan before giving up and
> > there is swap space available, pay no attention to swappiness
> > preference anymore.  Just swap.
> > 
> > Note that this change won't make too big of a difference for general
> > reclaim: anonymous pages are already force-scanned when there is only
> > very little file cache left, and there very likely isn't when the
> > reclaimer enters this final cycle.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Ok, I see the motivation for your patch but is the block inside still
> wrong for what you want? After your patch the block looks like this
> 
>                 if (sc->priority || noswap) {
>                         scan >>= sc->priority;
>                         if (!scan && force_scan)
>                                 scan = SWAP_CLUSTER_MAX;
>                         scan = div64_u64(scan * fraction[file], denominator);
>                 }
> 
> if sc->priority == 0 and swappiness==0 then you enter this block but
> fraction[0] for anonymous pages will also be 0 and because of the ordering
> of statements there, scan will be
> 
> scan = scan * 0 / denominator
> 
> so you are still not reclaiming anonymous pages in the swappiness=0
> case. What did I miss?

Don't get confused by noswap, it is only set when there physically is
no swap space.  If !sc->priority, that block is skipped and
fraction[0] does not matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
