Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9CFB6B6F65
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 16:34:16 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id r1-v6so859714lfi.16
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 13:34:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 28-v6sor6708573lfx.4.2018.09.04.13.34.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Sep 2018 13:34:14 -0700 (PDT)
Date: Tue, 4 Sep 2018 23:34:11 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm: slowly shrink slabs with a relatively small number
 of objects
Message-ID: <20180904203411.haiiy22ogpj77fvx@esperanza>
References: <20180831203450.2536-1-guro@fb.com>
 <3b05579f964cca1d44551913f1a9ee79d96f198e.camel@surriel.com>
 <20180831213138.GA9159@tower.DHCP.thefacebook.com>
 <20180903182956.GE15074@dhcp22.suse.cz>
 <20180903202803.GA6227@castle.DHCP.thefacebook.com>
 <20180904070005.GG14951@dhcp22.suse.cz>
 <20180904153445.GA22328@tower.DHCP.thefacebook.com>
 <20180904161431.GP14951@dhcp22.suse.cz>
 <20180904175243.GA4889@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180904175243.GA4889@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 04, 2018 at 10:52:46AM -0700, Roman Gushchin wrote:
> Reparenting of all pages is definitely an option to consider,

Reparenting pages would be great indeed, but I'm not sure we could do
that, because we'd have to walk over page lists of semi-active kmem
caches and do it consistently while some pages may be freed as we go.
Kmem caches are so optimized for performance that implementing such a
procedure without impacting any hot paths would be nearly impossible
IMHO. And there are two implementations (SLAB/SLUB), both of which we'd
have to support.

> but it's not free in any case, so if there is no problem,
> why should we? Let's keep it as a last measure. In my case,
> the proposed patch works perfectly: the number of dying cgroups
> jumps around 100, where it grew steadily to 2k and more before.
> 
> I believe that reparenting of LRU lists is required to minimize
> the number of LRU lists to scan, but I'm not sure.

AFAIR the sole purpose of LRU reparenting is releasing kmemcg_id as soon
as a cgroup directory is deleted. If we didn't do that, dead cgroups
would occupy slots in per memcg arrays (list_lru, kmem_cache) so if we
had say 10K dead cgroups, we'd have to allocate 80 KB arrays to store
per memcg data for each kmem_cache and list_lru. Back when kmem
accounting was introduced, we used kmalloc() for allocating those arrays
so growing the size up to 80 KB would result in getting ENOMEM when
trying to create a cgroup too often. Now, we fall back on vmalloc() so
may be it wouldn't be a problem...

Alternatively, I guess we could "reparent" those dangling LRU objects
not to the parent cgroup's list_lru_memcg, but instead to a special
list_lru_memcg which wouldn't be assigned to any cgroup and which would
be reclaimed ASAP on both global or memcg pressure.
