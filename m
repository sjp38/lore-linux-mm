Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 522896B0026
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:57:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 139so2762355pfw.7
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 07:57:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s3-v6si3980514plp.523.2018.03.21.07.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Mar 2018 07:57:06 -0700 (PDT)
Date: Wed, 21 Mar 2018 07:56:25 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 03/10] mm: Assign memcg-aware shrinkers bitmap to memcg
Message-ID: <20180321145625.GA4780@bombadil.infradead.org>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163850081.21546.6969747084834474733.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152163850081.21546.6969747084834474733.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 21, 2018 at 04:21:40PM +0300, Kirill Tkhai wrote:
> +++ b/include/linux/memcontrol.h
> @@ -151,6 +151,11 @@ struct mem_cgroup_thresholds {
>  	struct mem_cgroup_threshold_ary *spare;
>  };
>  
> +struct shrinkers_map {
> +	struct rcu_head rcu;
> +	unsigned long *map[0];
> +};
> +
>  enum memcg_kmem_state {
>  	KMEM_NONE,
>  	KMEM_ALLOCATED,
> @@ -182,6 +187,9 @@ struct mem_cgroup {
>  	unsigned long low;
>  	unsigned long high;
>  
> +	/* Bitmap of shrinker ids suitable to call for this memcg */
> +	struct shrinkers_map __rcu *shrinkers_map;
> +
>  	/* Range enforcement for interrupt charges */
>  	struct work_struct high_work;
>  

Why use your own bitmap here?  Why not use an IDA which can grow and
shrink automatically without you needing to play fun games with RCU?
