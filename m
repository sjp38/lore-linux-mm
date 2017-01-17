Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7F56B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:02:00 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f5so70881654pgi.1
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 16:02:00 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g73si23026489pfa.11.2017.01.16.16.01.58
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 16:01:59 -0800 (PST)
Date: Tue, 17 Jan 2017 09:07:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/9] slab: remove synchronous rcu_barrier() call in memcg
 cache release path
Message-ID: <20170117000754.GA25218@js1304-P5Q-DELUXE>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-3-tj@kernel.org>
 <20170114131939.GA2668@esperanza>
 <20170114151921.GA32693@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114151921.GA32693@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vladimir Davydov <vdavydov@tarantool.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 10:19:21AM -0500, Tejun Heo wrote:
> Hello, Vladimir.
> 
> On Sat, Jan 14, 2017 at 04:19:39PM +0300, Vladimir Davydov wrote:
> > On Sat, Jan 14, 2017 at 12:54:42AM -0500, Tejun Heo wrote:
> > > This patch updates the cache release path so that it simply uses
> > > call_rcu() instead of the synchronous rcu_barrier() + custom batching.
> > > This doesn't cost more while being logically simpler and way more
> > > scalable.
> > 
> > The point of rcu_barrier() is to wait until all rcu calls freeing slabs
> > from the cache being destroyed are over (rcu_free_slab, kmem_rcu_free).
> > I'm not sure if call_rcu() guarantees that for all rcu implementations
> > too. If it did, why would we need rcu_barrier() at all?
> 
> Yeah, I had a similar question and scanned its users briefly.  Looks
> like it's used in combination with ctors so that its users can
> opportunistically dereference objects and e.g. check ids / state /
> whatever without worrying about the objects' lifetimes.

Hello, Tejun.

Long time no see! :)

IIUC, rcu_barrier() here prevents to destruct the kmem_cache until all
slab pages in it are freed. These slab pages are freed through call_rcu().

Your patch changes it to another call_rcu() and, I think, if sequence of
executing rcu callbacks is the same with sequence of adding rcu
callbacks, it would work. However, I'm not sure that it is
guaranteed by RCU API. Am I missing something?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
