Date: Tue, 31 Jul 2007 01:27:51 -0700
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-ID: <20070731082751.GB7316@localdomain>
References: <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com> <20070731015647.GC32468@localdomain> <Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com> <20070730192721.eb220a9d.akpm@linux-foundation.org> <Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com> <20070730214756.c4211678.akpm@linux-foundation.org> <Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com> <20070730221736.ccf67c86.akpm@linux-foundation.org> <Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com> <20070730225809.ed0a95ff.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070730225809.ed0a95ff.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com
Cc: linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 30, 2007 at 10:58:09PM -0700, Andrew Morton wrote:
>On Mon, 30 Jul 2007 22:33:03 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
>
>
>Of course not.  But I don't know how you can be proposing solutions
>without yet knowing what the problem is.
>
>The first thing Kiran should have done was to gather a kernel profile.  If
>we're spending a lot (proably half) of time in shrink_active_lsit() then
>yeah, that's a plausible theory.

Well, we have used RAMFS with 2.6.17 kernels with reasonable performance.
What we saw here was a regression from earlier behavior.  2.6.17 never went
into reclaim with this kind of workload:

Quote 2.6.17

int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
{
        cpumask_t mask;
        int node_id;

        /*
         * Do not reclaim if there was a recent unsuccessful attempt at zone
         * reclaim.  In that case we let allocations go off node for the
         * zone_reclaim_interval.  Otherwise we would scan for each off-node
         * page allocation.
         */
        if (time_before(jiffies,
                zone->last_unsuccessful_zone_reclaim + zone_reclaim_interval))
                        return 0;


>From what I can see with .21 and .22, going into reclaim is a problem rather
than reclaim efficiency itself. Sure, if unreclaimable pages are not on LRU
it would be good, but the main problem for my narrow eyes is going into
reclaim when there are no reclaimable pages, and the fact that benchmark
works as expected with the fixed arithmetic reinforces that impression.

What am I missing?

Thanks,
Kiran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
