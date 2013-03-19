Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 139076B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 06:58:32 -0400 (EDT)
Date: Tue, 19 Mar 2013 10:58:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering
 pages under writeback
Message-ID: <20130319105828.GI2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-8-git-send-email-mgorman@suse.de>
 <20130318115827.GB7245@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130318115827.GB7245@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 18, 2013 at 07:58:27PM +0800, Wanpeng Li wrote:
> On Sun, Mar 17, 2013 at 01:04:13PM +0000, Mel Gorman wrote:
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
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> >---
> > include/linux/mmzone.h |  8 ++++++++
> > mm/vmscan.c            | 29 ++++++++++++++++++++++++-----
> > 2 files changed, 32 insertions(+), 5 deletions(-)
> >
> >diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >index edd6b98..c758fb7 100644
> >--- a/include/linux/mmzone.h
> >+++ b/include/linux/mmzone.h
> >@@ -498,6 +498,9 @@ typedef enum {
> > 	ZONE_DIRTY,			/* reclaim scanning has recently found
> > 					 * many dirty file pages
> > 					 */
> >+	ZONE_WRITEBACK,			/* reclaim scanning has recently found
> >+					 * many pages under writeback
> >+					 */
> > } zone_flags_t;
> >
> > static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
> >@@ -525,6 +528,11 @@ static inline int zone_is_reclaim_dirty(const struct zone *zone)
> > 	return test_bit(ZONE_DIRTY, &zone->flags);
> > }
> >
> >+static inline int zone_is_reclaim_writeback(const struct zone *zone)
> >+{
> >+	return test_bit(ZONE_WRITEBACK, &zone->flags);
> >+}
> >+
> > static inline int zone_is_reclaim_locked(const struct zone *zone)
> > {
> > 	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >index 493728b..7d5a932 100644
> >--- a/mm/vmscan.c
> >+++ b/mm/vmscan.c
> >@@ -725,6 +725,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >
> > 		if (PageWriteback(page)) {
> > 			/*
> >+			 * If reclaim is encountering an excessive number of
> >+			 * pages under writeback and this page is both under
> 
> Is the comment should changed to "encountered an excessive number of 
> pages under writeback or this page is both under writeback and PageReclaim"?
> See below:
> 

I intended to check for PageReclaim as well but it got lost in a merge
error. Fixed now.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
