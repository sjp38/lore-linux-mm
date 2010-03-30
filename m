Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 421756B01F9
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 02:53:43 -0400 (EDT)
Date: Tue, 30 Mar 2010 14:53:58 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100330065358.GA24828@sli10-desk.sh.intel.com>
References: <20100330150453.8E9F.A69D9226@jp.fujitsu.com>
 <1269930756.17240.4.camel@sli10-desk.sh.intel.com>
 <20100330153750.8EA2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100330153750.8EA2.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 30, 2010 at 02:40:07PM +0800, KOSAKI Motohiro wrote:
> > On Tue, 2010-03-30 at 14:08 +0800, KOSAKI Motohiro wrote:
> > > Hi
> > > 
> > > > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > > > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > > > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > > > value, but our calculation round it to zero. The commit makes vmscan
> > > > completely skip anon pages and cause oops.
> > > > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > > > to 1. See below patch.
> > > > But the offending commit still changes behavior. Without the commit, we scan
> > > > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > > > It's required to fix this too.
> > > 
> > > Can you please post your /proc/meminfo 
> > attached.
> > > and reproduce program? I'll digg it.
> > our test is quite sample. mount tmpfs with double memory size and store several
> > copies (memory size * 2/G) of kernel in tmpfs, and then do kernel build.
> > for example, there is 3G memory and then tmpfs size is 6G and there is 6
> > kernel copy.
> 
> Wow, tmpfs size > memsize!
> 
> 
> > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > had similar logic, but 1% swap-out made lots bug reports. 
> > can you elaborate this?
> > Completely restore previous behavior (do full scan with priority 0) is
> > ok too.
> 
> This is a option. but we need to know the root cause anyway.
I thought I mentioned the root cause in first mail. My debug shows
recent_rotated[0] is big, but recent_rotated[1] is almost zero, which makes
percent[0] 0. But you can double check too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
