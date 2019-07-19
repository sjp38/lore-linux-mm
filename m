Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20B27C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 07:05:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C27C2184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 07:05:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C27C2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DA396B0005; Fri, 19 Jul 2019 03:05:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08DD46B0006; Fri, 19 Jul 2019 03:05:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E96F68E0001; Fri, 19 Jul 2019 03:05:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B60F6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 03:05:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so21459687edt.4
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:05:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mSqjTMFDi0z5fYBDFuwCFoRm04orwT8GwUSUBCAZjLE=;
        b=rQxxdQznoJMwMuEldsQ7bCb/wdsC105AdfSmfVtRn7PqPHbKsEzIsTEe/XdX0EJ5Kb
         uvu2y9+Ve+VEd648RrtUDbtBGmw1HZU2mawUWMGD4W4Ut31xfpgQH6h73PRvU6Q3fpzH
         DA4xHEumP2c2Gl2kfn1kdSEPFU8ZadihC5qIPUszOOZ/oj2+Nu6MGfbVxHj/lcjMfKWt
         BgEEo/RW93615qLR9ZmEfEicveCXw46jAPL/9yJT0KEDKeC2Sljz6l/jfkBVW2HBfIdu
         l+uam9diu/lroGS9PADhg4mTxN7RLXfeBMcLzU1QMbCvPafC795J27edMHYTou8dJkT2
         DQPQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW9NrJ850LtzUmoiRcRhu4BsZ+5bhxAlEyDz66/RHxa3eclGgRt
	zIgu7k/D2mBooK20100DrdyrTh6kHzH9vfBwk6QSGI7e/4P870594+AjOdAn80XfvcBmE+SCAZo
	KDgE1dwNCidWi/OE56awa1CQmfHZn7ny/eZovKBgLt9P45WtVy6SQSBol9fTY4/U=
X-Received: by 2002:a17:906:604c:: with SMTP id p12mr39309801ejj.26.1563519932073;
        Fri, 19 Jul 2019 00:05:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYeIizNL8chc+Lyu7AC9Cd1ueCY8ntPaNfCWHA8q3qhHTIgcKrERZ+dm4R1nUhe8M84vCN
X-Received: by 2002:a17:906:604c:: with SMTP id p12mr39309740ejj.26.1563519930957;
        Fri, 19 Jul 2019 00:05:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563519930; cv=none;
        d=google.com; s=arc-20160816;
        b=j//ErcSzyfBf4sJ0BLA3YiWWEsFMYAoRNdIdhehJZ4qYdd+897crcSv1bIOiHm/OUL
         4mQS+19imNEdlHgaFqzz3vchSL1ORpdett62NZJoxGTB6sQyurU0iDeR3Gp3QYbsD/Ed
         X1Y2G7dfZjNSRM1iLT1yhvGS4/OW9+kEG2Odp5VeDmDCiz2C6EF5YIavcGnQwLSy7IQo
         lTc3QhNyCf93Z8d5MQEt7S4tHs0DTL8RsAZrD/35VMmC7KUYZ3oVSHudQul90m7jOHta
         WZE8diAHM5xxd77Z5fugXwgJeFTQR+dHkP9rgCDmCOH0TYLZsEe8ydzqULcwWQylNWMp
         mscw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mSqjTMFDi0z5fYBDFuwCFoRm04orwT8GwUSUBCAZjLE=;
        b=Mu8xu1wLuCznupyEKhNIuZBtzLz4tKhENQ1XPkwYopBOYjDpmtlsh3bLmDgciVFUln
         NwdIYhaEo2LdC7HmEjLF9vs30tDo2bydAzSsitzjvR4PjNXMC91XE0mpGUcOX3fM9YnV
         Xgp6+tejasr8t9jd6H3F5mNxVQme3S9Hhi7m+FbKLVCfNlAh2T7zxoepHuMpN45UK/ho
         +hxoCIt8ktysz4PRSfaDdckVRAVh4td9h+Urb3tenuIF20lstTLk6U2pYEIJWlS1OOZN
         wU4J2JYDFt58VJZo/+QnDnpzoC9vg0kB1SSmoFifQUyLfmQuqUXFxMQDj0+am9TkUc7U
         OqZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20si1026854edb.132.2019.07.19.00.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 00:05:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1EAEBAF4E;
	Fri, 19 Jul 2019 07:05:30 +0000 (UTC)
Date: Fri, 19 Jul 2019 09:05:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm, slab: Move memcg_cache_params structure to mm/slab.h
Message-ID: <20190719070528.GN30461@dhcp22.suse.cz>
References: <20190718180827.18758-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718180827.18758-1-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-07-19 14:08:27, Waiman Long wrote:
> The memcg_cache_params structure is only embedded into the kmem_cache
> of slab and slub allocators as defined in slab_def.h and slub_def.h
> and used internally by mm code. There is no needed to expose it in
> a public header. So move it from include/linux/slab.h to mm/slab.h.
> It is just a refactoring patch with no code change.

No objection from me. As long as this survives all weird config
combinations and implicit header files dependencies...

