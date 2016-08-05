Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6E26B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 21:22:11 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so438313608pac.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 18:22:11 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id tj3si17388146pab.171.2016.08.04.18.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 18:22:10 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id cf3so18327329pad.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 18:22:09 -0700 (PDT)
Date: Fri, 5 Aug 2016 10:22:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
Message-ID: <20160805012212.GB514@swordfish>
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
 <20160804115809.GA447@swordfish>
 <CALZtONBODigWHuCdz0j9OUTwEhs9vdfuQZ1HnjHDLXNdNdz4qg@mail.gmail.com>
 <20160805004357.GA514@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160805004357.GA514@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, Vitaly Wool <vitalywool@gmail.com>, Marcin =?utf-8?B?TWlyb3PFgmF3?= <marcin@mejor.pl>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (08/05/16 09:43), Sergey Senozhatsky wrote:
> On (08/04/16 14:15), Dan Streetman wrote:
> [..]
> >    yep that's exactly right.  I reproduced it with zbud compiled out.
> [..]
> >    yep that's true as well.
> >    i can get patches going for both these, unless you're already working on
> >    it?
> 
> please go ahead.

while at it.

__zswap_param_set():

	pool = zswap_pool_find_get(type, compressor);
	if (pool) {
		zswap_pool_debug("using existing", pool);
		list_del_rcu(&pool->list);
	} else {
		spin_unlock(&zswap_pools_lock);
		pool = zswap_pool_create(type, compressor);
		spin_lock(&zswap_pools_lock);
	}

	if (pool)
		ret = param_set_charp(s, kp);
	else
		ret = -EINVAL;

	if (!ret) {
		put_pool = zswap_pool_current();
		list_add_rcu(&pool->list, &zswap_pools);
	} else if (pool) {
		/* add the possibly pre-existing pool to the end of the pools
		 * list; if it's new (and empty) then it'll be removed and
		 * destroyed by the put after we drop the lock
		 */
		list_add_tail_rcu(&pool->list, &zswap_pools);
		put_pool = pool;
	}

this can be simplified, I think.

suppose there is no zswap_pool_find_get() pool. so we try to
zswap_pool_create() one, but it doesn't go well. at this point
we basically can just return -ENOMEM

	spin_unlock(&zswap_pools_lock);
	pool = zswap_pool_create(type, compressor);
	if (!pool)
		return -ENOMEM;
	spin_lock(&zswap_pools_lock);

so some of later if-s can go away.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
