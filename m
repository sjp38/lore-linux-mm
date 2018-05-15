Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A889E6B000D
	for <linux-mm@kvack.org>; Tue, 15 May 2018 00:08:38 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o16-v6so4803659lfk.12
        for <linux-mm@kvack.org>; Mon, 14 May 2018 21:08:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z7-v6sor2272816ljb.84.2018.05.14.21.08.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 21:08:35 -0700 (PDT)
Date: Tue, 15 May 2018 07:08:32 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v5 10/13] mm: Set bit in memcg shrinker bitmap on first
 list_lru item apearance
Message-ID: <20180515040832.ukmrcdl5czqpldgv@esperanza>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594602582.22949.2526776640167844592.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152594602582.22949.2526776640167844592.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Thu, May 10, 2018 at 12:53:45PM +0300, Kirill Tkhai wrote:
> Introduce set_shrinker_bit() function to set shrinker-related
> bit in memcg shrinker bitmap, and set the bit after the first
> item is added and in case of reparenting destroyed memcg's items.
> 
> This will allow next patch to make shrinkers be called only,
> in case of they have charged objects at the moment, and
> to improve shrink_slab() performance.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/memcontrol.h |   15 +++++++++++++++
>  mm/list_lru.c              |   22 ++++++++++++++++++++--
>  2 files changed, 35 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index e5e7e0fc7158..82f892e77637 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1274,6 +1274,21 @@ static inline void memcg_put_cache_ids(void)
>  
>  extern int memcg_shrinker_nr_max;
>  extern int memcg_expand_shrinker_maps(int old_id, int id);
> +
> +static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg, int nid, int nr)

Nit: too long line (> 80 characters)
Nit: let's rename 'nr' to 'shrinker_id'

> +{
> +	if (nr >= 0 && memcg && memcg != root_mem_cgroup) {
> +		struct memcg_shrinker_map *map;
> +
> +		rcu_read_lock();
> +		map = MEMCG_SHRINKER_MAP(memcg, nid);

Missing rcu_dereference.

> +		set_bit(nr, map->map);
> +		rcu_read_unlock();
> +	}
> +}
> +#else
> +static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
> +					  int node, int id) { }

Nit: please keep the signature (including argument names) the same as in
MEMCG-enabled definition, namely 'node' => 'nid', 'id' => 'shrinker_id'.

Thanks.
