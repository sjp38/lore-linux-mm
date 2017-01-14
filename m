Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B02A36B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:19:53 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id j90so4004810lfi.3
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 05:19:53 -0800 (PST)
Received: from smtp44.i.mail.ru (smtp44.i.mail.ru. [94.100.177.104])
        by mx.google.com with ESMTPS id x10si9831616lfd.263.2017.01.14.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 05:19:51 -0800 (PST)
Date: Sat, 14 Jan 2017 16:19:39 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 2/9] slab: remove synchronous rcu_barrier() call in memcg
 cache release path
Message-ID: <20170114131939.GA2668@esperanza>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-3-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114055449.11044-3-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

Hello Tejun,

Thanks a lot for looking into this issue as it seems to affect a lot of
users!

On Sat, Jan 14, 2017 at 12:54:42AM -0500, Tejun Heo wrote:
> This patch updates the cache release path so that it simply uses
> call_rcu() instead of the synchronous rcu_barrier() + custom batching.
> This doesn't cost more while being logically simpler and way more
> scalable.

The point of rcu_barrier() is to wait until all rcu calls freeing slabs
from the cache being destroyed are over (rcu_free_slab, kmem_rcu_free).
I'm not sure if call_rcu() guarantees that for all rcu implementations
too. If it did, why would we need rcu_barrier() at all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
