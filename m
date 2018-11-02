Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 881CC6B000A
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 13:48:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f22-v6so2327377pgv.21
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 10:48:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u66-v6si35316559pgu.94.2018.11.02.10.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 10:48:27 -0700 (PDT)
Date: Fri, 2 Nov 2018 18:48:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Message-ID: <20181102174823.GI28039@dhcp22.suse.cz>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102073009.GP23921@dhcp22.suse.cz>
 <20181102154844.GA17619@tower.DHCP.thefacebook.com>
 <20181102161314.GF28039@dhcp22.suse.cz>
 <20181102162237.GB17619@tower.DHCP.thefacebook.com>
 <20181102165147.GG28039@dhcp22.suse.cz>
 <20181102172547.GA19042@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102172547.GA19042@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Dexuan Cui <decui@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri 02-11-18 17:25:58, Roman Gushchin wrote:
> On Fri, Nov 02, 2018 at 05:51:47PM +0100, Michal Hocko wrote:
> > On Fri 02-11-18 16:22:41, Roman Gushchin wrote:
[...]
> > > 2) We do forget to scan the last page in the LRU list. So if we ended up with
> > > 1-page long LRU, it can stay there basically forever.
> > 
> > Why 
> > 		/*
> > 		 * If the cgroup's already been deleted, make sure to
> > 		 * scrape out the remaining cache.
> > 		 */
> > 		if (!scan && !mem_cgroup_online(memcg))
> > 			scan = min(size, SWAP_CLUSTER_MAX);
> > 
> > in get_scan_count doesn't work for that case?
> 
> No, it doesn't. Let's look at the whole picture:
> 
> 		size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
> 		scan = size >> sc->priority;
> 		/*
> 		 * If the cgroup's already been deleted, make sure to
> 		 * scrape out the remaining cache.
> 		 */
> 		if (!scan && !mem_cgroup_online(memcg))
> 			scan = min(size, SWAP_CLUSTER_MAX);
> 
> If size == 1, scan == 0 => scan = min(1, 32) == 1.
> And after proportional adjustment we'll have 0.

My friday brain hurst when looking at this but if it doesn't work as
advertized then it should be fixed. I do not see any of your patches to
touch this logic so how come it would work after them applied?
-- 
Michal Hocko
SUSE Labs
