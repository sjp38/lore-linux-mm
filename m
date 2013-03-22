Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id DB21E6B005C
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 04:27:23 -0400 (EDT)
Date: Fri, 22 Mar 2013 08:27:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering
 pages under writeback
Message-ID: <20130322082719.GR1878@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-8-git-send-email-mgorman@suse.de>
 <514B5492.4030806@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <514B5492.4030806@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 21, 2013 at 02:42:26PM -0400, Rik van Riel wrote:
> On 03/17/2013 09:04 AM, Mel Gorman wrote:
> >Historically, kswapd used to congestion_wait() at higher priorities if it
> >was not making forward progress. This made no sense as the failure to make
> >progress could be completely independent of IO. It was later replaced by
> >wait_iff_congested() and removed entirely by commit 258401a6 (mm: don't
> >wait on congested zones in balance_pgdat()) as it was duplicating logic
> >in shrink_inactive_list().
> >
> >This is problematic. If kswapd encounters many pages under writeback and
> >it continues to scan until it reaches the high watermark then it will
> >quickly skip over the pages under writeback and reclaim clean young
> >pages or push applications out to swap.
> >
> >The use of wait_iff_congested() is not suited to kswapd as it will only
> >stall if the underlying BDI is really congested or a direct reclaimer was
> >unable to write to the underlying BDI. kswapd bypasses the BDI congestion
> >as it sets PF_SWAPWRITE but even if this was taken into account then it
> >would cause direct reclaimers to stall on writeback which is not desirable.
> >
> >This patch sets a ZONE_WRITEBACK flag if direct reclaim or kswapd is
> >encountering too many pages under writeback. If this flag is set and
> >kswapd encounters a PageReclaim page under writeback then it'll assume
> >that the LRU lists are being recycled too quickly before IO can complete
> >and block waiting for some IO to complete.
> 
> I really like the concept of this patch.
> 

Thanks.

> >@@ -756,9 +769,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  				 */
> >  				SetPageReclaim(page);
> >  				nr_writeback++;
> >+
> >  				goto keep_locked;
> >+			} else {
> >+				wait_on_page_writeback(page);
> >  			}
> >-			wait_on_page_writeback(page);
> >  		}
> >
> >  		if (!force_reclaim)
> 
> This looks like an area for future improvement.
> 
> We do not need to wait for this specific page to finish writeback,
> we only have to wait for any (bunch of) page(s) to finish writeback,
> since we do not particularly care which of the pages from near the
> end of the LRU get reclaimed first.
> 

We do not have a good interface for waiting on IO to complete on any of a
list of pages. It could be polled but that feels unsatisfactory. Calling
congestion_wait() would sortof work and it's sortof what we used to do
in the past bvased on scanning priority but it only works if we happen to
wait on the correct async/sync queue and there is no guarnatee that it'll
wake when IO on a relevant page completes.

> I wonder if this is one of the causes for the high latencies that
> are sometimes observed in direct reclaim...
> 

I'm skeptical.

In the far past, direct reclaim would only indirectly stall on page writeback
using congestion_wait or a similar interface. Later it was possible for
direct reclaim to stall on wait_on_page_writeback() during lumpy reclaim
and that might be what you're thinking of?

It could be an indirect cause of direct reclaim stalls. If kswapd is
blocked on page writeback then it does mean that a process may stall in
direct reclaim because kswapd is not making forward progress but it
should not be the cause of high latencies.

Under what circumstances are you seeing high latencies in
direct reclaim? We should be able to measure the stalls using the
trace_mm_vmscan_direct_reclaim_begin and trace_mm_vmscan_direct_reclaim_end
tracepoints and pin down the cause.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
