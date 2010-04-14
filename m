Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0B33A6B020C
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 21:27:03 -0400 (EDT)
Date: Wed, 14 Apr 2010 09:27:00 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100414012700.GA10450@sli10-desk.sh.intel.com>
References: <4BC3DA2B.3070605@redhat.com>
 <20100413144519.D107.A69D9226@jp.fujitsu.com>
 <20100413175414.D110.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413175414.D110.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 04:55:52PM +0800, KOSAKI Motohiro wrote:
> > > > I'm surprised this ack a bit. Rik, do you have any improvement plan about
> > > > streaming io detection logic?
> > > > I think the patch have a slightly marginal benefit, it help to<1% scan
> > > > ratio case. but it have big regression, it cause streaming io (e.g. backup
> > > > operation) makes tons swap.
> > > 
> > > How?  From the description I believe it took 16GB in
> > > a zone before we start scanning anon pages when
> > > reclaiming at DEF_PRIORITY?
> > > 
> > > Would that casue a problem?
> > 
> > Please remember, 2.6.27 has following +1 scanning modifier.
> > 
> >   zone->nr_scan_active += (zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
> >                                                                          ^^^^
> > 
> > and, early (ano not yet merged) SplitLRU VM has similar +1. likes
> > 
> >          scan = zone_nr_lru_pages(zone, sc, l);
> >          scan >>= priority;
> >          scan = (scan * percent[file]) / 100 + 1;
> >                                              ^^^
> > 
> > We didn't think only one page scanning is not big matter. but it was not
> > correct. we got streaming io bug report. the above +1 makes annoying swap
> > io. because some server need big backup operation rather much much than
> > physical memory size.
> > 
> > example, If vm are dropping 1TB use once pages, 0.1% anon scanning makes
> > 1GB scan. and almost server only have some gigabyte swap although it
> > has >1TB memory.
> > 
> > If my memory is not correct, please correct me.
> > 
> > My point is, greater or smaller than 16GB isn't essential. all patches 
> > should have big worth than the downside. The description said "the impact 
> > sounds not a big deal", nobody disagree it. but it's worth is more little.
> > I don't imagine this patch improve anything.
> 
> And now I've merged this patch into my local vmscan patch queue.
> After solving streaming io issue, I'll put it to mainline.
if the streaming io issue is popular, how about below patch against my last one?
we take priority == DEF_PRIORITY an exception.
 
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2010-04-14 09:03:28.000000000 +0800
+++ linux/mm/vmscan.c	2010-04-14 09:19:56.000000000 +0800
@@ -1629,6 +1629,22 @@ static void get_scan_count(struct zone *
 	fraction[0] = ap;
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
+
+	/*
+	 * memory pressure isn't high, we allow percentage underflow. This
+	 * avoids swap in stream io case.
+	 */
+	if (priority == DEF_PRIORITY) {
+		if (fraction[0] * 99 < fraction[1]) {
+			fraction[0] = 0;
+			fraction[1] = 1;
+			denominator = 1;
+		} else if (fraction[1] * 99 < fraction[0]) {
+			fraction[0] = 1;
+			fraction[1] = 0;
+			denominator = 1;
+		}
+	}
 out:
 	for_each_evictable_lru(l) {
 		int file = is_file_lru(l);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
