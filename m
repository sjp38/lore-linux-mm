Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9CCD6B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:19:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so187032756pfy.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:19:25 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id u21si16004293plj.19.2017.01.14.07.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 07:19:24 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 75so1193785pgf.3
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:19:24 -0800 (PST)
Date: Sat, 14 Jan 2017 10:19:21 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/9] slab: remove synchronous rcu_barrier() call in memcg
 cache release path
Message-ID: <20170114151921.GA32693@mtj.duckdns.org>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-3-tj@kernel.org>
 <20170114131939.GA2668@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114131939.GA2668@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

Hello, Vladimir.

On Sat, Jan 14, 2017 at 04:19:39PM +0300, Vladimir Davydov wrote:
> On Sat, Jan 14, 2017 at 12:54:42AM -0500, Tejun Heo wrote:
> > This patch updates the cache release path so that it simply uses
> > call_rcu() instead of the synchronous rcu_barrier() + custom batching.
> > This doesn't cost more while being logically simpler and way more
> > scalable.
> 
> The point of rcu_barrier() is to wait until all rcu calls freeing slabs
> from the cache being destroyed are over (rcu_free_slab, kmem_rcu_free).
> I'm not sure if call_rcu() guarantees that for all rcu implementations
> too. If it did, why would we need rcu_barrier() at all?

Yeah, I had a similar question and scanned its users briefly.  Looks
like it's used in combination with ctors so that its users can
opportunistically dereference objects and e.g. check ids / state /
whatever without worrying about the objects' lifetimes.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
