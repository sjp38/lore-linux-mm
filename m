Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8890E6B01F0
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:55:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3D8tsCc006386
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Apr 2010 17:55:54 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 25E1E45DE4E
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:55:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 07D6E45DE4D
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:55:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CDAA21DB8044
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:55:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 88D6AE08004
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:55:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100413144519.D107.A69D9226@jp.fujitsu.com>
References: <4BC3DA2B.3070605@redhat.com> <20100413144519.D107.A69D9226@jp.fujitsu.com>
Message-Id: <20100413175414.D110.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 13 Apr 2010 17:55:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > > I'm surprised this ack a bit. Rik, do you have any improvement plan about
> > > streaming io detection logic?
> > > I think the patch have a slightly marginal benefit, it help to<1% scan
> > > ratio case. but it have big regression, it cause streaming io (e.g. backup
> > > operation) makes tons swap.
> > 
> > How?  From the description I believe it took 16GB in
> > a zone before we start scanning anon pages when
> > reclaiming at DEF_PRIORITY?
> > 
> > Would that casue a problem?
> 
> Please remember, 2.6.27 has following +1 scanning modifier.
> 
>   zone->nr_scan_active += (zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
>                                                                          ^^^^
> 
> and, early (ano not yet merged) SplitLRU VM has similar +1. likes
> 
>          scan = zone_nr_lru_pages(zone, sc, l);
>          scan >>= priority;
>          scan = (scan * percent[file]) / 100 + 1;
>                                              ^^^
> 
> We didn't think only one page scanning is not big matter. but it was not
> correct. we got streaming io bug report. the above +1 makes annoying swap
> io. because some server need big backup operation rather much much than
> physical memory size.
> 
> example, If vm are dropping 1TB use once pages, 0.1% anon scanning makes
> 1GB scan. and almost server only have some gigabyte swap although it
> has >1TB memory.
> 
> If my memory is not correct, please correct me.
> 
> My point is, greater or smaller than 16GB isn't essential. all patches 
> should have big worth than the downside. The description said "the impact 
> sounds not a big deal", nobody disagree it. but it's worth is more little.
> I don't imagine this patch improve anything.

And now I've merged this patch into my local vmscan patch queue.
After solving streaming io issue, I'll put it to mainline.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
