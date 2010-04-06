Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D070A6B01F0
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 22:06:24 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3626Lsc027177
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Apr 2010 11:06:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5047845DE54
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 11:06:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 226D745DE51
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 11:06:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EDBD31DB805E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 11:06:20 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 904C71DB8043
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 11:06:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100406015045.GA7870@localhost>
References: <20100406012536.GB18672@sli10-desk.sh.intel.com> <20100406015045.GA7870@localhost>
Message-Id: <20100406105324.7E30.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Apr 2010 11:06:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Apr 06, 2010 at 09:25:36AM +0800, Li, Shaohua wrote:
> > On Sun, Apr 04, 2010 at 10:19:06PM +0800, KOSAKI Motohiro wrote:
> > > > On Fri, Apr 02, 2010 at 05:14:38PM +0800, KOSAKI Motohiro wrote:
> > > > > > > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > > > > > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > > > > > > <1% seems no good reclaim rate.
> > > > > > > 
> > > > > > > Oops, the above mention is wrong. sorry. only 1 page is still too big.
> > > > > > > because under streaming io workload, the number of scanning anon pages should
> > > > > > > be zero. this is very strong requirement. if not, backup operation will makes
> > > > > > > a lot of swapping out.
> > > > > > Sounds there is no big impact for the workload which you mentioned with the patch.
> > > > > > please see below descriptions.
> > > > > > I updated the description of the patch as fengguang suggested.
> > > > > 
> > > > > Umm.. sorry, no.
> > > > > 
> > > > > "one fix but introduce another one bug" is not good deal. instead, 
> > > > > I'll revert the guilty commit at first as akpm mentioned.
> > > > Even we revert the commit, the patch still has its benefit, as it increases
> > > > calculation precision, right?
> > > 
> > > no, you shouldn't ignore the regression case.
> 
> > I don't think this is serious. In my calculation, there is only 1 page swapped out
> > for 6G anonmous memory. 1 page should haven't any performance impact.
> 
> 1 anon page scanned for every N file pages scanned?
> 
> Is N a _huge_ enough ratio so that the anon list will be very light scanned?
> 
> Rik: here is a little background.

The problem is, the VM are couteniously discarding no longer used file
cache. if we are scan extra anon 1 page, we will observe tons swap usage
after few days.

please don't only think benchmark.


> Under streaming IO, the current get_scan_ratio() will get a percent[0]
> that is (much) less than 1, so underflows to 0.
> 
> It has the bad effect of completely disabling the scan of anon list,
> which leads to OOM in Shaohua's test case. OTOH, it also has the good
> side effect of keeping anon pages in memory and totally prevent swap
> IO.
> 
> Shaohua's patch improves the computation precision by computing nr[]
> directly in get_scan_ratio(). This is good in general, however will
> enable light scan of the anon list on streaming IO.

In such case, percent[0] should be big. I think underflowing is not point.
His test case is merely streaming io copy, why can't we drop tmpfs cached
page? his /proc/meminfo describe his machine didn't have droppable file cache.
so, big percent[1] value seems makes no sense. no?

I'm not sure we need either below detection. I need more investigate.
 1) detect no discardable file cache
 2) detect streaming io on tmpfs (as regular file)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
