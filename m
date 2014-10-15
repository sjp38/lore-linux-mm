Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id F0D5A6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 11:03:00 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id gq15so1194903lab.40
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 08:03:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7si30926801lbb.38.2014.10.15.08.02.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 08:02:58 -0700 (PDT)
Date: Wed, 15 Oct 2014 17:02:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/5] mm: memcontrol: convert reclaim iterator to simple
 css refcounting
Message-ID: <20141015150256.GF23547@dhcp22.suse.cz>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
 <1413303637-23862-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413303637-23862-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 14-10-14 12:20:33, Johannes Weiner wrote:
> The memcg reclaim iterators use a complicated weak reference scheme to
> prevent pinning cgroups indefinitely in the absence of memory pressure.
> 
> However, during the ongoing cgroup core rework, css lifetime has been
> decoupled such that a pinned css no longer interferes with removal of
> the user-visible cgroup, and all this complexity is now unnecessary.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 250 +++++++++++++++++---------------------------------------
>  1 file changed, 76 insertions(+), 174 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b62972c80055..67dabe8b0aa6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> +		do {
> +			pos = ACCESS_ONCE(iter->position);
> +			/*
> +			 * A racing update may change the position and
> +			 * put the last reference, hence css_tryget(),
> +			 * or retry to see the updated position.
> +			 */
> +		} while (pos && !css_tryget(&pos->css));
> +	}
[...]
> +	if (reclaim) {
> +		if (cmpxchg(&iter->position, pos, memcg) == pos && memcg)
> +			css_get(&memcg->css);
> +
> +		if (pos)
> +			css_put(&pos->css);

This looks like a reference leak. css_put pairs with the above
css_tryget but no css_put pairs with css_get for the cached one. We
need:
---
