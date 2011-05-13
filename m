Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7C62F90010C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:25:50 -0400 (EDT)
Date: Fri, 13 May 2011 12:25:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] Reduce impact to overall system of SLUB using
 high-order allocations
Message-ID: <20110513112545.GG3569@suse.de>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
 <1305149960.2606.53.camel@mulgrave.site>
 <alpine.DEB.2.00.1105111527490.24003@chino.kir.corp.google.com>
 <1305153267.2606.57.camel@mulgrave.site>
 <4DCBC0E8.5020609@cs.helsinki.fi>
 <1305209096.2575.14.camel@mulgrave.site>
 <1305215624.2575.52.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1305215624.2575.52.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 10:53:44AM -0500, James Bottomley wrote:
> On Thu, 2011-05-12 at 09:04 -0500, James Bottomley wrote:
> > On Thu, 2011-05-12 at 14:13 +0300, Pekka Enberg wrote:
> > > On 5/12/11 1:34 AM, James Bottomley wrote:
> > > > On Wed, 2011-05-11 at 15:28 -0700, David Rientjes wrote:
> > > >> On Wed, 11 May 2011, James Bottomley wrote:
> > > >>
> > > >>> OK, I confirm that I can't seem to break this one.  No hangs visible,
> > > >>> even when loading up the system with firefox, evolution, the usual
> > > >>> massive untar, X and even a distribution upgrade.
> > > >>>
> > > >>> You can add my tested-by
> > > >>>
> > > >> Your system still hangs with patches 1 and 2 only?
> > > > Yes, but only once in all the testing.  With patches 1 and 2 the hang is
> > > > much harder to reproduce, but it still seems to be present if I hit it
> > > > hard enough.
> > > 
> > > Patches 1-2 look reasonable to me. I'm not completely convinced of patch 
> > > 3, though. Why are we seeing these problems now? This has been in 
> > > mainline for a long time already. Shouldn't we fix kswapd?
> > 
> > So I'm open to this.  The hang occurs when kswapd races around in
> > shrink_slab and never exits.  It looks like there's a massive number of
> > wakeups triggering this, but we haven't been able to diagnose it
> > further.  turning on PREEMPT gets rid of the hang, so I could try to
> > reproduce with PREEMPT and turn on tracing.  The problem so far has been
> > that the number of events is so huge that the trace buffer only captures
> > a few microseconds of output.
> 
> OK, here's the trace from a PREEMPT kernel (2.6.38.6) when kswapd hits
> 99% and stays there.  I've only enabled the vmscan tracepoints to try
> and get a longer run.  It mosly looks like kswapd waking itself, but
> there might be more in there that mm trained eyes can see.
> 

For 2.6.38.6, commit [2876592f: mm: vmscan: stop reclaim/compaction
earlier due to insufficient progress if !__GFP_REPEAT] may also be
needed if CONFIG_COMPACTION if set.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
