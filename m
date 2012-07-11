Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id B12A16B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 22:23:07 -0400 (EDT)
Date: Wed, 11 Jul 2012 11:23:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
Message-ID: <20120711022304.GA17425@bbox>
References: <1341878153-10757-1-git-send-email-minchan@kernel.org>
 <20120709170856.ca67655a.akpm@linux-foundation.org>
 <20120710002510.GB5935@bbox>
 <alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi David,

On Tue, Jul 10, 2012 at 06:02:06PM -0700, David Rientjes wrote:
> On Tue, 10 Jul 2012, Minchan Kim wrote:
> 
> > > So I dunno, this all looks like we have a kernel problem and we're
> > > throwing our problem onto hopelessly ill-equipped users of that kernel?
> > 
> > As you know, this patch isn't for solving regular high-order allocations.
> > As I wrote down, The problem is that we removed lumpy reclaim without any
> > notification for user who might have used it implicitly.
> 
> And so now they're running with CONFIG_DEBUG_VM to try to figure out why 
> they have seen a regression, which is required for your patch to have an 
> effect?

Enabling that warning if some debug option is enabled was Mel's comment by
private discussion and I thought new debug option is overkill for it
so I added in CONFIG_DEBUG_VM.

> 
> > If such user disable compaction which is a replacement of lumpy reclaim,
> > their system might be broken in real practice while test is passing.
> > So, the goal is that let them know it in advance so that I expect they can
> > test it stronger than old.
> > 
> 
> So what are they supposed to do?  Enable CONFIG_COMPACTION as soon as they 
> see the warning?  When they have seen the warning a specific number of 
> times?  How much is "very few" high-order allocations over what time 
> period?  This is what anybody seeing these messages for the first time is 
> going to ask.

I admit that is a bit vague but we don't have a way to specify it because
it depends on workload(ex, how many we have movable pages and swap system at
the moment) so it's the best I can do for achieve the goal
which is alert for careful investigating/tuning the system
since lumpy reclaim is gone.

If you have a better idea, please suggest me.

> 
> > Although they see the page allocation failure with compaction, it would
> > be very helpful reports. It means we need to make compaction more
> > aggressive about reclaiming pages.
> > 
> 
> If CONFIG_COMPACTION is disabled, then how will making compaction more 
> aggressive about reclaiming pages help?

I mentioned "Although they see the page allocation failture with *compaction*"

> 
> Should we consider enabling CONFIG_COMPACTION in defconfig?  If not, would 

I hope so but Mel didn't like it because some users want to have a smallest
kernel if they don't care of high-order allocation.


> it be possible with a different extfrag_threshold (and more aggressive 
> when things like THP are enabled)?

Anyway, we should enable compaction for it although the system doesn't 
care about high-order allocation and it ends up make bloting kernel unnecessary.

I tend to agree Andrew and your concern but I don't have a good idea but
alert vague warning message. Anyway, we need *alert* this fact which removed
lumpy reclaim for being able to disabling CONFIG_COMPACTION.
Then, what do you think about this?

At least, it would give a chance to think over about disabing
this options more carefully so then it depends on their choices which are
more hard testing, ask it to the community or just turn off.

diff --git a/mm/Kconfig b/mm/Kconfig
index 16f6b42..099e681 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -195,6 +195,10 @@ config COMPACTION
        depends on MMU
        help
          Allows the compaction of memory for the allocation of huge pages.
+         Notice. We replaced lumpy reclaim which was scheme of helping
+         high-order allocations with compaction at 3.4 so if you don't
+         care about high-order allocations but want the smallest kernel,
+         you could select "N", otherwise, "y" is preferred.
 
 #
 # support for page migration


> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
