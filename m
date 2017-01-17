Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 642846B0260
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:37:48 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so292200712pfa.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:37:48 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id r21si25410577pgg.64.2017.01.17.08.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 08:37:47 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id t6so4308186pgt.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:37:47 -0800 (PST)
Date: Tue, 17 Jan 2017 08:37:45 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/9] slab: remove synchronous rcu_barrier() call in memcg
 cache release path
Message-ID: <20170117163745.GA8352@mtj.duckdns.org>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-3-tj@kernel.org>
 <20170114131939.GA2668@esperanza>
 <20170114151921.GA32693@mtj.duckdns.org>
 <20170117000754.GA25218@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117000754.GA25218@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vladimir Davydov <vdavydov@tarantool.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

Hello, Joonsoo.

On Tue, Jan 17, 2017 at 09:07:54AM +0900, Joonsoo Kim wrote:
> Long time no see! :)

Yeah, happy new year!

> IIUC, rcu_barrier() here prevents to destruct the kmem_cache until all
> slab pages in it are freed. These slab pages are freed through call_rcu().

Hmm... why do we need that tho?  SLAB_DESTROY_BY_RCU only needs to
protect the slab pages, not kmem cache struct.  I thought that this
was because kmem cache destruction is allowed to release pages w/o RCU
delaying it.

> Your patch changes it to another call_rcu() and, I think, if sequence of
> executing rcu callbacks is the same with sequence of adding rcu
> callbacks, it would work. However, I'm not sure that it is
> guaranteed by RCU API. Am I missing something?

The call sequence doesn't matter.  Whether you're using call_rcu() or
rcu_barrier(), you're just waiting for a grace period to pass before
continuing.  It doens't give any other ordering guarantees, so the new
code should be equivalent to the old one except for being asynchronous.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
