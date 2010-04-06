Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 895516B01F4
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 21:27:44 -0400 (EDT)
Date: Tue, 6 Apr 2010 09:27:41 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100406012741.GA22749@sli10-desk.sh.intel.com>
References: <20100331045348.GA3396@sli10-desk.sh.intel.com>
 <20100331142708.039E.A69D9226@jp.fujitsu.com>
 <20100331145030.03A1.A69D9226@jp.fujitsu.com>
 <20100402065052.GA28027@sli10-desk.sh.intel.com>
 <20100404004838.GA6390@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100404004838.GA6390@localhost>
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 04, 2010 at 08:48:38AM +0800, Wu, Fengguang wrote:
> On Fri, Apr 02, 2010 at 02:50:52PM +0800, Li, Shaohua wrote:
> > On Wed, Mar 31, 2010 at 01:53:27PM +0800, KOSAKI Motohiro wrote:
> > > > > On Tue, Mar 30, 2010 at 02:08:53PM +0800, KOSAKI Motohiro wrote:
> > > > > > Hi
> > > > > > 
> > > > > > > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > > > > > > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > > > > > > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > > > > > > value, but our calculation round it to zero. The commit makes vmscan
> > > > > > > completely skip anon pages and cause oops.
> > > > > > > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > > > > > > to 1. See below patch.
> > > > > > > But the offending commit still changes behavior. Without the commit, we scan
> > > > > > > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > > > > > > It's required to fix this too.
> > > > > > 
> > > > > > Can you please post your /proc/meminfo and reproduce program? I'll digg it.
> > > > > > 
> > > > > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > > > > had similar logic, but 1% swap-out made lots bug reports. 
> > > > > if 1% is still big, how about below patch?
> > > > 
> > > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > > <1% seems no good reclaim rate.
> > > 
> > > Oops, the above mention is wrong. sorry. only 1 page is still too big.
> > > because under streaming io workload, the number of scanning anon pages should
> > > be zero. this is very strong requirement. if not, backup operation will makes
> > > a lot of swapping out.
> > Sounds there is no big impact for the workload which you mentioned with the patch.
> > please see below descriptions.
> > I updated the description of the patch as fengguang suggested.
> > 
> > 
> > 
> > Commit 84b18490d introduces a regression. With it, our tmpfs test always oom.
> > The test uses a 6G tmpfs in a system with 3G memory. In the tmpfs, there are
> > 6 copies of kernel source and the test does kbuild for each copy. My
> > investigation shows the test has a lot of rotated anon pages and quite few
> > file pages, so get_scan_ratio calculates percent[0] to be zero. Actually
> > the percent[0] shoule be a very small value, but our calculation round it
> > to zero. The commit makes vmscan completely skip anon pages and cause oops.
> > 
> > To avoid underflow, we don't use percentage, instead we directly calculate
> > how many pages should be scaned. In this way, we should get several scan pages
> > for < 1% percent. With this fix, my test doesn't oom any more.
> > 
> > Note, this patch doesn't really change logics, but just increase precise. For
> > system with a lot of memory, this might slightly changes behavior. For example,
> > in a sequential file read workload, without the patch, we don't swap any anon
> > pages. With it, if anon memory size is bigger than 16G, we will say one anon page
> 
>                                                                   see?
Thanks, will send a updated against -mm since we reverted the offending patch.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
