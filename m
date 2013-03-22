Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 1A4B56B0002
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 12:54:06 -0400 (EDT)
Date: Fri, 22 Mar 2013 12:53:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning
 requirements for kswapd
Message-ID: <20130322165349.GI1953@cmpxchg.org>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-3-git-send-email-mgorman@suse.de>
 <20130321162518.GB27848@cmpxchg.org>
 <20130321180238.GM1878@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130321180238.GM1878@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 21, 2013 at 06:02:38PM +0000, Mel Gorman wrote:
> On Thu, Mar 21, 2013 at 12:25:18PM -0400, Johannes Weiner wrote:
> > On Sun, Mar 17, 2013 at 01:04:08PM +0000, Mel Gorman wrote:
> > > Simplistically, the anon and file LRU lists are scanned proportionally
> > > depending on the value of vm.swappiness although there are other factors
> > > taken into account by get_scan_count().  The patch "mm: vmscan: Limit
> > > the number of pages kswapd reclaims" limits the number of pages kswapd
> > > reclaims but it breaks this proportional scanning and may evenly shrink
> > > anon/file LRUs regardless of vm.swappiness.
> > > 
> > > This patch preserves the proportional scanning and reclaim. It does mean
> > > that kswapd will reclaim more than requested but the number of pages will
> > > be related to the high watermark.
> > 
> > Swappiness is about page types, but this implementation compares all
> > LRUs against each other, and I'm not convinced that this makes sense
> > as there is no guaranteed balance between the inactive and active
> > lists.  For example, the active file LRU could get knocked out when
> > it's almost empty while the inactive file LRU has more easy cache than
> > the anon lists combined.
> > 
> 
> Ok, I see your point. I think Michal was making the same point but I
> failed to understand it the first time around.
> 
> > Would it be better to compare the sum of file pages with the sum of
> > anon pages and then knock out the smaller pair?
> 
> Yes, it makes more sense but the issue then becomes how can we do that
> sensibly, The following is straight-forward and roughly in line with your
> suggestion but it does not preseve the scanning ratio between active and
> inactive of the remaining LRU lists.

After thinking more about it, I wonder if subtracting absolute values
of one LRU goal from the other is right to begin with, because the
anon/file balance percentage is applied to individual LRU sizes, and
these sizes are not necessarily comparable.

Consider an unbalanced case of 64 file and 32768 anon pages targetted.
If the balance is 70% file and 30% anon, we will scan 70% of those 64
file pages and 30% of the 32768 anon pages.

Say we decide to bail after one iteration of 32 file pages reclaimed.
We would have scanned only 50% of the targetted file pages, but
subtracting those remaining 32 leaves us with 99% of the targetted
anon pages.

So would it make sense to determine the percentage scanned of the type
that we stop scanning, then scale the original goal of the remaining
LRUs to that percentage, and scan the remainder?

In the above example, we'd determine we scanned 50% of the targetted
file pages, so we reduce the anon inactive and active goals to 50% of
their original values, then scan the difference between those reduced
goals and the pages already scanned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
