Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2F66B000D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 16:54:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n20-v6so1413753pgv.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 13:54:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 95-v6si1859617pld.426.2018.07.03.13.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 13:54:08 -0700 (PDT)
Date: Tue, 3 Jul 2018 13:54:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 13/17] mm: Set bit in memcg shrinker bitmap on first
 list_lru item apearance
Message-Id: <20180703135406.a5408dd14c31ddfa96894ada@linux-foundation.org>
In-Reply-To: <153063065671.1818.15914674956134687268.stgit@localhost.localdomain>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
	<153063065671.1818.15914674956134687268.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, 03 Jul 2018 18:10:56 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> Introduce set_shrinker_bit() function to set shrinker-related
> bit in memcg shrinker bitmap, and set the bit after the first
> item is added and in case of reparenting destroyed memcg's items.
> 
> This will allow next patch to make shrinkers be called only,
> in case of they have charged objects at the moment, and
> to improve shrink_slab() performance.
> 
> ...
>
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1308,6 +1308,18 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
>  
>  extern int memcg_expand_shrinker_maps(int new_id);
>  
> +static inline void memcg_set_shrinker_bit(struct mem_cgroup *memcg,
> +					  int nid, int shrinker_id)
> +{
> +	if (shrinker_id >= 0 && memcg && !mem_cgroup_is_root(memcg)) {
> +		struct memcg_shrinker_map *map;
> +
> +		rcu_read_lock();
> +		map = rcu_dereference(memcg->nodeinfo[nid]->shrinker_map);
> +		set_bit(shrinker_id, map->map);
> +		rcu_read_unlock();
> +	}
> +}

Three callsites, this seem rather large for inlining.
