Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id EE38F6B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 16:38:17 -0400 (EDT)
Date: Wed, 26 Jun 2013 22:38:03 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/7] mm: compaction: don't depend on kswapd to invoke
 reset_isolation_suitable
Message-ID: <20130626203803.GC28030@redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-4-git-send-email-aarcange@redhat.com>
 <51AF9630.5040105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51AF9630.5040105@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 03:49:04PM -0400, Rik van Riel wrote:
> On 06/05/2013 11:10 AM, Andrea Arcangeli wrote:
> > If kswapd never need to run (only __GFP_NO_KSWAPD allocations and
> > plenty of free memory) compaction is otherwise crippled down and stops
> > running for a while after the free/isolation cursor meets. After that
> > allocation can fail for a full cycle of compaction_deferred, until
> > compaction_restarting finally reset it again.
> >
> > Stopping compaction for a full cycle after the cursor meets, even if
> > it never failed and it's not going to fail, doesn't make sense.
> >
> > We already throttle compaction CPU utilization using
> > defer_compaction. We shouldn't prevent compaction to run after each
> > pass completes when the cursor meets, unless it failed.
> >
> > This makes direct compaction functional again. The throttling of
> > direct compaction is still controlled by the defer_compaction
> > logic.
> >
> > kswapd still won't risk to reset compaction, and it will wait direct
> > compaction to do so. Not sure if this is ideal but it at least
> > decreases the risk of kswapd doing too much work. kswapd will only run
> > one pass of compaction until some allocation invokes compaction again.
> 
> Won't kswapd reset compaction even with your patch,
> but only when kswapd invokes compaction and the cursors
> meet?

kswapd won't ever reset it because of the current_is_kswapd check.

> In other words, the behaviour should be correct even
> for cases where kswapd is the only thing in the system
> doing compaction (eg. GFP_ATOMIC higher order allocations),
> but your changelog does not describe it completely.

In that case with the previous code compact_blockskip_flush would
never get set and still compaction would never be resetted.

> > This decreased reliability of compaction was introduced in commit
> > 62997027ca5b3d4618198ed8b1aba40b61b1137b .
> >
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> The code looks good to me.
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>

Thanks. Not sure if this does exactly what you expected but it's not
changing the behavior of the GFP_ATOMIC load if compared to the
current upstream comapction code.

The first attempt to add compaction in kswapd a few years back failed
because it slowed down network NFS loads with jumbo frames.  kswapd
was doing too much compaction for very short lived allocations
(worthless and totally wasted CPU), so I believe this time compaction
in kswapd worked out just because we don't activate with GFP_ATOMIC
network jumbo frame allocations. So the above to me sounds more a
feature than a bug and that's why I've been careful not to ever reset
compaction within kswapd (just like the previous code).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
