Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1ACFC6B01EF
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 23:31:21 -0400 (EDT)
Date: Tue, 6 Apr 2010 11:31:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100406033114.GB13169@localhost>
References: <20100406105324.7E30.A69D9226@jp.fujitsu.com> <20100406023043.GA12420@localhost> <20100406115543.7E39.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100406115543.7E39.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 10:58:43AM +0800, KOSAKI Motohiro wrote:
> > On Tue, Apr 06, 2010 at 10:06:19AM +0800, KOSAKI Motohiro wrote:
> > > > On Tue, Apr 06, 2010 at 09:25:36AM +0800, Li, Shaohua wrote:
> > > > > On Sun, Apr 04, 2010 at 10:19:06PM +0800, KOSAKI Motohiro wrote:
> > > > > > > On Fri, Apr 02, 2010 at 05:14:38PM +0800, KOSAKI Motohiro wrote:
> > > > > > > > > > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > > > > > > > > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > > > > > > > > > <1% seems no good reclaim rate.
> > > > > > > > > > 
> > > > > > > > > > Oops, the above mention is wrong. sorry. only 1 page is still too big.
> > > > > > > > > > because under streaming io workload, the number of scanning anon pages should
> > > > > > > > > > be zero. this is very strong requirement. if not, backup operation will makes
> > > > > > > > > > a lot of swapping out.
> > > > > > > > > Sounds there is no big impact for the workload which you mentioned with the patch.
> > > > > > > > > please see below descriptions.
> > > > > > > > > I updated the description of the patch as fengguang suggested.
> > > > > > > > 
> > > > > > > > Umm.. sorry, no.
> > > > > > > > 
> > > > > > > > "one fix but introduce another one bug" is not good deal. instead, 
> > > > > > > > I'll revert the guilty commit at first as akpm mentioned.
> > > > > > > Even we revert the commit, the patch still has its benefit, as it increases
> > > > > > > calculation precision, right?
> > > > > > 
> > > > > > no, you shouldn't ignore the regression case.
> > > > 
> > > > > I don't think this is serious. In my calculation, there is only 1 page swapped out
> > > > > for 6G anonmous memory. 1 page should haven't any performance impact.
> > > > 
> > > > 1 anon page scanned for every N file pages scanned?
> > > > 
> > > > Is N a _huge_ enough ratio so that the anon list will be very light scanned?
> > > > 
> > > > Rik: here is a little background.
> > > 
> > > The problem is, the VM are couteniously discarding no longer used file
> > > cache. if we are scan extra anon 1 page, we will observe tons swap usage
> > > after few days.
> > > 
> > > please don't only think benchmark.
> > 
> > OK the days-of-streaming-io typically happen in file servers.  Suppose
> > a file server with 16GB memory, 1GB of which is consumed by anonymous
> > pages, others are for page cache.
> > 
> > Assume that the exact file:anon ratio computed by the get_scan_ratio()
> > algorithm is 1000:1. In that case percent[0]=0.1 and is rounded down
> > to 0, which keeps the anon pages in memory for the few days.
> > 
> > Now with Shaohua's patch, nr[0] = (262144/4096)/1000 = 0.06 will also
> > be rounded down to 0. It only becomes >=1 when
> > - reclaim runs into trouble and priority goes low
> > - anon list goes huge
> > 
> > So I guess Shaohua's patch still has reasonable "underflow" threshold :)
> 
> Again, I didn't said his patch is no worth. I only said we don't have to
> ignore the downside. 

Right, we should document both the upside and downside.

The main difference happens when file:anon scan ratio > 100:1.

For the current percent[] based computing, percent[0]=0 hence nr[0]=0
which disables anon list scan unconditionally, for good or for bad.

For the direct nr[] computing,
- nr[0] will be 0 for typical file servers, because with priority=12
  and anon lru size < 1.6GB, nr[0] = (anon_size/4096)/100 < 0
- nr[0] will be non-zero when priority=1 and anon_size > 100 pages,
  this stops OOM for Shaohua's test case, however may not be enough to
  guarantee safety (your previous reverting patch can provide this
  guarantee).

I liked Shaohua's patch a lot -- it adapts well to both the
file-server case and the mostly-anon-pages case :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
