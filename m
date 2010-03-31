Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E008E6B01F0
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 02:03:46 -0400 (EDT)
Date: Wed, 31 Mar 2010 14:03:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100331060343.GA22223@localhost>
References: <20100331142708.039E.A69D9226@jp.fujitsu.com> <20100331055108.GA21963@localhost> <20100331145602.03A7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100331145602.03A7.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 02:00:52PM +0800, KOSAKI Motohiro wrote:
> > KOSAKI-san,
> > 
> > On Wed, Mar 31, 2010 at 01:38:12PM +0800, KOSAKI Motohiro wrote:
> > > > On Tue, Mar 30, 2010 at 02:08:53PM +0800, KOSAKI Motohiro wrote:
> > > > > Hi
> > > > > 
> > > > > > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > > > > > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > > > > > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > > > > > value, but our calculation round it to zero. The commit makes vmscan
> > > > > > completely skip anon pages and cause oops.
> > > > > > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > > > > > to 1. See below patch.
> > > > > > But the offending commit still changes behavior. Without the commit, we scan
> > > > > > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > > > > > It's required to fix this too.
> > > > > 
> > > > > Can you please post your /proc/meminfo and reproduce program? I'll digg it.
> > > > > 
> > > > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > > > had similar logic, but 1% swap-out made lots bug reports. 
> > > > if 1% is still big, how about below patch?
> > > 
> > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > <1% seems no good reclaim rate.
> > > 
> > > perhaps I'll take your patch for stable tree. but we need to attack the root
> > > cause. iow, I guess we need to fix scan ratio equation itself.
> > 
> > I tend to regard this patch as a general improvement for both
> > .33-stable and .34. 
> > 
> > I do agree with you that it's desirable to do more test&analyze and
> > check further for possibly hidden problems.
> 
> Yeah, I don't want ignore .33-stable too. if I can't find the root cause
> in 2-3 days, I'll revert guilty patch anyway.

OK, thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
