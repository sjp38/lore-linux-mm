Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2987D6B00F3
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 22:35:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2I2Zmfn029693
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 18 Mar 2010 11:35:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EB4145DE4F
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 11:35:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55F6945DE57
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 11:35:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3466A1DB803B
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 11:35:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DDE4D1DB8042
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 11:35:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 07/11] Memory compaction core
In-Reply-To: <20100317114045.GE12388@csn.ul.ie>
References: <20100317170116.870A.A69D9226@jp.fujitsu.com> <20100317114045.GE12388@csn.ul.ie>
Message-Id: <20100318085741.8729.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Mar 2010 11:35:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, Mar 17, 2010 at 07:31:53PM +0900, KOSAKI Motohiro wrote:
> > nit
> > 
> > > +static int compact_zone(struct zone *zone, struct compact_control *cc)
> > > +{
> > > +	int ret = COMPACT_INCOMPLETE;
> > > +
> > > +	/* Setup to move all movable pages to the end of the zone */
> > > +	cc->migrate_pfn = zone->zone_start_pfn;
> > > +	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> > > +	cc->free_pfn &= ~(pageblock_nr_pages-1);
> > > +
> > > +	for (; ret == COMPACT_INCOMPLETE; ret = compact_finished(zone, cc)) {
> > > +		unsigned long nr_migrate, nr_remaining;
> > > +		if (!isolate_migratepages(zone, cc))
> > > +			continue;
> > > +
> > > +		nr_migrate = cc->nr_migratepages;
> > > +		migrate_pages(&cc->migratepages, compaction_alloc,
> > > +						(unsigned long)cc, 0);
> > > +		update_nr_listpages(cc);
> > > +		nr_remaining = cc->nr_migratepages;
> > > +
> > > +		count_vm_event(COMPACTBLOCKS);
> > 
> > V1 did compaction per pageblock. but current patch doesn't.
> > so, Is COMPACTBLOCKS still good name?
> 
> It's not such a minor nit. I wondered about that myself but it's still a
> block - just not a pageblock. Would COMPACTCLUSTER be a better name as it's
> related to COMPACT_CLUSTER_MAX?

I've looked at this code again. honestly I'm a abit confusing even though both your
suggestions seems reasonable.  

now COMPACTBLOCKS is tracking #-of-called-migrate_pages. but I can't imazine
how to use it. can you please explain this ststics purpose? probably this is only useful
when conbination other stats, and the name should be consist with such combination one.


> > > +		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
> > > +		if (nr_remaining)
> > > +			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
> > > +
> > > +		/* Release LRU pages not migrated */
> > > +		if (!list_empty(&cc->migratepages)) {
> > > +			putback_lru_pages(&cc->migratepages);
> > > +			cc->nr_migratepages = 0;
> > > +		}
> > > +
> > > +		mod_zone_page_state(zone, NR_ISOLATED_ANON, -cc->nr_anon);
> > > +		mod_zone_page_state(zone, NR_ISOLATED_FILE, -cc->nr_file);
> > 
> > I think you don't need decrease this vmstatistics here. migrate_pages() and
> > putback_lru_pages() alredy does.
> > 
> 
> Hmm, I do need to decrease the vmstats here but not by this much. The
> pages migrated need to be accounted for but not the ones that failed. I
> missed this because migration was always succeeding. Thanks. I'll get it
> fixed for V5

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
