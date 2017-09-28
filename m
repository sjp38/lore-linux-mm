Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5285C6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 17:02:32 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j16so6382953pga.6
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 14:02:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z131si2027528pgz.239.2017.09.28.14.02.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 14:02:31 -0700 (PDT)
Date: Thu, 28 Sep 2017 14:02:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Make count list_lru_one::nr_items lockless
Message-Id: <20170928140230.a9a0cd44a09eae9441a83bdc@linux-foundation.org>
In-Reply-To: <fbb67bef-c13f-7fcb-fa6a-e3a7f6e5c82b@virtuozzo.com>
References: <150583358557.26700.8490036563698102569.stgit@localhost.localdomain>
	<20170927141530.25286286fb92a2573c4b548f@linux-foundation.org>
	<fbb67bef-c13f-7fcb-fa6a-e3a7f6e5c82b@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com

On Thu, 28 Sep 2017 10:48:55 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> >> This patch aims to make super_cache_count() (and other functions,
> >> which count LRU nr_items) more effective.
> >> It allows list_lru_node::memcg_lrus to be RCU-accessed, and makes
> >> __list_lru_count_one() count nr_items lockless to minimize
> >> overhead introduced by locking operation, and to make parallel
> >> reclaims more scalable.
> > 
> > And...  what were the effects of the patch?  Did you not run the same
> > performance tests after applying it?
> 
> I've just detected the such high usage of shrink slab on production node. It's rather
> difficult to make it use another kernel, than it uses, only kpatches are possible.
> So, I haven't estimated how it acts on node's performance.
> On test node I see, that the patch obviously removes raw_spin_lock from perf profile.
> So, it's a little bit untested in this way.

Well that's a problem.  The patch increases list_lru.o text size by a
lot (4800->5696) which will have a cost.  And we don't have proof that
any benefit is worth that cost.  It shouldn't be too hard to cook up a
synthetic test to trigger memcg slab reclaim and then run a
before-n-after benchmark?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
