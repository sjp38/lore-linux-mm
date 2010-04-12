Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 59C5C6B01EE
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 22:01:59 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:57:39 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100412015739.GA14988@sli10-desk.sh.intel.com>
References: <20100331045348.GA3396@sli10-desk.sh.intel.com>
 <20100331142708.039E.A69D9226@jp.fujitsu.com>
 <20100331145030.03A1.A69D9226@jp.fujitsu.com>
 <20100402065052.GA28027@sli10-desk.sh.intel.com>
 <20100406050325.GA17797@localhost>
 <20100409065104.GA21480@sli10-desk.sh.intel.com>
 <20100409142057.be0ce5af.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100409142057.be0ce5af.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 05:20:57AM +0800, Andrew Morton wrote:
> On Fri, 9 Apr 2010 14:51:04 +0800
> Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > get_scan_ratio() calculates percentage and if the percentage is < 1%, it will
> > round percentage down to 0% and cause we completely ignore scanning anon/file
> > pages to reclaim memory even the total anon/file pages are very big.
> > 
> > To avoid underflow, we don't use percentage, instead we directly calculate
> > how many pages should be scaned. In this way, we should get several scanned pages
> > for < 1% percent.
> > 
> > This has some benefits:
> > 1. increase our calculation precision
> > 2. making our scan more smoothly. Without this, if percent[x] is underflow,
> > shrink_zone() doesn't scan any pages and suddenly it scans all pages when priority
> > is zero. With this, even priority isn't zero, shrink_zone() gets chance to scan
> > some pages.
> > 
> > Note, this patch doesn't really change logics, but just increase precision. For
> > system with a lot of memory, this might slightly changes behavior. For example,
> > in a sequential file read workload, without the patch, we don't swap any anon
> > pages. With it, if anon memory size is bigger than 16G, we will see one anon page
> > swapped. The 16G is calculated as PAGE_SIZE * priority(4096) * (fp/ap). fp/ap
> > is assumed to be 1024 which is common in this workload. So the impact sounds not
> > a big deal.
> 
> I grabbed this.
> 
> Did we decide that this needed to be backported into 2.6.33.x?  If so,
> some words explaining the reasoning would be needed.
> 
> Come to that, it's not obvious that we need this in 2.6.34 either. 
Not needed.

> is the user-visible impact here?
Should be very small I think.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
