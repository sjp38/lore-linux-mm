Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 2383F6B0033
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 16:04:52 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq13so90596pab.11
        for <linux-mm@kvack.org>; Wed, 11 Sep 2013 13:04:51 -0700 (PDT)
Date: Wed, 11 Sep 2013 13:04:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
In-Reply-To: <20130911160357.GA32273@dhcp22.suse.cz>
Message-ID: <alpine.LNX.2.00.1309111233200.2912@eggly.anvils>
References: <alpine.LNX.2.00.1309062254470.11420@eggly.anvils> <20130909110847.GB18056@dhcp22.suse.cz> <20130911154057.GA16765@teo> <20130911160357.GA32273@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Vorontsov <anton@enomsg.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 11 Sep 2013, Michal Hocko wrote:
> On Wed 11-09-13 08:40:57, Anton Vorontsov wrote:
> > On Mon, Sep 09, 2013 at 01:08:47PM +0200, Michal Hocko wrote:
> > > On Fri 06-09-13 22:59:16, Hugh Dickins wrote:
> > > > Hit divide-by-0 in vmpressure_work_fn(): checking vmpr->scanned before
> > > > taking the lock is not enough, we must check scanned afterwards too.
> > > 
> > > As vmpressure_work_fn seems the be the only place where we set scanned
> > > to 0 (except for the rare occasion when scanned overflows which
> > > would be really surprising) then the only possible way would be two
> > > vmpressure_work_fn racing over the same work item. system_wq is
> > > !WQ_NON_REENTRANT so one work item might be processed by multiple
> > > workers on different CPUs. This means that the vmpr->scanned check in
> > > the beginning of vmpressure_work_fn is inherently racy.
> > > 
> > > Hugh's patch fixes the issue obviously but doesn't it make more sense to
> > > move the initial vmpr->scanned check under the lock instead?
> > > 
> > > Anton, what was the initial motivation for the out of the lock
> > > check? Does it really optimize anything?
> > 
> > Thanks a lot for the explanation.
> > 
> > Answering your question: the idea was to minimize the lock section, but the
> > section is quite small anyway so I doubt that it makes any difference (during
> > development I could not measure any effect of vmpressure() calls in my system,
> > though the system itself was quite small).
> > 
> > I am happy with moving the check under the lock
> 
> The patch below. I find it little bit nicer than Hugh's original one
> because having the two checks sounds more confusing.
> What do you think Hugh, Anton?
> 
> > or moving the work into its own WQ_NON_REENTRANT queue.
> 
> That sounds like an overkill.
> 
> ---
> From 888745909da34f8aee8a208a82d467236b828d0d Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 11 Sep 2013 17:48:10 +0200
> Subject: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
> 
> Hugh Dickins has reported a division by 0 when a vmpressure event is
> processed. The reason for the exception is that a single vmpressure
> work item (which is per memcg) might be processed by multiple CPUs
> because it is enqueued on system_wq which is !WQ_NON_REENTRANT.
> This means that the out of lock vmpr->scanned check in
> vmpressure_work_fn is inherently racy and the racing workers will see
> already zeroed scanned value after they manage to take the spin lock.
> 
> The patch simply moves the vmp->scanned check inside the sr_lock to fix
> the race.
> 
> The issue was there since the very beginning but "vmpressure: change
> vmpressure::sr_lock to spinlock" might have made it more visible as the
> racing workers would sleep on the mutex and give it more time to see
> updated value. The issue was still there, though.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: stable@vger.kernel.org

Nack!  But equally Nack to my original.

Many thanks for looking into how this might have happened, Michal,
and for mentioning the WQ_NON_REENTRANT flag: which I knew nothing
about, but have now followed up.

I owe you all an abject apology: what I didn't mention in my patch
was that actually I hit the problem on a v3.3-based kernel to which
vmpressure had been backported.

I have not yet seen the problem on v3.11 or v3.10, and now believe
that it cannot happen there - which would explain why I was the
first to hit it.

When I looked up WQ_NON_REENTRANT in the latest tree, I found
	WQ_NON_REENTRANT	= 1 << 0, /* DEPRECATED */
and git blame on that line leads to Tejun explaining
    
    dbf2576e37 ("workqueue: make all workqueues non-reentrant") made
    WQ_NON_REENTRANT no-op but the following patches didn't remove the
    flag or update the documentation.  Let's mark the flag deprecated and
    update the documentation accordingly.

dbf2576e37 went into v3.7, so I now believe this divide-by-0 could
only happen on a backport of vmpressure to an earlier kernel than that.

Tejun made that change precisely to guard against this kind of subtle
unsafe issue; but it does provide a good illustration of the danger of
backporting something to a kernel where primitives behave less safely.

Sorry for wasting all your time.

As to your code change itself, Michal: I don't really mind one way or
the other - it now seems unnecessary.  On the one hand I liked Anton's
minor optimization, on the other hand your way is more proof against
future change.

My Nack is really to your comment (and the Cc stable): we cannot
explain in terms of WQ_NON_REENTRANT when that is a no-op!

Hugh

> ---
>  mm/vmpressure.c |   17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index e0f6283..ad679a0 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -164,18 +164,19 @@ static void vmpressure_work_fn(struct work_struct *work)
>  	unsigned long scanned;
>  	unsigned long reclaimed;
>  
> +	spin_lock(&vmpr->sr_lock);
> +
>  	/*
> -	 * Several contexts might be calling vmpressure(), so it is
> -	 * possible that the work was rescheduled again before the old
> -	 * work context cleared the counters. In that case we will run
> -	 * just after the old work returns, but then scanned might be zero
> -	 * here. No need for any locks here since we don't care if
> -	 * vmpr->reclaimed is in sync.
> +	 * Several contexts might be calling vmpressure() and the work
> +	 * item is sitting on !WQ_NON_REENTRANT workqueue so different
> +	 * CPUs might execute it concurrently. Bail out if the scanned
> +	 * counter is already 0 because all the work has been done already.
>  	 */
> -	if (!vmpr->scanned)
> +	if (!vmpr->scanned) {
> +		spin_unlock(&vmpr->sr_lock);
>  		return;
> +	}
>  
> -	spin_lock(&vmpr->sr_lock);
>  	scanned = vmpr->scanned;
>  	reclaimed = vmpr->reclaimed;
>  	vmpr->scanned = 0;
> -- 
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
