Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 31D066B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 01:37:36 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p0O6bPLe011914
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 17:37:25 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0O6bLnW2523210
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 17:37:25 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0O6bKoI027636
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 17:37:21 +1100
Date: Mon, 24 Jan 2011 12:07:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [REPOST] [PATCH 3/3] Provide control over unmapped pages (v3)
Message-ID: <20110124063710.GM2897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110120123039.30481.81151.stgit@localhost6.localdomain6>
 <20110120123649.30481.93286.stgit@localhost6.localdomain6>
 <alpine.DEB.2.00.1101200856310.10695@router.home>
 <20110121072315.GL2897@balbir.in.ibm.com>
 <alpine.DEB.2.00.1101210947270.13881@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101210947270.13881@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux.com> [2011-01-21 09:55:17]:

> On Fri, 21 Jan 2011, Balbir Singh wrote:
> 
> > * Christoph Lameter <cl@linux.com> [2011-01-20 09:00:09]:
> >
> > > On Thu, 20 Jan 2011, Balbir Singh wrote:
> > >
> > > > +	unmapped_page_control
> > > > +			[KNL] Available if CONFIG_UNMAPPED_PAGECACHE_CONTROL
> > > > +			is enabled. It controls the amount of unmapped memory
> > > > +			that is present in the system. This boot option plus
> > > > +			vm.min_unmapped_ratio (sysctl) provide granular control
> > >
> > > min_unmapped_ratio is there to guarantee that zone reclaim does not
> > > reclaim all unmapped pages.
> > >
> > > What you want here is a max_unmapped_ratio.
> > >
> >
> > I thought about that, the logic for reusing min_unmapped_ratio was to
> > keep a limit beyond which unmapped page cache shrinking should stop.
> 
> Right. That is the role of it. Its a minimum to leave. You want a maximum
> size of the pagte cache.

In this case we want the maximum to be as small as the minimum, but
from a general design perspective maximum does make sense.

> 
> > I think you are suggesting max_unmapped_ratio as the point at which
> > shrinking should begin, right?
> 
> The role of min_unmapped_ratio is to never reclaim more pagecache if we
> reach that ratio even if we have to go off node for an allocation.
> 
> AFAICT What you propose is a maximum size of the page cache. If the number
> of page cache pages goes beyond that then you trim the page cache in
> background reclaim.
> 
> > > > +			reclaim_unmapped_pages(priority, zone, &sc);
> > > > +
> > > >  			if (!zone_watermark_ok_safe(zone, order,
> > >
> > > Hmmmm. Okay that means background reclaim does it. If so then we also want
> > > zone reclaim to be able to work in the background I think.
> >
> > Anything specific you had in mind, works for me in testing, but is
> > there anything specific that stands out in your mind that needs to be
> > done?
> 
> Hmmm. So this would also work in a NUMA configuration, right. Limiting the
> sizes of the page cache would avoid zone reclaim through these limit. Page
> cache size would be limited by the max_unmapped_ratio.
> 
> zone_reclaim only would come into play if other allocations make the
> memory on the node so tight that we would have to evict more page
> cache pages in direct reclaim.
> Then zone_reclaim could go down to shrink the page cache size to
> min_unmapped_ratio.
>

I'll repost with max_unmapped_ration changes

Thanks for the review! 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
