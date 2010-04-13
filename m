Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 34C986B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 03:55:23 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3D7tK13023391
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Apr 2010 16:55:20 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2183D45DE50
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:55:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E142645DE4D
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:55:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C9DFF1DB8044
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:55:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 568F3E08006
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:55:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <4BC3DA2B.3070605@redhat.com>
References: <20100413102641.4A18.A69D9226@jp.fujitsu.com> <4BC3DA2B.3070605@redhat.com>
Message-Id: <20100413144519.D107.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 13 Apr 2010 16:55:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On 04/12/2010 09:30 PM, KOSAKI Motohiro wrote:
> >> On 04/09/2010 05:20 PM, Andrew Morton wrote:
> >>
> >>> Come to that, it's not obvious that we need this in 2.6.34 either.  What
> >>> is the user-visible impact here?
> >>
> >> I suspect very little impact, especially during workloads
> >> where we can just reclaim clean page cache at DEF_PRIORITY.
> >> FWIW, the patch looks good to me, so:
> >>
> >> Acked-by: Rik van Riel<riel@redhat.com>
> >>
> >
> > I'm surprised this ack a bit. Rik, do you have any improvement plan about
> > streaming io detection logic?
> > I think the patch have a slightly marginal benefit, it help to<1% scan
> > ratio case. but it have big regression, it cause streaming io (e.g. backup
> > operation) makes tons swap.
> 
> How?  From the description I believe it took 16GB in
> a zone before we start scanning anon pages when
> reclaiming at DEF_PRIORITY?
> 
> Would that casue a problem?

Please remember, 2.6.27 has following +1 scanning modifier.

  zone->nr_scan_active += (zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
                                                                         ^^^^

and, early (ano not yet merged) SplitLRU VM has similar +1. likes

         scan = zone_nr_lru_pages(zone, sc, l);
         scan >>= priority;
         scan = (scan * percent[file]) / 100 + 1;
                                             ^^^

We didn't think only one page scanning is not big matter. but it was not
correct. we got streaming io bug report. the above +1 makes annoying swap
io. because some server need big backup operation rather much much than
physical memory size.

example, If vm are dropping 1TB use once pages, 0.1% anon scanning makes
1GB scan. and almost server only have some gigabyte swap although it
has >1TB memory.

If my memory is not correct, please correct me.

My point is, greater or smaller than 16GB isn't essential. all patches 
should have big worth than the downside. The description said "the impact 
sounds not a big deal", nobody disagree it. but it's worth is more little.
I don't imagine this patch improve anything.


> 
> > So, I thought we sould do either,
> > 1) drop this one
> > 2) merge to change stream io detection logic improvement at first, and
> >     merge this one at second.
> 
> We may need better streaming IO detection, anyway.

agreed. that's no doubt.


> I have noticed that while heavy sequential reads are fine,
> the virtual machines on my desktop system do a lot of whole
> block writes.  Presumably, a lot of those writes are to the
> same blocks, over and over again.
> 
> This causes the blocks to be promoted to the active file
> list, which ends up growing the active file list to the
> point where things from the working set get evicted.
> 
> All for file pages that may only get WRITTEN to by the
> guests, because the guests cache their own copy whenever
> they need to read them!
> 
> I'll have to check the page cache code to see if it
> keeps frequently written pages as accessed.  We may be
> better off evicting frequently written pages, and
> keeping our cache space for data that is read...

One question, In such case your guest don't use DirectIO?
Or do you talk about guest VM behabior?

I guess inactive_file_is_low_global() can be improvement a lot.
but I'm not sure.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
