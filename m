Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 187BF900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 16:31:43 -0400 (EDT)
Date: Thu, 12 May 2011 22:31:25 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110512203125.GL16531@cmpxchg.org>
References: <1305127773-10570-4-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105120942050.24560@router.home>
 <1305213359.2575.46.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site>
 <1305215742.27848.40.camel@jaguar>
 <1305225467.2575.66.camel@mulgrave.site>
 <1305229447.2575.71.camel@mulgrave.site>
 <1305230652.2575.72.camel@mulgrave.site>
 <20110512202917.GK16531@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110512202917.GK16531@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 10:29:17PM +0200, Johannes Weiner wrote:
> On Thu, May 12, 2011 at 03:04:12PM -0500, James Bottomley wrote:
> > On Thu, 2011-05-12 at 14:44 -0500, James Bottomley wrote:
> > > On Thu, 2011-05-12 at 13:37 -0500, James Bottomley wrote:
> > > > On Thu, 2011-05-12 at 18:55 +0300, Pekka Enberg wrote:
> > > > > On Thu, 2011-05-12 at 10:43 -0500, James Bottomley wrote:
> > > > > > However, since you admit even you see problems, let's concentrate on
> > > > > > fixing them rather than recriminations?
> > > > > 
> > > > > Yes, please. So does dropping max_order to 1 help?
> > > > > PAGE_ALLOC_COSTLY_ORDER is set to 3 in 2.6.39-rc7.
> > > > 
> > > > Just booting with max_slab_order=1 (and none of the other patches
> > > > applied) I can still get the machine to go into kswapd at 99%, so it
> > > > doesn't seem to make much of a difference.
> > > > 
> > > > Do you want me to try with the other two patches and max_slab_order=1?
> > > 
> > > OK, so patches 1 + 2 plus setting slub_max_order=1 still manages to
> > > trigger the problem (kswapd spinning at 99%).  This is still with
> > > PREEMPT; it's possible that non-PREEMPT might be better, so I'll try
> > > patches 1+2+3 with PREEMPT just to see if the perturbation is caused by
> > > it.
> > 
> > Confirmed, I'm afraid ... I can trigger the problem with all three
> > patches under PREEMPT.  It's not a hang this time, it's just kswapd
> > taking 100% system time on 1 CPU and it won't calm down after I unload
> > the system.

I am so sorry, I missed the "won't" here.  Please ignore.

> That is kind of expected, though.  If one CPU is busy with a streaming
> IO load generating new pages, kswapd is busy reclaiming the old ones
> so that the generator does not have to do the reclaim itself.
> 
> By unload, do you mean stopping the generator?  And if so, how quickly
> after you stop the generator does kswapd go back to sleep?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
