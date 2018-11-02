Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E029E6B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 12:51:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so1494002edi.6
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 09:51:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4-v6si2345043eds.451.2018.11.02.09.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 09:51:50 -0700 (PDT)
Date: Fri, 2 Nov 2018 17:51:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Message-ID: <20181102165147.GG28039@dhcp22.suse.cz>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102073009.GP23921@dhcp22.suse.cz>
 <20181102154844.GA17619@tower.DHCP.thefacebook.com>
 <20181102161314.GF28039@dhcp22.suse.cz>
 <20181102162237.GB17619@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102162237.GB17619@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Dexuan Cui <decui@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri 02-11-18 16:22:41, Roman Gushchin wrote:
> On Fri, Nov 02, 2018 at 05:13:14PM +0100, Michal Hocko wrote:
> > On Fri 02-11-18 15:48:57, Roman Gushchin wrote:
> > > On Fri, Nov 02, 2018 at 09:03:55AM +0100, Michal Hocko wrote:
> > > > On Fri 02-11-18 02:45:42, Dexuan Cui wrote:
> > > > [...]
> > > > > I totally agree. I'm now just wondering if there is any temporary workaround,
> > > > > even if that means we have to run the kernel with some features disabled or
> > > > > with a suboptimal performance?
> > > > 
> > > > One way would be to disable kmem accounting (cgroup.memory=nokmem kernel
> > > > option). That would reduce the memory isolation because quite a lot of
> > > > memory will not be accounted for but the primary source of in-flight and
> > > > hard to reclaim memory will be gone.
> > > 
> > > In my experience disabling the kmem accounting doesn't really solve the issue
> > > (without patches), but can lower the rate of the leak.
> > 
> > This is unexpected. 90cbc2508827e was introduced to address offline
> > memcgs to be reclaim even when they are small. But maybe you mean that
> > we still leak in an absence of the memory pressure. Or what does prevent
> > memcg from going down?
> 
> There are 3 independent issues which are contributing to this leak:
> 1) Kernel stack accounting weirdness: processes can reuse stack accounted to
> different cgroups. So basically any running process can take a reference to any
> cgroup.

yes, but kmem accounting should rule that out, right? If not then this
is a clear bug and easy to backport because that would mean to add a
missing memcg_kmem_enabled check.

> 2) We do forget to scan the last page in the LRU list. So if we ended up with
> 1-page long LRU, it can stay there basically forever.

Why 
		/*
		 * If the cgroup's already been deleted, make sure to
		 * scrape out the remaining cache.
		 */
		if (!scan && !mem_cgroup_online(memcg))
			scan = min(size, SWAP_CLUSTER_MAX);

in get_scan_count doesn't work for that case?

> 3) We don't apply enough pressure on slab objects.

again kmem accounting disabled should make this moot

> Because one reference is enough to keep the entire memcg structure in place,
> we really have to close all three to eliminate the leak. Disabling kmem
> accounting mitigates only the last one.
-- 
Michal Hocko
SUSE Labs
