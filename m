Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 4F57F6B0044
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 18:28:14 -0400 (EDT)
Date: Mon, 12 Aug 2013 15:28:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [RFC] kmemcg: remove union from memcg_params
Message-Id: <20130812152812.915d5e8ebe5467586a457eb0@linux-foundation.org>
In-Reply-To: <1375995086-15456-1-git-send-email-avagin@openvz.org>
References: <1375995086-15456-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri,  9 Aug 2013 00:51:26 +0400 Andrey Vagin <avagin@openvz.org> wrote:

> struct memcg_cache_params {
>         bool is_root_cache;
>         union {
>                 struct kmem_cache *memcg_caches[0];
>                 struct {
>                         struct mem_cgroup *memcg;
>                         struct list_head list;
>                         struct kmem_cache *root_cache;
>                         bool dead;
>                         atomic_t nr_pages;
>                         struct work_struct destroy;
>                 };
>         };
> };
> 
> This union is a bit dangerous. //Andrew Morton
> 
> The first problem was fixed in v3.10-rc5-67-gf101a94.
> The second problem is that the size of memory for root
> caches is calculated incorrectly:
> 
> 	ssize_t size = memcg_caches_array_size(num_groups);
> 
> 	size *= sizeof(void *);
> 	size += sizeof(struct memcg_cache_params);
> 
> The last line should be fixed like this:
> 	size += offsetof(struct memcg_cache_params, memcg_caches)
> 
> Andrew suggested to rework this code without union and
> this patch tries to do that.

hm, did I?

> This patch removes is_root_cache and union. The size of the
> memcg_cache_params structure is not changed.
> 

It's a bit sad to consume more space because we're sucky programmers. 
It would be better to retain the union and to stop writing buggy code
to handle it!

Maybe there are things we can do to reduce the likelihood of people
mishandling the union - don't use anonymous fields, name each member,
access it via helper functions, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