> In fact both the slub_def.h and slab_def.h should be moved into the mm
> directory as well, but that will probably cause many merge conflicts.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  include/linux/slab.h | 62 -------------------------------------------
>  mm/slab.h            | 63 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 63 insertions(+), 62 deletions(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 56c9c7eed34e..ab2b98ad76e1 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -595,68 +595,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>  	return __kmalloc_node(size, flags, node);
>  }
>  
> -struct memcg_cache_array {
> -	struct rcu_head rcu;
> -	struct kmem_cache *entries[0];
> -};
> -
> -/*
> - * This is the main placeholder for memcg-related information in kmem caches.
> - * Both the root cache and the child caches will have it. For the root cache,
> - * this will hold a dynamically allocated array large enough to hold
> - * information about the currently limited memcgs in the system. To allow the
> - * array to be accessed without taking any locks, on relocation we free the old
> - * version only after a grace period.
> - *
> - * Root and child caches hold different metadata.
> - *
> - * @root_cache:	Common to root and child caches.  NULL for root, pointer to
> - *		the root cache for children.
> - *
> - * The following fields are specific to root caches.
> - *
> - * @memcg_caches: kmemcg ID indexed table of child caches.  This table is
> - *		used to index child cachces during allocation and cleared
> - *		early during shutdown.
> - *
> - * @root_caches_node: List node for slab_root_caches list.
> - *
> - * @children:	List of all child caches.  While the child caches are also
> - *		reachable through @memcg_caches, a child cache remains on
> - *		this list until it is actually destroyed.
> - *
> - * The following fields are specific to child caches.
> - *
> - * @memcg:	Pointer to the memcg this cache belongs to.
> - *
> - * @children_node: List node for @root_cache->children list.
> - *
> - * @kmem_caches_node: List node for @memcg->kmem_caches list.
> - */
> -struct memcg_cache_params {
> -	struct kmem_cache *root_cache;
> -	union {
> -		struct {
> -			struct memcg_cache_array __rcu *memcg_caches;
> -			struct list_head __root_caches_node;
> -			struct list_head children;
> -			bool dying;
> -		};
> -		struct {
> -			struct mem_cgroup *memcg;
> -			struct list_head children_node;
> -			struct list_head kmem_caches_node;
> -			struct percpu_ref refcnt;
> -
> -			void (*work_fn)(struct kmem_cache *);
> -			union {
> -				struct rcu_head rcu_head;
> -				struct work_struct work;
> -			};
> -		};
> -	};
> -};
> -
>  int memcg_update_all_caches(int num_memcgs);
>  
>  /**
> diff --git a/mm/slab.h b/mm/slab.h
> index 5bf615cb3f99..68e455f2b698 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -30,6 +30,69 @@ struct kmem_cache {
>  	struct list_head list;	/* List of all slab caches on the system */
>  };
>  
> +#else /* !CONFIG_SLOB */
> +
> +struct memcg_cache_array {
> +	struct rcu_head rcu;
> +	struct kmem_cache *entries[0];
> +};
> +
> +/*
> + * This is the main placeholder for memcg-related information in kmem caches.
> + * Both the root cache and the child caches will have it. For the root cache,
> + * this will hold a dynamically allocated array large enough to hold
> + * information about the currently limited memcgs in the system. To allow the
> + * array to be accessed without taking any locks, on relocation we free the old
> + * version only after a grace period.
> + *
> + * Root and child caches hold different metadata.
> + *
> + * @root_cache:	Common to root and child caches.  NULL for root, pointer to
> + *		the root cache for children.
> + *
> + * The following fields are specific to root caches.
> + *
> + * @memcg_caches: kmemcg ID indexed table of child caches.  This table is
> + *		used to index child cachces during allocation and cleared
> + *		early during shutdown.
> + *
> + * @root_caches_node: List node for slab_root_caches list.
> + *
> + * @children:	List of all child caches.  While the child caches are also
> + *		reachable through @memcg_caches, a child cache remains on
> + *		this list until it is actually destroyed.
> + *
> + * The following fields are specific to child caches.
> + *
> + * @memcg:	Pointer to the memcg this cache belongs to.
> + *
> + * @children_node: List node for @root_cache->children list.
> + *
> + * @kmem_caches_node: List node for @memcg->kmem_caches list.
> + */
> +struct memcg_cache_params {
> +	struct kmem_cache *root_cache;
> +	union {
> +		struct {
> +			struct memcg_cache_array __rcu *memcg_caches;
> +			struct list_head __root_caches_node;
> +			struct list_head children;
> +			bool dying;
> +		};
> +		struct {
> +			struct mem_cgroup *memcg;
> +			struct list_head children_node;
> +			struct list_head kmem_caches_node;
> +			struct percpu_ref refcnt;
> +
> +			void (*work_fn)(struct kmem_cache *);
> +			union {
> +				struct rcu_head rcu_head;
> +				struct work_struct work;
> +			};
> +		};
> +	};
> +};
>  #endif /* CONFIG_SLOB */
>  
>  #ifdef CONFIG_SLAB
> -- 
> 2.18.1

-- 
Michal Hocko
SUSE Labs

