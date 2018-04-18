Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 481846B0008
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:58:03 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 91-v6so1490117plf.6
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:58:03 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 91-v6sor623179ply.71.2018.04.18.11.58.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 11:58:02 -0700 (PDT)
Date: Wed, 18 Apr 2018 11:58:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm:memcg: add __GFP_NOWARN in
 __memcg_schedule_kmem_cache_create
In-Reply-To: <20180418132715.GD17484@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1804181152240.227784@chino.kir.corp.google.com>
References: <20180418022912.248417-1-minchan@kernel.org> <20180418072002.GN17484@dhcp22.suse.cz> <20180418074117.GA210164@rodete-desktop-imager.corp.google.com> <20180418075437.GP17484@dhcp22.suse.cz> <20180418132328.GB210164@rodete-desktop-imager.corp.google.com>
 <20180418132715.GD17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed, 18 Apr 2018, Michal Hocko wrote:

> > Okay, no problem. However, I don't feel we need ratelimit at this moment.
> > We can do when we got real report. Let's add just one line warning.
> > However, I have no talent to write a poem to express with one line.
> > Could you help me?
> 
> What about
> 	pr_info("Failed to create memcg slab cache. Report if you see floods of these\n");
>  

Um, there's nothing actionable here for the user.  Even if the message 
directed them to a specific email address, what would you ask the user for 
in response if they show a kernel log with 100 of these?  Probably ask 
them to use sysrq at the time it happens to get meminfo.  But any user 
initiated sysrq is going to reveal very different state of memory compared 
to when the kmalloc() actually failed.

If this really needs a warning, I think it only needs to be done once and 
reveal the state of memory similar to how slub emits oom warnings.  But as 
the changelog indicates, the system is oom and we couldn't reclaim.  We 
can expect this happens a lot on systems with memory pressure.  What is 
the warning revealing that would be actionable?
