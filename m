Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFE68E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 05:50:12 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id d196so26433252qkb.6
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 02:50:12 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id k3si1612592qvo.122.2018.12.28.02.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 02:50:11 -0800 (PST)
Date: Fri, 28 Dec 2018 11:50:08 +0100
From: Greg KH <greg@kroah.com>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Message-ID: <20181228105008.GB15967@kroah.com>
References: <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102073009.GP23921@dhcp22.suse.cz>
 <20181102154844.GA17619@tower.DHCP.thefacebook.com>
 <20181102161314.GF28039@dhcp22.suse.cz>
 <20181102162237.GB17619@tower.DHCP.thefacebook.com>
 <20181102165147.GG28039@dhcp22.suse.cz>
 <20181102172547.GA19042@tower.DHCP.thefacebook.com>
 <20181102174823.GI28039@dhcp22.suse.cz>
 <20181102193827.GA18024@castle.DHCP.thefacebook.com>
 <20181105092053.GC4361@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105092053.GC4361@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Dexuan Cui <decui@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Mon, Nov 05, 2018 at 10:21:23AM +0100, Michal Hocko wrote:
> On Fri 02-11-18 19:38:35, Roman Gushchin wrote:
> > On Fri, Nov 02, 2018 at 06:48:23PM +0100, Michal Hocko wrote:
> > > On Fri 02-11-18 17:25:58, Roman Gushchin wrote:
> > > > On Fri, Nov 02, 2018 at 05:51:47PM +0100, Michal Hocko wrote:
> > > > > On Fri 02-11-18 16:22:41, Roman Gushchin wrote:
> > > [...]
> > > > > > 2) We do forget to scan the last page in the LRU list. So if we ended up with
> > > > > > 1-page long LRU, it can stay there basically forever.
> > > > > 
> > > > > Why 
> > > > > 		/*
> > > > > 		 * If the cgroup's already been deleted, make sure to
> > > > > 		 * scrape out the remaining cache.
> > > > > 		 */
> > > > > 		if (!scan && !mem_cgroup_online(memcg))
> > > > > 			scan = min(size, SWAP_CLUSTER_MAX);
> > > > > 
> > > > > in get_scan_count doesn't work for that case?
> > > > 
> > > > No, it doesn't. Let's look at the whole picture:
> > > > 
> > > > 		size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
> > > > 		scan = size >> sc->priority;
> > > > 		/*
> > > > 		 * If the cgroup's already been deleted, make sure to
> > > > 		 * scrape out the remaining cache.
> > > > 		 */
> > > > 		if (!scan && !mem_cgroup_online(memcg))
> > > > 			scan = min(size, SWAP_CLUSTER_MAX);
> > > > 
> > > > If size == 1, scan == 0 => scan = min(1, 32) == 1.
> > > > And after proportional adjustment we'll have 0.
> > > 
> > > My friday brain hurst when looking at this but if it doesn't work as
> > > advertized then it should be fixed. I do not see any of your patches to
> > > touch this logic so how come it would work after them applied?
> > 
> > This part works as expected. But the following
> > 	scan = div64_u64(scan * fraction[file], denominator);
> > reliable turns 1 page to scan to 0 pages to scan.
> 
> OK, 68600f623d69 ("mm: don't miss the last page because of round-off
> error") sounds like a good and safe stable backport material.

Thanks for this, now queued up.

greg k-h
