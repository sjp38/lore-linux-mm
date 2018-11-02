Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEA056B026B
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 12:13:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y72-v6so1416496ede.22
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 09:13:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y34-v6si14105260ede.5.2018.11.02.09.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 09:13:18 -0700 (PDT)
Date: Fri, 2 Nov 2018 17:13:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Message-ID: <20181102161314.GF28039@dhcp22.suse.cz>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102073009.GP23921@dhcp22.suse.cz>
 <20181102154844.GA17619@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102154844.GA17619@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Dexuan Cui <decui@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri 02-11-18 15:48:57, Roman Gushchin wrote:
> On Fri, Nov 02, 2018 at 09:03:55AM +0100, Michal Hocko wrote:
> > On Fri 02-11-18 02:45:42, Dexuan Cui wrote:
> > [...]
> > > I totally agree. I'm now just wondering if there is any temporary workaround,
> > > even if that means we have to run the kernel with some features disabled or
> > > with a suboptimal performance?
> > 
> > One way would be to disable kmem accounting (cgroup.memory=nokmem kernel
> > option). That would reduce the memory isolation because quite a lot of
> > memory will not be accounted for but the primary source of in-flight and
> > hard to reclaim memory will be gone.
> 
> In my experience disabling the kmem accounting doesn't really solve the issue
> (without patches), but can lower the rate of the leak.

This is unexpected. 90cbc2508827e was introduced to address offline
memcgs to be reclaim even when they are small. But maybe you mean that
we still leak in an absence of the memory pressure. Or what does prevent
memcg from going down?

> > Another workaround could be to use force_empty knob we have in v1 and
> > use it when removing a cgroup. We do not have it in cgroup v2 though.
> > The file hasn't been added to v2 because we didn't really have any
> > proper usecase. Working around a bug doesn't sound like a _proper_
> > usecase but I can imagine workloads that bring a lot of metadata objects
> > that are not really interesting for later use so something like a
> > targeted drop_caches...
> 
> This can help a bit too, but even using the system-wide drop_caches knob
> unfortunately doesn't return all the memory back.

Could you be more specific please?

-- 
Michal Hocko
SUSE Labs
