Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6FB308D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 10:55:24 -0500 (EST)
Date: Fri, 21 Jan 2011 09:55:17 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [REPOST] [PATCH 3/3] Provide control over unmapped pages (v3)
In-Reply-To: <20110121072315.GL2897@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1101210947270.13881@router.home>
References: <20110120123039.30481.81151.stgit@localhost6.localdomain6> <20110120123649.30481.93286.stgit@localhost6.localdomain6> <alpine.DEB.2.00.1101200856310.10695@router.home> <20110121072315.GL2897@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011, Balbir Singh wrote:

> * Christoph Lameter <cl@linux.com> [2011-01-20 09:00:09]:
>
> > On Thu, 20 Jan 2011, Balbir Singh wrote:
> >
> > > +	unmapped_page_control
> > > +			[KNL] Available if CONFIG_UNMAPPED_PAGECACHE_CONTROL
> > > +			is enabled. It controls the amount of unmapped memory
> > > +			that is present in the system. This boot option plus
> > > +			vm.min_unmapped_ratio (sysctl) provide granular control
> >
> > min_unmapped_ratio is there to guarantee that zone reclaim does not
> > reclaim all unmapped pages.
> >
> > What you want here is a max_unmapped_ratio.
> >
>
> I thought about that, the logic for reusing min_unmapped_ratio was to
> keep a limit beyond which unmapped page cache shrinking should stop.

Right. That is the role of it. Its a minimum to leave. You want a maximum
size of the pagte cache.

> I think you are suggesting max_unmapped_ratio as the point at which
> shrinking should begin, right?

The role of min_unmapped_ratio is to never reclaim more pagecache if we
reach that ratio even if we have to go off node for an allocation.

AFAICT What you propose is a maximum size of the page cache. If the number
of page cache pages goes beyond that then you trim the page cache in
background reclaim.

> > > +			reclaim_unmapped_pages(priority, zone, &sc);
> > > +
> > >  			if (!zone_watermark_ok_safe(zone, order,
> >
> > Hmmmm. Okay that means background reclaim does it. If so then we also want
> > zone reclaim to be able to work in the background I think.
>
> Anything specific you had in mind, works for me in testing, but is
> there anything specific that stands out in your mind that needs to be
> done?

Hmmm. So this would also work in a NUMA configuration, right. Limiting the
sizes of the page cache would avoid zone reclaim through these limit. Page
cache size would be limited by the max_unmapped_ratio.

zone_reclaim only would come into play if other allocations make the
memory on the node so tight that we would have to evict more page
cache pages in direct reclaim.
Then zone_reclaim could go down to shrink the page cache size to
min_unmapped_ratio.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
