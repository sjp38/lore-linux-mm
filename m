Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C01356B01EF
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 01:09:48 -0400 (EDT)
Date: Tue, 6 Apr 2010 13:09:45 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100406050945.GA3819@sli10-desk.sh.intel.com>
References: <20100406105324.7E30.A69D9226@jp.fujitsu.com>
 <20100406023043.GA12420@localhost>
 <20100406115543.7E39.A69D9226@jp.fujitsu.com>
 <20100406033114.GB13169@localhost>
 <4BBAAD3F.3090900@redhat.com>
 <20100406044910.GA16303@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100406044910.GA16303@localhost>
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 12:49:10PM +0800, Wu, Fengguang wrote:
> On Tue, Apr 06, 2010 at 11:40:47AM +0800, Rik van Riel wrote:
> > On 04/05/2010 11:31 PM, Wu Fengguang wrote:
> > > On Tue, Apr 06, 2010 at 10:58:43AM +0800, KOSAKI Motohiro wrote:
> > >> Again, I didn't said his patch is no worth. I only said we don't have to
> > >> ignore the downside.
> > >
> > > Right, we should document both the upside and downside.
> > 
> > The downside is obvious: streaming IO (used once data
> > that does not fit in the cache) can push out data that
> > is used more often - requiring that it be swapped in
> > at a later point in time.
> > 
> > I understand what Shaohua's patch does, but I do not
> > understand the upside.  What good does it do to increase
> > the size of the cache for streaming IO data, which is
> > generally touched only once?
> 
> Not that bad :)  With Shaohua's patch the anon list will typically
> _never_ get scanned, just like before.
> 
> If it's mostly use-once IO, file:anon will be 1000 or even 10000, and
> priority=12.  Then only anon lists larger than 16GB or 160GB will get
> nr[0] >= 1.
> 
> > What kind of performance benefits can we get by doing
> > that?
> 
> So vmscan behavior and performance remain the same as before.
> 
> For really large anon list, such workload is beyond our imagination.
> So we cannot assert "don't scan anon list" will be a benefit.
> 
> On the other hand, in the test case of "do stream IO when most memory
> occupied by tmpfs pages", it is very bad behavior refuse to scan anon
> list in normal and suddenly start scanning _the whole_ anon list when
> priority hits 0. Shaohua's patch helps it by gradually increasing the
> scan nr of anon list as memory pressure increases.
Yep, the gradually increasing scan nr is the main advantage in my mind.

Thanks,
Shaohua
> > > The main difference happens when file:anon scan ratio>  100:1.
> > >
> > > For the current percent[] based computing, percent[0]=0 hence nr[0]=0
> > > which disables anon list scan unconditionally, for good or for bad.
> > >
> > > For the direct nr[] computing,
> > > - nr[0] will be 0 for typical file servers, because with priority=12
> > >    and anon lru size<  1.6GB, nr[0] = (anon_size/4096)/100<  0
> > > - nr[0] will be non-zero when priority=1 and anon_size>  100 pages,
> > >    this stops OOM for Shaohua's test case, however may not be enough to
> > >    guarantee safety (your previous reverting patch can provide this
> > >    guarantee).
> > >
> > > I liked Shaohua's patch a lot -- it adapts well to both the
> > > file-server case and the mostly-anon-pages case :)
> > 
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
