Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8B96B00E9
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 12:52:06 -0400 (EDT)
Received: by iwn8 with SMTP id 8so5357197iwn.14
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 09:52:03 -0700 (PDT)
Date: Wed, 20 Jul 2011 01:51:55 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH]vmscan: fix a livelock in kswapd
Message-ID: <20110719165155.GB2978@barrios-desktop>
References: <1311059367.15392.299.camel@sli10-conroe>
 <CAEwNFnB6HKJ3j9cWzyb2e3BS2BQrE66F6eT02C4cozRC9YQ7kw@mail.gmail.com>
 <1311065584.15392.300.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311065584.15392.300.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, Jul 19, 2011 at 04:53:04PM +0800, Shaohua Li wrote:
> On Tue, 2011-07-19 at 16:45 +0800, Minchan Kim wrote:
> > On Tue, Jul 19, 2011 at 4:09 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> > > I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> > > After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> > > kswapd2 are keeping running and I can't access filesystem, but most memory is
> > > free. This looks like a regression since commit 08951e545918c159.
> > 
> > Could you tell me what is 08951e545918c159?
> > You mean [ebd64e21ec5a,
> > mm-vmscan-only-read-new_classzone_idx-from-pgdat-when-reclaiming-successfully]
> > ?
> ha, sorry, I should copy the commit title.
> 08951e545918c159(mm: vmscan: correct check for kswapd sleeping in
> sleeping_prematurely)
> 

I don't mean it. In my bogus git tree, I can't find it but I can look at it in repaired git tree. :)
Anyway, I have a comment. Please look at below.

On Tue, Jul 19, 2011 at 03:09:27PM +0800, Shaohua Li wrote:
> I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> kswapd2 are keeping running and I can't access filesystem, but most memory is
> free. This looks like a regression since commit 08951e545918c159.
> Node 2 and 3 have only ZONE_NORMAL, but balance_pgdat() will return 0 for
> classzone_idx. The reason is end_zone in balance_pgdat() is 0 by default, if
> all zones have watermark ok, end_zone will keep 0.
> Later sleeping_prematurely() always returns true. Because this is an order 3
> wakeup, and if classzone_idx is 0, both balanced_pages and present_pages
> in pgdat_balanced() are 0.

Sigh. Yes.

> We add a special case here. If a zone has no page, we think it's balanced. This
> fixes the livelock.

Yes. Your patch can fix it but I don't like that it adds handling special case.
(Although Andrew merged quickly).

The problem is to return 0-classzone_idx if all zones was okay.
So how about this?

This can change old behavior slightly.
For example, if balance_pgdat calls with order-3 and all zones are okay about order-3,
it will recheck order-0 as end_zone isn't 0 any more.
But I think it's desriable side effect we have missed.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ed24b9..cfef52b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2389,7 +2389,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
        unsigned long balanced;
        int priority;
        int i;
-       int end_zone = 0;       /* Inclusive.  0 = ZONE_DMA */
+       int end_zone = *classzone_idx;
        unsigned long total_scanned;
        struct reclaim_state *reclaim_state = current->reclaim_state;
        unsigned long nr_soft_reclaimed;

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
