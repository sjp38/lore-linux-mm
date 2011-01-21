Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E54C88D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 02:23:22 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id p0L7NIKU026691
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:53:18 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0L7NIVl430208
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:53:18 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0L7NHTE002100
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 18:23:18 +1100
Date: Fri, 21 Jan 2011 12:53:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [REPOST] [PATCH 3/3] Provide control over unmapped pages (v3)
Message-ID: <20110121072315.GL2897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110120123039.30481.81151.stgit@localhost6.localdomain6>
 <20110120123649.30481.93286.stgit@localhost6.localdomain6>
 <alpine.DEB.2.00.1101200856310.10695@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101200856310.10695@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux.com> [2011-01-20 09:00:09]:

> On Thu, 20 Jan 2011, Balbir Singh wrote:
> 
> > +	unmapped_page_control
> > +			[KNL] Available if CONFIG_UNMAPPED_PAGECACHE_CONTROL
> > +			is enabled. It controls the amount of unmapped memory
> > +			that is present in the system. This boot option plus
> > +			vm.min_unmapped_ratio (sysctl) provide granular control
> 
> min_unmapped_ratio is there to guarantee that zone reclaim does not
> reclaim all unmapped pages.
> 
> What you want here is a max_unmapped_ratio.
>

I thought about that, the logic for reusing min_unmapped_ratio was to
keep a limit beyond which unmapped page cache shrinking should stop.
I think you are suggesting max_unmapped_ratio as the point at which
shrinking should begin, right?
 
> 
> >  {
> > @@ -2297,6 +2320,12 @@ loop_again:
> >  				shrink_active_list(SWAP_CLUSTER_MAX, zone,
> >  							&sc, priority, 0);
> >
> > +			/*
> > +			 * We do unmapped page reclaim once here and once
> > +			 * below, so that we don't lose out
> > +			 */
> > +			reclaim_unmapped_pages(priority, zone, &sc);
> > +
> >  			if (!zone_watermark_ok_safe(zone, order,
> 
> Hmmmm. Okay that means background reclaim does it. If so then we also want
> zone reclaim to be able to work in the background I think.

Anything specific you had in mind, works for me in testing, but is
there anything specific that stands out in your mind that needs to be
done?

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
