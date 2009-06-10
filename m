Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E001B6B00A1
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 03:31:00 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A7Vs46032385
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 10 Jun 2009 16:31:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B37045DE4F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 16:31:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F84345DE51
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 16:31:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 16FBD1DB8043
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 16:31:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A2FA11DB803A
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 16:31:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Properly account for the number of page cache pages zone_reclaim() can reclaim
In-Reply-To: <20090610011939.GA5603@localhost>
References: <1244566904-31470-2-git-send-email-mel@csn.ul.ie> <20090610011939.GA5603@localhost>
Message-Id: <20090610162926.DDC8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Jun 2009 16:31:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 10, 2009 at 01:01:41AM +0800, Mel Gorman wrote:
> > On NUMA machines, the administrator can configure zone_reclaim_mode that
> > is a more targetted form of direct reclaim. On machines with large NUMA
> > distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
> > unmapped pages will be reclaimed if the zone watermarks are not being met.
> > 
> > There is a heuristic that determines if the scan is worthwhile but the
> > problem is that the heuristic is not being properly applied and is basically
> > assuming zone_reclaim_mode is 1 if it is enabled.
> > 
> > Historically, once enabled it was depending on NR_FILE_PAGES which may
> > include swapcache pages that the reclaim_mode cannot deal with.  Patch
> > vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch by
> > Kosaki Motohiro noted that zone_page_state(zone, NR_FILE_PAGES) included
> > pages that were not file-backed such as swapcache and made a calculation
> > based on the inactive, active and mapped files. This is far superior
> > when zone_reclaim==1 but if RECLAIM_SWAP is set, then NR_FILE_PAGES is a
> > reasonable starting figure.
> > 
> > This patch alters how zone_reclaim() works out how many pages it might be
> > able to reclaim given the current reclaim_mode. If RECLAIM_SWAP is set
> > in the reclaim_mode it will either consider NR_FILE_PAGES as potential
> > candidates or else use NR_{IN}ACTIVE}_PAGES-NR_FILE_MAPPED to discount
> > swapcache and other non-file-backed pages.  If RECLAIM_WRITE is not set,
> > then NR_FILE_DIRTY number of pages are not candidates. If RECLAIM_SWAP is
> > not set, then NR_FILE_MAPPED are not.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Christoph Lameter <cl@linux-foundation.org>
> > ---
> >  mm/vmscan.c |   52 ++++++++++++++++++++++++++++++++++++++--------------
> >  1 files changed, 38 insertions(+), 14 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 2ddcfc8..2bfc76e 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2333,6 +2333,41 @@ int sysctl_min_unmapped_ratio = 1;
> >   */
> >  int sysctl_min_slab_ratio = 5;
> >  
> > +static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
> > +{
> > +	return zone_page_state(zone, NR_INACTIVE_FILE) +
> > +		zone_page_state(zone, NR_ACTIVE_FILE) -
> > +		zone_page_state(zone, NR_FILE_MAPPED);
> 
> This may underflow if too many tmpfs pages are mapped.

sorry my fault.
I'm preparing updated patch.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
